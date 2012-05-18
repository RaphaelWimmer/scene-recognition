import os

SUN_DIR = '/work4/shiry/scene-recognition/data/sun/'
TRAIN_DIR = os.path.join(SUN_DIR, 'train')
TEST_DIR = os.path.join(SUN_DIR, 'test')
TRAIN_IMAGES = 60

scenes_to_train_images = {}
for filename in os.listdir(TRAIN_DIR):
	scene, junk = filename.split('-')
	if not scene in scenes_to_train_images:
		scenes_to_train_images[scene] = 0
	scenes_to_train_images[scene] += 1

for filename in os.listdir(TEST_DIR):
	scene, junk = filename.split('-')
	if not scene in scenes_to_train_images:
		scenes_to_train_images[scene] = 0
	if scenes_to_train_images[scene] >= TRAIN_IMAGES:
		continue
	scenes_to_train_images[scene] += 1
	os.rename(os.path.join(TEST_DIR, filename), os.path.join(TRAIN_DIR, filename))
