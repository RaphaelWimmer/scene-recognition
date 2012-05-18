import os

scenes_to_counts = {}

for filename in os.listdir('/work4/shiry/scene-recognition/data/sun/'):
	scene, junk = filename.split('-')
	if not scene in scenes_to_counts:
		scenes_to_counts[scene] = 0
	scenes_to_counts[scene] += 1

print scenes_to_counts
