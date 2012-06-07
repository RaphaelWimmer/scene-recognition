%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% cluster_lib      Matlab library for cluster processing
%% Author: Lubomir Bourdev   lbourdev@eecs.berkeley.edu     Jan 30, 2010
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% An example of an operation to do on the clusters. To make your own just
% copy from here and modify. Each operation must be in a separate file.

% Computes the powers of a set of numbers.
function handles=small_features
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
function output = do_job(first_el, last_el, to_do_file)


addpath(genpath('/work/bharath2/BGT_pami'));
load(to_do_file);
small_feature_path='/work/bharath2/small_features/%s.mat';
to_do_here=to_do(first_el:last_el, :);
for i=1:size(to_do_here,1)
    I=imread(['/work/bharath2/images_todo/' to_do_here(i,:) '.jpg']);
    
    fprintf(2, 'Doing image %d/%d : %s\n',i, numel(to_do_here), to_do_here(i,:));
    fname=sprintf(small_feature_path,to_do_here(i,:));
    a=exist(fname, 'file');
    if(a==0)
        fprintf(2,'Computing..\n');
    J=double(I)/255;
    [bg,cga,cgb]=mex_pb_parts_final_selected(J(:,:,1),J(:,:,2),J(:,:,3));
    
    save(fname,'bg', 'cga', 'cgb');
    clear bg;
clear cga;
clear cgb;

    end
end
output=[];
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
output=[];
end

% handles.dont_load_jobs_in_collect = true; 
%   If this is set, collect_jobs will receive filenames of the jobs instead of the loaded
%   jobs. Do this if the jobs are too large to fit all in memory

