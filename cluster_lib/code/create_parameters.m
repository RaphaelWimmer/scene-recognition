% create parameter .mat files so that we can pass them to the map and reduce
% functions.

DEBUG = false;

prefix = '/work/shiry/scene-recognition/';

if (DEBUG)
	disp('DEBUG MODE...');
	NUM_TRAINING_EXAMPLES_PER_CLASS = 2;
	train_image_dir = [prefix 'data/tiny/train'];
	test_image_dir = [prefix 'data/tiny/test'];
	data_dir = [prefix 'data/tiny/temp_data'];
else
	disp('SUN MODE...');
	NUM_TRAINING_EXAMPLES_PER_CLASS = 60;
	train_image_dir = [prefix 'data/sun/train']; 
	test_image_dir = [prefix 'data/sun/test']; 
	data_dir = [prefix 'data/sun/temp_data'];
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

% give true labels to each image
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

% mess with the names for training
filenames = train_filenames;
num_files = num_train_files;
image_dir = train_image_dir;
save('train_param_file.mat', 'image_dir', 'filenames', 'num_files', 'num_train_classes');

% mess with the names for testing
filenames = test_filenames;
num_files = num_test_files;
image_dir = test_image_dir;
save('test_param_file.mat', 'image_dir', 'filenames', 'num_files', 'num_train_classes', 'test_class_counts', 'test_classes');

% and the general parameters
save('param_file.mat','train_image_dir', 'test_image_dir', 'train_filenames', 'test_filenames', 'num_train_files', 'num_test_files', 'num_train_classes', 'test_class_counts', 'test_classes', 'NUM_TRAINING_EXAMPLES_PER_CLASS');
