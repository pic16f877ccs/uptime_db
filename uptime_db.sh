#!/bin/bash
#
# The bash script creates a SQLite3 database using data, date and time (reboot, shutdown) from /var/log/wtmp
#
# Version information
SCRIPT_VERSION="0.2.0"
errors_flag=0;
show_all_tables_flag=0;
#
show_help() {
cat <<_EOF_
Usage: ./uptime_db [-h | -v | -s] [-et]
-e,    -errors,         --errors                  Show all errors
-h,    -help,           --help                    Display help
-s,    -sversion        --sversion                Show schema version
-t,    -tables,         --tables                  Display tables and views
-v,    -version,        --version                 Show version
_EOF_
}
#
options=$(getopt -l "errors,help,sversion,tables,version" -o "ehstv" -a -- "$@")
#
eval set -- "$options"
#
for var in "$@"
do 
    if [ '--help' = "$var" -o '-help' = "$var" -o '-h' = "$var" ]; then
        show_help;
        exit 0;
    fi
done
# 
for var in "$@"
do 
    if [ '--version' = "$var" -o '-version' = "$var" -o '-v' = "$var" ]; then
        if [ "$#" -gt 2 ]; then
            show_help;
            exit 0;
        else
            echo "uptime_db $SCRIPT_VERSION";
            exit 0;
        fi
    fi
done
# 
for var in "$@"
do 
    if [ '--sversion' = "$var" -o '-sversion' = "$var" -o '-s' = "$var" ]; then
        if [ "$#" -gt 2 ]; then
            show_help;
            exit 0;
        else
            sqlite3 wtmp.db3 <<<"PRAGMA schema_version";
            exit 0;
        fi
    fi
done
#
while true
do
case "$1" in
-e|--errors)
    errors_flag=1;
    ;;
-t|--tables)
    show_all_tables_flag=1;
    ;;
--)
    shift
    break;;
esac
shift
done
#
bin_to_txt() {
    utmpdump /var/log/wtmp 2> /dev/null;
}
#
bin_to_txt_err() {
    utmpdump /var/log/wtmp;
}
#
parse_csv() {
    sed -nE -e 's/^.*(shutdown|reboot).*([0-9]{4}-[0-9]{2}-[0-9]{2})T(.*),.*$/\1,\2 \3,\2,\3/gp' |\
    sed -E -e '1{/^shutdown,[0-9]{4}(-[0-9][0-9]){2} [0-9]{2}(:[0-9][0-9]){2},[0-9]{4}(-[0-9][0-9]){2},[0-9]{2}(:[0-9][0-9]){2}$/d}';
}
#
embedded_views() {
    sqlite3 wtmp.db3\
    "CREATE VIEW IF NOT EXISTS uptime AS SELECT date,\
    (SUM(uptime) / 60 / 60 / 24) || 'd ' || strftime('%Hh %mm %Ss', SUM(uptime), 'unixepoch') AS\
    uptime_perday FROM wtmp GROUP BY date;"\
    "CREATE VIEW IF NOT EXISTS on_counts AS SELECT date, COUNT(type) AS turn_ons FROM wtmp WHERE type = 'reboot' GROUP BY date;"\
    "CREATE VIEW IF NOT EXISTS total_uptime AS SELECT date || ' to ' || (SELECT date FROM wtmp ORDER BY id DESC LIMIT 1) AS\
    'date_range', (SUM(uptime) / 60 / 60 / 24) || 'd ' || strftime('%Hh %mm %Ss', SUM(uptime), 'unixepoch') AS 'total_uptime' FROM wtmp;"\
    "CREATE VIEW IF NOT EXISTS days_of_week AS SELECT date, (SELECT dow FROM day_of_week WHERE id = CAST(strftime('%u', wtmp.date) AS INTEGER)) AS\
    dow FROM wtmp;"\
    "CREATE VIEW IF NOT EXISTS uptime_rank_january AS SELECT date, (SUM(uptime) / 60 / 60 / 24) || 'd ' || strftime('%Hh %mm %Ss', SUM(uptime), 'unixepoch') AS total_uptime, ROW_NUMBER() OVER(ORDER BY SUM(uptime) DESC) AS uptime_rank FROM wtmp WHERE date LIKE '2023-01-%' GROUP BY date;"\
    "CREATE VIEW IF NOT EXISTS uptime_rank_february AS SELECT date, (SUM(uptime) / 60 / 60 / 24) || 'd ' || strftime('%Hh %mm %Ss', SUM(uptime), 'unixepoch') AS total_uptime, ROW_NUMBER() OVER(ORDER BY SUM(uptime) DESC) AS uptime_rank FROM wtmp WHERE date LIKE '2023-02-%' GROUP BY date;"\
    "CREATE VIEW IF NOT EXISTS uptime_rank_march AS SELECT date, (SUM(uptime) / 60 / 60 / 24) || 'd ' || strftime('%Hh %mm %Ss', SUM(uptime), 'unixepoch') AS total_uptime, ROW_NUMBER() OVER(ORDER BY SUM(uptime) DESC) AS uptime_rank FROM wtmp WHERE date LIKE '2023-03-%' GROUP BY date;"\
    "CREATE VIEW IF NOT EXISTS uptime_rank_april AS SELECT date, (SUM(uptime) / 60 / 60 / 24) || 'd ' || strftime('%Hh %mm %Ss', SUM(uptime), 'unixepoch') AS total_uptime, ROW_NUMBER() OVER(ORDER BY SUM(uptime) DESC) AS uptime_rank FROM wtmp WHERE date LIKE '2023-04-%' GROUP BY date;"\
    "CREATE VIEW IF NOT EXISTS uptime_rank_may AS SELECT date, (SUM(uptime) / 60 / 60 / 24) || 'd ' || strftime('%Hh %mm %Ss', SUM(uptime), 'unixepoch') AS total_uptime, ROW_NUMBER() OVER(ORDER BY SUM(uptime) DESC) AS uptime_rank FROM wtmp WHERE date LIKE '2023-05-%' GROUP BY date;"\
    "CREATE VIEW IF NOT EXISTS uptime_rank_june AS SELECT date, (SUM(uptime) / 60 / 60 / 24) || 'd ' || strftime('%Hh %mm %Ss', SUM(uptime), 'unixepoch') AS total_uptime, ROW_NUMBER() OVER(ORDER BY SUM(uptime) DESC) AS uptime_rank FROM wtmp WHERE date LIKE '2023-06-%' GROUP BY date;"\
    "CREATE VIEW IF NOT EXISTS uptime_rank_july AS SELECT date, (SUM(uptime) / 60 / 60 / 24) || 'd ' || strftime('%Hh %mm %Ss', SUM(uptime), 'unixepoch') AS total_uptime, ROW_NUMBER() OVER(ORDER BY SUM(uptime) DESC) AS uptime_rank FROM wtmp WHERE date LIKE '2023-07-%' GROUP BY date;"\
    "CREATE VIEW IF NOT EXISTS uptime_rank_august AS SELECT date, (SUM(uptime) / 60 / 60 / 24) || 'd ' || strftime('%Hh %mm %Ss', SUM(uptime), 'unixepoch') AS total_uptime, ROW_NUMBER() OVER(ORDER BY SUM(uptime) DESC) AS uptime_rank FROM wtmp WHERE date LIKE '2023-08-%' GROUP BY date;"\
    "CREATE VIEW IF NOT EXISTS uptime_rank_september AS SELECT date, (SUM(uptime) / 60 / 60 / 24) || 'd ' || strftime('%Hh %mm %Ss', SUM(uptime), 'unixepoch') AS total_uptime, ROW_NUMBER() OVER(ORDER BY SUM(uptime) DESC) AS uptime_rank FROM wtmp WHERE date LIKE '2023-09-%' GROUP BY date;"\
    "CREATE VIEW IF NOT EXISTS uptime_rank_october AS SELECT date, (SUM(uptime) / 60 / 60 / 24) || 'd ' || strftime('%Hh %mm %Ss', SUM(uptime), 'unixepoch') AS total_uptime, ROW_NUMBER() OVER(ORDER BY SUM(uptime) DESC) AS uptime_rank FROM wtmp WHERE date LIKE '2023-10-%' GROUP BY date;"\
    "CREATE VIEW IF NOT EXISTS uptime_rank_november AS SELECT date, (SUM(uptime) / 60 / 60 / 24) || 'd ' || strftime('%Hh %mm %Ss', SUM(uptime), 'unixepoch') AS total_uptime, ROW_NUMBER() OVER(ORDER BY SUM(uptime) DESC) AS uptime_rank FROM wtmp WHERE date LIKE '2023-11-%' GROUP BY date;"\
    "CREATE VIEW IF NOT EXISTS uptime_rank_december AS SELECT date, (SUM(uptime) / 60 / 60 / 24) || 'd ' || strftime('%Hh %mm %Ss', SUM(uptime), 'unixepoch') AS total_uptime, ROW_NUMBER() OVER(ORDER BY SUM(uptime) DESC) AS uptime_rank FROM wtmp WHERE date LIKE '2023-12-%' GROUP BY date;"
}
#
create_db_import() {
    sqlite3 wtmp.db3\
        "CREATE TEMP TABLE IF NOT EXISTS tmp(type TEXT NOT NULL, datetime TEXT NOT NULL UNIQUE, date TEXT NOT NULL, time TEXT);"\
        ".import --csv /dev/stdin tmp"\
        "CREATE TABLE IF NOT EXISTS wtmp(id INTEGER PRIMARY KEY, type TEXT NOT NULL, datetime TEXT NOT NULL UNIQUE, date TEXT NOT NULL, time TEXT, uptime INTEGER);"\
        "CREATE TRIGGER IF NOT EXISTS insert_wtmp AFTER INSERT ON wtmp BEGIN UPDATE wtmp SET uptime = strftime('%s', (SELECT datetime FROM wtmp WHERE id = NEW.id)) - strftime('%s', (SELECT datetime FROM wtmp WHERE id = (NEW.id - 1) AND type = 'reboot')) WHERE id = NEW.id AND type = 'shutdown'; end;"\
        "INSERT OR IGNORE INTO wtmp(type, datetime, date, time) SELECT type, datetime, date, time FROM tmp;"\
        "CREATE TABLE IF NOT EXISTS day_of_week (id INTEGER NOT NULL UNIQUE, dow TEXT NOT NULL UNIQUE);"\
        "INSERT INTO day_of_week (id, dow) VALUES(1, 'monday'), (2, 'tuesday'), (3, 'wednesday'), (4, 'thursday'), (5, 'friday'), (6, 'saturday'), (7, 'sunday') ON CONFLICT DO NOTHING;"
    embedded_views;
}
#
import_update_tb() {
    sqlite3 wtmp.db3\
    "CREATE TEMP TABLE IF NOT EXISTS tmp(type TEXT NOT NULL, datetime TEXT NOT NULL UNIQUE, date TEXT NOT NULL, time TEXT);"\
    ".import --csv /dev/stdin tmp"\
    "INSERT OR IGNORE INTO wtmp(type, datetime, date, time) SELECT type, datetime, date, time FROM tmp;"
}
#
if [ "$errors_flag" -eq 1 ]; then
    bin_to_txt_err | parse_csv | create_db_import
else
    bin_to_txt | parse_csv | create_db_import
fi
#
if [ "$show_all_tables_flag" -eq 1 ]; then
    sqlite3 wtmp.db3 <<<"PRAGMA table_list";
fi
#
