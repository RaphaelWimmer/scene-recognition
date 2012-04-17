#!/bin/bash
for dir_name in `ls scene_categories`
do
  echo $dir_name
  for img_num in {1..100}
  do
    printf -v var 'image_%04d.jpg' $img_num
    echo $var
    mv scene_categories/$dir_name/$var train/$dir_name-$var
  done
  for img_file in `ls scene_categories/$dir_name`
  do
    echo $img_file
    mv scene_categories/$dir_name/$img_file test/$dir_name-$img_file
  done
done
