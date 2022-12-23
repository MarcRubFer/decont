
#This script remove previous files and directories from data, res, log and out directories.
# Do you want to continue (Y/N) (con read y variable user_response)

# con "case" evaluar user_response
# case ... in


# If arguments 0 read -P "are you sure do you want to clean all files in data,res,log and out?

if [[ "$#" == 0 ]];
then
	read -p "Are you sure to clean directories data/, res/, log/ and out/? (Y/N)" user_response
	if [[ "$user_response" == [Yy] ]];
	then
		echo "rm -r data/*.gz res/* log/* out/*"
	else
		echo "Exit from cleanup"
		echo exit 0
	fi
else
	directories="$@"
	echo $directories
	for directory in "$directories";
	do 
		case "$directory" in
			data)
				echo "rm -r data/*.gz"
				;;
			res)
				echo "rm -r res/*"
				;;
			log)
				echo "rm -r log/*"
				;;
			out)
				echo "rm -r out/*"
				;;
			*)
				echo "This is not a valid directory"
		esac
	done
fi
