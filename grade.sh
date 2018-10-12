#!/bin/bash

# grade.sh is a script written by COMP11 TA Will Rusk to sreamline grading 
# assignments. 
# USAGE:
# grade.sh 
#  run the script with default options, will try to guess location of makefile
# 
# grade.sh -h
#  Display information on flags / usage info

# TODO LIST
# Find makefile intelligently
# Add unit test file & support
# Makefile generation
# Suppress make output
# File header comment checker
# Function header checker
# Calculate line length for source files only
# Output total number of lines / functions greater than 80 col / 30 lines
# Handle submissions with < 80 char lines and < 30 line fns (print something)
# Make f l and m flags not end execution / mutually exclusive.

# SETUP
USERID=`whoami`
BAR='=========='
OPTSTRING=":fhldmM:E:"
FLENS=true
LLENS=true
FEXT=(cpp txt text)

# TODO INTELLIGENTLY SET MAKEPATH
MAKEPATH=/h/$USERID/comp11/ta/hw4_F2018/makefile

print_help () {
	echo "USAGE: grade.sh [OPTION]..."
	echo "Grading program to assist COMP 11 TAs."
	echo ""
	echo "Options:"
	echo "  -d            Run the default grading checks, including f, l, m"
	echo "  -E \"EXT(s)\"   Specify file extensions for source code- will override defaults"
	echo "  -f            Check function lengths"
	echo "  -h            Prints help information"
	echo "  -l            Check line lengths"
	echo "  -M [PATH]     Specify the path to the makefile to be used."
	echo "  -m            Run make using the defualt location for the makefile"
	exit 0
}

calc_flens () {
	echo "$BAR COUNTING FUNCTION LENGTHS $BAR"
	FUNC_LENGTHS=`/g/11/2018f/grading/gtools/flens | sed 's/ //g'`

	for FUNC in $FUNC_LENGTHS
	do
		LEN=`echo $FUNC | tr -dc '0-9'`  
		STRIP=`echo $FUNC | sed "s/$LEN/ /g"`
		read -s FNAME FILENAME <<< $STRIP	
		if [ "$LEN" -gt 30 ] ; then 
			echo "Function $FNAME in file $FILENAME has a length of $LEN lines!"
			echo ""
		fi	
	done
}

calc_llens () {
	echo "$BAR COUNTING LINE LENGTHS $BAR"

	for EXT in FEXT
	do
		for FILE in ls *.$EXT
		do
		LINE_LENGTHS=`wc -L $FILE | sed 's/ //g'`
			for LINE in $LINE_LENGTHS
			do
				LEN=`echo $LINE | tr -dc '0-9'`
				FILENAME=`echo $LINE | sed "s/$LEN//"`
				if [ "$LEN" -gt 80 ] && [ "$FILENAME" != "total" ] ; then
					echo "Line greater than 80 columns!"
					echo "$FILENAME has line of length $LEN!"
					echo ""
				fi
			done
		done
	done
}

makef () {
	echo 'Copying makefile'
	cp  $MAKEPATH ./makefile
	echo 'Starting make all:'
	make all
}

# EVAL FLAGS
#Check Superseding flags
while getopts $OPTSTRING opt ; do
	case $opt in
	 M)
		MAKEPATH=$OPTARG
	 ;;
	 E)
		FEXT=$OPTARG
	 ;;
	 :)
		echo "Option $OPTARG requires an argument!" >&2
		exit 1
	 ;;
	esac
done

OPTIND=1

# Eval rest of flags
while getopts  $OPTSTRING opt ; do
	case $opt in
	 d)
		calc_flens
		calc_llens
		makef
		exit 1
	 ;; 
	 f)
		calc_flens
	 ;;
	 h)
		print_help
	 ;;
	 l)
		calc_llens
	 ;;
	 m)
		makef
	 ;;
	 \?)
		echo "Flag -$OPTARG not recognized!" >&2
		exit 1
	 ;;
	esac
done 