global config;
init;
time=clock;

% Choose the category here
category = 'person';

data_root = 'data/'; %[config.DATA_DIR '/' category];

disp(['Running on ' category]);

faster_detection = false;
enable_bigq = true; % enables context poselets

if faster_detection
    disp('Using parameters optimized for speed over accuracy.');
    config.DETECTION_IMG_MIN_NUM_PIX = 500^2;  % if the number of pixels in a detection image is < DETECTION_IMG_SIDE^2, scales up the image to meet that threshold
    config.DETECTION_IMG_MAX_NUM_PIX = 750^2;  
    config.PYRAMID_SCALE_RATIO = 2;
end

% Loads the SVMs for each poselet and the Hough voting params
clear output poselet_patches fg_masks;
load([data_root '/model.mat']); % model
if exist('output','var')
    model=output; clear output;
end
if ~enable_bigq
   model =rmfield(model,'bigq_weights');
   model =rmfield(model,'bigq_logit_coef');
   disp('Context is disabled.');
end

im1.image_file{1}=[data_root '/test.jpg'];
img = imread(im1.image_file{1});

[bounds_predictions,poselet_hits,torso_predictions]=detect_objects_in_image(img,model);
numPeopleInScene = length(bounds_predictions);

%display_thresh=5.7; % detection rate vs false positive rate threshold
%imshow(img);
%bounds_predictions.select(bounds_predictions.score>display_thresh).draw_bounds;
%torso_predictions.select(bounds_predictions.score>display_thresh).draw_bounds('blue');