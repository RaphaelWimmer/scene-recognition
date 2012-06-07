function prefix=get_job_unique_prefix
% The prefix is used if you want to run the same tasks with different data
% as non-conflicting jobs
global config;
%if isfield(config,'CLASSES')
%    prefix = char('a'+find(ismember(config.CLASSES,config.OBJECT_TYPE))-1);
%else
   prefix=''; 
%end
end
