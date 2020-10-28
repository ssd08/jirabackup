#!/bin/bash



#-------------------------------------------------------------------------------
# Comments
# Name: Jira Backup
# Author: ssd08
# About: backs up Jira database and JIRA HOME data directory.
# Requires:
#   - Remote storage to be mounted (NFS or SMB or... ).
# Tested:
#   - Bash 4.3
#   - Jira 7.8.1
#   - MySQL 14.14
#   - NFS version 3
#-------------------------------------------------------------------------------



#-------------------------------------------------------------------------------
# Function
# About: prints title of script in shell
# Accepts: null
# Returns: null
#-------------------------------------------------------------------------------
prnt_title()
{
  local char="="
  local -i i
  printf "\n"
  for (( i=1; i<=80; i++ )); do printf ${char}; done
  printf "\n                                  Jira Backup\n\n"
  printf "                       Say, have you read the HIPAA today?\n\n"
  printf "  HIPAA at bed and HIPAA at rise, keeps me employed and the company"
  printf " un-fined.\n"
  for (( i=1; i<=80; i++ )); do printf ${char}; done
  printf "\n\n"
  return
}



#-------------------------------------------------------------------------------
# Function
# About: checks if destination for backups is mounted at $dest
# Accepts: $dest as unitary argument
# Returns: null
#-------------------------------------------------------------------------------
chk_dest()
{
  if [ ! -d $1 ]; then
    printf "Error: destination path for backups does not exist.\n"
    printf "%s\n\n" "$1"
    exit 1
  fi
  sleep 1
  return
}



#-------------------------------------------------------------------------------
# Function
# About: checks if destination for backups is mounted at $dest
# Accepts: $dest as unitary argument
# Returns: null
#-------------------------------------------------------------------------------
chk_mnt_point()
{
  mount | grep $1 &> /dev/null
  mount_exist=$?
  if [ ${mount_exist} -eq 1 ]; then
    printf "Error: nothing currently mounted at the mount point for backups.\n"
    printf "%s\n\n" "$1"
    exit 2
  fi
  sleep 1
  return
}



#-------------------------------------------------------------------------------
# Main
#-------------------------------------------------------------------------------
declare dest=/mnt/jiraback
declare jirahome=/var/atlassian/application-data/jira
declare db=
declare dbuser=
declare dbpass=
declare timestamp=$(date +\%Y-\%m-\%d-\%I\%M\%p)


prnt_title
sleep 3

chk_dest $dest

chk_mnt_point $dest

printf "Dumping copy of Jira database to JIRA HOME\n(${jirahome})\n\n"
sleep 5
mysqldump $db -u${dbuser} -p${dbpass} -v > ${jirahome}/jira.sql


printf "Backing up Jira data/ and Jira database copy to the following:\n"
printf "${dest}\n\n"
sleep 6

tar cfvz ${dest}/jira-backup-${timestamp}.tar.gz \
-C ${jirahome} ./data ./jira.sql

if [[ $? -ne 0 || ! -e ${dest}/jira-backup-${timestamp}.tar.gz ]]; then
  printf "Error: failed to back up Jira to the following destination:\n"
  printf "$dest\n\n"
  exit 3
fi

printf "\n\nJira Backup completed successfully.\n\n"

printf "Removing copy of Jira database from JIRA HOME...\n"
rm -f ${jirahome}/${db}.sql
[[ $? -eq 0 ]] || printf "Error: cannot remove Jira Db copy from JIRA HOME\n\n"

printf "\n\nIMO, the safest command to extract this backup would be:\n\n"
printf "tar xvf jira-backup-${timestamp}.tar.gz -C /tmp\n\n"
printf "Bye\n\n"
exit 0