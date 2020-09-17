#!/bin/bash

#potential User Accounts UI

users=($(getent passwd {1000..60000} | cut -d: -f1))

# put into json for future reference and possible for README

authorizedUsers=($(tr "|" " " <<< $(zenity --list --title="User Accounts :" --text="Check All Authorized Users" --column "auth?" --column "users" ${users[@]/#/"FALSE "} --checklist 2> >(grep -v 'GtkDialog' >&2))))

# now we have a list of authorized users for json
echo "authorized : ${authorizedUsers[@]}"

usersToRemove=($(echo ${users[@]} ${authorizedUsers[@]} | tr ' ' '\n' | sort | uniq -u))

# now we have a list of unauthorized users to score deletion points for and also for json
echo "unauthorized : ${usersToRemove[@]}"
#you could probably add a general "points for deleting unauthorized user?" prompt here

passwordsToChange=($(tr "|" " " <<< $(zenity --list --title="User Accounts :" --text="Check All Users With Insecure Passwords" --column "passwd?" --column "users" ${authorizedUsers[@]/#/"FALSE "} --checklist 2> >(grep -v 'GtkDialog' >&2))))

#insert "users to add prompt?"
usersToAdd=(joe)

authorizedAdmins=($(tr "|" " " <<< $(zenity --list --title="User Accounts :" --text="Check All Authorized Admins" --column "admin?" --column "users" ${authorizedUsers[@]/#/"FALSE "} ${usersToAdd[@]/#/"FALSE "} --checklist 2> >(grep -v 'GtkDialog' >&2))))
#You can save the authorizedAdmins for README reference

#This is mainly for script reference
currentAdmins=($(getent group sudo | cut -d: -f4 | tr "," " "))

adminsToRemove=""
for ADMIN in "${currentAdmins[@]}"
do
	if [[ " ${authorizedAdmins[*]} " != *" $ADMIN "* ]] ; then
	adminsToRemove+="$ADMIN"
	fi
done

#unauthorized admins
echo "unauthorized admins : ${adminsToRemove[@]}"

adminsToAdd=""
for ADMIN in "${authorizedAdmins[@]}"
do
	if [[ " ${currentAdmins[*]} " != *" $ADMIN "* ]] ; then
	adminsToAdd+="$ADMIN"
	fi
done

# admins to add
echo "missing admins : ${adminsToAdd[@]}"
