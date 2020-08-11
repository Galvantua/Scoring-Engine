#!/usr/bin/env bash

###### Init Functions ######
prompt() {
	message="$1"
	outputVar="$2"
	echo "$message"
	echo -n "  : "
	read -rp "" $outputVar
	echo ""
}

createVuln() {
	type="$1"
	points=$2
	var1="$3"
	var2="$4"
	var3="$5"
	var4="$6"
	var5="$7"
	test=$($type "test" $var1 $var2 $var3 $var4 $var5)
	message=$($type "message" $var1 $var2 $var3 $var4 $var5)
	echo " 
if [ ${test} ]; then
	scorePoints \"$points\" \"$message\"
fi 
" >> vulns
	totalvulns=$(($totalvulns + 1))
	totalpoints=$(($totalpoints + $points))
}

vulnMakerUI () {
promptMessage="$1"
command="$2"
option1="$3"
option2="$4"
	while true; do
				prompt "$promptMessage" userResponse
				case "$userResponse" in
						[Yy]*)
								echo "Selected Yes, continuing...";
								sleep 1;
				if [ "$option1" != "" ]; then
				prompt "$option1" input1;
				fi
				if [ "$option2" != "" ]; then
				prompt "$option2" input2;
				fi
								prompt "How many points is this worth?" points
								echo "Adding vuln to engine...";
								createVuln "$command" "$points" "$input1" "$input2";
								sleep 1s;;
						[Nn]*)
								echo "Selected no, skipping...";
								sleep 1s;
								break;;
						*)
								echo "Yes or No, please";
								sleep 1s;;
				esac
		done

}

chkFileNegative() {
	outputType="$1"
	lineToCheck="$2"
	fileToCheck="$3"
	message="$4"
	if [ "$outputType" = "test" ]; then
		echo "\"\$(grep ${lineToCheck} ${fileToCheck})\" = \"\""
	elif [ "$outputType" = "message" ]; then
		echo "$message"
	fi
}

chkFilePositive() {
	outputType="$1"
	lineToCheck="$2"
	fileToCheck="$3"
	message="$4"
	if [ "$outputType" = "test" ]; then
		echo "\"\$(grep ${lineToCheck} ${fileToCheck})\" != \"\""
	elif [ "$outputType" = "message" ]; then
		echo "$message"
	fi
}

# User Accts #
deleteUser() {
	outputType="$1"
	user="$2"
	if [ "$outputType" = "test" ]; then
		echo "\"\$(getent passwd $user)\" = \"\""
	elif [ "$outputType" = "message" ]; then
		echo "Deleted User $user"
	fi
	
}

addUser() {
	outputType="$1"
	user="$2"
	if [ "$outputType" = "test" ]; then
		echo "\"\$(getent passwd $user)\" != \"\""
	elif [ "$outputType" = "message" ]; then
		echo "Added User $user"
	fi
	
}

changePasswd() {
	outputType="$1"
	user="$2"
	if [ "$outputType" = "test" ]; then
		currentDay=$(expr $(date +%s) / 86400)
		echo "\"\$(getent shadow $user | cut -d: -f3)\" -gt $currentDay"
	elif [ "$outputType" = "message" ]; then
		echo "Changed Password $user"
	fi
	
}

addGrp() {
	outputType="$1"
	group="$2"
	if [ "$outputType" = "test" ]; then
		echo "\"\$(getent group ${group} )\" != \"\""
	elif [ "$outputType" = "message" ]; then
		echo "Added group $group"
	fi
}

delGrp() {
	outputType="$1"
	group="$2"
	if [ "$outputType" = "test" ]; then
		echo "\"\$(getent group ${group} )\" = \"\""
	elif [ "$outputType" = "message" ]; then
		echo "Deleted group $group"
	fi
}

delFromGrp() {
	outputType="$1"
	user="$2"
	group="$3"
	if [ "$outputType" = "test" ]; then
		echo "\"\$(getent group ${group} | grep ${user})\" = \"\""
	elif [ "$outputType" = "message" ]; then
		echo "Deleted $user from group $group"
	fi
}

addToGrp() {
	outputType="$1"
	user="$2"
	group="$3"
	if [ "$outputType" = "test" ]; then
		echo "\"\$(getent group ${group} | grep ${user})\" != \"\""
	elif [ "$outputType" = "message" ]; then
		echo "Added $user to group $group"
	fi
}

###### Init Vars ######

totalvulns=0
totalpoints=0

###### Start Init ######
timedatectl set-timezone America/New_York
echo "* *     * * *   root    bash /opt/Scoring-Engine/engine.sh" >> /etc/crontab
clear
echo "Welcome to the init script for the St Augustine Composite Squadron Scoring Engine"
echo ""
echo "Creating engine..."
touch engine.sh
touch otherStuff
touch vulns
echo "" > vulns
echo ""
prompt "What is the System admin user?" sysUser
touch /etc/lightdm/lightdm.conf
echo "[Seat:*]
autologin-user=${sysUser}" > /etc/lightdm/lightdm.conf
echo '#!/bin/bash
# If you have this VM as an assesment leave NOW!!!
# Looking through this file is a violation of integrety, 
# and I WILL find out!!! 


####### init functions #######
init () {' > otherStuff
echo "
	cp /opt/Scoring-Engine/README /home/"${sysUser}"/Desktop/README
" >> otherStuff
echo '
	touch "$scoringReport"
	touch "$totalScore"
	touch "$scoringNegatives"
	touch "$scoringPositives"
	touch "$fixedVulns"

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
	echo "" > "$totalScore"
	echo "" > "$fixedVulns"
}' >> otherStuff


echo 'scorePoints () {
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
}' >> otherStuff



echo "Engine init done"
echo ""
echo "User Accounts"



##### User accounts
#test if user wants to do the user accts section

while true; do
	prompt "do you want to include user accounts?" UserAcctResponse
	case "$UserAcctResponse" in
		[Yy]*)
			echo "Selected Yes, continuing";
			UserAcctResponse="Y"
			break;;
		[Nn]*)
			echo "Selected no, skipping...";
			UserAcctResponse="N";
			break;;
		*)
			echo "Yes or No, please";;
	esac
done

#go though each vuln cat in user accts to add vulns or skip sections
if [ "$UserAcctResponse" == "Y" ]; then

	vulnMakerUI "Are there users that need to be deleted?" "deleteUser" "What user to delete?"

	vulnMakerUI "Are there users that need to be added?" "addUser" "What user to add?"

	vulnMakerUI "Are there users whose passwords need to be changed?" "changePasswd" "What user to change password?"

	vulnMakerUI "Are there groups that need to be removed?" "delGrp" "What group?"

	vulnMakerUI "Are there groups that need to be added?" "addGrp" "What group?"

	vulnMakerUI "Are there users who need to be removed from a group (this includes sudo)?" "delFromGrp" "What user to delete from group?" "What group?"

	vulnMakerUI "Are there users who need to be added to a group (this includes sudo)?" "addToGrp" "What user to add to group?" "What group?"

	while true; do
		prompt "Do you want to disable Guest Acct?" guestAcctResponse
		case "$guestAcctResponse" in
			[Yy]*)
				echo "Selected Yes, continuing...";
				sleep 1;
				prompt "How many points is this worth?" points;
				echo "Adding vuln to engine...";
				createVuln "chkFilePositive" $points "allow-guest=false" "/etc/lightdm/lightdm.conf" "Disabled Guest Account";
				sleep 1s;
				break;;
			[Nn]*)
				echo "Selected no, skipping...";
				sleep 1s;
				break;;
			*)
				echo "Yes or No, please";
				sleep 1s;;
		esac
	done
	
fi

echo "
####### Init Vars #######

scoringReport=\"/home/"${sysUser}"/Desktop/Score Report.html\"
scoringNegatives=\"/opt/Scoring-Engine/penalties\"
scoringPositives=\"/opt/Scoring-Engine/gainedVulns\"
totalScore=\"/opt/Scoring-Engine/totalScore\"
fixedVulns=\"/opt/Scoring-Engine/fixedVulns\"
totalVulns=${totalvulns}
totalPoints=${totalpoints}

####### Run Script #######
init" >> otherStuff


cat otherStuff > engine.sh

cat vulns >> engine.sh

echo '
if [[ "$(cat $totalScore)" = "" ]]; then
	echo 0 > "$totalScore"
fi

if [[ "$(cat $fixedVulns)" = "" ]]; then
	echo 0 > "$fixedVulns"
fi
' >> engine.sh

