% function do_qsub
% creates and submits to Torque a simple batch script with a matlab
% command.
%
% Pablo Arbelaez <arbelaez.eecs.berkeley.edu>
function do_qsub(jobName, batchDir, matlab_command, mem, hours, exec_config)
batchDir
prefix = exec_config.init_command
if ~isnan(exec_config.maxNumCompThreads)
    prefix = [prefix ';maxNumCompThreads(' num2str(exec_config.maxNumCompThreads) ');'];
end

if exec_config.needs_image_toolbox
    prefix = [prefix 'request_image_toolbox;'];
end

matlab_command = [prefix matlab_command];

fname = fullfile(batchDir, sprintf('%s.sh',jobName));
fid = fopen(fname,'w');
if fid==-1,
    error('Could not open file %s for writing.',fname);
end

fprintf(fid, sprintf('#!/bin/sh \n\n#PBS -N %s \n#PBS -r n\n',jobName));
%fprintf(fid, sprintf('#PBS -e %s \n#PBS -o %s \n#PBS -q batch \n\n',fullfile(batchDir,sprintf('%s.err',jobName)),fullfile(batchDir,sprintf('%s.log',jobName))));
fprintf(fid, sprintf('#PBS -l nodes=%d:ppn=%d \n\n',exec_config.nodes,exec_config.ppn));
if mem>16
    fprintf(fid, sprintf('#PBS -l mem=%dmb \n\n',mem));    
else
    fprintf(fid, sprintf('#PBS -l mem=%dg \n\n',mem));
end
fprintf(fid, sprintf('#PBS -l walltime=%d:00:00 \n\n',hours));
fprintf(fid, sprintf('/usr/sww/pkg/matlab-r2008a/bin/matlab -nojvm -nodisplay -r "%s;quit;" > %s 2> %s\n', matlab_command, fullfile(batchDir,sprintf('%s.log',jobName)), fullfile(batchDir,sprintf('%s.err',jobName))));	
%fprintf(fid, sprintf('/usr/sww/pkg/matlab-r2008a/bin/matlab -nojvm -nodisplay -r "%s;quit;"\n',matlab_command));
fclose(fid);
if(~exist(fname, 'file'))
	error('error doing qsub');
end
files=dir(fname);
files(1)


fprintf('qsub %s;',fname)
if exec_config.spawn_on_zen
    system(sprintf('qsub -q zen %s;',fname));
else
    system(sprintf('qsub %s;',fname));
end
end

