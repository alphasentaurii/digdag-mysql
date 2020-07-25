# digdag

In this project, we'll create a digdag workflow that executes an embulk script for ingesting csv files to a MySQL database. We'll then write SQL queries to prepare and analyze the data.

## About Embulk and Digdag

Embulk and Digdag are open source libraries for data ingestion and data pipeline orchestration,
respectively. These libraries were invented at Treasure Data and are foundational to the Treasure Data
product.

## Directory structure
.
├── README.md
└── embulk_to_mysql
  └── embulk_to_mysql.dig
  └── seed_customers.yml
  └── seed_pageviews.yml
  └── config_customers.yml
  └── config_pageviews.yml
  └── data
    └── customers
        └── customers_1.csv
        └── customers_2.csv
    └── pageviews
        └── pageviews_1.csv
        └── pageviews_2.csv

## Pre-requisites

- `sudo` privileges
- digdag
- embulk
- mysql/mariadb
- java 9 (embulk doesn't support Java 10,11,12 yet)

### Installing Java RE

Check which version of Java you're running. If you get an runtime error saying Java is not installed (when you go to run digdag or embulk) follow the steps below.

```bash
$ java -version
```

*Note: these are the steps for installing Java 9 from Oracle on an AWS remote server running Debian 9. If you're using a different environment you will need to adjust accordingly.

1. Download the tar file from ![Oracle](https://www.oracle.com/java/technologies/javase/javase9-archive-downloads.html): jdk-9.0.4_linux-x64_bin.tar.gz

2. Copy (`scp`) the tar file to the remote server
3. Unzip tar file into your JVM directory (you may need to create first)
4. Install Java
5. Set Java directory
6. Check version

```bash
$ sudo mkdir /usr/lib/jvm

$ sudo tar zxvf jre-8u261-linux-x64.tar.gz -C /usr/lib/jvm

$ sudo update-alternatives --install "/usr/bin/java" "java" "/usr/lib/jvm/jre1.8.0_261/bin/java" 1

$ sudo update-alternatives --set java /usr/lib/jvm/jre1.8.0_261/bin/java

$ java -version
java version "1.8.0_261"
Java(TM) SE Runtime Environment (build 1.8.0_261-b12)
Java HotSpot(TM) 64-Bit Server VM (build 25.261-b12, mixed mode)
```

 *For more in-depth doc on JAVA go here:*
https://docs.datastax.com/en/jdk-install/doc/jdk-install/installOracleJdkDeb.html

### Switch to root

```bash
$ sudo -s
```

### Install `digdag`

```bash
$ curl -o ~/bin/digdag --create-dirs -L "https://dl.digdag.io/digdag-latest"
$ chmod +x ~/bin/digdag
$ echo 'export PATH="$HOME/bin:$PATH"' >> ~/.bashrc
```

#### Check installation was successful

Check to make sure `digdag` is installed correctly:

```bash
$ digdag --help
```
### Install Embulk

```bash
curl --create-dirs -o ~/.embulk/bin/embulk -L "https://dl.embulk.org/embulk-latest.jar"
chmod +x ~/.embulk/bin/embulk
echo 'export PATH="$HOME/.embulk/bin:$PATH"' >> ~/.bashrc
source ~/.bashrc
```

### Install MariaDB/MySQL

```bash
$ sudo apt install mariadb-server -y
$ sudo apt install mysql-secure-installation
Enter current password for root (enter for none): [enter]
Set root password? [Y/n] n
 ... skipping.
Remove anonymous users? [Y/n] y
Disallow root login remotely? [Y/n] y
Remove test database and access to it? [Y/n] y
Reload privilege tables now? [Y/n] y
```

#### Create Database

```bash
$ sudo mariadb

Welcome to the MariaDB monitor.  Commands end with ; or \g.
Your MariaDB connection id is 53
Server version: 10.3.22-MariaDB-0+deb10u1 Debian 10

Copyright (c) 2000, 2018, Oracle, MariaDB Corporation Ab and others.

Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.

MariaDB> CREATE DATABASE td_coding_challenge DEFAULT CHARACTER SET utf8 COLLATE utf8_unicode_ci;
Query OK, 1 row affected (0.003 sec)

MariaDB> GRANT ALL ON td_coding_challenge.* TO 'digdag'@'localhost' IDENTIFIED BY 'digdag' WITH GRANT OPTION;
Query OK, 0 rows affected (0.000 sec)

MariaDB> FLUSH PRIVILEGES;
Query OK, 0 rows affected (0.000 sec)

MariaDB> exit
```

#### Test non-root user login

```bash
$ mariadb -u digdag -p
Enter password: 
Welcome to the MariaDB monitor.  Commands end with ; or \g.
Your MariaDB connection id is 54
Server version: 10.3.22-MariaDB-0+deb10u1 Debian 10

Copyright (c) 2000, 2018, Oracle, MariaDB Corporation Ab and others.

Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.

MariaDB [(none)]> SHOW DATABASES;
+---------------------+
| Database            |
+---------------------+
| information_schema  |
| td_coding_challenge |
+---------------------+
2 rows in set (0.000 sec)

MariaDB [(none)]> exit
```

## Install MySQL OutputPlugin

```bash
$ embulk gem install embulk-output-mysql
```

# Data Ingestion

## Create EMBULK Scripts

*Requirements*

- Files that have a prefix of “customers” should ingest to a table called “customers_tmp”
- Files that have a prefix of “pageviews” should ingest to a table called “pageviews_tmp”
- Ensure that all records from all files are ingested to the appropriate tables. 
- Any timestamps should be ingested to the database as `string/varchar`

### Customers Embulk Script

```bash
$ sudo nano seed_customers.yml
```

```bash
# seed_customers.yml
in:
  type: file
  path_prefix: ./data/customers/
  parser:
    charset: UTF-8
    newline: CRLF
    type: csv
    delimiter: ','
    quote:: '"'
    escape: null
    null_string: 'NULL'
    skip_header_lines: 1
    columns:
    - {name: user_id, type: string}
    - {name: first_name, type: string}
    - {name: last_name, type: string}
    - {name: job_title, type: string}
out:
  type: mysql
  host: localhost
  user: digdag
  password: digdag
  database: td_coding_challenge
  table: customers_tmp
  mode: insert
```

### Pageviews Embulk Script

```bash
$ sudo nano seed_pageviews.yml
```

```bash
# seed_pageviews.yml
in:
  type: file
  path_prefix: ./data/pageviews/
  parser:
    charset: UTF-8
    newline: CRLF
    type: csv
    delimiter: ','
    quote:: '"'
    escape: null
    null_string: 'NULL'
    skip_header_lines: 1
    columns:
    - {name: user_id, type: string}
    - {name: url, type: string}
    - {name: user_agent, type: string}
    - {name: timestamp, type: string, format: varchar}
out:
  type: mysql
  host: localhost
  user: digdag
  password: digdag
  database: td_coding_challenge
  table: pageviews_tmp
  mode: insert
```

---

## SQL Queries

### Customers Table

Creates a new table called `customers` that:
- Includes all columns from customers_tmp
- Parses the “user_agent” column to add a new column called ‘operating_system’ that contains one of the following values ("Windows", "Macintosh", "Linux", or "Other"). 

`create_customers.sql`

```sql
--create_customers.sql
CREATE TABLE customers 
SELECT c.user_id, c.first_name, c.last_name, c.job_title, p.user_agent AS operating_system 
FROM pageviews_tmp p 
JOIN customers_tmp c 
ON p.user_id = c.user_id 
GROUP BY user_id;

UPDATE customers 
  SET operating_system = 'Macintosh' 
  WHERE operating_system LIKE '%Mac%';

UPDATE customers 
  SET operating_system = 'Linux' 
  WHERE operating_system LIKE '%X11%';

UPDATE customers 
  SET operating_system = 'Windows' 
  WHERE operating_system LIKE '%Windows%';

UPDATE customers 
  SET operating_system = 'Other'
  WHERE operating_system NOT REGEXP 'Macintosh|Linux|Windows';
```

`update_customers.sql`

```sql
--update_customers.sql
UPDATE customers 
  SET operating_system = 'Macintosh' 
  WHERE operating_system LIKE '%Mac%';

UPDATE customers 
  SET operating_system = 'Linux' 
  WHERE operating_system LIKE '%X11%';

UPDATE customers 
  SET operating_system = 'Windows' 
  WHERE operating_system LIKE '%Windows%';

UPDATE customers 
  SET operating_system = 'Other'
  WHERE operating_system NOT REGEXP 'Macintosh|Linux|Windows';
```

### Pageviews Table

Creates a new table called `pageviews` that:
- Includes all columns from pageviews_tmp
- Excludes all records where job_title contains “Sales”

`create_pageviews.sql`
```sql
--create_pageviews.sql
CREATE TABLE pageviews 
SELECT * FROM pageviews_tmp
WHERE user_id IN 
(SELECT user_id
FROM customers
WHERE job_title NOT LIKE '%Sales%');
```

### Count Pageviews

Returns the total number of pageviews from users who are browsing with a Windows operating system or have “Engineer” in their job title.

`count_pageviews.sql`

```sql
--count_pageviews.sql--
SELECT COUNT(url) AS total_views 
FROM pageviews 
WHERE user_id 
IN (
  SELECT user_id 
  FROM customers 
  WHERE operating_system = 'Windows' 
  OR job_title LIKE '%Engineer%'
  )
```
Returns:

```bash
+-------------+
| total_views |
+-------------+
|        576  |
+-------------+
1 row in set (0.009 sec)
```

### Top 3 Users and Last Page Viewed

Returns top 3 user_id’s (ranked by total pageviews) who have viewed a web page with a “.gov” domain extension and the url of last page they viewed.

`top_3_users.sql`

```sql
--top_3_users.sql
WITH p2 AS(
	SELECT user_id, max(timestamp) AS last_timestamp 
	FROM pageviews 
	WHERE user_id 
  IN (
      SELECT user_id 
      FROM pageviews 
			WHERE url LIKE '%.gov%'
      ) 
	GROUP BY user_id 
	ORDER BY COUNT(url) DESC 
	LIMIT 3
  ) 
SELECT user_id, url AS last_page_viewed 
FROM pageviews 
WHERE user_id 
IN (
    SELECT user_id 
		FROM p2 
		WHERE timestamp=last_timestamp
    );
```
Returns:

```bash
+--------------------------------------+--------------------------------------------+
| user_id                              | last_page_viewed                           |
+--------------------------------------+--------------------------------------------+
| 5d9b8515-823e-49b8-ad44-5c91ef23462f | https://microsoft.com/morbi/porttitor.aspx |
| 6cf36c9e-1fa7-491d-a6e1-9c785d68a3d0 | http://nps.gov/quis/odio/consequat.json    |
| 752119fa-50dc-4011-8f13-23aa8d78eb18 | http://goo.ne.jp/nunc.html                 |
+--------------------------------------+--------------------------------------------+
3 rows in set (0.011 sec)
```

## Write a digdag workflow

```bash
$ digdag init embulk_to_mysql.dig
$ cd embulk_to_mysql.dig
$ sudo nano embulk_to_mysql.dig
```


```bash
# embulk_to_mysql.dig
timezone: UTC

_export:
  workflow_name: "embulk_to_mysql"
  start_msg:     "digdag ${workflow_name} start"
  end_msg:       "digdag ${workflow_name} finish"
  error_msg:     "digdag ${workflow_name} error"
  mysql:
    host: localhost
    port: 3306
    user: digdag
    password: digdag
    database: td_coding_challenge
    strict_transaction: false

+start:
  echo>: ${start_msg}

+guesstest:
  _parallel: true

# create embulk config files
  +guess_embulkCust:
    sh>: embulk guess seed_customers.yml -o config_customers.yml

  +guess_embulkPage:
    sh>: embulk guess seed_pageviews.yml -o config_pageviews.yml

# Data Ingestion
# Load database tmp tables

+loadDB:
  _parallel: true
  
  +csv_to_db_Cust:
    sh>: embulk run config_customers.yml

  +csv_to_db_Page:
    sh>: embulk run config_pageviews.yml

# Create/update new tables

+updateDB:
  +createCust:
    mysql>: create_customers.sql
  +updateCust:
    mysql>: update_customers.sql
  +createPage:
    mysql>: create_pageviews.sql

# Data Analysis
+runQueries:
  _parallel: true
  
  +query1:
    mysql>: count_pageviews.sql
  
  +query2:
    mysql>: top_3_users.sql

# End of Workflow
+end:
  echo>: ${end_msg}

_error:
  echo>: ${error_msg} 
```

## Run Digdag workflow

```bash
# If this isn't your first time running the workflow, use the --rerun flag 
$ digdag run embulk_to_mysql.dig --rerun -O log/task
```