# INSTRUCTIONS--------------------------------------------------------------------------------
#
# This script should download the file specified in the first argument ($1),
# place it in the directory specified in the second argument ($2),
# and *optionally*:
# - uncompress the downloaded file with gunzip if the third
#   argument ($3) contains the word "yes"
# - filter the sequences based on a word contained in their header lines:
#   sequences containing the specified word in their header should be **excluded**
#
# Example of the desired filtering:
#
#   > this is my sequence
#   CACTATGGGAGGACATTATAC
#   > this is my second sequence
#   CACTATGGGAGGGAGAGGAGA
#   > this is another sequence
#   CCAGGATTTACAGACTTTAAA
#
#   If $4 == "another" only the **first two sequence** should be output
#-----------------------------------------------------------------------------------------------

# Creation of directory of destiny (if no exists)

mkdir -p $2

# Script for download from $1 and store in $2

file_name=$(basename $1)

echo "Downloading sequence..."
echo

wget -O $2/$file_name $1

echo "Done"
echo "----"

# Script for optional uncompress ($3 == yes)

if [ $3 == "yes" ]
then
        echo "Uncompressing file..."
        echo

        gunzip $2/$file_name

        echo "Done"
        echo "----"
fi

# Script for filtering by $4
## NOTE: A new directory ($2/filtered) is created for store filtered sequences; so original sequences are not overwritten.

if [ $# == 4 ]
then
        echo "Filtering sequence..."
        echo

        filename_uncompress=$(basename $file_name .gz)
        mkdir -p $2/filtered
        sed -e "/$4/,+3{d}"  $2/$filename_uncompress > $2/filtered/$filename_uncompress-filter_by_$4

        echo "Done"
        echo "----"
fi
