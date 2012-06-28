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

Next steps:

Make sure that the data images splitting scripts are ok and run them to split the sun dataset into train and test

Make the second map reduce pair which:
map: cut up KK (the testing features matrix) so that each mapper only gets some images. Each mapper will use the classifiers output from the last reduce step (theoretically will be saved in results/intermediate_tmp - CHECK WHAT NAME THE STUPID THING GIVES IT). Each image is tested with ALL classifiers - loop over them!

reduce: squish all the confidence scores for all the images together. Here we would need to figure out the true labels of the test images - maybe save this in the parameters file? we called these like test_classes which is a vector whose lenght is the number of test classes and the values are the number of test images in that class. great.
