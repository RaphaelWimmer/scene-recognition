% This is a simplified script to run a matlab job on the cluster instead of hello_cluster_world
addpath /work/shiry/scene-recognition/cluster_lib/lib;

% This config file sits in the lib directory
exec_config = default_config

% Why is he loading this?
%load('/work/bharath2/det_pos.mat');

result_file = [exec_config.work_dir '/classifiers.mat']; % Where do we store the output
%usrdata_job = '/work/bharath2/det_pos.mat'; % This is a string passed to each job
usrdata_job = ''; % This is a string passed to each job
usrdata_collect = '';  % User parameters during the collect stage 
num_elements = 4500; % How many elements to perform the operation on - # of training images
max_elems_per_job = 30; % Target number of elements per job. Pick the number so jobs take at least a few minutes each
job_id = 'train'; % Unique string ID for the job. Must be less than 6 chars long
redo = true; % when true, will erase all cache and redo the entire operation. Use false if you interrupted the process and want to continue.
do_parallel_operation('train_poselets',job_id,num_elements,max_elems_per_job,usrdata_job,usrdata_collect,result_file,exec_config,[],redo);
