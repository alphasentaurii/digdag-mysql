# digdag

In this project, we'll create a digdag workflow that executes an embulk script for ingesting csv files to a MySQL database. We'll then write SQL queries to prepare and analyze the data.

## About Embulk and Digdag

Embulk and Digdag are open source libraries for data ingestion and data pipeline orchestration,
respectively. These libraries were invented at Treasure Data and are foundational to the Treasure Data
product.

## Directory structure
.
├── README.md
└── customers.yml
└── pageviews.yml
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
# $ sudo tar zxvf jdk-11.0.7_linux-x64_bin.tar.gz -C /usr/lib/jvm
# $ sudo update-alternatives --install "/usr/bin/java" "java" "/usr/lib/jvm/jdk-11.0.7/bin/java" 1
# update-alternatives: using /usr/lib/jvm/jdk-11.0.7/bin/java to provide /usr/bin/java (java) in auto mode
# $ sudo update-alternatives --set java /usr/lib/jvm/jdk-11.0.7/bin/java
#java version "11.0.7" 2020-04-14 LTS
#Java(TM) SE Runtime Environment 18.9 (build 11.0.7+8-LTS)
#Java HotSpot(TM) 64-Bit Server VM 18.9 (build 11.0.7+8-LTS, mixed mode)

$ sudo tar zxvf jdk-9.0.4_linux-x64_bin.tar.gz -C /usr/lib/jvm

$ sudo update-alternatives --install "/usr/bin/java" "java" "/usr/lib/jvm/jdk-9.0.4/bin/java" 1

$ sudo update-alternatives --set java /usr/lib/jvm/jdk-9.0.4/bin/java

$ java -version
java version "9.0.4"
Java(TM) SE Runtime Environment (build 9.0.4+11)
Java HotSpot(TM) 64-Bit Server VM (build 9.0.4+11, mixed mode)
```

 *For more in-depth doc on JAVA go here:*
https://docs.datastax.com/en/jdk-install/doc/jdk-install/installOracleJdkDeb.html

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

Gem plugin path is: /home/jester/.embulk/lib/gems

Fetching: embulk-output-mysql-0.8.7.gem (100%)
Successfully installed embulk-output-mysql-0.8.7
1 gem installed
```

## Create EMBULK Scripts

*Requirements*

- Files that have a prefix of “customers” should ingest to a table called “customers_tmp”
- Files that have a prefix of “pageviews” should ingest to a table called “pageviews_tmp”
- Ensure that all records from all files are ingested to the appropriate tables. 
- Any timestamps should be ingested to the database as `string/varchar`*

### Customers Embulk Script

```bash
$ sudo nano config1.yml
```

```bash
in:
  type: file
  path_prefix: ./data/customers/
  decoders:
  - {type: gzip}
  parser:
    charset: UTF-8
    newline: CRLF
    type: csv
    delimiter: ','
    quote:: '"'
    escape: ''
    null_string: 'NULL'
    skip_header_lines: 1
    columns:
    - {name: user_id, type: long}
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

### Embulk Guess

```bash
$ embulk guess config1.yml -o customers.yml
```
### Preview from input source

```bash
$ embulk preview customers.yml
```

### Run script

```bash
$ embulk run customers.yml
```

## Pageviews Embulk Script

```bash
$ sudo nano config2.yml
```

```bash
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
    - {name: user_id, type: long}
    - {name: url, type: string}
    - {name: user_agent, type: long}
    - {name: time, type: timestamp, format: '%Y-%m-%d %H:%M:%S'}
filters:
    - type: timestamp_format
    default_from_timestamp_format: ["%Y-%m-%d %H:%M:%S.%N %z", "%Y-%m-%d %H:%M:%S %z"]
    default_to_timezone: "UTC"
    default_to_timestamp_format: "%Y-%m-%d %H:%M:%S.%N"
    columns:
        - {name: time, type: long, to_unit: ms}
        - {name: $.nested.timestamp}
out:
  type: mysql
  host: localhost
  user: digdag
  password: digdag
  database: td_coding_challenge
  table: pageviews_tmp
  mode: insert
```

### Embulk Guess

```bash
$ embulk guess config2.yml -o pageviews.yml
```
### Preview from input source

```bash
$ embulk preview pageviews.yml
```

### Run script

```bash
$ embulk run pageviews.yml
```

---

## Write a digdag workflow

```bash
$ digdag init embulk_to_mysql.dig
$ cd mydag
$ sudo nano mysql_dag.dig
```

```bash
# mydag.dig
timezone: UTC

+setup:
  echo>: start ${session_time}

+disp_current_date:
  echo>: ${moment(session_time).utc().format('YYYY-MM-DD HH:mm:ss Z')}

+repeat:
  for_each>:
    #order: [first, second, third]
    #animal: [dog, cat]
  _do:
    #echo>: ${order} ${animal}
  _parallel: true

+teardown:
  echo>: finish ${session_time}
```

```bash
# my_workflow.dig
+load:
  +from_mysql:
    +tables:
      ...
  +from_postgres:
    ...
+dump:
  ...
```

```bash
# embulk_to_mysql.dig
timezone: UTC

+setup:
  echo>: start ${session_time}

+disp_current_date:
  echo>: ${moment(session_time).utc().format('YYYY-MM-DD HH:mm:ss Z')}

+load:
  sh>: embulk run customers.yml
+load:
  sh>: embulk run pageviews.yml

+teardown:
  echo>: finish ${session_time}
```


## Run Digdag workflow

```bash
$ digdag run workflow.dig
```