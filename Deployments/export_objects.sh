#!/bin/bash
#################################################################################################################
# Script Name: export_objects.sh                                                                                   #
# Description: This script is used for to take exports for performing new and delta AQRC_checks.                        #
# Objects will be imported based on inventory file and control file configuration.                              #
# Author: Shahrukh Shaik(Wipro)                                                                                 #
# Usage: This script accepts user, password, incident number, EmailRecipient (if any) as parameters             #
# Modification History:                                                                                         #
# Date          Developer            Description                                                                #
# ----          ---------            ------------                                                               #
# 08/20/2019    Shahrukh Shaik           Version 1                                                              #
# 06/09/2021    Shahrukh Shaik           Version 2                                                              #
#                                                                                                               #
#################################################################################################################

#. ~/.profile
_filepath="$(readlink -f ${BASH_SOURCE[0]})"
_directory="$(dirname $_filepath)"
DOMAIN=$1
REPOSITORY=$2
AQRC_USR=$3
SRC_FLDR_NM=$4
INCIDENT_NM=$5
EMAIL=$6,$AQRC_USR@bp365.onmicrosoft.com
INFA_USR=$7
INFA_PWD=$8
INFA_VERSION=$9
WORKFLOW_LIST=${10}
OBJ_TYPE='Workflow'
date=`date +'%Y%m%d%H%M%S'`
date1=`date +'%Y%m%d'`

. $_directory/Infa_environment_list.env
INFA="INFA"
LogFileName="export_script_"$INCIDENT_NM"_"$date".log"
INVENTORY_FILE="Inventory_Objects_"$INCIDENT_NM".csv"

ExportLog=$ExportLogFile"_"$INCIDENT_NM"_"$date1".log"
INFA_REPCNX_INFO="$ScriptDir/Tmp/pmrep"$date
export INFA_REPCNX_INFO

#Removing exiting persistent input file if already exists for this incident number
rm -f $xmlDir/"PersistentInput_"$INCIDENT_NM".xml"
export INFA_HOME=$_directory/../$INFA_VERSION
export PATH=$INFA_HOME/server/bin:$PATH
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$INFA_HOME/server/bin
Executable_Dir=$INFA_HOME/server/bin
export Executable_Dir
#exit if incorrect parameters
if [ $# -lt 9 ]
then
	echo "incorrect parameters, please pass user, password,incident number to the script"
	echo "incorrect parameters, please pass user, password,incident number to the script" >>$LogFileDir/$LogFileName
	exit 1
fi

#check for presence of Inventory file in $INVENTORY_FILE_Dir
#if [ ! -f $INVENTORY_FILE_Dir/$INVENTORY_FILE ]
#then
#echo
#echo "Expected filename $INVENTORY_FILE is not found in $INVENTORY_FILE_Dir"
#echo "Expected filename $INVENTORY_FILE is not found in $INVENTORY_FILE_Dir" >>$LogFileDir/$LogFileName
#echo
#exit 1
#fi



#rm $ScriptDir/Tmp/"obj_list"$INCIDENT_NM".csv"
#rm $ScriptDir/Tmp/"msgbody"$INCIDENT_NM".txt"
#rm $ScriptDir/Tmp/"msgcheckout"$INCIDENT_NM".txt"

export body="Hi All,"'\n''\n'"Objects has been exported successfully. Please find attached objects list and log file."'\n'

export checkout="Hi All,"'\n''\n'"Objects are checked out, please check in objects and start export again.Please check log file attached."'\n'

cd $ScriptDir
echo "current directory is $ScriptDir" >>$LogFileDir/$LogFileName


#check if inventory file has all fields
#awk -F ',' -v OFS=',' 'NF!=3 { print '$NR' >> "'$ScriptDir'/Tmp/Column_count_'$INCIDENT_NM'.txt"}' $INVENTORY_FILE_Dir/$INVENTORY_FILE
#return_code=$?
#
#
#if [ $return_code -gt 0 ]
#then
#
#echo "script encountered error while inventory file fields check"
#echo "script encountered error while inventory file fields check" >>$LogFileDir/$LogFileName
#exit 1
#fi

#if [ -s $ScriptDir/Tmp/"Column_count_"$INCIDENT_NM".txt" ]
#then
#echo "Inventory file $INVENTORY_FILE_Dir/$INVENTORY_FILE is expected to have 3 fields, please check."
#echo "Inventory file $INVENTORY_FILE_Dir/$INVENTORY_FILE is expected to have 3 fields, please check."  >>$LogFileDir/$LogFileName
#rm $ScriptDir/Tmp/"Column_count_"$INCIDENT_NM".txt"
#exit 1
#fi
#
##Get line count of inventory list file
#rowcount=$(cat $INVENTORY_FILE_Dir/$INVENTORY_FILE|wc -l)
rowcount=$(echo $WORKFLOW_LIST | tr ',' '\n')


#if [ $rowcount -lt 1 ]
#then
#echo "inventory file $INVENTORY_FILE has no objects"
#echo "inventory file $INVENTORY_FILE has no objects" >>$LogFileDir/$LogFileName
#
#exit 1
#fi
if [ -z $WORKFLOW_LIST ]
then
	echo "Empty Workflow list passed. Script is exiting now." | tee -a $LogFileDir/$LogFileName
	exit 1
fi
#Checking repository connection
pmrep connect -r $REPOSITORY -d $DOMAIN -n $INFA_USR -x $INFA_PWD > /dev/null 2>&1
return_code=$?

#if repository connection is failed then send email and exit
if [ $return_code == 0 ]
then
	echo "Connected to the Repository $REPOSITORY"
	echo "Connected to the Repository $REPOSITORY" >>$LogFileDir/$LogFileName

else

	echo "Invalid User credentials or User $INFA_USR does not exists in the domain $DOMAIN" | tee -a $LogFileDir/$LogFileName
	echo "Failed to Connect to the Repository $REPOSITORY" | tee -a $LogFileDir/$LogFileName

	#remove xmls if export fails
	cd $xmlDir
	rm -f *$INCIDENT_NM".xml"

	echo -e "Failed to Connect to the Repository $REPOSITORY. Please check the attached log file."'\n''\n'$EmailSignature|mailx -a $LogFileDir/$LogFileName -s "$INFA Deployment Automation: $INCIDENT_NM - Repository connection failed" $EMAIL
	return_code=$?

	exit 1
fi


count=0

#Loop the inventory file
#cat $INVENTORY_FILE_Dir/$INVENTORY_FILE|while read line
for line in $(echo $WORKFLOW_LIST | tr ',' '\n')
do

	if [ $count -ge 0 ]
	then

		#Assign variables
		OBJ_NM=$line


		echo "Finding checkout objects from folder $SRC_FLDR_NM" | tee -a $LogFileDir/$LogFileName

		cd $Executable_Dir

		##############################
		#Get list of dependent folders
		echo "Finding list of dependent folders"
		pmrep listobjectdependencies -n $OBJ_NM -o $OBJ_TYPE -p children  -f $SRC_FLDR_NM -b  | sed 1,8d | head -n -5 | awk '{print $2}' | sort | uniq > $ScriptDir/Tmp/"all_dependent_folders_"$INCIDENT_NM".txt"
		rm -f $ScriptDir/Tmp/"all_checkout_"$INCIDENT_NM".txt"
		for folder in $(cat $ScriptDir/Tmp/"all_dependent_folders_"$INCIDENT_NM".txt")
		do

			#Get checkout list from repository folder
			pmrep findcheckout -u -f $folder| head -n -3 | sed 1,8d >> $ScriptDir/Tmp/"all_checkout_"$INCIDENT_NM".txt"
			return_code=$?

			if [ $return_code -gt 0 ]
			then

				echo "script encountered error while pmrep findcheckout command" | tee -a $LogFileDir/$LogFileName

				#remove xmls if export fails
				cd $xmlDir
				rm -f *$INCIDENT_NM".xml"

				exit 1
			fi
		done
		rep_checkout_cnt=`cat $ScriptDir/Tmp/"all_checkout_"$INCIDENT_NM".txt"|wc -l`

		if [ $rep_checkout_cnt -gt 0 ]
		then


			awk '{print $(NF)}' $ScriptDir/Tmp/"all_checkout_"$INCIDENT_NM".txt" >$ScriptDir/Tmp/"checkout_list_"$INCIDENT_NM".txt"
			return_code=$?

			if [ $return_code -gt 0 ]
			then

				echo "script encountered error while printing last field from "checkout_list_"$INCIDENT_NM".txt"" | tee -a $LogFileDir/$LogFileName

				#remove xmls if export fails
				cd $xmlDir
				rm -f *$INCIDENT_NM".xml"

				exit 1
			fi

			sort $ScriptDir/Tmp/"checkout_list_"$INCIDENT_NM".txt" >$ScriptDir/Tmp/"sort_checkout_list"$INCIDENT_NM".txt"
			return_code=$?

			if [ $return_code -gt 0 ]
			then

				echo "script encountered error while sorting "checkout_list_"$INCIDENT_NM".txt"" | tee -a $LogFileDir/$LogFileName

				#remove xmls if export fails
				cd $xmlDir
				rm -f *$INCIDENT_NM".xml"

				exit 1
				exit 1
			fi

		fi

		#get list of impacted and invalid objects from repository
		pmrep executequery -q Impacted_Objects -t Shared -u $ScriptDir/Tmp/"all_impacted_obj_"$INCIDENT_NM".txt" >/dev/null 2>&1
		return_code=$?

		if [ $return_code -gt 0 ]
		then

			echo "script encountered error while executing query $Impacted_Objects from repository $REPOSITORY" | tee -a $LogFileDir/$LogFileName

			#remove xmls if export fails
			cd $xmlDir
			rm -f *$INCIDENT_NM".xml"

			exit 1
		fi

		#extracting the impacted or invalid objects from dependent object folders
		rm -f $ScriptDir/Tmp/"impacted_obj_"$INCIDENT_NM".txt"
		for folder in $(cat $ScriptDir/Tmp/"all_dependent_folders_"$INCIDENT_NM".txt")
		do
			cat $ScriptDir/Tmp/"all_impacted_obj_"$INCIDENT_NM".txt" | grep -w $folder >> $ScriptDir/Tmp/"impacted_obj_"$INCIDENT_NM".txt"
		done

		rep_impacted_obj_cnt=`cat $ScriptDir/Tmp/"impacted_obj_"$INCIDENT_NM".txt"|wc -l`

		if [ $rep_impacted_obj_cnt -gt 0 ]
		then

			awk -F ',' '{print $3}' $ScriptDir/Tmp/"impacted_obj_"$INCIDENT_NM".txt"  >$ScriptDir/Tmp/"temp_impacted_obj_"$INCIDENT_NM".txt"
			return_code=$?

			if [ $return_code -gt 0 ]
			then

				echo "script encountered error while printing last field from "impacted_obj_"$INCIDENT_NM".txt"" | tee -a $LogFileDir/$LogFileName

				#remove xmls if export fails
				cd $xmlDir
				rm -f *$INCIDENT_NM".xml"

				exit 1
			fi

			#sort impacted objects list
			sort $ScriptDir/Tmp/"temp_impacted_obj_"$INCIDENT_NM".txt" >$ScriptDir/Tmp/"sort_impacted_obj_"$INCIDENT_NM".txt"
			return_code=$?

			if [ $return_code -gt 0 ]
			then

				echo "script encountered error while sorting "sort_impacted_Obj_"$INCIDENT_NM".txt"" | tee -a $LogFileDir/$LogFileName

				#remove xmls if export fails
				cd $xmlDir
				rm -f *$INCIDENT_NM".xml"

				exit 1
			fi

		fi

		echo "Finding dependencies for object $OBJ_NM" | tee -a $LogFileDir/$LogFileName

		#Find child dependencies
		pmrep listobjectdependencies -n  $OBJ_NM -o $OBJ_TYPE -p children  -f $SRC_FLDR_NM >$ScriptDir/Tmp/"all_dependencies_"$INCIDENT_NM".txt"
		return_code=$?

		if [ $return_code -gt 0 ]
		then

			echo "script encountered error while finding dependencies for object $OBJ_NM, please check if object name is defined correctly in inventory file" | tee -a $LogFileDir/$LogFileName

			#remove xmls if export fails
			cd $xmlDir
			rm -f *$INCIDENT_NM".xml"

			exit 1
		fi


		#remove non-resuable objects from list
		grep -v -w "non-reusable" $ScriptDir/Tmp/"all_dependencies_"$INCIDENT_NM".txt" >$ScriptDir/Tmp/"temp_dependencies_"$INCIDENT_NM".txt"
		return_code=$?

		if [ $return_code -gt 0 ]
		then

			echo "script encountered error while using grep from all_"dependencies_"$INCIDENT_NM".txt"" | tee -a $LogFileDir/$LogFileName

			#remove xmls if export fails
			cd $xmlDir
			rm -f *$INCIDENT_NM".xml"

			exit 1
		fi

		#create dependencies list only for  below objects
		grep -e "reusable" -e "source" -e "target" -e "mapping" -e "mapplet" -e "workflow" -e "worklet" $ScriptDir/Tmp"/temp_dependencies_"$INCIDENT_NM".txt" >$ScriptDir/Tmp/"dependencies_obj_"$INCIDENT_NM".txt"
		return_code=$?

		if [ $return_code -gt 0 ]
		then

			echo "Script encountered error while grep from "temp_dependencies_"$INCIDENT_NM".txt"" | tee -a $LogFileDir/$LogFileName

			#remove xmls if export fails
			cd $xmlDir
			rm -f *$INCIDENT_NM".xml"

			exit 1
		fi

		#remove first column object type from file
		#cat $ScriptDir/Tmp/"dependencies_obj"$INCIDENT_NM".txt"| cut -d ' ' -f2-3 >$ScriptDir/Tmp/"dependencies"$INCIDENT_NM".txt"
		awk -F ' ' '{print $(NF)}' $ScriptDir/Tmp/"dependencies_obj_"$INCIDENT_NM".txt" >$ScriptDir/Tmp/"dependencies_"$INCIDENT_NM".txt"
		return_code=$?

		if [ $return_code -gt 0 ]
		then

			echo "Script encountered error while printing last field from "dependencies_"$INCIDENT_NM".txt"" | tee -a $LogFileDir/$LogFileName

			#remove xmls if export fails
			cd $xmlDir
			rm -f *$INCIDENT_NM".xml"

			exit 1
		fi

		sort $ScriptDir/Tmp/"dependencies_"$INCIDENT_NM".txt" >$ScriptDir/Tmp/"sorted_dependencies_"$INCIDENT_NM".txt"
		return_code=$?

		if [ $return_code -gt 0 ]
		then

			echo "script encountered error while sorting "sorted_dependencies_"$INCIDENT_NM".txt"" | tee -a $LogFileDir/$LogFileName

			#remove xmls if export fails
			cd $xmlDir
			rm -f *$INCIDENT_NM".xml"

			exit 1
		fi

		#check if any dependent object is impacted or invalid in source repository
		if [ $rep_impacted_obj_cnt -gt 0 ]
		then
			comm -12 $ScriptDir/Tmp/"sorted_dependencies_"$INCIDENT_NM".txt" $ScriptDir/Tmp/"sort_impacted_obj_"$INCIDENT_NM".txt" >$ScriptDir/Tmp/"impacted_objects_"$INCIDENT_NM".txt"
			return_code=$?

			if [ $return_code -gt 0 ]
			then

				echo "script encountered error while checking impacted objects from dependencies list" | tee -a $LogFileDir/$LogFileName

				#remove xmls if export fails
				cd $xmlDir
				rm -f *$INCIDENT_NM".xml"

				exit 1
			fi

			impactobject_count=`cat $ScriptDir/Tmp/"impacted_objects_"$INCIDENT_NM".txt"|wc -l`
			return_code=$?

			if [ $return_code -gt 0 ]
			then

				echo "script encountered error while checking impacted objects count" | tee -a $LogFileDir/$LogFileName
				echo -e "Error while checking impacted objects count. Please check the attached log file."'\n''\n'$EmailSignature|mailx -a $LogFileDir/$LogFileName -s "$INFA Deployment Automation: $INCIDENT_NM - Error checking count" $EMAIL

				#remove xmls if export fails
				cd $xmlDir
				rm -f *$INCIDENT_NM".xml"

				exit 1
			fi

			impacted_list=$(cat $ScriptDir/Tmp/"impacted_objects_"$INCIDENT_NM".txt")

			if [ $impactobject_count -gt 0 ]
			then
				echo "impacted objects count: $impactobject_count" | tee -a $LogFileDir/$LogFileName
				echo "Obejcts or their dependencies are in impacted state in repository $REPOSITORY. Please check log file $LogFileName for more details" | tee -a $LogFileDir/$LogFileName
				#echo $impacted_list
				echo "impacted objects list in repository $REPOSITORY"  | tee -a $LogFileDir/$LogFileName
				echo $impacted_list  | tee -a $LogFileDir/$LogFileName

				echo -e "Objects or their dependencies are invalid or impacted in reposirtoty $REPOSITORY".Please check the impacted object list.""'\n''\n'$EmailSignature|mailx -a $ScriptDir/Tmp/"impacted_objects_"$INCIDENT_NM".txt" -s "$INFA Deployment Automation: $INCIDENT_NM - Objects are invalid or impacted" $EMAIL

				#remove xmls if export fails
				cd $xmlDir
				rm -f *$INCIDENT_NM.xml

				exit 1
			fi

		fi

		if [ $rep_checkout_cnt -gt 0 ]
		then

			comm -12 $ScriptDir/Tmp/"sort_checkout_list"$INCIDENT_NM".txt" $ScriptDir/Tmp/"sorted_dependencies_"$INCIDENT_NM".txt" >$ScriptDir/Tmp/"checkout_objects_"$INCIDENT_NM".txt"

			findcheckout_count=`cat $ScriptDir/Tmp/"checkout_objects_"$INCIDENT_NM".txt"|wc -l`

			findcheckout_list=`cat $ScriptDir/Tmp/"checkout_objects_"$INCIDENT_NM".txt"`

			#if checkout object found in dependencies list then send email and exit
			if [ $findcheckout_count -gt 0 ]
			then
				echo "checkout objects count: $findcheckout_count" | tee -a $LogFileDir/$LogFileName
				echo "Objects or their dependencies are checked out in repository $REPOSITORY, objects needs to be checkin before export. Please check log file $LogFileName for more details" | tee -a $LogFileDir/$LogFileName
				#echo $findcheckout_list
				echo "checkout objects list in repository $REPOSITORY"  | tee -a $LogFileDir/$LogFileName
				echo $findcheckout_list  | tee -a $LogFileDir/$LogFileName
				#remove xmls if export fails
				cd $xmlDir
				rm -f *$INCIDENT_NM".xml"

				echo -e "Objects or their dependencies are checked out in reposirtoty $REPOSITORY".Please check the chekout object list.""'\n''\n'$EmailSignature|mailx -a $ScriptDir/Tmp/"checkout_objects_"$INCIDENT_NM".txt" -s "$INFA Deployment Automation: $INCIDENT_NM - Objects are checked out" $EMAIL
				return_code=$?

				if [ $return_code -gt 0 ]
				then
					echo "script encountered error while sending email" | tee -a $LogFileDir/$LogFileName
					echo "script encountered error while sending email" 
					exit 1
				fi

				exit 1
			fi

		fi

		#echo "line no $count:"

		echo "line no $count:"  >>$LogFileDir/$LogFileName

		#echo "source repository $REPOSITORY"
		echo "source repository $REPOSITORY"  >>$LogFileDir/$LogFileName

		#echo " domain name $DOMAIN"
		echo " domain name $DOMAIN"  >>$LogFileDir/$LogFileName

		#echo "source folder $SRC_FLDR_NM"
		echo "source folder $SRC_FLDR_NM"  >>$LogFileDir/$LogFileName

		#echo "object type $OBJ_TYPE"
		echo "object type $OBJ_TYPE"  >>$LogFileDir/$LogFileName+
		#echo "object name $OBJ_NM"
		echo "object name $OBJ_NM"  >>$LogFileDir/$LogFileName

		echo -e "\n"
		echo -e "\n"  >>$LogFileDir/$LogFileName


		#remove existing object in directory
		rm $xmlDir/$INCIDENT_NM".xml"

		cd $Executable_Dir

		REUSABLE=`pmrep listobjects -o $OBJ_TYPE -f $SRC_FLDR_NM | grep $OBJ_NM | awk '{print $2}'`
		if [ "$REUSABLE" == "reusable" ]
		then
			echo "none,$SRC_FLDR_NM,$OBJ_NM,$OBJ_TYPE,,LATEST,$REUSABLE" >>$xmlDir/"PersistentInput_"$INCIDENT_NM".xml"
		else
			echo "none,$SRC_FLDR_NM,$OBJ_NM,$OBJ_TYPE,,LATEST," >>$xmlDir/"PersistentInput_"$INCIDENT_NM".xml"
		fi
		echo "$OBJ_NM" >>$ScriptDir/Tmp/"obj_list_"$INCIDENT_NM".csv"
	else
		#echo "skipping first line"
		echo "skipping first line"  >>$LogFileDir/$LogFileName
	fi


	count=`expr $count + 1`

	#If end of file then send email
done

pmrep objectexport -i $xmlDir/"PersistentInput_"$INCIDENT_NM".xml" -m -s -b -r -u $xmlDir/$INCIDENT_NM".xml"  | tee -a $LogFileDir/$ExportLog

return_code=$?

#if command is unsuccessful then send email with log attachment and exit
if [ $return_code -eq 0 ]
then

	echo "Objects exported successfully" | tee -a $LogFileDir/$LogFileName
else

	echo "export failed , please check log" | tee -a $LogFileDir/$LogFileName

	#remove xmls if export fails
	cd $xmlDir
	rm -f $INCIDENT_NM".xml"

	echo -e "Informatica Objects export failed"|mailx -a $LogFileDir/$ExportLog -a $LogFileDir/$LogFileName -s "$INFA Deployment Automation: $INCIDENT_NM - Objects export failed" $EMAIL
	return_code=$?

	if [ $return_code -gt 0 ]
	then

		echo "script encountered error while sending email" | tee -a $LogFileDir/$LogFileName


		exit 1
		exit 1
	fi

	exit 1
	exit 1
fi

#create object list

#echo "Below list of objects imported from reposiotry $REPOSITORY and saved in $xmlDir"
echo "Below list of objects imported from repository $REPOSITORY and saved in $xmlDir"  | tee -a $LogFileDir/$LogFileName
cat $ScriptDir/Tmp/"obj_list_"$INCIDENT_NM".csv"  | tee -a $LogFileDir/$LogFileName

#Taking an old export from Pre-Prod environment if exists. ( Export XML generates only if atleast one of the objects exists )
# Repositpory String to search
if [ $REPOSITORY == 'ISE_AWS_DEV_PC_RS_01' ] || [ $REPOSITORY == 'ISE_AWS_QTY_PC_RS_01' ] || [ $REPOSITORY == 'ISE_AWS_PROD_PC_RS_01' ] || [ $REPOSITORY == 'ISE_AWS_PREPROD_PC_RS_01' ] 
then
	INFA_REPCNX_INFO="$ScriptDir/Tmp/pmrepeuprod"$date
	export INFA_REPCNX_INFO

	Rep_Prod='ISE_AWS_PROD_PC_RS_01'
else
	RepByte=`echo $REPOSITORY | cut -b -8`
	Rep_Prod=`echo $REPOSITORY | sed "s/$RepByte/Rep_EU_R/g"`
fi
pmrep connect -d ISE_AWS_PROD_PC_01 -r $Rep_Prod -n $INFA_USR -x $INFA_PWD > /dev/null

pmrep objectexport -i $xmlDir/"PersistentInput_"$INCIDENT_NM".xml" -m -s -b -r -u $xmlold_Dir/$AQRC_USR"_"$INCIDENT_NM".XML" | tee -a $LogFileDir/"AQRC_"$INCIDENT_NM".log"

[ ! -z $Parent ] && cp -f $xmlDir/$INCIDENT_NM".xml" $xmlnew_Dir/$AQRC_USR"_"$INCIDENT_NM".XML"
[ -z $Parent ] && cp -f $xmlDir/$INCIDENT_NM".xml" $xmlnew_Dir/$AQRC_USR"_"$INCIDENT_NM".XML" 

if [ -f $xmlold_Dir/$INCIDENT_NM".XML" ]
then
	echo "Old Export already Taken"
else
	INFA_REPCNX_INFO="$ScriptDir/Tmp/pmrepusprod"$date
	export INFA_REPCNX_INFO

	Rep_Prod=`echo $REPOSITORY | sed "s/$RepByte/Rep_US_R/g"`
	pmrep connect -d ISE_AWS_US_PROD_PC_01 -r $Rep_Prod -n $INFA_USR -x $INFA_PWD > /dev/null
	pmrep objectexport -i $xmlDir/"PersistentInput_"$INCIDENT_NM".xml" -m -s -b -r -u $xmlold_Dir/$AQRC_USR"_"$INCIDENT_NM".XML" | tee -a $LogFileDir/"AQRC_"$INCIDENT_NM".log"
	[ ! -z $Parent ] && cp -f $xmlDir/$INCIDENT_NM".xml" $xmlnew_Dir/$AQRC_USR"_"$INCIDENT_NM".XML"
	[ -z $Parent ] && cp -f $xmlDir/$INCIDENT_NM".xml" $xmlnew_Dir/$AQRC_USR"_"$INCIDENT_NM".XML"
fi

echo " AQRC objects exported successfully. "
echo "Objects of AQRC completed successfully for incident number"
#echo "$OBJ_LIST"

echo -e ${body} >$ScriptDir/Tmp/"msgbody_"$INCIDENT_NM".txt"

echo -e "\n" >>$ScriptDir/Tmp/"msgbody_"$INCIDENT_NM".txt"

echo -e ${EmailSignature} >>$ScriptDir/Tmp/"msgbody_"$INCIDENT_NM".txt"

echo "AQRC Objects exported successfully for incident number $INCIDENT_NM"

#cat $ScriptDir/"msgbody"$INCIDENT_NM".txt"

( cat $ScriptDir/Tmp/"msgbody_"$INCIDENT_NM".txt" ) | mailx -a $ScriptDir/Tmp/"obj_list_"$INCIDENT_NM".csv" -a $LogFileDir/$ExportLog -s "$INFA Deployment Automation: $INCIDENT_NM - $INFA Objects exported successfully" $EMAIL

return_code=$?

if [ $return_code -gt 0 ]
then

	echo "AQRC Objects exported successfully for build number $INCIDENT_NM but script encountered error while sending success email"  | tee -a $LogFileDir/$LogFileName

fi


#done< $INVENTORY_FILE_Dir/$INVENTORY_FILE
### Start of OS migration of exported files to DEV
#path="/app/informatica/infa_shared/ISE/SrcFiles/OS_Files_List_"$INCIDENT_NM".txt"
#echo $xmlold_Dir/$INCIDENT_NM".XML" > $path
#echo $xmlnew_Dir/$INCIDENT_NM".XML" >> $path
#sh /app/informatica/infa_shared/ISE/Scripts/Run_OS_Export.sh DEV $AQRC_USR $AQRC_PWD $INCIDENT_NM
#sh /app/informatica/infa_shared/ISE/Scripts/Run_OS_Import.sh DEV $AQRC_USR $AQRC_PWD $INCIDENT_NM
### Start of OS migration of exported files to DEV


cd $ScriptDir/Tmp

rm -f "obj_list_"$INCIDENT_NM".csv"
rm -f "msgbody_"$INCIDENT_NM".txt"
rm -f "msgcheckout_"$INCIDENT_NM".txt"
rm -f "Column_count_"$INCIDENT_NM".txt"
rm -f "temp_checkout_list_"$INCIDENT_NM".txt"
rm -f "checkout_list_"$INCIDENT_NM".txt"
rm -f "temp_impacted_obj_"$INCIDENT_NM".txt"
rm -f "temp_dependencies_"$INCIDENT_NM".txt"
rm -f "dependencies_obj_"$INCIDENT_NM".txt"
rm -f "dependencies_"$INCIDENT_NM".txt"
rm -f "sorted_dependencies_"$INCIDENT_NM".txt"
rm -f "sort_impacted_obj_"$INCIDENT_NM".txt"
rm -f "sort_checkout_list"$INCIDENT_NM".txt"
rm -f "sorted_dependencies_"$INCIDENT_NM".txt"
rm -f "obj_list_"$INCIDENT_NM".csv"

exit 0



