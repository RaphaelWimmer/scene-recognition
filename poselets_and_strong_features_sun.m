% add the libraries: strong features & poselets & libsvm to the path
path(path,'libraries/spatial_pyramid')
addpath('libraries/libsvm-3.12/matlab')
addpath('libraries/poselets/code')
addpath('libraries/poselets/code/annotation_tools')
addpath('libraries/poselets/code/categories')
addpath('libraries/poselets/code/poselet_detection')
addpath('libraries/poselets/code/poselet_detection/hog_mex')
addpath('libraries/poselets/code/visualize')

% set up poselet stuff VERY FIRST
% note that init CLEARS EVERYTHING IN THE WORKSPACE
% SO REALLY, DO IT FIRST
global config;
init;

DEBUG = false;

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

% get training file names
train_fnames = dir(fullfile(train_image_dir, '*.jpg'));
num_train_files = size(train_fnames,1);
train_filenames = cell(num_train_files,1);

for f = 1:num_train_files
	train_filenames{f} = train_fnames(f).name;
end

% get testing filenames
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

disp('strong featuring...');
% return pyramid descriptors for all files in train and test
maxImageSize = 1000; % Larger than this will be downsampled.
dictionarySize = 200; % Increased from her recommended 200 according to the SUN paper.
numTextonImages = 50; % The number of randomly selected images to build a dictionary from.
pyramid_train = BuildPyramid(train_filenames,train_image_dir,data_dir,maxImageSize,dictionarySize,numTextonImages);
pyramid_test = BuildPyramid(test_filenames,test_image_dir,data_dir,maxImageSize,dictionarySize,numTextonImages);

disp('poseletting...');

% These settings are for FAST DETECTION. If possible, we should comment them
% out and let the initialization of the config choose the optimal settings.
%config.DETECTION_IMG_MIN_NUM_PIX = 500^2;  % if the number of pixels in a detection image is < DETECTION_IMG_SIDE^2, scales up the image to meet that threshold
%config.DETECTION_IMG_MAX_NUM_PIX = 750^2;
%config.PYRAMID_SCALE_RATIO = 2;

load('data/model.mat'); % loads model

train_people = [];
confidence = 5.7; % this is the confidence level set at the demo for poselets

for f = 1:num_train_files
	imageFName = train_filenames{f};
	[dirN base] = fileparts(imageFName);
	baseFName = fullfile(dirN, base);
    outFName2 = fullfile(data_dir, sprintf('%s_poselet_hist.mat', baseFName));
    if(size(dir(outFName2),1)~=0)
       	fprintf('Skipping %s\n', imageFName);
       	load(outFName2, 'H');
       	train_people(f) = H;
       	continue;
    end

    disp(sprintf('poselets for train %d of %d', f, num_train_files));
    clear output poselet_patches fg_masks;
    img = imread([train_image_dir, '/', train_filenames{f}]);
    [bounds_predictions,~,~]=detect_objects_in_image(img,model);
    num_people_in_scene = size(bounds_predictions.select(bounds_predictions.score > confidence).bounds, 2); % only count the things we think are people
    train_people(f) = num_people_in_scene;
end

test_people = [];
for f = 1:num_test_files
	imageFName = test_filenames{f};
	[dirN base] = fileparts(imageFName);
	baseFName = fullfile(dirN, base);
    outFName2 = fullfile(data_dir, sprintf('%s_poselet_hist.mat', baseFName));
    if(size(dir(outFName2),1)~=0)
       	fprintf('Skipping %s\n', imageFName);
       	load(outFName2, 'H');
       	test_people(f) = H;
       	continue;
    end

    disp(sprintf('poselets for test %d of %d', f, num_test_files));
    clear output poselet_patches fg_masks;
    img = imread([test_image_dir, '/', test_filenames{f}]);
    [bounds_predictions,~,~]=detect_objects_in_image(img,model);
    num_people_in_scene = size(bounds_predictions.select(bounds_predictions.score > confidence).bounds, 2); % only count the things we think are people
    test_people(f) = num_people_in_scene;
end

% strap the poselet values onto the feature vectors
train_feature_vect = [pyramid_train, train_people'];
test_feature_vect = [pyramid_test, test_people'];

% compute histogram intersection kernel
disp('creating histogram intersection kernel...');
K = [(1:num_train_files)' , hist_isect(train_feature_vect, train_feature_vect)]; 
save('results/K_poselets_strong', 'K');

KK = [(1:num_test_files)' , hist_isect(test_feature_vect, train_feature_vect)];
save('results/KK_poselets_strong', 'KK');

decision_values = zeros(num_test_files, class_idx);

% make one-vs-all classifiers for each scene type
% and run it to get a confidence vector for each test image
for i=1:class_idx
    disp('builing classifier for class #');
	disp(i);

    % build the vector describing training labels; 0 for not this class, 1

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

    %# train and test
    model = svmtrain(train_class, K, '-t 4');
    disp('making predictions...');
    [predicted_class, ~, decision_value] = svmpredict(test_class, KK, model);
    decision_values(:,i) = abs(decision_value);
end

% boil down the confidence vectors to just the class with highest
% confidence for each test image
disp('finding highest confidence values...');
ultimate_decisions = zeros(num_test_files, 1);
for i=1:num_test_files
    [value, idx] = min(decision_values(i,:));
    ultimate_decisions(i) = idx;
end
ultimate_decisions = ultimate_decisions';

% confusion matrix
C = confusionmat(test_classes, ultimate_decisions)
save('results/confusion_poselets_strong', 'C');

correct = 0;
for i=1:num_test_files
    if ultimate_decisions(i) == test_classes(i)
        correct = correct + 1;
    end
end

accuracy = correct/num_test_files
