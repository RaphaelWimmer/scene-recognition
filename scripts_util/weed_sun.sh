#!/bin/bash
for letter_dir in `ls sun`
do
  echo $letter_dir
  for scene_dir in `ls sun/$letter_dir`
  do
    echo $scene_dir
    if [ `ls sun/$letter_dir/$scene_dir | wc -l` -ge 100 ]; then
      for img_num in (1..100)
      do
        file = `ls sun/$letter_dir/$scene_dir | head -n 1`
        dest = train_sun/$scene_dir-$file
        file = sun/$letter_dir/$scene_dir/$file
        echo mv $file $dest
      done
      while [ `ls sun/$letter_dir/$scene_dir | wc -l` -gt 0 ]; do
        file = `ls sun/$letter_dir/$scene_dir | head -n 1`
        dest = test_sun/$scene_dir-$file
        file = sun/$letter_dir/$scene_dir/$file
        echo mv $file $dest
      done
    fi
  done
done
