#!/bin/bash
# If you have this VM as an assesment leave NOW!!!
# Looking through this file is a violation of integrety, 
# and I WILL find out!!! 


####### init functions #######
init () {
	touch "$scoringReport"
	touch "$totalScore"
	touch "$scoringNegatives"
	touch "$scoringPositives"
	echo "This is the scoring report for the assesment for the St. Augustine Composite Squadron Cyber Education Program." > "$scoringReport"
	cat "$totalScore" >> "$scoringReport"
	cat "$scoringNegatives" >> "$scoringReport"
	cat "$scoringPositives" >> "$scoringReport"
	echo "" > $scoringPositives
	echo "" > $scoringNegatives
	echo "" > $totalScore
}

scorePoints () {
	#$1 Points
	#$2 Message
	score=$(cat $totalScore)
	newScore=$(($score + $1))
	echo "$2 : $1 pts" >> "$scoringPositives"
	echo $newScore > $totalScore
}

removePoints () {
	#$1 Points
	#$2 Message
	score=$(cat $totalScore)
	newScore=$(($score - $1))
	echo "$2 : $1 pts" >> "$scoringNegatives"
	echo $newScore > $totalScore
}

####### Init Vars #######

scoringReport="/home/user/Desktop/Score Report"
scoringNegatives="/opt/Scoring-Engine/penalties"
scoringPositives="/opt/Scoring-Engine/gainedVulns"
totalScore="/opt/Scoring-Engine/totalScore"

####### Run Script #######

init

if [ $(cat "/etc/lightdm/lightdm.conf" | grep "allow-guest = false") -e ""]; then
	echo ""
else
	scorePoints 3 "Disable Guest Account"
fi

