#!/usr/bin/env bash

# ##################################################
# QRC of shell scripts in an interactive HTML format
# Based on ShellCheck https://github.com/koalaman/shellcheck#user-content-installing
#
version="1.0.0"               # Sets version variable
#
scriptTemplateVersion="1.3.0" # Version of scriptTemplate.sh that this script is based on
#                               v.1.1.0 - Added 'debug' option
#                               v.1.1.1 - Moved all shared variables to Utils
#                                       - Added $PASS variable when -p is passed
#                               v.1.2.0 - Added 'checkDependencies' function to ensure needed
#                                         Bash packages are installed prior to execution
#                               v.1.3.0 - Can now pass CLI without an option to $args
#
# HISTORY:
#
# * DATE - v1.0.0  - First Creation
#
# ##################################################

# Provide a variable with the location of this script.
scriptPath="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Source Scripting Utilities
# -----------------------------------
# These shared utilities provide many functions which are needed to provide
# the functionality in this boilerplate. This script will fail if they can
# not be found.
# -----------------------------------

scriptPath="/mnt/d/Shahrukh/C backup/Desktop/HTML/shell-scripts-master"

utilsLocation="${scriptPath}/lib/utils.sh" # Update this path to find the utilities.

if [ -f "${utilsLocation}" ]; then
  source "${utilsLocation}"
else
  echo "Please find the file util.sh and add a reference to it in this script. Exiting."
  exit 1
fi

# trapCleanup Function
# -----------------------------------
# Any actions that should be taken if the script is prematurely
# exited.  Always call this function at the top of your script.
# -----------------------------------
function trapCleanup() {
  echo ""
  if is_dir "${tmpDir}"; then
    rm -r "${tmpDir}"
  fi
  die "Exit trapped."  # Edit this if you like.
}

# Set Flags
# -----------------------------------
# Flags which can be overridden by user input.
# Default values are below
# -----------------------------------
quiet=0
printLog=0
verbose=0
force=0
strict=0
debug=0
args=()
date1=`date +'%Y%m%d%H%M%S'`
JsonFile=ShellQRC_"$date1".json
JsonCsv=ShellQRC_"$date1".csv
JsonHtml=ShellQRC_"$date1".html

# Set Temp Directory
# -----------------------------------
# Create temp directory with three random numbers and the process ID
# in the name.  This directory is removed automatically at exit.
# -----------------------------------
tmpDir="/tmp/${scriptName}.$RANDOM.$RANDOM.$RANDOM.$$"
(umask 077 && mkdir "${tmpDir}") || {
  die "Could not create temporary directory! Exiting."
}

# Logging
# -----------------------------------
# Log is only used when the '-l' flag is set.
#
# To never save a logfile change variable to '/dev/null'
# Save to Desktop use: $HOME/Desktop/${scriptBasename}.log
# Save to standard user log location use: $HOME/Library/Logs/${scriptBasename}.log
# -----------------------------------
logFile="$HOME/Library/Logs/${scriptBasename}.log"

# Check for Dependencies
# -----------------------------------
# Arrays containing package dependencies needed to execute this script.
# The script will fail if dependencies are not installed.  For Mac users,
# most dependencies can be installed automatically using the package
# manager 'Homebrew'.
# -----------------------------------
#homebrewDependencies=()

function mainScript() {
############## Begin Script Here ###################
####################################################

#echo -n
#echo -e 'Content-Type: text/html; Charset="us-ascii" ' > "$tmpDir"/"$JsonHtml"
echo "<html><head><STYLE> body {
margin:auto;
    padding:0;
    text-align:center;
}

 p {
         font-size: 15px;
        font-family: Calibri, Geneva, sans-serif;
        font-weight: bold;
        color: #606060;
}
hr {
    width: 80%;
        height: 1px;
        margin-left: auto;
        margin-right: auto;
        background-color:#8FBC8F;
        border: 0 none;
        margin-top: 0px;
        margin-bottom:0px;
}
p.header {
        text-align: center;
        font-size: 25px;
        font-family: Calibri, Geneva, sans-serif;
        font-weight: bold;
        color: #006400;
}
table.redTable {
  border: 1px solid #606060;
  font-family: Calibri, Geneva, sans-serif;
  background-color: #FFFFFF;
  width: 80%;
  text-align: center;
  border-collapse: collapse;
  margin-left: auto;
   margin-right: auto;
}
table.redTable td, table.redTable th {
  border: 1px solid #606060;
  padding: 3px 2px;

}
table.redTable tbody td {
  font-size: 13px;
  color: #606060;
}

table.redTable thead {
  background: #99CC00;

  border-bottom: 2px solid #606060;
}
table.redTable thead th {
  font-size: 15px;
  font-weight: bold;
  color: #FFFFFF;
  border-left: 2px solid #606060;
}
table.redTable thead th:first-child {
  border-left: none;
}

table.redTable tfoot td {
  font-size: 14px;
}
table.redTable tfoot .links {
  text-align: right;
}
table.redTable tfoot .links a{
  display: inline-block;
  background: #1C6EA4;
  color: #606060;
  padding: 2px 8px;
  border-radius: 5px;
}
.logo {
    display: block;
    margin-left: auto;
    margin-right: 100px;
 }
</STYLE></head><body><img width="100" height="100" src="#" alt="My Logo" class="logo"><br><hr><p class="header" > Unix Shell Scripts QRC</p><p> Hi All,<br/><br/> Below is the table report for the Shell QRC Performed for "$args".<br/> <br/></p>" >> "$tmpDir"/"$JsonHtml"
shellcheck -s "$shellname"-f json "$args" > "$tmpDir"/"$JsonFile"

if [ $? -eq 0 ]
then
	echo " $args passed all the basic AQRC checks by shellcheck " >> "$tmpDir"/"$JsonHtml"
else
echo "Generating error report"

count=$(jq -r '.[].file' "$tmpDir"/"$JsonFile" | wc -l)
i=0
rm "$tmpDir"/"$JsonCsv"
while [ $i -lt $count ]
do
        jq -j ".[$i]| .file,\",\", .level,\",\", .line,\",'\", .message,\"'\n\"" "$tmpDir"/"$JsonFile" >> "$tmpDir"/"$JsonCsv"
        i=$(expr $i + 1)
done

awk 'BEGIN{FS=","; print "<TABLE class='redTable'><thead><tr><TH>Scriptname(s)</TH><TH>Level</TH><TH>Line No.</TH><TH>Message</TH></tr></thead>"} {	out="";	if ($2 == "info"){print "<tr bgcolor=#FEEFB3 >";} 	else if ($2 == "warning") {print "<tr bgcolor=#FFBF00 >";} 	else if ($2 == "error") {print "<tr bgcolor=red >";} 	else {print "<tr>";}	for(i=1;i<=3;i++){ print "<td align=center>"$i"</td>";};	print "<td align=center>";	for(i=4;i<=NF;i++){out=out" "$i};	print out;	print "</td>";	print "</tr>"} END{print "</TABLE>"}' "$tmpDir"/"$JsonCsv" >> "$tmpDir"/"$JsonHtml"

fi

echo -en "<p><br/>Regards, <br/> <i>Name here </i> <br/> <br/></p></body></html>" >> "$tmpDir"/"$JsonHtml"

cat <<EOF - "$tmpDir"/"$JsonHtml" | /usr/sbin/sendmail -t
To: email@exmaple.com
Subject: Shell Check Report 
Content-Type: text/html
EOF

####################################################
############### End Script Here ####################
}

############## Begin Options and Usage ###################


# Print usage
usage() {
  echo -n "${scriptName} [OPTION]... [FILE]...

This is my script template.

 Options:
  -u, --username    Username for script
  -p, --password    User password
  --force           Skip all user interaction.  Implied 'Yes' to all actions.
  -q, --quiet       Quiet (no output)
  -l, --log         Print log to file
  -s, --shellname      Exit script with null variables.  i.e 'set -o nounset'
  -v, --verbose     Output more information. (Items echoed to 'verbose')
  -d, --debug       Runs script in BASH debug mode (set -x)
  -h, --help        Display this help and exit
      --version     Output version information and exit
"
}

# Iterate over options breaking -ab into -a -b when needed and --foo=bar into
# --foo bar
optstring=h
unset options
while (($#)); do
  case $1 in
    # If option is of type -ab
    -[!-]?*)
      # Loop over each character starting with the second
      for ((i=1; i < ${#1}; i++)); do
        c=${1:i:1}

        # Add current char to options
        options+=("-$c")

        # If option takes a required argument, and it's not the last char make
        # the rest of the string its argument
        if [[ $optstring = *"$c:"* && ${1:i+1} ]]; then
          options+=("${1:i+1}")
          break
        fi
      done
      ;;

    # If option is of type --foo=bar
    --?*=*) options+=("${1%%=*}" "${1#*=}") ;;
    # add --endopts for --
    --) options+=(--endopts) ;;
    # Otherwise, nothing special
    *) options+=("$1") ;;
  esac
  shift
done
set -- "${options[@]}"
unset options

# Print help if no arguments were passed.
# Uncomment to force arguments when invoking the script
 [[ $# -eq 0 ]] && set -- "--help"

# Read the options and set stuff
while [[ $1 = -?* ]]; do
  case $1 in
    -h|--help) usage >&2; exit ;;
    --version) echo "$(basename $0) ${version}"; exit ;;
    -u|--username) shift; username=${1} ;;
    -p|--password) shift; echo "Enter Pass: "; stty -echo; read -r PASS; stty echo;
      echo ;;
    -v|--verbose) verbose=1 ;;
    -l|--log) printLog=1 ;;
    -q|--quiet) quiet=1 ;;
    -s|--shellname) shift; echo shellname={1} ;;
    -d|--debug) debug=1;;
    --force) force=1 ;;
    --endopts) shift; break ;;
    *) die "invalid option: '$1'." ;;
  esac
  shift
done

# Store the remaining part as arguments.
args+=("$@")

############## End Options and Usage ###################




# ############# ############# #############
# ##       TIME TO RUN THE SCRIPT        ##
# ##                                     ##
# ## You shouldn't need to edit anything ##
# ## beneath this line                   ##
# ##                                     ##
# ############# ############# #############


# Run your script
mainScript

exit # Exit cleanly
