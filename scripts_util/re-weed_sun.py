import os

#test = '/usr/local/shiry/cs280_project/scene-recognition/data/test_sun/'
test = '/usr/local/shiry/cs280_project/scene-recognition/data/train_sun/'

acceptable_prefixes = []
f = open('../people_scenes.txt')
for line in f:
  count = int(line.split()[0])
  scene_name = line.replace(str(count), '').strip().replace(' ', '_')
  acceptable_prefixes.append(scene_name)

for fname in os.listdir(test):
  prefix, name = fname.split('-')
  if prefix in acceptable_prefixes:
    print 'keep ' + fname
  else:
    print 'rm ' + fname
    os.remove(test+fname)
