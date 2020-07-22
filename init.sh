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
		return "getent passwd $user"
	elif [ "$outputType" = "message" ]; then
		return "Deleted User $user"
	fi
	
}
######

echo " Welcome to the init script for the St Augustine Composite Squadron Scoring Engine"

echo "user accts"


createVuln "deleteUser" 3 "eve"
