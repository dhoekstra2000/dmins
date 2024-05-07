#!/bin/bash
out_dir=$1
dest=$2
dest_file=${dest/$out_dir/}

if [ $dest_file = aps.pdf ]
then
	>&2 echo "Taking out last page to pdf/$dest_file"
	
	# Copy last page into aps.pdf file and remove annotations
	pdftk $dest cat end output - uncompress | sed '/^\/Annots/d' | pdftk - output pdf/aps.pdf compress
else
	cp $dest pdf/$dest_file
fi

echo "pdf/$dest_file"
