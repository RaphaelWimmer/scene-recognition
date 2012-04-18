% set image_dir and data_dir to your actual directories
train_image_dir = 'data/train'; 
test_image_dir = 'data/test'; 
data_dir = 'data/data';

% for other parameters, see BuildPyramid
fnames = dir(fullfile(train_image_dir, '*.jpg'));
num_train_files = size(fnames,1);
filenames = cell(num_train_files,1);

for f = 1:num_train_files
	filenames{f} = fnames(f).name;
end

% return pyramid descriptors for all files in filenames
pyramid_train = BuildPyramid(filenames,train_image_dir,data_dir);

% for other parameters, see BuildPyramid
fnames = dir(fullfile(test_image_dir, '*.jpg'));
num_test_files = size(fnames,1);
filenames = cell(num_test_files,1);

for f = 1:num_test_files
	filenames{f} = fnames(f).name;
end

% return pyramid descriptors for all files in filenames
pyramid_test = BuildPyramid(filenames,test_image_dir,data_dir);

% compute histogram intersection kernel
K = [(1:num_train_files)' , hist_isect(pyramid_train, pyramid_train)]; 
KK = [(1:num_test_files)' , hist_isect(pyramid_test, pyramid_train)];

test_class_counts = [141, 260, 228, 160, 208, 274, 310, 192, 256, 115, 116, 211, 110, 189, 215];
test_classes = [];
for i=1:15
    truez = ones(test_class_counts(i))*i;
    test_classes = vertcat(test_classes, truez(:,1));
end

decision_values = [];

for i=1:15
    pre_zeroze = zeros((i-1)*100);
    wonz = ones(100);
    post_zeroze = zeros(1400);
    if(i > i)
        train_class = [pre_zeroze(1,:), wonz(1,:), post_zeroze(1,:)]';
    else
        train_class = [wonz(1,:), post_zeroze(1,:)]';
    end
    
    pre_zeroze = zeros(sum(test_class_counts(1:i)));
    wonz = ones(test_class_counts(i));
    post_zeroze = zeros(sum(test_class_counts(i+1:length(test_class_counts))));
    if(i > 1)
        test_class = [pre_zeroze(1,:), wonz(1,:), post_zeroze(1,:)]';
    else
        test_class = [wonz(1,:), post_zeroze(1,:)]';
    end

    %# train and test
    model = svmtrain(train_class, K, '-t 4');
    [predicted_class, accuracy, decision_value] = svmpredict(test_class, KK, model);
    decision_values(:,i) = decision_value;
end

ultimate_decisions = [];
for i=1:num_test_files
    [value, idx] = max(decision_values(i,:));
    ultimate_decisions(i) = idx;
end

%# confusion matrix
C = confusionmat(test_classes, ultimate_decisions')