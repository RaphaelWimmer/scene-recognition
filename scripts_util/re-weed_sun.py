import os

train = '/usr/local/shiry/cs280_project/scene-recognition/data/train_sun/'
test = '/usr/local/shiry/cs280_project/scene-recognition/data/test_sun/'

acceptable_prefixes = []
f = open('../people_scenes.txt')
for line in f:
  count = int(line.split()[0])
  scene_name = line.replace(str(count), '').strip().replace(' ', '_')
  acceptable_prefixes.append(scene_name)

prefix_counts = {}

for fname in os.listdir(train):
  prefix, name = fname.split('-')
  if prefix in acceptable_prefixes:
    if prefix in prefix_counts:
      prefix_counts[prefix] += 1
    else:
      prefix_counts[prefix] = 1
    if prefix_counts[prefix] > 50:
      print 'mv ' + fname
	  os.rename(train+fname, test+fname)
    else:
      print 'keep ' + fname
  else:
    print 'rm ' + fname
	os.remove(train+fname)
