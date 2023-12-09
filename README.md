# WTMP to SQLite

This repository contains a Bash script that processes the Linux `wtmp` file and converts the information into a SQLite3 database. The script creates several views on the database for convenient querying of system uptime and reboot counts.

## Getting Started

### Prerequisites

- Ensure you have `bash` and `sqlite3` installed on your Linux system.
- You must have read permissions for `/var/log/wtmp`.

### Installing

1. Clone the repository or download the Bash script to your local machine.

   ```bash
   git clone https://github.com/pic16f877ccs/uptime_db
   ```

   or simply download `uptime_db.sh`.

2. Navigate to the directory containing the script.

   ```bash
   cd uptime_db
   ```

3. Make the script executable.

   ```bash
   chmod +x uptime_db.sh
   ```

### Usage

1. Run the script.

   ```bash
   ./uptime_db.sh
   ```

   The script will create a SQLite database named `wtmp.db3` containing the processed `wtmp` data.

2. Access the database and execute view queries to get information.

   ```bash
   sqlite3 wtmp.db3
   ```

   Then you can run SQL queries. For instance, to see the uptime per day:

   ```sql
   SELECT * FROM uptime;
   ```

## Views

Several views have been created in the SQLite database:

- `uptime`: Shows the uptime per day.
- `on_counts`: Shows the count of reboots per day.
- `total_uptime`: Shows the total uptime.
- `uptime_rank_january`: Shows the uptime rank for January.
- `uptime_rank_february`: Shows the uptime rank for February.

You can query these views just like regular tables.

## Common Queries

Here are some common queries you can execute on the views:

1. To see the total number of reboots per day in November:

   ```sql
   SELECT * FROM on_counts WHERE date LIKE '2023-11-%';
   ```

2. To get the total uptime until the latest logged date:

   ```sql
   SELECT * FROM total_uptime;
   ```

3. To view the daily uptime ranking for October:

   ```sql
   SELECT * FROM uptime_rank_october;
   ```

4. To check the uptime for a specific date:

   ```sql
   SELECT uptime FROM uptime WHERE date = 'YYYY-MM-DD';
   ```

Replace `'YYYY-MM-DD'` with the desired date.

## License

This project is licensed under the [GPL-3.0 license](LICENSE).

## Acknowledgments

- `utmpdump` for providing the raw `wtmp` data.
- The SQLite team for the awesome database engine.
- The Linux community for continuing to support open-source projects.
<!--- This readme file created by ChatGPT-4 --->

```
