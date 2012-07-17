create_parameters: sets up the parameters .mat files that we pass into the map and reduce functions.

train_poselets:
Map reduce pair for training:
% Using only poselets
%
% Map:
% 1. detect poselets
% 2. build kernalized features
% 
% Reduce:
% 1. build linear svms for each class

KK_poselets:
% Map reduce pair for creating test features:
% Using only poselets
%
% Map:
% 1. detect poselets
% 2. build kernalized features
% 
% Reduce:
% 1. Collect KK - the test images feature matrix.

Next steps:

Make the second map reduce pair which:
map: cut up KK (the testing features matrix) so that each mapper only gets some images. Each mapper will use the classifiers output from the last reduce step (theoretically will be saved in results/intermediate_tmp - CHECK WHAT NAME THE STUPID THING GIVES IT). Each image is tested with ALL classifiers - loop over them!

reduce: squish all the confidence scores for all the images together. Here we would need to figure out the true labels of the test images - maybe save this in the parameters file? we called these like test_classes which is a vector whose lenght is the number of test classes and the values are the number of test images in that class. great.

this is the comment for the test_poselets.m:
% Map reduce pair for testing:
% Using only poselets
%
% Cut KK (the testing images features matrix) so that each mapper only gets some images.
%
% Map:
% 1. Use ALL classifiers (the output from the last reduce step) to test each image. (Have to use ALL classifiers - so loop over them). 
% 
% Reduce:
% 1. Collect all the confidence scores for all the images together. Here we need to use the true labels for all the test images.

