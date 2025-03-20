#!/bin/bash

# Set Oracle Environment Variables
export ORACLE_HOME=/u01/app/oracle/product/19c/dbhome_1
export ORACLE_BASE=/u01/app/oracle
export PATH=$ORACLE_HOME/bin:$PATH
export ORATAB=/etc/oratab

# Header for Output
echo "------------------------------------------------------------"
echo "  ORACLE DATABASE STATUS REPORT  - $(date)"
echo "------------------------------------------------------------"
printf "%-15s %-10s %-12s %-15s %-15s %-12s\n" "DATABASE" "STATUS" "LOG_MODE" "UPTIME" "ARCHIVE_MODE" "ACTIVE_SESSIONS"
echo "------------------------------------------------------------"

# Loop through each running database in /etc/oratab
grep -v '^#' $ORATAB | awk -F: '{print $1}' | while read DB_NAME
do
  # Set ORACLE_SID
  export ORACLE_SID=$DB_NAME
  
  # Check Database Status
  STATUS=$(sqlplus -s / as sysdba <<EOF
SET HEADING OFF;
SET FEEDBACK OFF;
SELECT status FROM v\$instance;
EXIT;
EOF
  )

  # Check Log Mode
  LOG_MODE=$(sqlplus -s / as sysdba <<EOF
SET HEADING OFF;
SET FEEDBACK OFF;
SELECT log_mode FROM v\$database;
EXIT;
EOF
  )

  # Check Uptime
  UPTIME=$(sqlplus -s / as sysdba <<EOF
SET HEADING OFF;
SET FEEDBACK OFF;
SELECT TO_CHAR(sysdate-startup_time, 'HH24:MI:SS') FROM v\$instance;
EXIT;
EOF
  )

  # Check Archive Mode
  ARCHIVE_MODE=$(sqlplus -s / as sysdba <<EOF
SET HEADING OFF;
SET FEEDBACK OFF;
SELECT log_mode FROM v\$database;
EXIT;
EOF
  )

  # Check Active Sessions
  ACTIVE_SESSIONS=$(sqlplus -s / as sysdba <<EOF
SET HEADING OFF;
SET FEEDBACK OFF;
SELECT COUNT(*) FROM v\$session WHERE status='ACTIVE';
EXIT;
EOF
  )

  # Display results in a formatted table
  printf "%-15s %-10s %-12s %-15s %-15s %-12s\n" "$DB_NAME" "$STATUS" "$LOG_MODE" "$UPTIME" "$ARCHIVE_MODE" "$ACTIVE_SESSIONS"
done

echo "------------------------------------------------------------"
