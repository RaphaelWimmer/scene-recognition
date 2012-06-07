function do_single_job(job_id,matlab_command,out_file,exec_config,dont_wait)
spawn_one_job(job_id,matlab_command,out_file,exec_config);
if ~dont_wait
    wait_on_job(job_id,out_file,exec_config);
end
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function already_done=spawn_one_job(job_id,matlab_command,out_file,exec_config)
    
job_name = [get_job_unique_prefix job_id 'J'];

if ~exist(exec_config.batch_dir,'file')
    mkdir(exec_config.batch_dir);
end
if exist([exec_config.batch_dir '/' job_name],'file')
    delete([exec_config.batch_dir '/' job_name]);
end
%delete(out_file);
already_done = true;
if exist(out_file,'file')
    disp(sprintf('Job %s is done',job_id));
    return;
end
already_done=false;


if exec_config.run_on_single_node
    eval(matlab_command);
else
    [status,result]=system(sprintf('qstat | grep \'' %s \'' | grep %s | wc -l',job_name,exec_config.usr_name));
    if str2num(result)>0
        disp(sprintf('job %s is running',job_id));
%        [status,result]=system(sprintf('qstat | grep %s | grep %s',job_id,exec_config.usr_name));
%        disp(sprintf('qstat outputs: %s',result));
        return;
    end
    disp(sprintf('Spawning single job %s',job_name));
    do_qsub(job_name, exec_config.batch_dir, matlab_command, exec_config.collect_mem, exec_config.collect_exec_hours, exec_config);
end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function wait_on_job(job_id,out_file,exec_config)

if exec_config.run_on_single_node
    return;
end

job_name = [get_job_unique_prefix job_id 'J'];

tic;
while 1
    [status,result]=system(sprintf('qstat | grep %s | grep %s | wc -l',job_name,exec_config.usr_name));
    num_running = str2num(result);
    if num_running==0
        break;
    end

    pause(exec_config.sleep_time);
    disp(sprintf('Waiting %d secs for %s',round(toc), job_name));
end

if ~exist(out_file,'file')
    while ~exist(out_file,'file')
        pause(5);
        fprintf('.');
    end
    fprintf('\n');
end
end

