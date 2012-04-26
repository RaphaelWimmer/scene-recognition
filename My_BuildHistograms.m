function [ H_all ] = My_BuildHistograms( imageFileList, dataBaseDir, imageDir )
%function [ H_all ] = My_BuildHistograms( imageFileList, dataBaseDir, imageDir )
%
%find texton labels of patches and compute texton histograms of all images
%   
% For each image the set of sift descriptors is loaded and then each
%  descriptor is labeled with its texton label. Then the global histogram
%  is calculated for the image. If you wish to just use the Bag of Features
%  image descriptor you can stop at this step, H_all is the histogram or
%  Bag of Features descriptor for all input images.
%
% imageFileList: cell of file paths
% imageBaseDir: the base directory for the image files
% dataBaseDir: the base directory for the data files that are generated
%  by the algorithm. If this dir is the same as imageBaseDir the files
%  will be generated in the same location as the image file
% featureSuffix: this is the suffix appended to the image file name to
%  denote the data file that contains the feature textons and coordinates. 
%  Its default value is '_sift.mat'.
% dictionarySize: size of descriptor dictionary (200 has been found to be
%  a good size)
% canSkip: if true the calculation will be skipped if the appropriate data 
%  file is found in dataBaseDir. This is very useful if you just want to
%  update some of the data or if you've added new images.

fprintf('Building Poselet Histograms\n\n');

%% loading the poseletes model weeeeeee
load('data/model.mat'); % loads model

fprintf('Loaded poselets model\n');

%% compute poselet counts of patches and whole-image histograms
H_all = zeros(size(imageFileList,1), 1);

for f = 1:size(imageFileList,1)

    imageFName = imageFileList{f};
    [dirN base] = fileparts(imageFName);
    baseFName = fullfile(dirN, base);
    
    outFName = fullfile(dataBaseDir, sprintf('%s_poselet_ind.mat', baseFName));
    outFName2 = fullfile(dataBaseDir, sprintf('%s_poselet_hist.mat', baseFName));
    if(size(dir(outFName),1)~=0 && size(dir(outFName2),1)~=0)
        fprintf('Skipping %s\n', imageFName);
        load(outFName2, 'H');
        H_all(f, :) = H;
        continue;
    end
    
    %% load sift descriptors
   % load(inFName, 'features');
   % ndata = size(features.data,1);
   % fprintf('Loaded %s, %d descriptors\n', inFName, ndata);
   
    % Poseleting
    confidence = 5.7; % this is the confidence level set at the demo for poselets
    clear output poselet_patches fg_masks;
    img = imread([imageDir, '/', imageFName]);
    [bounds_predictions,~,~]=detect_objects_in_image(img,model);
    all_bounds = bounds_predictions.select(bounds_predictions.score > confidence).bounds; % only count the things we think are people

    %% find all bounds in the image 
    poselet_ind.x = all_bounds(1,:);
    poselet_ind.y = all_bounds(2,:);
    poselet_ind.pWid = all_bounds(3,:);
    poselet_ind.pHgt = all_bounds(4,:);
    poselet_ind.wid = size(img, 2);
    poselet_ind.hgt = size(img, 1);

    %H = hist(size(all_bounds, 2), 1);
    H = size(all_bounds, 2); % We are only counting the number of people in the whole image without regard to what they are doing. So the size of the dictionary is always 1.
    H_all(f, :) = H;
	
    %% save texton indices and histograms
    save(outFName, 'poselet_ind');
    save(outFName2, 'H');
end

%% save histograms of all images in this directory in a single file
outFName = fullfile(dataBaseDir, 'poselet_histograms.mat');
save(outFName, 'H_all', '-ascii');


end
