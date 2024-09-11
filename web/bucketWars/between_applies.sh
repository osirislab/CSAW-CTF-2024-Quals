#! /bin/bash
#
#############
# 1. Copy site files
# 2. Deploy with prompts
# 3. Multiple terraform applications 
#############

#GREEN='\033[0;32m'
#BLUE='\033[0;34m'
#
# High Intensity
NC='\033[0m' # No Color
RED='\033[0;91m'         # Red
GREEN='\033[0;92m'       # Green
YELLOW='\033[0;93m'      # Yellow
BLUE='\033[0;94m'        # Blue
PURPLE='\033[0;95m'      # Purple
CYAN='\033[0;96m'        # Cyan
WHITE='\033[0;97m'       # White


#bucket_one_name=#EXPORTED_IN_TERRAFROM.TFVARS
#bucket_two_name=#EXPORTED_IN_TERRAFORM.TFVARS

##################
# COPY SITE FILES
##################
echo -e "${YELLOW}[ Reseting all site files, including index_v1.html ] ${NC}" 
echo -e "${CYAN}=> cp -r site_files.bk site_files${NC}"
cp -r site_files.bk/. site_files

read -p "This script will deploy the 'bucketWars' '24 Quals challenge. Please read all prompts.  Press enter to continue..."


#####################################
# TERRAFORM INIT & APPLY 
#####################################
echo 
echo
echo -e "${YELLOW}[ Running terraform init ]${NC}"
echo -e "${CYAN}=> terraform init ${NC}" 
terraform init 
echo 
echo
echo -e "${YELLOW}[ Running terraform apply -var-file ]${NC}"
echo -e "${CYAN}=> terraform apply -var-file='terraform.tfvars'${NC}" 
terraform apply -var-file="terraform.tfvars"



#####################################
# DEPLOY ARTIFACTS -- TERRAFORM RUN 1
#####################################
echo 
echo
echo -e "${YELLOW}[ Running terraform plan ]${NC}"
echo -e "${CYAN}=> terraform plan${NC}" 
terraform plan

echo    
echo    
echo -e "${YELLOW}[ Continue with terraform apply? (Yy) ]${NC}"
read -p "" -n 1 -r
echo    
if [[ $REPLY =~ ^[Yy]$ ]]
then
	echo -e "${CYAN}=> terraform apply"
	terraform apply || true
else
	echo -e "${RED}Exiting then...${NC}"
	exit 1
fi


################################
# MAKE BUCKETS PUBLIC ON CONSOLE
################################
echo -e "${YELLOW}!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!${NC}"
echo -e "${GREEN}[ The 'Error putting S3 policy: AccessDenied: Access Denied' is expected]${NC}"
echo -e "${YELLOW}[ Please visit AWS S3 console and make these two buckets public ]${NC}"
echo -e "${YELLOW}!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!${NC}"
echo
echo -e "${RED} 	* ${bucket_one_name} *${NC}"
echo -e "${RED} 	* ${bucket_two_name} *${NC}"
echo    
echo -e "${YELLOW}[ Continue with terraform apply? (Yy) ]${NC}"
read -p "" -n 1 -r
echo    
if [[ $REPLY =~ ^[Yy]$ ]]
then
	echo -e "${CYAN}=> terraform apply${NC}"
	terraform apply || true
else
	echo -e "${RED}Exiting then...${NC}"
	exit 1
fi

echo -e "${YELLOW}Continue with terraform apply?${NC}"


###################
## MODIFY INDEX_V1
###################
echo -e "${GREEN}[ Modifying version of index_v1.html ]${NC}"
echo -e "${CYAN}cp site_deltas/index_v1_d1.html site_files/index_v1.html${NC}"
cp site_deltas/index_v1_d1.html site_files/index_v1.html
echo 
echo -e "${GREEN}[ FILE MUTATED -- PERFORMING TERRAFORM APPLY -- please type 'yes' to apply ]${NC} when terraform asks"
terraform apply
echo -e "${CYAN}done${NC}"
echo 

#######################
## MODIFY INDEX_V1 Again
#######################
echo -e "${GREEN}[ Modifying version of index_v1.html ]${NC}"
cp site_deltas/index_v1_d2.html site_files/index_v1.html
echo 
echo -e "${GREEN}[ FILE MUTATED -- PERFORMING TERRAFORM APPLY -- please type 'yes' to apply ]${NC} when terraform asks"
terraform apply
echo -e "${CYAN}done${NC}"
echo 

#######################
## MODIFY INDEX_V1 Again
#######################
echo -e "${GREEN}[ Modifying version of index_v1.html ]${NC}"
echo -e "${CYAN}cp site_deltas/index_v1_d3.html site_files/index_v1.html${NC}"
cp site_deltas/index_v1_d4.html site_files/index_v1.html
echo 
echo -e "${GREEN}[ FILE MUTATED -- PERFORMING TERRAFORM APPLY -- please type 'yes' to apply ]${NC} when terraform asks"
terraform apply
echo -e "${CYAN}done${NC}"
echo 



######################
# CONFIRM SITE IS LIVE
######################
bucketSite=https://s3.us-east-2.amazonaws.com/${bucket_one_name}/versions.html

if [ `curl -v --silent $bucketSite  2>&1 | grep OK | wc -l` -eq "0" ]; then
   echo "${bucketSite} not LIVE. Either site not live or AWS bucket name or region has changed...contant CSAW admins";
   exit;
else
   echo "${bucketSite} challenge seems LIVE. Script exiting";
   exit 0
fi

