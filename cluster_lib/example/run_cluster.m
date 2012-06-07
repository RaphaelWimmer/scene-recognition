addpath /work/bharath2/cluster_lib/lib;


exec_config = default_config


load('/work/bharath2/det_pos.mat');

% Compute the squares of the numbers 1..10
result_file = [exec_config.work_dir '/power_vec.mat']; % Where do we store the output
usrdata_job = '/work/bharath2/det_pos.mat'; % Compute the powers of two. This is a string passed to each job
usrdata_collect = '';  % No user parameters during the collect stage 
num_elements = 288; % How many elements to perform the operation on
max_elems_per_job = 50; % Target number of elements per job. Pick the number so jobs take at least a few minutes each
job_id = 'save'; % Unique string ID for the job. Must be less than 6 chars long
redo = true; % when true, will erase all cache and redo the entire operation. Use false if you interrupted the process and want to continue.
do_parallel_operation('save_det_cluster',job_id,num_elements,max_elems_per_job,usrdata_job,usrdata_collect,result_file,exec_config,[],redo);
