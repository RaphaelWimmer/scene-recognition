function all_hits=detect_poselets_range(first_el, last_el,model, imgnames, imgpath)
init;
all_hits=hit_list;

for k=first_el:last_el
	I=imread(sprintf(imgpath, imgnames{k}));
	temp_hits=detect_objects_in_image(I, model);
	all_hits=all_hits.append(temp_hits);
end 	
