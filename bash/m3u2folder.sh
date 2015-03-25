#!/bin/bash

file=$(zenity --file-selection --title="Μόρτη... διάλεξε λίστα... ")
case $? in
         0)
		
		directory=$(zenity --file-selection --directory --title="Μόρτη... διάλεξε το φακελάκι να τα κανω πακετο ")
		echo "$directory"
		echo "$file"
		if [ $? == 0 ]; then
			grep -v "\#" "$file" > temp_file
			lines=$(wc -l  < temp_file)
			for ((b=1;b<=$lines;b++)); do
				sound_file=$(sed -n "${b}p;${b}q" temp_file);
				filename="${basename $sound_file}"
				cp -v "$sound_file" "$directory/$b. $filename" 
			done | zenity --progress --auto-close --title="Λιστοαντιγραφέας" --text="Βαστα να κοπιαρω..." --pulsate --width=300
			rm temp_file
		fi

		;;
         1)
                zenity --warning --text "Ρε φιλαρακι, δεν θες; Τι μας παιδευεις τοτε;"
		exit
		;;
        -1)
                zenity --warning --text "Ασε την πατησαμε... μεγα σφαλμα... λεμε"
		exit
		;;
esac



