classdef job
    properties
        is_parallel
        op_name;
        id;
        num_elems;
        max_elems_per_job;
        usrdata;
        usrdata_collect;
        out_file;
        exec_config;
    end
    methods
        function j = job(op_name,job_id,usrdata,out_file,  num_elems, max_elems_per_job, usrdata_collect, exec_config)
           j.op_name=op_name;
           j.id=job_id;
           j.usrdata=usrdata;
           j.out_file=out_file;
           if ~exist('num_elems','var')
               j.is_parallel=false;
           else
               j.is_parallel=true;
               j.num_elems=num_elems;
               j.max_elems_per_job=max_elems_per_job;
               if exist('usrdata_collect','var')
                   j.usrdata_collect=usrdata_collect;
               else
                   j.usrdata_collect=[];                   
               end
           end
           if ~exist('exec_config','var')
               global config;
               j.exec_config=config.exec_config;
			else
				j.exec_config=exec_config;
           end
        end
        
        function spawn(job, range, redo)
           if ~exist('redo','var')
              redo=false; 
           end
            if job.is_parallel
               if ~exist('range','var') 
                  range=1:job.num_elems; 
               end
                do_parallel_operation(job.op_name, job.id, job.num_elems, job.max_elems_per_job, job.usrdata, job.usrdata_collect, job.out_file, job.exec_config,range,redo);
            else
                assert(~exist('range','var') || isempty(range)); % range defined only for parallel jobs
                do_single_operation(job.op_name, job.id, job.usrdata, job.out_file, job.exec_config,true,redo);
            end
        end
        function complete(job, redo)
           if ~exist('redo','var')
              redo=false; 
           end
            if job.is_parallel
                do_parallel_operation(job.op_name, job.id, job.num_elems, job.max_elems_per_job, job.usrdata, job.usrdata_collect, job.out_file, job.exec_config,[],redo);
            else
                do_single_operation(job.op_name, job.id, job.usrdata, job.out_file, job.exec_config,false,redo);
            end
        end
    end
end
