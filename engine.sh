#!/bin/bash
# If you have this VM as an assesment leave NOW!!!
# Looking through this file is a violation of integrety, 
# and I WILL find out!!! 


####### init functions #######
init () {

	cp /opt/Scoring-Engine/README /home/user/Desktop/README


	touch "$scoringReport"
	touch "$totalScore"
	touch "$scoringNegatives"
	touch "$scoringPositives"
	touch "$fixedVulns"
	touch "$lastScore"

	score=$(cat "$totalScore")
	score="${score} Points Earned out of ${totalPoints}"
	numberVulns=$(cat "$fixedVulns")

	penalties=$(cat "$scoringNegatives" )
	vulns=$(cat "$scoringPositives" )
	
	cat "/opt/Scoring-Engine/head" > "$scoringReport"
	echo 	"<h1>This is the scoring report for the assesment for the St. Augustine Composite Squadron Cyber Education Program.</h1>" >> "$scoringReport"

	echo	"<br />" >> "$scoringReport"

	echo	"<h2> Updated at $(date) </h2>" >> "$scoringReport"
	echo	"<h2> $score </h2>" >> "$scoringReport"
	
	echo	"<h3> Penalties: </h3>" >> "$scoringReport"

	echo	"$penalties" >> "$scoringReport"

	echo	"<h3> Fixed Vulnerabilities: </h3>" >> "$scoringReport"
	echo	"<h3> $numberVulns fixed out of $totalVulns </h3>" >> "$scoringReport"

	echo	"$vulns" >> "$scoringReport"
	echo 	"</body></html>" >> "$scoringReport"
	echo "" > "$scoringPositives"
	echo "" > "$scoringNegatives"
	echo "$(cat "$totalScore")" > "$lastScore"
	echo "" > "$totalScore"
	echo "" > "$fixedVulns"
}
scorePoints () {
	#$1 Points
	#$2 Message
	score=$(cat $totalScore)
	newScore=$(($score + $1))
	echo "<p class=\"vulns\">$2 : <span class=\"green\">$1 pts</span></p>" >> "$scoringPositives"
	echo $newScore > "$totalScore"
	fixed=$(cat $fixedVulns)
	newFixed=$(($fixed + 1))
	echo "$newFixed" > $fixedVulns
}

removePoints () {
	#$1 Points
	#$2 Message
	score=$(cat "$totalScore")
	newScore=$(($score - $1))
	echo "<p class=\"penalties\">$2 : <span class=\"red\">$1 pts</span></p>" >> "$scoringNegatives"
	echo $newScore > "$totalScore"
}
sendGainedPoints(){
	notify-send -u critical -i "/opt/Scoring-Engine/gained.png" "Scoring Engine" "You Gained Points"
	aplay "/opt/Scoring-Engine/gained.wav"
}
sendLostPoints(){
	notify-send -u critical -i "/opt/Scoring-Engine/lost.png" "Scoring Engine" "You Lost Points"
	aplay "/opt/Scoring-Engine/lost.wav"
}


####### Init Vars #######

scoringReport="/home/user/Desktop/Score Report.html"
scoringNegatives="/opt/Scoring-Engine/penalties"
scoringPositives="/opt/Scoring-Engine/gainedVulns"
totalScore="/opt/Scoring-Engine/totalScore"
lastScore="/opt/Scoring-Engine/lastScore"
fixedVulns="/opt/Scoring-Engine/fixedVulns"

totalVulns=1
totalPoints=8

####### Run Script #######
init


if [ "$(grep "ANSWER: 0" "/home/user/Desktop/Forensics Question 1")" != "" ]; then
	scorePoints "8" "Solved Forensics Question 1"
fi 

if [[ "$(cat $totalScore)" = "" ]]; then
	echo 0 > "$totalScore"
fi

if [[ "$(cat $fixedVulns)" = "" ]]; then
	echo 0 > "$fixedVulns"
fi

if [[ "$( cat "$totalScore")" -gt "$(cat "$lastScore")" ]]; then
	sendGainedPoints
elif [[ "$( cat "$totalScore")" -lt "$(cat "$lastScore")" ]]; then
	sendLostPoints
fi

