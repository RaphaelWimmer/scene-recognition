function filename=job_output_filename(job_id,job_index, work_dir)
    
filename = sprintf('%s/%s/%s_%d.mat',work_dir,job_id,job_id,job_index);

end