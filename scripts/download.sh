# Creation of directory of destiny (if no exists)

mkdir -p "$2"

# Script for download from $1 and store in $2

file_name="$(basename "$1")"

if [[ -e "$2"/"$file_name" ]];	#Bonus 2: Check if the output already exists before running a command.
then
	echo -e "The file "$file_name" has already been downloaded"
else
	echo "Downloading sequence(s)..."
	echo

	wget -O "$2"/"$file_name" "$1"
	
	echo "Done"
	echo "----"
fi

# Script for optional uncompress ($3 == yes)
file_uncompress=$(basename -s .gz $file_name)

if [[ "$3" == "yes" ]];
then
	if [[ -e $file_uncompress ]]; #Bonus2: Check if the output already exists before running a command.
	then
		echo "File is already uncompress"
	else
        	echo "Uncompressing file "$file_name" ..."
        	echo

        	gunzip -k "$2"/"$file_name"

        	echo "Done"
        	echo "----"
	fi
fi

# Script for filtering by $4

if [ "$#" == 4 ]
then
        echo "Filtering "$file_name" sequence by '"$4"'..."
        echo

        file_filtered=$(basename "$file_name" .gz)
	mv "$2"/"$file_filtered" "$2"/temp_"$file_filtered"
	
	seqkit grep -v -r -n -p ".*$4.*" $2/temp_"$file_filtered" > "$2"/"$file_filtered"
	rm "$2"/temp_"$file_filtered"

        echo "Done"
        echo "----"
fi
