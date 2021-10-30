#! /bin/bash
#==================Functions==================================================================
function BackupFolder2Zip {
local sourceFolder=""

tput setaf $inputcolor
echo "BACKUP FOLDER:"
tput sgr 0
while [[ ! -d $sourceFolder ]] &&  [[ ! $sourceFolder = e ]]
do
	echo -ne "Input existed folder to backup. Or \"e\" to back to menu: "
	tput setaf $inputcolor
	read -e sourceFolder GF_DIR
	tput sgr 0
	echo ""
done

if [[ $sourceFolder == e ]]
then
	clear
	return 0
fi

echo -ne "Input folder to save zip file. Or \"e\" to back to menu: "
tput setaf $inputcolor
if [[ -d $destinationFolder ]]
then
	echo -ne "\n[$destinationFolder - just Enter to use]"
fi
read -e tmp GF_DIR
if [[ ${#tmp} -gt 0 ]]
then
	destinationFolder=$tmp
fi
tput sgr 0
echo ""

while [[ ! -d $destinationFolder ]] && [[ ! $destinationFolder = e ]]
do
	echo -ne "Destination folder $(tput setaf $inputcolor)$destinationFolder$(tput sgr 0) is not existed. Do you want to create now? (y/n) "
	read -n 1 coi
	echo ""
	if [[ $coi = y ]]
	then
		sudo mkdir -p $destinationFolder
		if [[ $? -eq 0 ]]
		then
			echo "$(tput setaf $inputcolor)$destinationFolder$(tput sgr 0) has been create.!"
		else
			echo "Fail when create folder. Error: $?"
		fi
	else
		echo -ne "Input existed folder to save the zip file. Or type \"e\" to menu:"
		tput setaf $inputcolor
		read -e destinationFolder GF_DIR
		tput sgr 0
	fi
done

if [[ $destinationFolder = e ]]
then
	clear
	return 0

fi

tput setaf $runningcolor
local filename="$(basename $sourceFolder)_$(date +%Y.%m.%d_%H.%M.%S).zip"
sudo zip -r "$destinationFolder/$filename" "$sourceFolder"
tput sgr 0

if [[ $? -eq 0 ]]
then
	echo "-------------------------------------------------------------------------"
	echo "Backup $(tput setaf $inputcolor)$sourceFolder$(tput sgr 0) done!"
	echo "The zip file: $(tput setaf $inputcolor)$filename$(tput sgr 0)"
	echo "Save to folder:$(tput setaf $inputcolor)$destinationFolder$(tput sgr 0)"
	echo "Contents in folder:"
	ls -lh $destinationFolder
	echo "-------------------------------------------------------------------------"
	return 9999
else
	echo "-------------------------------------------------------------------------"
	tput setaf 1
	echo "Backup fail!"
	tput sgr 0
	echo "-------------------------------------------------------------------------"
	return 1
fi

}

#---------------------------------------------------------------------------
function BackupMariaDB {
local databaseName=""
local user=""


while [[ $databaseName = "" ]]
do
	echo -n "Input name of existed database: "
	tput setaf $inputcolor
	read -e databaseName GF_DIR
	tput sgr 0
done


while [[ $user == "" ]]
do
	echo -n "User: "
	tput setaf $inputcolor
	read user
	tput sgr 0
done

echo -ne "Input folder to save sql file, Or type e to back to menu: "
tput setaf $inputcolor
if [[ -d $destinationFolder ]]
then
	echo -ne "\n[$destinationFolder - just Enter to use]"
fi
read -e tmp GF_DIR

if [[ ${#tmp} -gt 0 ]]
then
	destinationFolder=$tmp
fi
tput sgr 0
echo ""

while [[ ! -d $destinationFolder && ! $destinationFolder = e ]]
do
	echo -ne "Destination folder $(tput setaf 1)$destinationFolder$(tput sgr 0) is not existed. Do you want to create now? (y/n) "
	read -n 1 coi
	echo ""
	if [[ $coi == y ]]
	then
		sudo mkdir -p $destinationFolder

		if [[ $? -eq 0 ]]
		then
			echo "$(tput setaf $inputcolor)$destinationFolder$(tput sgr 0) has been create.!"

		else
			echo "Fail when create folder. Error: $?"
		fi
	else
		echo -ne "Input existed folder to save sql backup. Or type \"e\" to menu:"
		tput setaf $inputcolor 
		read -e destinationFolder GF_DIR
		tpur sgr 0
	fi
done

if [[ $destinationFolder = e ]]
then
	return 0
fi

sudo chown $USER:$USER $destinationFolder
tput setaf $runningcolor
local filename="$(basename $databaseName)_$(date +%Y.%m.%d_%H.%M.%S).sql"
sudo mysqldump -u "$user" -p "$databaseName" > "$destinationFolder/$filename"
tput sgr 0

if [[ $? -eq 0 ]]
then
	echo "---------------------------------------------------------------------------"	
	echo "Backup $(tput setaf $inputcolor)$databaseName$(tput sgr 0) successful"
	echo "The sql file: $(tput setaf $inputcolor)$filename$(tput sgr 0)"
	echo "Save to folder: $(tput setaf $inputcolor)$destinationFolder$(tput sgr 0)"
	echo "Contents in folder:"
	ls -lh $destinationFolder
	echo "---------------------------------------------------------------------------"
	return 9999	
else
	echo "-------------------------------------------------------------------------"
	tput setaf 1
	echo "Backup fail!"

	echo "-------------------------------------------------------------------------"
	tput sgr 0
	return 1
fi
  
}

#---------------------------------------------------------------------------------------------
function ShowMenu {
local argsCount=$#
local count=1
declare -a args[$argsCount]

echo "-------------------------------------------------------------------------"
for item in "$@"
do
	echo "[$(tput setaf $inputcolor)$count$(tput sgr 0)] $item"
	args[$[count-1]]=$item
	count=$[count+1]
done


echo "[$(tput setaf $inputcolor)e$(tput sgr 0)] Exit menu"
echo "[$(tput setaf $inputcolor)f$(tput sgr 0)] Finish this program!!!"

echo "Select: "
echo "-------------------------------------------------------------------------"
tput cuu 2 
tput cuf 8
tput setaf $inputcolor
read -n 1 s
#tput cud 1 

if [[ $s =~ $regI ]]
then
	if [[ $s -ge  1 ]] && [[ $s -le $argsCount ]]
	then
		local ind=$[s-1]
		echo -e " - ${args[$ind]}\n"
		tput sgr 0
		return $s
	else
		echo -e "\n"
		tput sgr 0
		return 9998
	fi
elif [[ $s = e ]]
then
	echo -e " - Exit to parent menu (loop if this is main menu)\n"
	tput sgr 0
	sleep 0.5
	return 0
elif [[ $s = f ]]
then
	echo -e " - Quit program\n"
	tput sgr 0
	sleep 0.5
	exit
else
	echo -e " - What the f**k has been input!\n"
	tput sgr 0
	sleep 0.5
	return 9998

fi
}
#Finish functions -> main code ======================================================================
#Simple backup tool

inputcolor=2
runningcolor=3
regI='^[0-9]?$' #regular integer check
selected=""
destinationFolder=""
result=-1
#just note result:
#   -1: ????
#    0: just exit function, do nothing
#    1: fail
# 9998: out of range
# 9999: success

echo "$(tput setaf $inputcolor)$(date +%F): Hello $USER. Welcome to simple backup tool$(tput sgr 0)"
clear
menuItems=("Backup folder" "Backup MySQL/MariaDB database")
while [[ 0 ]]
do
	echo -e "$(tput setaf $inputcolor)Input [*] to select:$(tput sgr 0)"
	tput sgr 0

	ShowMenu "${menuItems[0]}" "${menuItems[1]}"
	selected=$?

	if [[ $selected -ge 1 ]] && [[ $selected -le ${#menuItems[@]} ]]
	then
		echo -n "Going to ${menuItems[$selected-1]}..."
		for i in {3..1..-1}
		do
			sleep 0.4 
			tput cub 1
			tput ech 1
		done

		case $selected in
			1)
				clear
				BackupFolder2Zip
				result=$?
			       	;;
			2)
				clear
				BackupMariaDB 
				result=$?
				;;
		esac
	else
		clear
	fi
done
