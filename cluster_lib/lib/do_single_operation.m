%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% cluster_lib      Matlab library for cluster processing
%% Author: Lubomir Bourdev   lbourdev@eecs.berkeley.edu     Jan 30, 2010
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function do_single_operation(fn_name,job_id,usr_data,out_file,exec_config,dont_wait,redo)
if exist('redo','var') && redo
    disp(sprintf('Clearing all cache and recomputing %s',fn_name));
    if exist(out_file,'file')
       delete(out_file); 
    end
end
if ~exist('exec_config','var')
   global config;
   exec_config=config.exec_config;
end

if ~exist('dont_wait','var')
   dont_wait=false;
end

start_time=clock;
matlab_command = sprintf('output=%s(''%s''); if ~exist(''%s'',''file'') save(''%s'',''output''); end', fn_name,usr_data,out_file,out_file);
do_single_job(job_id,matlab_command,out_file,exec_config,dont_wait);
if exist('log_time','file')
   log_time(start_time,fn_name); 
end

end


