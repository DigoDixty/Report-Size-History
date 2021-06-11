#!/bin/bash

time psql -d warehouse -f reload_list_check_drop.sql

time psql -d warehouse -c "SELECT script_test FROM admin.tb_drop_check WHERE INFO = 'CHECK' ORDER BY schemaname, tablename, partitionrank DESC" -t > query_check_tables.sql

time psql -d warehouse -f query_check_tables.sql
