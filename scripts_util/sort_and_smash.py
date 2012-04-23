scenes_to_counts = {}

for fname in ['shiry.txt', 'valkyrie.txt']:
	f = open(fname)
	for line in f:
		pieces = line.split()
		count = int(pieces[0])
		scene = line.replace(str(count), '').strip().lower()
		if scene in scenes_to_counts:
			scenes_to_counts[scene] += count
		else:
			scenes_to_counts[scene] = count
	f.close()

print scenes_to_counts

f = open('out.txt', 'w')
for scene, count in scenes_to_counts.iteritems():
	f.write(str(count) + ' ' + scene + '\n')

f.close()
