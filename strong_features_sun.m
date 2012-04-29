% add the libraries: strong features & libsvm to the path
path(path,'libraries/spatial_pyramid')
%path(path, 'libraries/libsvm-3.12/matlab')
addpath('libraries/libsvm-3.12/matlab')


DEBUG = true;

if (DEBUG)
	disp('DEBUG MODE...');
	NUM_TRAINING_EXAMPLES_PER_CLASS = 2;
	train_image_dir = 'data/tiny_train';
	test_image_dir = 'data/tiny_test';
	data_dir = 'data/tiny_data';
else
	disp('SUN MODE...');
	NUM_TRAINING_EXAMPLES_PER_CLASS = 50;
	train_image_dir = 'data/train_sun'; 
	test_image_dir = 'data/test_sun'; 
	data_dir = 'data/data_sun';
end

% get training filenames
train_fnames = dir(fullfile(train_image_dir, '*.jpg'));
num_train_files = size(train_fnames,1);
train_filenames = cell(num_train_files,1);

for f = 1:num_train_files
	train_filenames{f} = train_fnames(f).name;
end

% get training filenames
test_fnames = dir(fullfile(test_image_dir, '*.jpg'));
num_test_files = size(test_fnames,1);
test_filenames = cell(num_test_files,1);

current_head = 'not a head';
test_class_counts = [];
counter = 0;
class_idx = 0;

for f = 1:num_test_files
	test_filenames{f} = test_fnames(f).name;
    if isempty(strfind(test_fnames(f).name, current_head))
        if class_idx > 0
            test_class_counts(class_idx) = counter;
        end
        current_head = strtok(test_fnames(f).name, '-');
        counter = 1;
        class_idx = class_idx + 1;
    else
        counter = counter + 1;
    end
end
test_class_counts(class_idx) = counter;

test_classes = [];
for i=1:class_idx
    truez = ones(test_class_counts(i))*i;
    test_classes = vertcat(test_classes, truez(:,1));
end

% get a count for how many classifiers we will want to build
class_idx = 0;
current_head = 'not a head';

for f = 1:num_train_files
    if isempty(strfind(train_fnames(f).name, current_head))
        current_head = strtok(train_fnames(f).name, '-');
        class_idx = class_idx + 1;
    end
end

num_train_classes = class_idx;

% return pyramid descriptors for all files in train and test
maxImageSize = 1000; % Larger than this will be downsampled.
%dictionarySize = 300; % Increased from her recommended 200 according to the SUN paper.
%numTextonImages = 300; % The number of randomly selected images to build a dictionary from.
dictionarySize = 200; % Increased from her recommended 200 according to the SUN paper.
numTextonImages = 50; % The number of randomly selected images to build a dictionary from.
pyramid_train = BuildPyramid(train_filenames,train_image_dir,data_dir,maxImageSize,dictionarySize,numTextonImages);
pyramid_test = BuildPyramid(test_filenames,test_image_dir,data_dir,maxImageSize,dictionarySize,numTextonImages);

disp('hist_isecting...');
% compute histogram intersection kernel
K = [(1:num_train_files)' , hist_isect_c(pyramid_train, pyramid_train)]; 
save('results/K_strong', 'K');

KK = [(1:num_test_files)' , hist_isect_c(pyramid_test, pyramid_train)];
save('results/KK_strong', 'KK');

decision_values = [];

% make one-vs-all classifiers for each scene type
for i=1:num_train_classes
    disp(sprintf('builing classifier for class #%d', i));

    % build the vector describing training labels; 0 for not this class, 1
    % for this class
    train_class = zeros(num_train_files);
    train_class = train_class(:,1);
    train_class((i-1)*NUM_TRAINING_EXAMPLES_PER_CLASS+1:i*NUM_TRAINING_EXAMPLES_PER_CLASS) = 1;
    
    % build the vector describing test labels; 0 for not this class, 1 for
    % this class
    test_class = zeros(num_test_files);
    test_class = test_class(:,1);
    if i > 1
        test_class(sum(test_class_counts(1:i-1)):sum(test_class_counts(1:i))) = 1;
    else
        test_class(1:sum(test_class_counts(1:i))) = 1;
    end

	disp('going to train...');
    %# train and test
    model = svmtrain(train_class, K, '-t 4');
    disp('making predictions...');
    [predicted_class, ~, decision_value] = svmpredict(test_class, KK, model);
    decision_values(:,i) = abs(decision_value);
end

disp('finding highest confidence values...');
ultimate_decisions = [];
for i=1:num_test_files
    [value, idx] = min(decision_values(i,:));
    ultimate_decisions(i) = idx;
end
ultimate_decisions = ultimate_decisions';

%# confusion matrix
C = confusionmat(test_classes, ultimate_decisions)
save('results/confusion_strong', 'C');

correct = 0;
for i=1:num_test_files
    if ultimate_decisions(i) == test_classes(i)
        correct = correct + 1;
    end
end

accuracy = correct/num_test_files
