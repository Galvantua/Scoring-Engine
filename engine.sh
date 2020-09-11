#!/bin/bash
# If you have this VM as an assesment leave NOW!!!
# Looking through this file is a violation of integrety, 
# and I WILL find out!!! 


####### init functions #######
init () {

	cp /opt/Scoring-Engine/README /home/user/Desktop/README

	touch "$scoringReport"

	score="${totalScore} Points Earned out of ${totalPoints}"
	numberVulns="$fixedVulns"

	penalties="$scoringNegatives"
	vulns="$scoringPositives"
	
	cat "/opt/Scoring-Engine/head" > "$scoringReport"
	echo 	"<h1>This is the scoring report for the assesment for the St. Augustine Composite Squadron Cyber Education Program.</h1>" >> "$scoringReport"

	echo	"<br />" >> "$scoringReport"

	echo	"<h2> Updated at $(date) </h2>" >> "$scoringReport"
	echo	"<h2> $score </h2>" >> "$scoringReport"
	
	echo	"<h3> Penalties: </h3>" >> "$scoringReport"

	echo "$penalties" | while read penalty; do
		message="$(echo $penalty | jq ".message")"
		points=$(echo $penalty | jq ".points")
		echo "<p class=\"penalties\">$message : <span class=\"red\">$points pts</span></p>" >> "$scoringReport"
	done

	echo	"<h3> Fixed Vulnerabilities: </h3>" >> "$scoringReport"
	echo	"<h3> $numberVulns fixed out of $totalVulns </h3>" >> "$scoringReport"
	echo "$vulns" | while read vuln; do
		message="$(echo $vuln | jq ".message")"
		points=$(echo $vuln | jq ".points")
		echo "<p class=\"vulns\">$message : <span class=\"green\">$points pts</span></p>" >> "$scoringReport"
	done

	echo 	"</body></html>" >> "$scoringReport"

	jq '.scoredVulnMessages |= []' "$config" | sponge "$config"
	jq '.scoredPenaltyMessages |= []' "$config" | sponge "$config"
	
	jq --arg points $totalScore '.lastPoints |= $points' "$config" | sponge "$config"
	jq '.currentPoints |= 0' "$config" | sponge "$config"
	jq '.currentVulns |= 0' "$config" | sponge "$config"
}

scorePoints () {
	points=$1
	message="$2"
	score=$totalScore
	newScore=$(($score + $points))
	jq ".scoredVulnMessages[.scoredVulnMessages| length] |=.+ {\"message\": \"$message\", \"points\": $points}" "$config" | sponge "$config"
	totalScore=$newScore
	fixed=$fixedVulns
	newFixed=$(($fixed + 1))
	fixedVulns=$newFixed
}
removePoints () {
	points=$1
	message="$2"
	score=$totalScore
	newScore=$(($score - $points))
	jq ".scoredPenaltyMessages[.scoredPenaltyMessages| length] |=.+ {\"message\": $message, \"points\": $points}" "$config" | sponge "$config"
	totalScore=$newScore
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
config="/opt/Scoring-Engine/config.json"
systemUser="$(jq -r ".systemUser" $config)"
scoringReport="/home/$systemUser/Desktop/Score Report.html"
scoringNegatives="$(jq -c ".scoredPenaltyMessages[]" $config)"
scoringPositives="$(jq -c ".scoredVulnMessages[]" $config)"
totalScore=$(jq -r ".currentPoints" $config)
lastScore=$(jq -r ".lastPoints" $config)
fixedVulns=$(jq -r ".currentVulns" $config)
totalVulns=$(jq -r ".totalVulns" $config)
totalPoints=$(jq -r ".totalPoints" $config)

####### Run Script #######
init

jq -c ".filesToCheckPositive[]" "$config" | while read vuln; do
	lineToCheck=$(echo "$vuln" | jq -r ".lineToCheck")
	fileToCheck=$(echo "$vuln" | jq -r ".fileToCheck")
	message=$(echo "$vuln" | jq -r ".message")
	points=$(echo "$vuln" | jq -r ".points")

	if [ "$(grep "$lineToCheck" "$fileToCheck")" != "" ]; then
		scorePoints $points "$message"
	fi
done

if [ -z $totalScore ]; then
	totalScore=0
fi

if [ -z $fixedVulns ]; then
	fixedVulns=0
fi

if [[ $totalScore -gt $lastScore ]]; then
	sendGainedPoints
elif [[ $totalScore -lt $lastScore ]]; then
	sendLostPoints
fi

jq ".currentPoints |= $totalScore" ./config.json | sponge ./config.json
jq ".currentVulns |= $fixedVulns" ./config.json | sponge ./config.json