%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% cluster_lib      Matlab library for cluster processing
%% Author: Lubomir Bourdev   lbourdev@eecs.berkeley.edu     Jan 30, 2010
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% An example of an operation to do on the clusters. To make your own just
% copy from here and modify. Each operation must be in a separate file.

% Computes the powers of a set of numbers.
function handles=smooth_tg
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
feature_path = '/work/bharath2/temp/%s.mat';
newtg_path='/work/bharath2/smoothed_tg/%s.mat';

to_do_here=iids(first_el:last_el);
for i=1:numel(to_do_here);
   iid=to_do_here{i};
    fname=sprintf(feature_path, iid);
a=exist(fname, 'file');
if(a~=0)    
load(sprintf(feature_path, iid), 'tg1', 'tg2', 'tg3');
end
gtheta = [1.5708    1.1781    0.7854    0.3927   0    2.7489    2.3562    1.9635];
filters = make_filters([3 5 10 20], gtheta);
for j=1:8
     tg1(:,:,j)=fitparab(double(tg1(:,:,j)), 5, 5/4, gtheta(j), filters{2,j});
     tg2(:,:,j)=fitparab(double(tg2(:,:,j)), 10, 10/4, gtheta(j), filters{3,j});
     tg3(:,:,j)=fitparab(double(tg3(:,:,j)), 20, 20/4, gtheta(j), filters{4,j});
end

save(sprintf(newtg_path,iid), 'tg1', 'tg2', 'tg3');
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
function filters = make_filters(radii, gtheta)

d = 2; 

filters = cell(numel(radii), numel(gtheta));
for r = 1:numel(radii),
    for t = 1:numel(gtheta),
        
        ra = radii(r);
        rb = ra / 4;
        theta = gtheta(t);
        
        ra = max(1.5, ra);
        rb = max(1.5, rb);
        ira2 = 1 / ra^2;
        irb2 = 1 / rb^2;
        wr = floor(max(ra, rb));
        wd = 2*wr+1;
        sint = sin(theta);
        cost = cos(theta);
        
        % 1. compute linear filters for coefficients
        % (a) compute inverse of least-squares problem matrix
        filt = zeros(wd,wd,d+1);
        xx = zeros(2*d+1,1);
        for u = -wr:wr,
            for v = -wr:wr,
                ai = -u*sint + v*cost; % distance along major axis
                bi = u*cost + v*sint; % distance along minor axis
                if ai*ai*ira2 + bi*bi*irb2 > 1, continue; end % outside support
                xx = xx + cumprod([1;ai+zeros(2*d,1)]);
            end
        end
        A = zeros(d+1,d+1);
        for i = 1:d+1,
            A(:,i) = xx(i:i+d);
        end
        
        % (b) solve least-squares problem for delta function at each pixel
        for u = -wr:wr,
            for v = -wr:wr,
                ai = -u*sint + v*cost; % distance along major axis
                bi = u*cost + v*sint; % distance along minor axis
                if (ai*ai*ira2 + bi*bi*irb2) > 1, continue; end % outside support
                yy = cumprod([1;ai+zeros(d,1)]);
                filt(v+wr+1,u+wr+1,:) = A\yy;
            end
        end
        
        filters{r,t}=filt;
    end
end

end
