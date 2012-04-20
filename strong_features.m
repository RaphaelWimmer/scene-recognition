NUM_TRAINING_EXAMPLES_PER_CLASS = 50;

% set image_dir and data_dir to your actual directories
train_image_dir = 'data/sun_train'; 
test_image_dir = 'data/sun_test'; 
data_dir = 'data/sun_data';

% for other parameters, see BuildPyramid
fnames = dir(fullfile(train_image_dir, '*.jpg'));
num_train_files = size(fnames,1);
filenames = cell(num_train_files,1);

for f = 1:num_train_files
	filenames{f} = fnames(f).name;
end

% return pyramid descriptors for all files in filenames
%pyramid_train = BuildPyramid(filenames,train_image_dir,data_dir);

% for other parameters, see BuildPyramid
fnames = dir(fullfile(test_image_dir, '*.jpg'));
num_test_files = size(fnames,1);
filenames = cell(num_test_files,1);

current_head = 'not a head';
test_class_counts = [];
counter = 0;
class_idx = 0;

for f = 1:num_test_files
	filenames{f} = fnames(f).name;
    if isempty(strfind(fnames(f).name, current_head))
        if class_idx > 0
            test_class_counts(class_idx) = counter;
        end
        current_head = strtok(fnames(f).name, '-');
        counter = 1;
        class_idx = class_idx + 1;
    else
        counter = counter + 1;
    end
end
test_class_counts(class_idx) = counter;

test_classes = [];
for i=1:15
    truez = ones(test_class_counts(i))*i;
    test_classes = vertcat(test_classes, truez(:,1));
end

% return pyramid descriptors for all files in filenames
%pyramid_test = BuildPyramid(filenames,test_image_dir,data_dir);

% compute histogram intersection kernel
K = [(1:num_train_files)' , hist_isect(pyramid_train, pyramid_train)]; 
KK = [(1:num_test_files)' , hist_isect(pyramid_test, pyramid_train)];

decision_values = [];

for i=1:15
    
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

    %# train and test
    model = svmtrain(train_class, K, '-t 4');
    [predicted_class, ~, decision_value] = svmpredict(test_class, KK, model);
    decision_values(:,i) = abs(decision_value);
end

ultimate_decisions = [];
for i=1:num_test_files
    [value, idx] = min(decision_values(i,:));
    ultimate_decisions(i) = idx;
end
ultimate_decisions = ultimate_decisions';

%# confusion matrix
C = confusionmat(test_classes, ultimate_decisions)

correct = 0;
for i=1:num_test_files
    if ultimate_decisions(i) == test_classes(i)
        correct = correct + 1;
    end
end

accuracy = correct/num_test_files