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

	score=$(cat "$totalScore")
	score="${score} Points Earned"
	
	penalties=$(cat "$scoringNegatives" )
	vulns=$(cat "$scoringPositives" )
	
	echo 	"<!DOCTYPE html>
			<html lang=\"en\">
				<head>
    				<meta charset=\"UTF-8\">
    				<meta name=\"viewport\" content=\"width=device-width, initial-scale=1.0\">
    				<title>Scoring Report</title>
				</head>
				<body>" > "$scoringReport"
	echo 	"		<h1>This is the scoring report for the assesment for the St. Augustine Composite Squadron Cyber Education Program.</h1>" >> "$scoringReport"

	echo	"		<h2> $score </h2>" >> "$scoringReport"
	
	echo	"		<h3> Penalties: </h3>" >> "$scoringReport"

	echo	"		$penalties" >> "$scoringReport"

	echo	"		<h3> Fixed Vulnerabilities: </h3>" >> "$scoringReport"

	echo	"		$vulns" >> "$scoringReport"
	echo 	"	</body>
			</html>" >> "$scoringReport"
	echo "" > $scoringPositives
	echo "" > $scoringNegatives
}

scorePoints () {
	#$1 Points
	#$2 Message
	score=$(cat $totalScore)
	newScore=$(($score + $1))
	echo "<p class=\"vulns\">$2 : $1 pts</p>" >> "$scoringPositives"
	echo $newScore > $totalScore
}

removePoints () {
	#$1 Points
	#$2 Message
	score=$(cat $totalScore)
	newScore=$(($score - $1))
	echo "<p class=\"penalties\">$2 : $1 pts</p>" >> "$scoringNegatives"
	echo $newScore > $totalScore
}

####### Init Vars #######

scoringReport="/home/user/Desktop/Score Report.html"
scoringNegatives="/opt/Scoring-Engine/penalties"
scoringPositives="/opt/Scoring-Engine/gainedVulns"
totalScore="/opt/Scoring-Engine/totalScore"

####### Run Script #######

init

if [[ "$(cat "/etc/lightdm/lightdm.conf" | grep "allow-guest = false")" = ""]]; then
	echo ""
else
	scorePoints 3 "Disable Guest Account"
fi


if [ -s "$totalScore" ]; then
	echo 0 > "$totalScore"
else
	echo ""
fi


