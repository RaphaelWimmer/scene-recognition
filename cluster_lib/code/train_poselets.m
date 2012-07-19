% Map reduce pair for training:
% Using only poselets
%
% Map:
% 1. detect poselets
% 2. build kernalized features
% 
% Reduce:
% 1. build linear svms for each class

function handles=train_poselets
   handles.do_job       = @do_job;
    handles.collect_jobs = @collect_jobs;
end
    
% Invoked multiple times for different sets of elements. It performs the operation and saves results to separate file. The operation is performed for elements in the range [first_el, last_el]
%    first_el, last_el -> specifies the range of elements to work on.
%    param_file -> a string containing the name of the user-specified parameter file.
%    map_output -> Return the results. You can return a struct of multiple elements.
%              If you return [] for all calls to do_job, collect_jobs will not be called 
function map_output = do_job(first_el, last_el, param_file)
	prefix = '/work/shiry/scene-recognition/'
	
	addpath([prefix 'libraries/liblinear-1.91/matlab'])
	addpath([prefix 'libraries/poselets/code'])
	addpath([prefix 'libraries/poselets/code/annotation_tools'])
	addpath([prefix 'libraries/poselets/code/categories'])
	addpath([prefix 'libraries/poselets/code/poselet_detection'])
	addpath([prefix 'libraries/poselets/code/poselet_detection/hog_mex'])
	addpath([prefix 'libraries/poselets/code/visualize'])
	addpath([prefix 'libraries/vlfeat-0.9.14/toolbox/misc'])
	
	% set up poselets
	global config;
	init;

	% the parameters specify the image file names and... ? paths?
	load(param_file); % do we need to do params = load(param_file)????

	load([prefix 'libraries/data/model.mat']); % loads model

	people = [];
	confidence = 5.7; % this is the confidence level set at the demo for poselets

	for f = first_el:last_el 
		imageFName = filenames{f};
		[dirN base] = fileparts(imageFName);
		baseFName = fullfile(dirN, base);
		outFName2 = fullfile(data_dir, sprintf('%s_poselet_hist.mat', baseFName));
		if(size(dir(outFName2),1)~=0)
			fprintf('Skipping %s\n', imageFName);
			load(outFName2, 'H');
			people(f) = H;
			continue;
		end
	end

	clear output poselet_patches fg_masks;
	img = imread([image_dir, '/', filenames{f}]);
	[bounds_predictions,~,~]=detect_objects_in_image(img,model);
	num_people_in_scene = size(bounds_predictions.select(bounds_predictions.score > confidence).bounds, 2); % only count the things we think are people
	people(f) = num_people_in_scene;

	K = [(first_el:last_el)' , vl_homkermap(people, 1)]; 
	map_output = K;
end


% Invoked once after all jobs have completed. Use
% it to merge the data into a single file.
%    job_outputs -> job_outputs{i}.elements_range is the range of
%                  elements processed by job i 
%                  job_outputs{i}.output is the job output
%    param_file -> name of parameter file.
%    reduce_output -> Return the results of combination. You can return a struct of multiple elements
function reduce_output = collect_jobs(job_outputs,ranges,param_file)
	% collect the kernel from all the mappers
	K = zeros(numel(job_outputs));
	for k=1:numel(job_outputs)
		temp=job_outputs{k}.output;	
		K(job_outputs{k}.elements_range) = temp;
	end

	classifiers = [];

	% make one-vs-all classifiers for each scene type
	for i=1:num_train_classes

		% build the vector describing training labels; 0 for not this class, 1
		train_class = zeros(num_train_files);
		train_class = train_class(:,1);
		train_class((i-1)*NUM_TRAINING_EXAMPLES_PER_CLASS+1:i*NUM_TRAINING_EXAMPLES_PER_CLASS) = 1;

		% train SVM
		model = train(train_class, K);
		classifiers = [classifiers; model];
	end
	% we are assuming that this gets written out to results/intermediate_tmp. If it is not there - panic.
	reduce_output = classifiers;
end
% We think this file is done.
