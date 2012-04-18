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

wonz = ones(142);
zeroze = zeros(3001-142);
testClass = [wonz(1,:), zeroze(1,:)]';

%for(i=1:15)
    wonz = ones(100);
    zeroze = zeros(1400);
    trainClass = [wonz(1,:), zeroze(1,:)]';
    % compute histogram intersection kernel
    K = [(1:num_train_files)' , hist_isect(pyramid_train, pyramid_train)]; 
    KK = [(1:num_test_files)' , hist_isect(pyramid_test, pyramid_train)];


    %# train and test
    model = svmtrain(trainClass, K, '-t 4');
    [predClass, acc, decVals] = svmpredict(testClass, KK, model);
%end


%# confusion matrix
C = confusionmat(testClass,predClass)