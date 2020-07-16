#!/usr/bin/env bash
#---------------------------------------------TESTS--------------------------------------------------------#
[ ! -x "$(which aws)" ] && echo "aws cli is a requirement to run this program. Please install it" && exit 0
[ ! -x "$(which jq)"  ] && echo "jq is a requirement to run this program. Please install it" && exit 0 
#----------------------------------------------------------------------------------------------------------#
#------------------------------------------- VARIABLES ----------------------------------------------------#
help="
  $(basename $0) - [OPTIONS]

  	-h Help
  	-i Find IP value on Hoested Zones
  		$(basename $0) -i 1.1.1.1
  	-c Find CNAME value on Hosted Zones
  		$(basename $0) -c example.com
"
Arg="$2"
#----------------------------------------------------------------------------------------------------------#
#----------------------------------------- FUNCTIONS ------------------------------------------------------#
Query (){
	printf "\nGathering info from all Hosted Zones. This might take a few moments...\n"
	Hostedzones=$(aws route53 list-hosted-zones \
                 | jq -r '.HostedZones[] .Id' \
                 | sed 's%/hostedzone/%%')
    ARRAY+=($Hostedzones)
	printf "\nThe below records are pointing to $Arg\n"
	local counter=0
	while [[ $counter -lt ${#ARRAY[@]} ]]; do
		aws route53 list-resource-record-sets \
		--hosted-zone-id ${ARRAY[$counter]} \
		--query "ResourceRecordSets[?ResourceRecords[?Value == '$Arg'] && Type == '$1'].Name"
		counter=$(($counter+1))
	done
}
#-------------------------------------------------------------------------------------------------------#
#---------------------------------------- EXECUTION ----------------------------------------------------#
case "$1" in
	-h) echo "$help" && exit 0                            ;;
	-i) Query "A"                                         ;;
	-c) Query "CNAME"                                     ;;
     *) echo "Invalid Option. Type -h for help" && exit 1 ;;
esac
#------------------------------------------------------------------------------------------------------#