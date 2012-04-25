import os

test = '/usr/local/shiry/cs280_project/scene-recognition/data/test_sun/'

counts = {};
for fname in os.listdir(test):
  prefix, garbage = fname.split('-')
  if prefix in counts:
    counts[prefix] += 1
  else:
    counts[prefix] = 1
  if counts[prefix] > 200:
	  #print "removing " + fname
	 os.remove(test+fname)
