#!/bin/bash
#################################################################################################################
# Script Name: import_objects.sh                                                                                #
# Description: This script is used for importing objects into  INFA repository.                                 #
# Objects will be imported based on inventory file and control file configuration.                              #
# Author: Shahrukh, Shaik (Wipro)                                                                                   #
# Usage: This script accepts user, password, incident number, Label Name (if any) as parameters                 #
# Modification History:                                                                                         #
# Date          Developer            Description                                                                #
# ----          ---------            ------------                                                               #
# 06/22/2020    Shahrukh Shaik           Version 1.0                                                            #
#                                                                                                               #
#################################################################################################################

#INVENTORY_FILE_Dir=/app/informatica/infa_shared/Automation/Inventory_files
#LogFileDir=/app/informatica/infa_shared/Sadik
#ScriptDir=/app/informatica/infa_shared/Sadik
#xmlDir=/app/informatica/infa_shared/Sadik/xml
#. ~/.profile
_filepath="$(readlink -f ${BASH_SOURCE[0]})"
_directory="$(dirname $_filepath)"
. $_directory/Infa_environment_list.env
DOMAIN=$1
REPOSITORY=$2
INFA_NUSR=$3
SRC_FOLDER_NM=$4
INCIDENT_NM=$5
EMAIL=$6,$EmailRecipient
INFA_USR=$7
INFA_PWD=$8
SRC_REP_NM=$9
INFA_VERSION=${10}
WORKFLOW_LIST=${11}

date=`date +'%Y%m%d%H%M%S'`
date1=`date +'%Y%m%d'`
LogFileName="import_script_"$4"_"$date1".log"
ImportLog=$ImportLogFile"_"$4"_"$date1".log"
ValidateLog="ValidateLog_"$4"_"$date1".log"
INVENTORY_FILE="Inventory_Objects_"$4".csv"
PRE_TGT_REP_NM=XXXX
CONFLICT_INV_FILE="Conflict_file_"$4".csv"
#TGT_REP_NM=`cat $INVENTORY_FILE_Dir/$INVENTORY_FILE | awk -F"," 'NR==1{print $6}'`
#TGT_DOMAIN_NM=`cat $INVENTORY_FILE_Dir/$INVENTORY_FILE | awk -F"," 'NR==1{print $7}'`
#CNTRL_SRC_REP_NM=`cat $INVENTORY_FILE_Dir/$INVENTORY_FILE | awk -F"," 'NR==1{print "\x22" $3 "\x22"}'`
#CNTRL_TGT_REP_NM=`cat $INVENTORY_FILE_Dir/$INVENTORY_FILE | awk -F"," 'NR==1{print "\x22" $6 "\x22"}'`
TGT_REP_NM="$REPOSITORY"
TGT_DOMAIN_NM="$DOMAIN"
CNTRL_SRC_REP_NM="\"$SRC_REP_NM"\"
CNTRL_TGT_REP_NM="\"$REPOSITORY"\"
OBJ_TYPE='Workflow'

INFA_REPCNX_INFO="$ScriptDir/Tmp/pmrepimport"$date
export INFA_REPCNX_INFO


export INFA_HOME=$_directory/../$INFA_VERSION
export PATH=$INFA_HOME/server/bin:$PATH
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$INFA_HOME/server/bin
Executable_Dir=$INFA_HOME/server/bin
export Executable_Dir
touch $LogFileDir/$LogFileName

#exit if less than 3 parameters
if [ $# -lt 9 ]
then
echo "Incorrect number of parameters passed $#." | tee -a $LogFileDir/$LogFileName
exit 1
fi

#check for presence for inventory file in $INVENTORY_FILE_Dir
#if [ ! -f $INVENTORY_FILE_Dir/$INVENTORY_FILE ]
#then
#echo
#echo >>$LogFileDir/$LogFileName
#echo "Expected filename $INVENTORY_FILE is not found in $INVENTORY_FILE_Dir"
#echo "Expected filename $INVENTORY_FILE is not found in $INVENTORY_FILE_Dir" >>$LogFileDir/$LogFileName
#echo
#exit 1
#fi

#check if file has all fields
#awk -F ',' -v OFS=',' 'NF!=3 { print '$NR' >> "'$ScriptDir'/Tmp/Column_count_'$INCIDENT_NM'.txt"}' $INVENTORY_FILE_Dir/$INVENTORY_FILE

#if [ -s $ScriptDir/Tmp/"Column_count_"$INCIDENT_NM".txt" ]
#then
#echo "Inventory file $INVENTORY_FILE_Dir/$INVENTORY_FILE is expected to have 3 fields, please check."
#echo "Inventory file $INVENTORY_FILE_Dir/$INVENTORY_FILE is expected to have 3 fields, please check."  >>$LogFileDir/$LogFileName
#rm $ScriptDir/Tmp/"Column_count"$INCIDENT_NM".txt"
#exit 1
#fi
#
#rm $ScriptDir/Tmp/"imp_obj_list_"$INCIDENT_NM".csv"

export body="Hi All,"'\n''\n'"Objects has been imported successfully."'\n''\n'"Please find attached log file."'\n''\n'



cd $ScriptDir
#echo "current directory is $ScriptDir"

#variable initialization
count=0

# Get line count of inventory list file
#rowcount=$(cat $INVENTORY_FILE_Dir/$INVENTORY_FILE|wc -l)

#if [ $rowcount -lt 2 ]
#if [ $rowcount -lt 1 ]
#then
#echo "inventory file $INVENTORY_FILE has no objects"
#echo "inventory file $INVENTORY_FILE has no objects" >>$LogFileDir/$LogFileName
#exit 1
#fi

#Apply label name
#OBJ_TYPE=$(sed -n '2p' $INVENTORY_FILE_Dir/$INVENTORY_FILE | awk -F"," '{print $1}')
L_Name=$INCIDENT_NM
if [ -z $L_Name ]
then
Label_Name="Label_"$INCIDENT_NM
echo " No label name passed"  | tee -a $LogFileDir/$LogFileName
echo "Default label "Label_"$INCIDENT_NM  will be applied." | tee -a $LogFileDir/$LogFileName
else
Label_Name="Label_"$L_Name
echo "$Label_Name as label will be applied" | tee -a $LogFileDir/$LogFileName
fi

rm $LogFileDir/$ImportLog
rm $LogFileDir/$ValidateLog
#Loop the inventory file
#cat $INVENTORY_FILE_Dir/$INVENTORY_FILE|while read line
for line in $(echo $WORKFLOW_LIST | tr ',' '\n')
do

#Assign variables
OBJ_NM=$line

echo "line no $count:" | tee -a $LogFileDir/$LogFileName
echo "source folder $SRC_FOLDER_NM"  | tee -a $LogFileDir/$LogFileName
echo "object type $OBJ_TYPE" | tee -a $LogFileDir/$LogFileName
echo "object name $OBJ_NM" | tee -a $LogFileDir/$LogFileName
echo -e "\n" | tee -a $LogFileDir/$LogFileName

#######################

cd $Executable_Dir

echo "Connecting to target repository $TGT_REP_NM of domain $TGT_DOMAIN_NM"
pmrep connect -r $TGT_REP_NM -d $TGT_DOMAIN_NM -n $INFA_USR -x $INFA_PWD >> $LogFileDir/$LogFileName 2>&1
echo "Checking for existing impacted or invalid objects present."
	if [ "$PRE_TGT_REP_NM" != "$TGT_REP_NM" ]
	then
	
	PRE_TGT_REP_NM=$TGT_REP_NM
	
	#get list of impacted and invalid objects from repository
	pmrep executequery -q Impacted_Objects -t Shared -u $ScriptDir/Tmp/"pre_impacted_obj_"$INCIDENT_NM".txt"
	return_code=$?
	
		if [ $return_code -gt 0 ]
		then
		
		echo "script encountered error while executing query $Impacted_Objects from repository $SRC_REP_NM" | tee -a $LogFileDir/$LogFileName
		
		exit 1
		fi
	
	#check if there are any impacted objects
	pre_impacted_obj_cnt=`cat $ScriptDir/Tmp/"pre_impacted_obj_"$INCIDENT_NM".txt"|wc -l`
	
		if [ $pre_impacted_obj_cnt -gt 0 ]
		then
		
		awk -F ',' '{print $3}' $ScriptDir/Tmp/"pre_impacted_obj_"$INCIDENT_NM".txt"  >$ScriptDir/Tmp/"temp_pre_impacted_obj_"$INCIDENT_NM".txt"
		return_code=$?
		
			if [ $return_code -gt 0 ]
			then
			
			echo "script encountered error while printing last field from "pre_impacted_obj_"$INCIDENT_NM".txt"" | tee -a $LogFileDir/$LogFileName
			exit 1
			fi
		
		#sort impacted objects list
		sort $ScriptDir/Tmp/"temp_pre_impacted_obj_"$INCIDENT_NM".txt" >$ScriptDir/Tmp/"sorted_pre_impacted_obj_"$INCIDENT_NM".txt"
		return_code=$?
		
			if [ $return_code -gt 0 ]
			then
			echo "script encountered error while sorting "temp_pre_impacted_Obj_"$INCIDENT_NM".txt"" | tee -a $LogFileDir/$LogFileName
			
			exit 1
			fi
		
		fi
	
	fi

impact_count=`grep $OBJ_NM $ScriptDir/Tmp/"sorted_pre_impacted_obj_"$INCIDENT_NM".txt"| wc -l`

	if [ $impact_count -gt 0 ]
	then
	echo "$OBJ_NM is invalid or impacted in repository $TGT_REP_NM." | tee -a $LogFileDir/$LogFileName
	
	exit 1
	fi


done


####################################################################################


#Control file preparation

grep -e '<FOLDER NAME=' $xmlDir/$INCIDENT_NM".xml" >$ScriptDir/Tmp/"Check_folders_"$INCIDENT_NM".txt"
return_code=$?

if [ $return_code -gt 0 ]
then
echo "script encountered error while grep from xml" | tee -a $LogFileDir/$LogFileName
exit 1
fi

#cat $ScriptDir/Tmp/"Check_folders"$INCIDENT_NM".txt"

cat $ScriptDir/import_cntrl_file_template_HDR.xml >$ScriptDir/Tmp/$ControlFile"_"$INCIDENT_NM"_temp.xml"
sed -i "s/INFA_VERSION/$INFA_VERSION/g" $ScriptDir/Tmp/$ControlFile"_"$INCIDENT_NM"_temp.xml"

cd $ScriptDir/Tmp

#loop
while read line
#for line in $(cat "Check_folders_"$INCIDENT_NM".txt")
do

line_count=`expr $line_count + 1`
echo $count

echo "Line from "Check_folders_"$INCIDENT_NM".txt": " $line_count >>$LogFileDir/$LogFileName

FOLDER_NM=$(echo $line| awk -F'=' '{print $2}')
return_code=$?

if [ $return_code -gt 0 ]
then

echo "script encountered error while printing field from "Check_folders_"$INCIDENT_NM".txt"" | tee -a $LogFileDir/$LogFileName
exit 1
fi

CNTRL_SRC_FOLDER="<FOLDERMAP SOURCEFOLDERNAME="$FOLDER_NM" SOURCEREPOSITORYNAME="$CNTRL_SRC_REP_NM
CNTRL_TGT_FOLDER="TARGETFOLDERNAME="$FOLDER_NM" TARGETREPOSITORYNAME="$CNTRL_TGT_REP_NM"/>"


echo $CNTRL_SRC_FOLDER >>$ScriptDir/Tmp/$ControlFile"_"$INCIDENT_NM"_temp.xml"
echo "           "$CNTRL_TGT_FOLDER>>$ScriptDir/Tmp/$ControlFile"_"$INCIDENT_NM"_temp.xml"

done < Check_folders_"$INCIDENT_NM".txt

if [ ! -s $INVENTORY_FILE_Dir/$CONFLICT_INV_FILE ]
then
cat $ScriptDir/import_cntrl_file_template_FTR.xml >>$ScriptDir/Tmp/$ControlFile"_"$INCIDENT_NM"_temp.xml"
else
echo "
<RESOLVECONFLICT> 
<TYPEOBJECT OBJECTTYPENAME=\""ALL"\" RESOLUTION=\""REPLACE"\"/>" >>$ScriptDir/Tmp/$ControlFile"_"$INCIDENT_NM"_temp.xml"

#cat $INVENTORY_FILE_Dir/$CONFLICT_INV_FILE | while read line
for line in $(cat $INVENTORY_FILE_Dir/$CONFLICT_INV_FILE)
do
echo $line
CON_OBJ_NM=$(echo $line| awk -F"," '{print $1}')
echo $CON_OBJ_NM
CON_OBJ_TYPE=$(echo $line| awk -F"," '{print $2}')
CON_OBJ_FLDR=$(echo $line| awk -F"," '{print $3}')
RESOL=$(echo $line| awk -F"," '{print $4}')

echo "<SPECIFICOBJECT NAME=\""$CON_OBJ_NM"\" OBJECTTYPENAME=\""$CON_OBJ_TYPE"\" FOLDERNAME=\""$CON_OBJ_FLDR"\" REPOSITORYNAME=\""$SRC_REP_NM"\" RESOLUTION=\""$RESOL"\"/> " 


echo "<SPECIFICOBJECT NAME=\""$CON_OBJ_NM"\" OBJECTTYPENAME=\""$CON_OBJ_TYPE"\" FOLDERNAME=\""$CON_OBJ_FLDR"\" REPOSITORYNAME=\""$SRC_REP_NM"\" RESOLUTION=\""$RESOL"\"/> " >>$ScriptDir/Tmp/$ControlFile"_"$INCIDENT_NM"_temp.xml"
done
echo "
</RESOLVECONFLICT>
</IMPORTPARAMS>
" >>$ScriptDir/Tmp/$ControlFile"_"$INCIDENT_NM"_temp.xml"
fi


#########
sed 's/GROUP//g' $ScriptDir/Tmp/$ControlFile"_"$INCIDENT_NM"_temp.xml"| sed 's/in_LABEL/'$Label_Name'/'| sed 's/in_COMMENTS/'$Label_Name'/' >$ControlFileDir/$ControlFile"_"$INCIDENT_NM".xml"
return_code=$?
##########
if [ $return_code -gt 0 ]
then
echo "sed command failed to replace in control file." | tee -a $LogFileDir/$LogFileName

exit 1
fi



#############################################################################################
#Objects importing
cd $Executable_Dir

# checking repository connection
pmrep connect -r $TGT_REP_NM -d $TGT_DOMAIN_NM -n $INFA_USR -x $INFA_PWD >>/dev/null 2>&1
pmrep deletelabel -a $Label_Name -f  >/dev/null 2>&1
pmrep createlabel -a $Label_Name | tee -a $LogFileDir/$LogFileName
return_code=$?

if [ $return_code -gt 0 ]
then
echo "script encountered error while creating label" | tee -a $LogFileDir/$LogFileName

exit 1
fi

echo "started importing object(s)" | tee -a $LogFileDir/$LogFileName

#import objects
pmrep objectimport -i $xmlDir/$INCIDENT_NM".xml" -c $ControlFileDir/$ControlFile"_"$INCIDENT_NM".xml" -p  | tee -a $LogFileDir/$ImportLog
return_code=$?

#if pmrep command is unsuccessful send email with log attachment and exit
if [ $return_code -eq 0 ]
	then
	if [ $(grep 'Failed to execute objectimport' $LogFileDir/$ImportLog | wc -l ) -ge 1 ]
	then
	exit 1
	fi
	#echo "$OBJ_NM"_"$SRC_FOLDER_NM"_"$INCIDENT_NM.xml" >>$ScriptDir/Tmp/"imp_obj_list_"$INCIDENT_NM".csv"
	echo "$OBJ_NM" >>$ScriptDir/Tmp/"imp_obj_list_"$INCIDENT_NM".csv"
	echo "Objects imported successfully" | tee -a $LogFileDir/$LogFileName
	else
	echo "import failed , please check log file" | tee -a $LogFileDir/$LogFileName
	
	echo -e "Import failed. Please check the attached log file."'\n''\n'$EmailSignature|mailx -a $LogFileDir/$ImportLog -a $LogFileDir/$LogFileName -s "INFA Deployment Automation: $INCIDENT_NM - Objects Import failed" $EMAIL
	return_code=$?

	if [ $return_code -gt 0 ]
		then
		echo "Import failed, script encountered error while sending email" | tee -a $LogFileDir/$LogFileName
		exit 1
	fi

	exit 1
fi

#check if there are any failed objects
grep '* Failed to Import' $LogFileDir/$ImportLog >$ScriptDir/Tmp/$INCIDENT_NM"_Failed_Import_List.txt"
Failed_Import_cnt=`grep '* Failed to Import' $LogFileDir/$ImportLog|wc -l`
Failed_Import_List=`cat $ScriptDir/Tmp/$INCIDENT_NM"_Failed_Import_List.txt"`

if [ $Failed_Import_cnt -gt 0 ]
	then
	echo "Below objects has not imported, please check import log" | tee -a $LogFileDir/$LogFileName
	echo "$Failed_Import_List" | tee -a $LogFileDir/$LogFileName
	echo -e "Objects failed to import in folder $SRC_FOLDER_NM" > $ScriptDir/Tmp/$INCIDENT_NM"_failed_folder_msg.txt"
	echo -e "\n" >>$ScriptDir/Tmp/$INCIDENT_NM"_failed_folder_msg.txt"
	echo -e ${EmailSignature} >>$ScriptDir/Tmp/$INCIDENT_NM"_failed_folder_msg.txt"
	
	( cat $ScriptDir/Tmp/$INCIDENT_NM"_failed_folder_msg.txt" )|mailx -a $ScriptDir/Tmp/$INCIDENT_NM"_Failed_Import_List.txt" -a $LogFileDir/$ImportLog -s "INFA Deployment Automation: Failed to Import Objects EOM" $EmailRecipient
	return_code=$?
	
	if [ $return_code -gt 0 ]
		then
		echo "Failed to Import Objects, script encountered error while sending email" | tee -a $LogFileDir/$LogFileName
		exit 1
	fi
	
	exit 1
fi

#############################################################################################


#Loop the inventory file
#cat $INVENTORY_FILE_Dir/$INVENTORY_FILE|while read line
for line in $(echo $WORKFLOW_LIST | tr ',' '\n')
do


#Assign variables
OBJ_NM=$line
#CNTRL_TGT_FOLDER_NM=$(echo $line| awk -F"," '{print "\x22" $8 "\x22"}')

echo "target repository $TGT_REP_NM"  >>$LogFileDir/$LogFileName
#echo "target domain $TGT_DOMAIN_NM"
echo "target domain $TGT_DOMAIN_NM"  >>$LogFileDir/$LogFileName
#echo "target folder $TGT_FOLDER_NM"
echo "target folder $TGT_FOLDER_NM"  >>$LogFileDir/$LogFileName
#echo "object type $OBJ_TYPE"
echo "object type $OBJ_TYPE"  >>$LogFileDir/$LogFileName
#echo "object name $OBJ_NM"
echo "object name $OBJ_NM"  >>$LogFileDir/$LogFileName
#echo -e "\n"
echo -e "\n"  >>$LogFileDir/$LogFileName

echo $OBJ_NM >> $ScriptDir/Tmp/"imp_obj_list_"$INCIDENT_NM".csv"
#################################################################
#validate and save object
pmrep Validate -n $OBJ_NM -o $OBJ_TYPE -f $SRC_FOLDER_NM -s >>$LogFileDir/$ValidateLog 2>&1
return_code=$?

if [ $return_code -eq 0 ]
	then
	#echo "$OBJ_NM is validated and saved  successfully"
	echo "$OBJ_NM is validated and saved successfully"  | tee -a $LogFileDir/$LogFileName
	
	else
	
	echo "$OBJ_NM failed to validate." | tee -a $LogFileDir/$LogFileName
	echo "pmrep validate command failed for object $OBJ_NM."  | tee -a $LogFileDir/$LogFileName
	
	
	echo -e "Objects validation and save failed. Please check the attached log file."'\n''\n'$EmailSignature|mailx -a $LogFileDir/$ValidateLog -a $LogFileDir/$LogFileName -s "INFA Deployment Automation: $INCIDENT_NM - valiadte and save failed" $EMAIL
	return_code=$?
	
	if [ $return_code -gt 0 ]
		then
		
		echo "script encountered error while sending email" | tee -a $LogFileDir/$LogFileName
		
		exit 1
	fi
	
	exit 1
fi




	
	#get list of impacted and invalid objects from repository
	pmrep executequery -q Impacted_Objects -t Shared -u $ScriptDir/Tmp/"post_impacted_obj_"$INCIDENT_NM".txt"
	return_code=$?
	
		if [ $return_code -gt 0 ]
			then
			
			echo "Imported objects successfully but script encountered error while checking impacted objects after import. Check manually in repository $SRC_REP_NM"
			echo "Imported objects successfully but script encountered error while executing query $Impacted_Objects from repository $SRC_REP_NM" >>$LogFileDir/$LogFileName
			echo -e "Imported objects successfully but error while executing repository query for impacted objects list. Please check the attached log file."'\n''\n'$EmailSignature|mailx -a $LogFileDir/$LogFileName -s "INFA Deployment Automation: $INCIDENT_NM - Error executing repository query" $EMAIL
			
			exit 0
		fi
	
	post_impacted_obj_cnt=`cat $ScriptDir/Tmp/"post_impacted_obj_"$INCIDENT_NM".txt"|wc -l`
	
		if [ $post_impacted_obj_cnt -gt 0 ]
			then
			
			awk -F ',' '{print $3}' $ScriptDir/Tmp/"post_impacted_obj_"$INCIDENT_NM".txt"  >$ScriptDir/Tmp/"temp_post_impacted_obj_"$INCIDENT_NM".txt"
			return_code=$?
			
				if [ $return_code -gt 0 ]
					then
					
					echo "Imported objects successfully but script encountered error while checking impacted objects after import. Check manually in repository $SRC_REP_NM"
					echo "Imported objects successfully but script encountered error while printing last field from "post_impacted_obj_"$INCIDENT_NM".txt"" >>$LogFileDir/$LogFileName
					echo -e "Error while printing last field from impacted objects list.Please check the attached log file."'\n''\n'$EmailSignature|mailx -a $LogFileDir/$LogFileName -s "INFA Deployment Automation: $INCIDENT_NM - Error printing last field from impacted objects list" $EMAIL
					
					exit 0
				fi
			
			#sort impacted objects list
			sort $ScriptDir/Tmp/"temp_post_impacted_obj_"$INCIDENT_NM".txt" >$ScriptDir/Tmp/"sorted_post_impacted_obj_"$INCIDENT_NM".txt"
			return_code=$?
			
				if [ $return_code -gt 0 ]
					then
					
					echo "Imported objects successfully but script encountered error while checking impacted objects after import. Check manually in repository $SRC_REP_NM"
					echo "script encountered error while sorting "temp_post_impacted_Obj_"$INCIDENT_NM".txt"" >>$LogFileDir/$LogFileName
					echo -e "Error while sorting impacted objects list. Please check the attached log file."'\n''\n'$EmailSignature|mailx -a $LogFileDir/$LogFileName -s "INFA Deployment Automation: $INCIDENT_NM - Error sorting impacted objects list" $EMAIL
					
					exit 0
				fi
			
			
			#check if any object is impacted or invalid in target repository
			diff $ScriptDir/Tmp/"sorted_pre_impacted_obj_"$INCIDENT_NM".txt" $ScriptDir/Tmp/"sorted_post_impacted_obj_"$INCIDENT_NM".txt" >$ScriptDir/Tmp/"post_impacted_objects_"$INCIDENT_NM".txt"
			return_code=$?
			
				if [ $return_code -ge 2 ]
					then
					
					echo "script encountered error while checking impacted objects after deployment" | tee -a $LogFileDir/$LogFileName
					echo -e "Error while checking impacted objects after deployment. Please check the attached log file."'\n''\n'$EmailSignature|mailx -a $LogFileDir/$LogFileName -s "INFA Deployment Automation: $INCIDENT_NM - Error checking impacted objects after deployment" $EmailRecipient
					
					exit 0
				fi
			
				if [ $return_code -eq 1 ]
					then
					
					grep '>' $ScriptDir/Tmp/"post_impacted_objects_"$INCIDENT_NM".txt" > $ScriptDir/Tmp/"impacted_list"$INCIDENT_NM".csv"
					
					#impact_count=`cat $ScriptDir/Tmp/"post_impacted_objects_"$INCIDENT_NM".txt"|wc -l`
					
					impact_count=`cat $ScriptDir/Tmp/"impacted_list"$INCIDENT_NM".csv"|wc -l`
					
					if [ $impact_count -gt 0 ]
						then
						
						echo "Objects has been impacted after this deployment.Please check the log for more details." | tee -a $LogFileDir/$LogFileName
						echo "Below objects has been impacted after this deployment"  | tee -a $LogFileDir/$LogFileName
						cat $ScriptDir/Tmp/$ScriptDir/Tmp/"impacted_list"$INCIDENT_NM".csv"  | tee -a $LogFileDir/$LogFileName
						echo -e "Objects has been impacted after this deployment. Please check the attached log file."'\n''\n'$EmailSignature|mailx -a $LogFileDir/$LogFileName -s "INFA Deployment Automation: $INCIDENT_NM - Objects impacted" $EMAIL
						
						exit 0
					fi
			
			
				fi
			
		fi
	

done



#print object list
OBJ_LIST=`cat $ScriptDir/Tmp/"imp_obj_list_"$INCIDENT_NM".csv"`
#echo "Below list of objects imported into folder $TGT_FOLDER_NM in  reposiotry $TGT_REP_NM"
echo "Below list of objects imported into folder $SRC_FOLDER_NM in repository $TGT_REP_NM"   | tee -a $LogFileDir/$LogFileName
echo "$OBJ_LIST" | tee -a $LogFileDir/$LogFileName

#prepare email body
echo -e ${body} >$ScriptDir/Tmp/"import_msgbody_"$INCIDENT_NM".txt"
echo -e "\n" >>$ScriptDir/Tmp/"import_msgbody_"$INCIDENT_NM".txt"
echo -e ${EmailSignature} >>$ScriptDir/Tmp/"import_msgbody_"$INCIDENT_NM".txt"

echo "Objects imported successfully for incident number $INCIDENT_NM"

#cat $ScriptDir/Tmp/"import_msgbody"$INCIDENT_NM".txt"

#send success email
( cat $ScriptDir/Tmp/"import_msgbody_"$INCIDENT_NM".txt" ) | mailx -a $ScriptDir/Tmp/"imp_obj_list_"$INCIDENT_NM".csv" -a $LogFileDir/$ImportLog -s "INFA Deployment Automation: $INCIDENT_NM - Objects imported successfully" $EMAIL
return_code=$?

if [ $return_code -gt 0 ]
then

echo "Objects imported successfully but script encountered error while sending email"
echo "Objects imported successfully but script encountered error while sending email" >>$LogFileDir/$LogFileName
exit 0
fi



rm $ScriptDir/Tmp/"Column_count_"$INCIDENT_NM".txt"
rm $ScriptDir/Tmp/"imp_obj_list_"$INCIDENT_NM".csv"
rm $ScriptDir/Tmp/"import_msgbody_"$INCIDENT_NM".txt"
rm $ScriptDir/Tmp/$INCIDENT_NM"_Failed_Import_List.txt"
rm $ScriptDir/Tmp/$INCIDENT_NM"_failed_folder_msg.txt"
rm $ScriptDir/Tmp/"temp_post_impacted_obj_"$INCIDENT_NM".txt" 
rm $ScriptDir/Tmp/"temp_pre_impacted_obj_"$INCIDENT_NM".txt"
rm $ScriptDir/Tmp/$INCIDENT_NM"_Rep_Login.txt"

exit 0
 



