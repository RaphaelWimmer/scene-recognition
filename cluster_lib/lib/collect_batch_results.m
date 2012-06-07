function collect_batch_results(op_name,job_id,work_dir,num_elements,max_elems_per_job,usrdata_collect,out_file)
% Invoked on the node that collects all the job outputs. First collects the job
% outputs and if any are not empty calls the collect_jobs user defined function

handles = eval(op_name);

num_jobs = ceil(num_elements/max_elems_per_job);
ranges = nan(num_jobs,2);
if isfield(handles,'dont_load_jobs_in_collect') && handles.dont_load_jobs_in_collect
    dont_load_jobs_in_collect = true;
else
    dont_load_jobs_in_collect = false;
end

all_empty=true;
for i=1:num_jobs
    out_name = job_output_filename(job_id,i,work_dir);
    ranges(i,:) = [max_elems_per_job*(i-1)+1 min(num_elements,max_elems_per_job*i)];
    if dont_load_jobs_in_collect
        results{i} = out_name;
    else
        results{i} = load(out_name);
        if ~isempty(results{i})
            all_empty=false;
        end
    end
end

if dont_load_jobs_in_collect || ~all_empty
   output=handles.collect_jobs(results,ranges,usrdata_collect); 
   if ~exist(out_file,'file')
       qqq=whos('output');
       if qqq.bytes>2000000000
           save(out_file,'-v7.3','output');       
       else
           save(out_file,'output');
       end
   end
end

if 1
    rmdir([work_dir '/' job_id],'s');
else
    disp('WARNING: DEBUG MODE in collect_batch_results (does not clean temp files)');
end