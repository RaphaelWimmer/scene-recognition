import os

sun = '/work4/shiry/scene-recognition/data/sun/'

acceptable_prefixes = []
f = open('../people_scenes.txt')
for line in f:
  count = int(line.split()[0])
  scene_name = line.replace(str(count), '').strip().replace(' ', '_')
  acceptable_prefixes.append(scene_name)

for filename in os.listdir(sun):
  scene, base = filename.split("-")

  if scene in acceptable_prefixes:
    print "keep " + scene
  else:
    print 'rm ' + scene
    os.remove(os.path.join(sun, filename))
