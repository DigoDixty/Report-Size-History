#!/bin/bash

time psql -d warehouse -f list_of_drop.sql -t > list_drop_checked_tbs.sql

#time psql -d warehouse -f list_drop_checked_tbs.sql
