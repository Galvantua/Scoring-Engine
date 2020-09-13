#!/usr/bin/env bash
# checklist:
# zenity --list --column "column1" --column "column2" FALSE row1 FALSE row2 --checklist

#text entry:
# zenity --entry --text"Question"

###### Init Functions ######
promptText() {
	message="$1"
	if [ "$2" = "" ]; then
	title="Scoring Engine :"
	else
	title="$2"
	fi
	userResponse=$(zenity --entry --title="$title" --text="$message" 2> >(grep -v 'GtkDialog' >&2))
}
promptYN() {
	message="$1"
	if [ "$2" = "" ]; then
	title="Scoring Engine :"
	else
	title="$2"
	fi
	zenity --question --title="$title" --text="$message" 2> >(grep -v 'GtkDialog' >&2)
	if [ $? = 0 ]; then
		userResponse="Y"
	elif [ $? = 1 ]; then
		userResponse="N"
	fi
}

createVuln() {
	type="$1"
	points=$2
	var1="$3"
	var2="$4"
	var3="$5"
	var4="$6"
	var5="$7"
	message="$("$type" "message" "$points" "" "$var1" "$var2" "$var3" "$var4" "$var5")"
	$type "test" "$points" "$message" "$var1" "$var2" "$var3" "$var4" "$var5"
	
	#vuln="
#if [ ${test} ]; then
#	scorePoints \"$points\" \"$message\"
#fi "
#	echo "$vuln" >> vulns
	totalvulns=$(($totalvulns + 1))
	totalpoints=$(($totalpoints + $points))
}

vulnMakerUI () {
	promptMessage="$1"
	command="$2"
	option1="$3"
	option2="$4"
	option3="$5"
	while true; do
		promptYN "$promptMessage" 
		case "$userResponse" in
			[Yy]*)
				echo "Selected Yes, continuing...";
				sleep 1;
			
				if [ "$option1" != "" ]; then
					promptText "$option1";
					input1="$userResponse"
				fi
			
				if [ "$option2" != "" ]; then
					promptText "$option2";
					input2="$userResponse"
				fi

				if [ "$option3" != "" ]; then
					promptText "$option3";
					input3="$userResponse"
				fi

				promptText "How many points is this worth?"
				points=$userResponse
				echo "Adding vuln to engine...";
				createVuln "$command" "$points" "$input1" "$input2" "$input3";
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
	points=$2
	message"$3"
	lineToCheck="$4"
	fileToCheck="$5"
	messageToPrint="$6"

	if [ "$outputType" = "test" ]; then
		echo "\"\$(grep ${lineToCheck} ${fileToCheck})\" != \"\""
		jq ".filesToCheckPositive[.filesToCheckPositive| length] |=.+ {\"lineToCheck\": \"$answer\", \"fileToCheck\": \"/home/$sysUser/Desktop/$fileName\", \"points\": $points, \"message\": \"$message\"}" ./config.json | sponge ./config.json
	elif [ "$outputType" = "message" ]; then
		echo "$messageToPrint"
	fi
}

createForensics() {
	outputType="$1"
	points="$2"
	message="$3"
	question="$4"
	answer="$5"
	fileName="$6"
	if [ "$outputType" = "test" ]; then
		touch "$fileName"
		echo "Forensics Question:" > "$fileName"
		echo "$question" >> "$fileName"
		echo "" >> "$fileName"
		echo "ANSWER: " >> "$fileName"
		chown "$sysUser":"$sysUser" "$fileName"
		mv "$fileName" "/home/${sysUser}/Desktop/"
		jq ".filesToCheckPositive[.filesToCheckPositive| length] |=.+ {\"lineToCheck\": \"$answer\", \"fileToCheck\": \"/home/$sysUser/Desktop/$fileName\", \"points\": $points, \"message\": \"$message\"}" ./config.json | sponge ./config.json
		# echo "\"\$(grep \"ANSWER: $answer\" \"/home/$sysUser/Desktop/$fileName\")\" != \"\""
	elif [ "$outputType" = "message" ]; then
		echo "Solved ${fileName}"
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
clear
echo "Welcome to the init script for the St Augustine Composite Squadron Scoring Engine. Would you like to continue?" #replace with gui

promptText "What is the System admin user?"
sysUser="$userResponse"

if [ "$(grep 'bash /opt/Scoring-Engine/engine.sh' /etc/crontab)" = "" ]; then
	echo "DISPLAY=:0.0" >> /etc/crontab
	echo "XAUTHORITY=/home/${sysUser}/.Xauthority" >> /etc/crontab
	echo "* *     * * *   root    bash /opt/Scoring-Engine/engine.sh" >> /etc/crontab
fi
touch /etc/lightdm/lightdm.conf
echo "[Seat:*]
autologin-user=${sysUser}" > /etc/lightdm/lightdm.conf


#### Forensics Questions
#test if user wants to add forensics questions

while true; do
	promptYN "Do you want to include Forensics Questions?" 
	case "$userResponse" in
		[Yy]*)
			echo "Selected Yes, continuing";
			userResponse="Y"
			break;;
		[Nn]*)
			echo "Selected no, skipping...";
			userResponse="N";
			break;;
		*)
			echo "Yes or No, please";;
	esac
done

if [ "$userResponse" == "Y" ]; then
	vulnMakerUI "Would you like to add a Forensics Question?" "createForensics" "What question should be answered?" "What is the answer to the question?" "What should the file be named? (We reccomend \"Forensics_Question_number\")"
fi

##### User accounts
#test if user wants to do the user accts section

while true; do
	promptYN "do you want to include user accounts?"
	case "$userResponse" in
		[Yy]*)
			echo "Selected Yes, continuing";
			userResponse="Y"
			break;;
		[Nn]*)
			echo "Selected no, skipping...";
			userResponse="N";
			break;;
		*)
			echo "Yes or No, please";;
	esac
done

#go though each vuln cat in user accts to add vulns or skip sections
if [ "$userResponse" == "Y" ]; then

	vulnMakerUI "Are there users that need to be deleted?" "deleteUser" "What user to delete?"

	vulnMakerUI "Are there users that need to be added?" "addUser" "What user to add?"

	vulnMakerUI "Are there users whose passwords need to be changed?" "changePasswd" "What user to change password?"

	vulnMakerUI "Are there groups that need to be removed?" "delGrp" "What group?"

	vulnMakerUI "Are there groups that need to be added?" "addGrp" "What group?"

	vulnMakerUI "Are there users who need to be removed from a group (this includes sudo)?" "delFromGrp" "What user to delete from group?" "What group?"

	vulnMakerUI "Are there users who need to be added to a group (this includes sudo)?" "addToGrp" "What user to add to group?" "What group?"

	while true; do
		promptYN "Do you want to disable Guest Acct?"
		case "$userResponse" in
			[Yy]*)
				echo "Selected Yes, continuing...";
				sleep 1;
				promptText "How many points is this worth?" points;
				points=$userResponse
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

jq ".totalPoints |= $totalpoints" ./config.json | sponge ./config.json
jq ".totalVulns |= $totalvulns" ./config.json | sponge ./config.json
