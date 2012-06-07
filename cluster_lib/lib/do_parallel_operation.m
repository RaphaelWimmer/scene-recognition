%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% cluster_lib      Matlab library for cluster processing
%% Author: Lubomir Bourdev   lbourdev@eecs.berkeley.edu     Jan 30, 2010
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function do_parallel_operation(op_name,job_id,num_elements,max_elems_per_job,usrdata_job,usrdata_collect,out_file,exec_config,jobs_range,redo)
if ~exist('exec_config','var')
   global config;
   exec_config=config.exec_config;
end
if ~exist('jobs_range','var')
   jobs_range=[]; % An empty jobs_range means run all elements and invoke collect. 
end
if exist('redo','var') && redo
    disp(sprintf('Clearing all cache and recomputing %s',op_name));
    if exist([exec_config.work_dir '/' job_id],'file')
        delete([exec_config.work_dir '/' job_id '/*']); 
    end
    if exist(out_file,'file')
       delete(out_file); 
    end
end
if exist(out_file,'file')
    disp(sprintf('%s is computed',op_name));
   return; 
end
start_time=clock;
do_batch_jobs(job_id,op_name,num_elements,max_elems_per_job,usrdata_job,out_file,exec_config,jobs_range);

handles = eval(op_name);
if isfield(handles,'collect_jobs') && ~isempty(out_file) && isempty(jobs_range)
    disp(sprintf('Mergining results of %s',op_name));

    matlab_command=sprintf('collect_batch_results(\''%s\'',\''%s\'',\''%s\'',%d,%d,\''%s\'',\''%s\'')',op_name,job_id,exec_config.work_dir,num_elements,max_elems_per_job,usrdata_collect,out_file);
    do_single_job(job_id,matlab_command,out_file,exec_config,false);
end

if exist('log_time','file')
   log_time(start_time,op_name); 
end
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function do_batch_jobs(job_id,op_name,num_elements,max_elems_per_job,usr_data,out_file,exec_config,jobs_range)
spawn_batch_jobs(job_id,op_name,num_elements,max_elems_per_job,usr_data,exec_config,jobs_range);
num_jobs = ceil(num_elements/max_elems_per_job);
if isempty(jobs_range)
    wait_on_jobs(job_id,num_jobs,out_file,exec_config);
end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function spawn_batch_jobs(job_id,op_name,num_elements,max_elems_per_job,usr_data,exec_config,jobs_range)
batch_dir = [exec_config.batch_dir '/' job_id];

if ~exist(batch_dir,'file')
    mkdir(batch_dir);
elseif exist(batch_dir,'file')
    delete([batch_dir '/*']);
end


if exec_config.needs_image_toolbox
    max_running = num_image_licenses_available(exec_config)-2;
else
    max_running = 500;
end
max_running_for_user = 500;


num_jobs = ceil(num_elements/max_elems_per_job);

if ~exist([exec_config.work_dir '/' job_id],'file')
    mkdir([exec_config.work_dir '/' job_id]);
end


RESTART=false;

if isempty(jobs_range)
    jobs_range=1:num_jobs;
else
    jobs_range(jobs_range>num_jobs)=[];
end

if isequal(exec_config.hostname,'s84')
    jobs_range=fliplr(jobs_range);
end
for i=jobs_range
    job_name = sprintf('%s%s_%d',get_job_unique_prefix,job_id,i);
        
    out_name = job_output_filename(job_id,i,exec_config.work_dir);
    if exist(out_name,'file')
        %        disp(sprintf('job %s is done',job_name));
        continue;
    end

    if RESTART
        disp(sprintf('Killing job %s',job_name));
        system(sprintf('qdel `qstat | grep \'' %s \'' | grep \''%s'' | sed \''s/\\..*//\''` >& /dev/null',job_name,exec_config.usr_name));
    end

    first_el = max_elems_per_job*(i-1)+1;
    last_el = min(num_elements,max_elems_per_job*i);

    matlab_command = sprintf('handles=eval(\''%s\''); if ~exist(\''%s\'',\''file\'') output=handles.do_job(%d,%d,\''%s\''); if ~exist(\''%s\'',\''file\'') save(\''%s\'',\''output\''); end; end', op_name,out_name,first_el,last_el,usr_data,out_name,out_name);
    if exec_config.run_on_single_node
        disp(sprintf('Starting job %s to process elements %d to %d',job_name,first_el,last_el));
        eval(matlab_command);
    else
        [status,result]=system(sprintf('qstat | grep \'' %s \'' | grep %s | wc -l',job_name,exec_config.usr_name));
        if str2double(result)>0
            disp(sprintf('Job %s is running',job_name));
            continue;
        end

        while 1
            [status,result]=system(sprintf('qstat | grep \'' %s \'' | grep %s | wc -l',job_id,exec_config.usr_name));
            num_running = str2num(result); %#ok<ST2NM>
            if exec_config.needs_image_toolbox
                max_running = num_running+num_image_licenses_available(exec_config)-2;
            end
            if num_running<=max_running
                [status,result]=system(sprintf('qstat | grep \'' %s \'' | wc -l', exec_config.usr_name));
                num_all_running_for_user = str2num(result); %#ok<ST2NM>
                if num_all_running_for_user<=max_running_for_user
                    break;
                end
            end
            disp(sprintf('Num active jobs: %d. Waiting for them to become %d before spawning more',num_running, max_running));
            pause(10);
         end

        disp(sprintf('Spawning job %s of %d',job_name,num_jobs));
        do_qsub(job_name, batch_dir, matlab_command, exec_config.mem, exec_config.exec_hours, exec_config);
    end
end

end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function wait_on_jobs(job_id,num_jobs,out_collect_file,exec_config)

for i=1:num_jobs
    job_name = sprintf('%s%s_%d',get_job_unique_prefix,job_id,i);
    out_name = job_output_filename(job_id,i,exec_config.work_dir);
    if ~exist(out_name,'file')
        fprintf('Waiting for job %s ',job_name);
        while ~exist(out_name,'file') && (isempty(out_collect_file) || ~exist(out_collect_file,'file'))
            pause(exec_config.sleep_time);
            fprintf('.');
        end
        fprintf('\n');
    end
end

% Make sure the jobs have cleared
if ~exec_config.run_on_single_node
    while 1
        [status,result]=system(sprintf('qstat | grep \'' %s%s\'' | grep %s | wc -l',get_job_unique_prefix,job_id,exec_config.usr_name));
        if str2num(result)==0
            break;
        end
        pause(exec_config.sleep_time);
        fprintf('.');
    end
end

end

function num_avaliable = num_image_licenses_available(exec_config)
    num_avaliable = 70;
    if ~exec_config.run_on_single_node
        [q1,q2]=system('/usr/sww/pkg/matlab-r2008a/etc/lmstat -a | grep Image_Tool');
        if q1==0
            q3=strread(q2,'%s');
            num_avaliable = str2num(q3{6})-str2num(q3{11});
        end
    end
end
