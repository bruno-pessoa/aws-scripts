#---------------------------------------------TESTS--------------------------------------------------------#
[ ! -x "$(which aws)" ] && echo "aws cli is a requirement to run this program. Please install it" && exit 0
[ ! -x "$(which jq)" ] && echo "jq is a requirement to run this program. Please install it" && exit 0 
#----------------------------------------------------------------------------------------------------------#
#------------------------------------------- VARIABLES ----------------------------------------------------#
printf "\nGathering info from all Hosted Zones. This might take a few moments...\n"
Hostedzones=$(aws route53 list-hosted-zones | jq '.HostedZones[] .Id' | sed 's/"//g;s%/hostedzone/%%')
ARRAY+=($Hostedzones)
#----------------------------------------------------------------------------------------------------------#
#----------------------------------------- FUNCTIONS ------------------------------------------------------#
Find_ip (){
	printf "Insert IP Address: "
	read ip
	local counter=0
	printf "\nThe below records are pointing to $ip\n"
	while [[ $counter -lt ${#ARRAY[@]} ]]; do
		aws route53 list-resource-record-sets \
		--hosted-zone-id ${ARRAY[$counter]} \
		--query "ResourceRecordSets[?ResourceRecords[?Value == '$ip'] && Type == 'A'].Name"
		counter=$(($counter+1))
	done
}

Find_cname (){
	printf "Insert CNAME: "
	read cname
	local counter=0
	printf "\nThe below records are pointing to $cname\n"
	while [[ $counter -lt ${#ARRAY[@]} ]]; do
		aws route53 list-resource-record-sets \
		--hosted-zone-id ${ARRAY[$counter]} \
		--query "ResourceRecordSets[?ResourceRecords[?Value == '$cname'] && Type == 'CNAME'].Name"
		counter=$(($counter+1))
	done
}
#-------------------------------------------------------------------------------------------------------#
#---------------------------------------- EXECUTION ----------------------------------------------------#
while :
do
  echo " "
  echo "Choose Option"

  echo "  1 - Find by IP"
  echo "  2 - Find by CNAME"
  echo "  3 - Exit"

  read -p "Option: " option

  case $option in
    1) Find_ip    ;;
    2) Find_cname ;;
	3) exit 0     ;;
  esac
  echo " "
done
#-------------------------------------------------------------------------------------------------------#