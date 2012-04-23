#!/bin/bash
for letter_dir in `ls sun`
do
  for scene_dir in `ls sun/$letter_dir`
  do
    somefile=`ls sun/$letter_dir/$scene_dir | head -n 1`
    somefile=sun/$letter_dir/$scene_dir/$somefile
    if [ -d $somefile ]; then
      echo $somefile
      for subdir in `ls sun/$letter_dir/$scene_dir`
      do
        if [ `ls sun/$letter_dir/$scene_dir/$subdir | wc -l` -ge 100 ]; then
          for img_num in {1..100}
          do
            file=`ls sun/$letter_dir/$scene_dir/$subdir | head -n 1`
            dest=train_sun/$scene_dir'_'$subdir-$file
            file=sun/$letter_dir/$scene_dir/$subdir/$file
            mv $file $dest
          done
          while [ `ls sun/$letter_dir/$scene_dir/$subdir | wc -l` -gt 0 ]; do
            file=`ls sun/$letter_dir/$scene_dir/$subdir | head -n 1`
            dest=test_sun/$scene_dir'_'$subdir-$file
            file=sun/$letter_dir/$scene_dir/$subdir/$file
            mv $file $dest
          done
        fi
      done
    fi
  done
done
