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
echo "Creating engine..."
touch engine.sh
echo ""
read -rp "What is the System admin user?" $sysUser

echo '#!/bin/bash
# If you have this VM as an assesment leave NOW!!!
# Looking through this file is a violation of integrety, 
# and I WILL find out!!! 


####### init functions #######
init () {
	if [ -f \"/opt/Scoring-Engine/README\" ]; then
		mv /opt/Scoring-Engine/README /home/user/Desktop/
	fi
	
	touch "$scoringReport"
	touch "$totalScore"
	touch "$scoringNegatives"
	touch "$scoringPositives"

	score=$(cat "$totalScore")
	score="${score} Points Earned"
	
	penalties=$(cat "$scoringNegatives" )
	vulns=$(cat "$scoringPositives" )
	
	cat "/opt/Scoring-Engine/head" > "$scoringReport"
	echo 	"<h1>This is the scoring report for the assesment for the St. Augustine Composite Squadron Cyber Education Program.</h1>" >> "$scoringReport"

	echo	"<h2> $score </h2>" >> "$scoringReport"
	
	echo	"<h3> Penalties: </h3>" >> "$scoringReport"

	echo	"$penalties" >> "$scoringReport"

	echo	"<h3> Fixed Vulnerabilities: </h3>" >> "$scoringReport"

	echo	"$vulns" >> "$scoringReport"
	echo 	"</body></html>" >> "$scoringReport"
	echo "" > "$scoringPositives"
	echo "" > "$scoringNegatives"
	echo "" > "$totalScore"
}' > "engine.sh"
echo 'scorePoints () {
	#$1 Points
	#$2 Message
	score=$(cat $totalScore)
	newScore=$(($score + $1))
	echo "<p class=\"vulns\">$2 : <span class=\"green\">$1 pts</span></p>" >> "$scoringPositives"
	echo $newScore > $totalScore
}

removePoints () {
	#$1 Points
	#$2 Message
	score=$(cat "$totalScore")
	newScore=$(($score - $1))
	echo "<p class=\"penalties\">$2 : <span class=\"red\">$1 pts</span></p>" >> "$scoringNegatives"
	echo $newScore > "$totalScore"
}' >> "engine.sh"

echo "
####### Init Vars #######

scoringReport=\"/home/"$sysUser"/Desktop/Score Report.html\"
scoringNegatives=\"/opt/Scoring-Engine/penalties\"
scoringPositives=\"/opt/Scoring-Engine/gainedVulns\"
totalScore=\"/opt/Scoring-Engine/totalScore\"

####### Run Script #######
init" >> "engine.sh"

echo "Engine init done"
echo ""
echo "User Accounts"

#do you want to do user accounts?
#if yes, continue
#else skip

#do you make 

createVuln "deleteUser" 3 "eve"
