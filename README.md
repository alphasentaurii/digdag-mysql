# Digdag MySQL

The `Digdag MySQL` project demonstrates how to use `SQL queries` with `digdag` and `embulk` open source libraries for ingesting and analyzing data. We'll load a MySQL database from CSV files and perform data analysis using SQL queries inside an automated digdag workflow.

![GitHub repo size](https://img.shields.io/github/repo-size/hakkeray/digdag)
![GitHub license](https://img.shields.io/github/license/hakkeray/digdag?color=black)

## Prerequisites

Before you begin, ensure you have met the following requirements:

* You have a `<Windows/Linux/Mac>` machine.
* You have access to `sudo` privileges
* You have installed `Java` version 8

For help installing and configuring Java and MySQL, check out my blog post ![Digdag MySQL Tutorial](https://www.hakkeray.com/datascience/2020/07/21/digdag-mysql-tutorial.html).

## Running the Digdag MySQL project

Use `sudo` to get root privileges

```bash
$ sudo -s
```

### Install `digdag`

```bash
$ curl -o ~/bin/digdag --create-dirs -L "https://dl.digdag.io/digdag-latest"
$ chmod +x ~/bin/digdag
$ echo 'export PATH="$HOME/bin:$PATH"' >> ~/.bashrc
```

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

### Install Plugin(s)

```bash
$ embulk gem install embulk-output-mysql
```

### Create MySQL Database

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

MariaDB [(none)]> quit
```

### Run the Digdag MySQL workflow

```bash
$ cd embulk_to_mysql
$ digdag run embulk_to_mysql.dig -O log/task
```

*Note: If this isn't your first time running the workflow, use the --rerun flag:*
```bash
$ digdag run embulk_to_mysql.dig --rerun -O log/task
```

# Contact
If you want to contact me you can reach me at rukeine@gmail.com.

# License
This project uses the following license: MIT License.

```
         _ __ _   _
  /\_/\ | '__| | | |
  [===] | |  | |_| |
   \./  |_|   \__,_|
```

