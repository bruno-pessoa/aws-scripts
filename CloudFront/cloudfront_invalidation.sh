#!/usr/bin/env bash

#---------------------------------------------TESTS--------------------------------------------------------#
[ ! -x "$(which aws)" ] && echo "aws cli is a requirement to run this program. Please install it" && exit 0
[ ! -x "$(which jq)" ] && echo "jq is a requirement to run this program. Please install it" && exit 0 
#----------------------------------------------------------------------------------------------------------#
#------------------------------------------- VARIABLES ----------------------------------------------------#
help="
  $(basename $0) - [OPTIONS]

  	-h Help
  	-l Lists all distribution info 
  	-i Invalidate Distribution
  		$(basename $0) -i <distroid> '<paths>' - The paths must be quoted and separated by commas.
"
Distro_id="$2"
Path="$3"
#----------------------------------------------------------------------------------------------------------#
#----------------------------------------- FUNCTIONS ------------------------------------------------------#
List_distros (){
	echo "
	Gathering info from all Distributions. This might take a few moments...
	"
	Distro_ids=$(aws cloudfront list-distributions | jq -r '.DistributionList .Items[] .Id')

	ARRAY+=($Distro_ids)

	local counter=0
	while [[ $counter -lt ${#ARRAY[@]} ]]; do
		id=${ARRAY[$counter]}
		domain=$(aws cloudfront get-distribution \
		--id ${ARRAY[$counter]} \
		| jq -r '.Distribution .DomainName')
		cname=$(aws cloudfront get-distribution  \
		--id ${ARRAY[$counter]} \
		| jq -r -e '.Distribution .DistributionConfig .Aliases .Items[]' 2> /dev/null \
		| tr '\n' ',')
		origin=$(aws cloudfront get-distribution \
		--id ${ARRAY[$counter]} \
		| jq -r '.Distribution .DistributionConfig .Origins .Items[] .Id' 2> /dev/null \
		| tr '\n' ',')
		
		echo "
		------------------------------------
		Distribution ID     : $id
		Distribution Domain : $domain
		Distribution CNAMES : $cname
		Distribution Origins: $origin
		------------------------------------
		"
		counter=$(($counter+1))
	done
}

Invalidate (){
	invalidationid=$(aws cloudfront create-invalidation \
	--distribution-id $Distro_id --paths $Path \
	| jq -r '.Invalidation .Id')
	printf "\nInvalidation Initiated\n"
	Get_status
}

Get_status (){
	invalidationstatus=$(aws cloudfront get-invalidation \
	--id $invalidationid \
	--distribution-id $Distro_id \
	| jq -r '.Invalidation .Status')
}

Check_status (){

	while [ $invalidationstatus != "Completed" ]; do
	  Get_status
	  echo " "
	  echo "$invalidationstatus ..."
	  echo " "
	  [ $invalidationstatus != "Completed" ] && sleep 10
	done

	if [ $invalidationstatus == "Completed" ]; then
	  echo "Invalidation on path $Path for the $Distro_id distribution is completed"
	else
	  echo "Something is wrong!"
	fi
}
#-------------------------------------------------------------------------------------------------------#
#---------------------------------------- EXECUTION ----------------------------------------------------#
case "$1" in
	-h) echo "$help" && exit 0                            ;;
	-l) List_distros                                      ;;
	-i) Invalidate && Check_status                        ;;
     *) echo "Invalid Option. Type -h for help" && exit 1 ;;
esac
#------------------------------------------------------------------------------------------------------#