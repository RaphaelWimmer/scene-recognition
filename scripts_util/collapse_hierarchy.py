import os

new_dest = "/work/shiry/scene-recognition/data/sun/"

for (root, dirs, files) in os.walk("/work/shiry/scene-recognition/data/sun/SUN397/"):
  for file in files:
    # we need to prepend the scene name, including the indoor, outdoor parts
    scene = ""
    if (len(os.path.split(os.path.split(root)[0])[1]) == 1): # we are in letter/scene/
      scene = os.path.split(root)[1]
    elif (len(os.path.split(os.path.split(os.path.split(root)[0])[0])[1]) == 1): # we are in letter/scene/{indoor}/
      scene = os.path.split(os.path.split(root)[0])[1] + "_" + os.path.split(root)[1]
    else:
      print "ignoring files in " + root
      continue
    new_filename = os.path.join(new_dest, scene+"-"+file)
    os.rename(os.path.join(root, file), new_filename)
