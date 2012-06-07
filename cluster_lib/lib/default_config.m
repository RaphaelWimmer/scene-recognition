function exec_config=default_config
    % Sets up default execution parameters
    [err,usr_name]=system('whoami');
    usr_name(usr_name==10)=[];
    exec_config.usr_name=usr_name;
    
    % Directory where we create shell scripts and get error messages for
    % each operation. It doesn't grow large and you can safely delete it
    % when the jobs are done
    exec_config.batch_dir = ['/work4/' exec_config.usr_name '/scene-recognition/results/batch_tmp'];

    % Directory where we keep intermediate results of the jobs. It may get
    % large depending on your jobs. The jobs check for files there and if
    % the files are present (from previous runs) they get reused, which
    % could be faster. But if you want to redo the jobs again you need to
    % delete this directory
    exec_config.work_dir = ['/work4/' exec_config.usr_name '/scene-recognition/results/work_tmp'];

    exec_config.sleep_time = 10; % how long to check if jobs need update
    
    % set to true if your job uses the coveted image toolbox. If true, it
    % will spawn no more than 10 jobs at a time. Each job will wait until a
    % license is available before executing
    exec_config.needs_image_toolbox=false;
    
    exec_config.exec_hours=4;  % maximum time your job should take   
    exec_config.mem=2;         % maximum memory for your job
    exec_config.collect_exec_hours=4;  % maximum time your collect job should take   
    exec_config.collect_mem=2;         % maximum memory for your collect job
    
    exec_config.nodes=1;      
    exec_config.ppn=1;  % processors per node
    exec_config.maxNumCompThreads = 1; % Max number of computation threads
    
    % Any set of commands to be executed on the new node before running
    % jobs. Add addpath, initialization, etc. This is executed only when
    % exec_config.run_on_single_node==false
    exec_config.init_command = ['addpath ' pwd '; addpath ' pwd '/../lib'];
    
    
    % Set this to true to debug on a single node. Remember not to use the
    % front node!
    exec_config.run_on_single_node = false;
    
    if ~exec_config.run_on_single_node
        [q1,q2]=system('echo $HOSTNAME');
        if q1~=0
            [q1,q2]=system('echo $HOST');            
        end
        q2(q2==10)=[];
        exec_config.hostname=q2;
        if ~isequal(q2,'s84') && ~isequal(q2,'psi')
            disp('Warning: not on x84 or psi. Running on a single node.');
            exec_config.run_on_single_node = true;
        end
    end
    
    exec_config.spawn_on_zen = false;
end
