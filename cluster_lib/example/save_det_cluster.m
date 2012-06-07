%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% cluster_lib      Matlab library for cluster processing
%% Author: Lubomir Bourdev   lbourdev@eecs.berkeley.edu     Jan 30, 2010
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% An example of an operation to do on the clusters. To make your own just
% copy from here and modify. Each operation must be in a separate file.

% Computes the powers of a set of numbers.
function handles=get_all_Ws
    % Leave these unchanged
    handles.do_job       = @do_job;
    handles.collect_jobs = @collect_jobs;
end
    
% Invoked multiple times for different sets of elements. It performs the operation and saves results to
% separate file. The operation is performed for elements in the range [first_el, last_el]
%    first_el, last_el -> specifies the range of elements to work on.
%    usr_data -> a string containing any user-specified parameters. To pass
%                large parameters, save them to file and pass the file names.
%    output -> Return the results. You can return a struct of multiple elements.
%              If you return [] for all calls to do_job, collect_jobs will not be called 
%function output = do_job(first_el,last_el,usrdata_job)
%   pow = str2num(usrdata_job);  
%   for i=first_el:last_el
%      output(i-first_el+1) = power(i,pow);
%   end
function output = do_job(first_el, last_el, model_file)


m=load(model_file);
model=m.output;
addpath(genpath('/work/bharath2/highlight_code'));
addpath('/work/bharath2/imtoolbox');

cnt=1;
for k=1:numel(model.svms)
    
    for l=1:size(model.svms{k}.svms,2)
	if(cnt>=first_el && cnt<=last_el)
        fprintf('Doing %d/%d\n', cnt, numel(model.selected_p));
        W = get_hog_greedy(model.svms{k}.svms(1:end-1, l), model.svms{k}.dims);
	save(sprintf('/work/bharath2/Ws/%d.mat', cnt), 'W');
	end
        cnt=cnt+1;
    end
    
end
	output=0;
end

% Invoked once after all jobs have completed. Use
% it to merge the data into a single file.
%    job_outputs -> job_outputs{i}.elements_range is the range of
%                  elements processed by job i 
%                  job_outputs{i}.output is the job output
%    usr_data -> a string containing any user-specified parameters. To pass
%                large parameters, pass their file names in this string.
%    output -> Return the results of combination. You can return a struct of multiple elements
function output = collect_jobs(job_outputs,ranges,usr_data)
output=0;

end

% handles.dont_load_jobs_in_collect = true; 
%   If this is set, collect_jobs will receive filenames of the jobs instead of the loaded
%   jobs. Do this if the jobs are too large to fit all in memory

