# Creation of directory of destiny (if no exists)

mkdir -p "$2"

# Script for download from $1 and store in $2

file_name="$(basename "$1")"

echo "Downloading sequence(s)..."
echo

wget -O "$2"/"$file_name" "$1"

echo "Done"
echo "----"

# Script for optional uncompress ($3 == yes)

if [ "$3" == "yes" ]
then
        echo "Uncompressing file..."
        echo

        gunzip -k "$2"/"$file_name"

        echo "Done"
        echo "----"
fi

# Script for filtering by $4

if [ "$#" == 4 ]
then
        echo "Filtering sequence by '"$4"'..."
        echo

        file_filtered=$(basename "$file_name" .gz)
	mv "$2"/"$file_filtered" "$2"/temp_"$file_filtered"
	
	seqkit grep -v -r -n -p ".*$4.*" $2/temp_"$file_filtered" > "$2"/"$file_filtered"
	rm "$2"/temp_"$file_filtered"

        echo "Done"
        echo "----"
fi
