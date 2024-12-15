# you can use gmail application password feature because with default mail function in linux, google will not accept mail sended by your machine even script will not return any error while sending mail.
#! /usr/bin/env bash

export ORACLE_HOME="/u01/app/oracle/product/21.0.0/dbhome_1"
export PATH="$ORACLE_HOME/bin:$PATH"

# use dbsnmp user
email_to="blabla@gmail.com"
user=${1}
password=${2}
server=${3}
port="1521"
svc=${4}
ssh_user="oracle"
lock_dir=/home/oracle/scripts/monitoring/
lock_file_local=monsh_${server}_lock


function logprefix()
{
    date '+%Y-%m-%d %H-%M-%S'
}

function logging()
{
    # shellcheck disable=SC2068
    echo $(logprefix) : $server : $svc : $@
}

function send_email
{
mail -s "$1" $email_to <<< "$2"
}

function disc_usage {
        logging "Checking $2 partition Use% on $1 host"
        use_per=$(ssh -o "StrictHostKeyChecking no" ${ssh_user}@${1} df -h | grep ${2}\$ | awk '{print $5}' | sed 's/%//g')
        if (( $use_per > 85 ))
        then
                logging "ERR: $2 partition Use% on $1 host is too high: ${use_per}%"
                send_email "DB_Monitoring: ERR: $2 partition Use% on $1 host is too high: ${use_per}%" "$( logging 'WARNING: Space issue with partition. DBA should investigate in bussiness time. Possible solution is to run scripts in cron')"
        else
                logging "INFO: $2 partition Use% on $1 host OK: ${use_per}%"
        fi
}

function load_avg {
        logging "INFO: Checking Load average for $1:"
        loadavg_string=$(ssh -o "StrictHostKeyChecking no" ${ssh_user}@${1} cat /proc/loadavg)
        proc_number=$(ssh -o "StrictHostKeyChecking no"  ${ssh_user}@${1} nproc)
        logging "INFO: loadavg_string: $loadavg_string, number_of_proc: $proc_number"
        loadavg1=$(echo $loadavg_string | awk '{print $1}')
        loadavg2=$(echo $loadavg_string | awk '{print $2}')
        if (( $( echo "$( bc <<< "$proc_number - $loadavg1" ) < 0" | bc -l) && $( echo "$( bc <<< "$proc_number - $loadavg2" ) < 0" | bc -l) ))
        then
          logging "WARNING: load average is high on $1 : $loadavg_string : proc_number: $proc_number "
          logging "Sending email..."
          send_email "DB_Monitoring: WARNING: load average check on $1 loadavg: $loadavg_string : proc_number: $proc_number" "$( logging 'WARNING: load average is high. DB_OPS should investigate in bussiness time.')"
        else
          logging "INFO: load average is OK on $1 : $loadavg_string : proc_number: $proc_number"
        fi

}



CONN="${user}/${password}@${server}:${port}/${svc}"

query_header="
SET PAGESIZE 0;
SET FEEDBACK OFF;
SET VERIFY OFF;
SET SERVEROUTPUT ON;
SET HEADING OFF;
"

sql_connection_check="SELECT 'SUCCESS' FROM dual;"
sql_blocked_sessions="select INST_ID,SQL_ID,BLOCKING_SESSION,BLOCKING_SESSION_STATUS,SID,SERIAL#,USERNAME,OSUSER,PROCESS,MACHINE,PROGRAM,WAIT_CLASS,SECONDS_IN_WAIT,CON_ID from  gv\$session where blocking_session is not NULL and seconds_in_wait > 60 order by blocking_session;"
sql_users_with_expired_passwords="select c.name con_name, u.username, u.account_status, u.expiry_date, u.profile, u.created, u.last_login from cdb_users u join v\$containers c on c.con_id = u.con_id where u.con_id > 2 and u.common = 'NO' and u.authentication_type = 'PASSWORD' and u.expiry_date <= trunc(sysdate) + 10 order by u.expiry_date;"
sql_check_backups="select t.name, t.CREATION_TIME from ( select pdbs.name,pdbs.con_id, pdbs.CREATION_TIME from v\$pdbs pdbs left join (select to_char(START_TIME,'yyyy/mm/dd') btime, CON_ID, SUM(PIECES) bpieces from gv\$backup_set where  INCREMENTAL_LEVEL=0 and  CURRENT_DATE - COMPLETION_TIME <=8 and CON_ID !=2  group by to_char(START_TIME,'yyyy/mm/dd'), CON_ID order by to_char(START_TIME,'yyyy/mm/dd'), CON_ID ) backup_set on pdbs.con_id = backup_set.con_id where backup_set.con_id is null ) t where t.con_id !=2;"

sql_list="
sql_connection_check
sql_blocked_sessions
sql_users_with_expired_passwords
sql_check_backups
"

# Check if lockfile exists
test -f ${lock_dir}/${lock_file_local} && ( logging "Lock file exists for ${server}. mon.sh script is already running" && send_email "DB_Monitoring: WARNING: ${lock_file_local} file detected on $server - Attempt of 2nd launch"  ) && exit 0

# Put lockfile
touch ${lock_dir}/${lock_file_local}


logging "Performing SQL checks ..."

for sql_query_name in ${sql_list}
do
  #echo "sql_query_name: ${sql_query_name}"
  # variable reference "inside" another variable:
  sql_query_val=$(eval "echo \${$sql_query_name}")
  #echo "sql_query_val: ${sql_query_val}"
  query_result=$(echo "
  ${query_header}
  ${sql_query_val}" | sqlplus -s  $CONN)

  if [ -z "${query_result}" ]
  then	  
     logging "INFO: No result returned for  ${sql_query_name}"
  else
    if [ $sql_query_name == 'sql_connection_check' ]
    then
	if [ $query_result != 'SUCCESS' ]
	then
	   logging "ERR: Connection check failed for ${sql_query_name} query: ${query_result}"
	   logging "Sending email..."
	   send_email "DB_Monitoring: ERR: Connection check failed for ${sql_query_name} query" "$( logging 'SQL returned not SUCCESSFUL status' )"
	   continue
        else
           logging "INFO: Connection check is SUCCESSFULL for ${sql_query_name} query."		
	   continue
	fi
    fi
    logging "ERR: SQL returned result for ${sql_query_name} query : ${query_result}"
    logging "Sending email..."
    send_email "DB_Monitoring: ERR: SQL returned result for ${sql_query_name} query" "$( logging 'SQL returned result' )"
  fi
done    

logging "Performing OS checks ..."

disc_usage $server /
disc_usage $server /dev/shm
load_avg $server

rm ${lock_dir}/${lock_file_local}
