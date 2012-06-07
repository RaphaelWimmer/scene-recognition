% This is a simplified script to run a matlab job on the cluster instead of hello_cluster_world
addpath /work4/shiry/scene-recognition/cluster_lib/lib;

% This config file sits in the lib directory
exec_config = default_config

% Why is he loading this?
%load('/work/bharath2/det_pos.mat');

result_file = [exec_config.work_dir '/power_vec.mat']; % Where do we store the output
%usrdata_job = '/work/bharath2/det_pos.mat'; % This is a string passed to each job
usrdata_job = '2'; % This is a string passed to each job
usrdata_collect = '';  % User parameters during the collect stage 
%num_elements = 288; % How many elements to perform the operation on
num_elements = 10; % How many elements to perform the operation on
%max_elems_per_job = 50; % Target number of elements per job. Pick the number so jobs take at least a few minutes each
max_elems_per_job = 3; % Target number of elements per job. Pick the number so jobs take at least a few minutes each
%job_id = 'save'; % Unique string ID for the job. Must be less than 6 chars long
job_id = 'hello'; % Unique string ID for the job. Must be less than 6 chars long
redo = true; % when true, will erase all cache and redo the entire operation. Use false if you interrupted the process and want to continue.
%do_parallel_operation('save_det_cluster',job_id,num_elements,max_elems_per_job,usrdata_job,usrdata_collect,result_file,exec_config,[],redo);
do_parallel_operation('example_parallel_op',job_id,num_elements,max_elems_per_job,usrdata_job,usrdata_collect,result_file,exec_config,[],redo);
