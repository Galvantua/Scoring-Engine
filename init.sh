#!/usr/bin/env bash

###### Init Functions ######

createVuln() {
	type="$1"
	points=$2
	var1="$3"
	test=$($type "test" $var1)
	message=$($type "message" $var1 )
	echo " 
if [ ${test} ]; then
	scorePoints \"$points\" \"$message\"
fi
"
}

deleteUser() {
	outputType="$1"
	user="$2"
	if [ "$outputType" = "test" ]; then
		echo "$(getent passwd $user) = \"\""
	elif [ "$outputType" = "message" ]; then
		echo "Deleted User $user"
	fi
	
}

addUser() {
	outputType="$1"
	user="$2"
	if [ "$outputType" = "test" ]; then
		echo "$(getent passwd $user) != \"\""
	elif [ "$outputType" = "message" ]; then
		echo "Added User $user"
	fi
	
}

changePasswd() {
	outputType="$1"
	user="$2"
	if [ "$outputType" = "test" ]; then
		echo "$(getent shadow $user | cut -d: -f3) = \"$(echo $(($(date --utc --date \"$1\" +%s)/86400)))\" "
	elif [ "$outputType" = "message" ]; then
		echo "Changed Password $user"
	fi
	
}
###### Init Vars ######

totalvars=0
totalpoints=0

###### Start Init ######
clear
echo "Welcome to the init script for the St Augustine Composite Squadron Scoring Engine"
echo ""
echo "User Accounts"

#do you want to do user accounts?
#if yes, continue
#else skip

#do you make 

createVuln "deleteUser" 3 "eve"
