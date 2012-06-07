%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% cluster_lib      Matlab library for cluster processing
%% Author: Lubomir Bourdev   lbourdev@eecs.berkeley.edu     Jan 30, 2010
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Example of how to use the cluster processing library. Generates a vector
%% of the squares of numbers 1 to 100.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


addpath ../lib

% Get the default job execution parameters. The execution parameters
% include stuff like how long each job takes, how much memory, how
% often to spawn new jobs, the data directory, etc.
exec_config = default_config;

% Enable this for debugging. Runs all on a single node. Remember not to run on the front node.
%exec_config.run_on_single_node = true;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Example 1: Splits the task into several jobs and collects them
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% Compute the squares of the numbers 1..10
result_file = [exec_config.work_dir '/power_vec.mat']; % Where do we store the output
usrdata_job = '2'; % Compute the powers of two. This is a string passed to each job
usrdata_collect = '';  % No user parameters during the collect stage 
num_elements = 10; % How many elements to perform the operation on
max_elems_per_job = 3; % Target number of elements per job. Pick the number so jobs take at least a few minutes each
job_id = 'hello'; % Unique string ID for the job. Must be less than 6 chars long
redo = true; % when true, will erase all cache and redo the entire operation. Use false if you interrupted the process and want to continue.
do_parallel_operation('example_parallel_op',job_id,num_elements,max_elems_per_job,usrdata_job,usrdata_collect,result_file,exec_config,[],redo);

% Test - load the file and display on screen 1 -> 1\\ 2 -> 4\\ 3 -> 9... 
disp('Result of example_parallel_op');
r=load(result_file);
for i=1:length(r.output)
    disp(sprintf('%d -> %f',i,r.output(i)));
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Example 2: Performs the same task on a single node.
%% Use this to perform a single processing-intensive job while running on
%% the front node.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


job_id = 'hi';
redo = true; 
usrdata_single = '3 10';   % powers of 3 for the numbers 1..10
exec_config.mem=4; % For this one use 4 GB
result_file = [exec_config.work_dir '/power_vec2.mat'];
do_single_operation('example_single_op',job_id,usrdata_single,result_file,exec_config,redo);

% Test - load the file and display on screen 1 -> 1\\ 2 -> 4\\ 3 -> 9... 
disp('Result of example_single_op');
r=load(result_file);
for i=1:length(r.output)
    disp(sprintf('%d -> %f',i,r.output(i)));
end
