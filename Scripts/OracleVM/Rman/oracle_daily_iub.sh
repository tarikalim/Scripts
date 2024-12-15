#!/bin/bash

export ORACLE_HOME=/u01/app/oracle/product/21.0.0/dbhome_1
export PATH=$PATH:$ORACLE_HOME/bin
export NLS_DATE_FORMAT='YYYY-MM-DD HH24:MI:SS'
export ORACLE_SID=cdb1

# Check if lockfile exists
test -f /home/oracle/scripts/rman_$ORACLE_SID.lock && echo "Lock file exists for $ORACLE_SID. It seems backup is already running or not finished yet" && exit 0

# Put lockfile
touch /home/oracle/scripts/rman_$ORACLE_SID.lock

# Set incremental backup level. back_lvl variable value depends on the current day. If it is Saturday (Saturday=6) the back_lvl value is 0. If it is any other day back_lvl value will be 1
if (($(`date +%u`) == 1)); then
   back_lvl=0
else
   back_lvl=1
fi

date "+%Y-%m-%d %H:%M:%S"
echo "RMAN backup script for $ORACLE_SID started"

# The main block:
rman target=/<<EOF
   configure archivelog deletion policy to backed up 1 times to disk;
   configure compression algorithm 'medium';
   configure device type disk parallelism 2 backup type to backupset;
   configure retention policy to recovery window of 7 days;
   configure controlfile autobackup on;
   crosscheck archivelog all;
   run {
      delete noprompt obsolete;
      backup as compressed backupset incremental level $back_lvl database plus archivelog not backed up;
   }
   exit;
EOF

# Remove lock file
rm /home/oracle/scripts/rman_$ORACLE_SID.lock

date "+%Y-%m-%d %H:%M:%S"
echo "RMAN backup script for $ORACLE_SID finished"