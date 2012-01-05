#!/bin/bash
#---------------------------------------- #
# Copyright Vokiel.com | Robert Mikołajuk
#---------------------------------------- #
# general setings
S_CURRUSER=$(whoami)

S_START_DIR="/home/$S_CURRUSER/www"
S_KOHANA_VER="3.2"
S_KOHANA_TAR="/home/kohana/$S_KOHANA_VER.tar.gz"
S_DB_LOGIN="root"
S_DB_PASS="password"
S_DB_PORT=3306

# dialog vars
DIALOG=${DIALOG=dialog}
_DIALOG_BACKTITLE="Vokiel.com | Robert Mikołajuk | Logged user: $S_CURRUSER"
tempfile=`tempfile 2>/dev/null` || tempfile=/tmp/dialog_newproject$$
trap "rm -f $tempfile" 0 1 2 5 15

# navigation vars
NEXTSTEP=step_1
PREVSTEP=step_1

# options arrays
declare -a OPTIONS
declare -a STEPS=("Create directories" "Create database" "Copy Kohana files" "Create Kohana database config" )

step_1(){
	$DIALOG --clear --backtitle "$_DIALOG_BACKTITLE" \
		--title "| Step 1: Name |" \
		--inputbox "Enter your project name (folder name)" 12 60 "project_1" \
		2> $tempfile
	retval=$?

	NEXTSTEP=step_2
	get_last_response
	_projectname=$response
	read_options
}
step_2(){
	$DIALOG --clear --backtitle "$_DIALOG_BACKTITLE" \
		--title "| Step 2: Options |" \
		--separate-output \
	        --checklist "Select (multiple) options here" 12 60 4 \
		"1" "Create directories" on \
	        "2" "Create database" on \
	        "3" "Copy Kohana files" on \
	        "4" "Create Kohana database config" on \
		2> $tempfile
	retval=$?

	NEXTSTEP=step_3
	PREVSTEP=step_2
	get_last_response
	#OPTIONS=$( echo ${response//'"'} | tr " " "\n" )
	#OPTIONS=$(echo $response | tr " " "\n")
	#for x in $OPTIONS
	OPTIONS=($response)
	for (( i=0; i<${#OPTIONS[*]}; i++ ))
	do
		#x=${OPTIONS[$i]}
		#x=${x:1:1}
		#_OPTIONS[x]=$((x))
		x=$((i+1))
		_chosen="$_chosen\n$x. ${STEPS[$i]}"
	done
	read_options
}
step_3(){
	$DIALOG --clear --backtitle "$_DIALOG_BACKTITLE" \
		--title "| Step 3: Summary |" \
		--yesno "Crate new project: '$_projectname' \n\nWith options: $_chosen" 12 60
	retval=$?

	NEXTSTEP=step_4
	PREVSTEP=step_3
	get_last_response
	read_options
}
step_4(){
	step=0
	licznik=0
	max=${#OPTIONS[*]}
	percent=$( echo  100/$max | bc )
	# | awk '{printf("%d\n",$0+=$0<0?-0.5:0.5)}' )

	for (( i=0; i<$max; i++ ))
	do
		lp=$((i+1))
		licznik=$((lp*percent))
		echo $licznik | $DIALOG --backtitle "$_DIALOG_BACKTITLE"  --title "| Step 4: Progress |" --gauge "Current progress\n\nStep: $lp\nOperation: ${STEPS[$i]}" 12 60
		CALLBACK="do_step_$lp"
		${CALLBACK}
		sleep 1
	done
	NEXTSTEP=step_5
	PREVSTEP=step_4
	get_last_response
	read_options
}
step_5(){
	$DIALOG --clear --backtitle "$_DIALOG_BACKTITLE" \
		--title "| Step 5: End |" \
		--msgbox "Done.\n\n$_MESSAGES" 12 60
	retval=$?
	PREVSTEP=step_5

	clear;
	echo ""	
	echo $_dbpass
	echo ""
}
# asking if really want to quit
step_6(){
	$DIALOG --clear --backtitle "$_DIALOG_BACKTITLE" \
		--title "| Break? |" \
		--yesno "Do you really want to quit?" 12 60
	retval=$?
	if [ $retval = 0 ]; then
		NEXTSTEP=quit
	else
		NEXTSTEP=$PREVSTEP
		retval=0
	fi
	read_options
}
# normal quit from program
quit(){
	clear;
	echo ""
	echo "Done."
	echo "Program ended normaly."
	echo ""
}
# reading last response from dialog
get_last_response(){
	response=`cat $tempfile`
}
# read user choose
read_options(){
	case $retval in
	   0) ${NEXTSTEP};;
	   1) step_6;;
	   255) clear; echo ""; echo "Quit."; echo "";;
	esac
}

# create directory tree for new project
do_step_1(){
	_projectdir="$S_START_DIR/$_projectname"
	mkdir -p $_projectdir
	return
}

# create databse, add user, gran privileges
do_step_2(){
	_dbpass=$(cat /dev/urandom | tr -cd "[:alnum:]" | head -c 20 )
	_MESSAGES="User database password: $_dbpass\n\nThe password will be shown after program stops.\nEventually you can view database.php config file."
	query="CREATE DATABASE IF NOT EXISTS $_projectname; GRANT ALL ON $_projectname.* to $_projectname@'localhost' IDENTIFIED BY '$_dbpass'; FLUSH PRIVILEGES;"
	mysql -u "$S_DB_LOGIN" -h localhost -p"$S_DB_PASS" --port="$S_DB_PORT" --execute="$query"
	return
}

# copy kohana framework files from default location
do_step_3(){
	tar -xzf $S_KOHANA_TAR --strip-components=2 -C $_projectdir
	return
}

# make kohana database config and store in new location
do_step_4(){
	db="<?php defined('SYSPATH') OR die('No direct access allowed.'); return array('default' => array('type' => 'mysql','connection' => array('hostname' => 'localhost','username' => '$_projectname','password' => '$_dbpass','persistent' => FALSE, 'database' => '$_projectname',),'table_prefix' => '', 'charset' => 'utf8', 'caching' => FALSE, 'profiling' => TRUE,));"
	db_conf_file="$_projectdir/application/config/database.php"
	touch $db_conf_file
	echo $db > $db_conf_file
	return
}

# start program
step_1
