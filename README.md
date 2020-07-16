# digdag
technical challenge

Embulk and Digdag are open source libraries for data ingestion and data pipeline orchestration,
respectively. These libraries were invented at Treasure Data and are foundational to the Treasure Data
product. In this exercise you will install the open source versions of these tools and use them to ingest
data to a local MySQL database. After that, you will write SQL queries to prepare and analyze the data.

# Install `digdag`
```bash
$ curl -o ~/bin/digdag --create-dirs -L "https://dl.digdag.io/digdag-latest"
$ chmod +x ~/bin/digdag
$ echo 'export PATH="$HOME/bin:$PATH"' >> ~/.bashrc
```

# Install Embulk
```bash
curl --create-dirs -o ~/.embulk/bin/embulk -L "https://dl.embulk.org/embulk-latest.jar"
chmod +x ~/.embulk/bin/embulk
echo 'export PATH="$HOME/.embulk/bin:$PATH"' >> ~/.bashrc
source ~/.bashrc
```
# Install MariaDB/MySQL
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

# Create Database
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

$ 
```

# Test non-root user login
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

# Installing JAVA

If you get an runtime error saying Java is not installed follow the steps below.

*Note: These steps are for installing Java 11 from Oracle on an AWS remote server running Debian 9*

1. Download the tar file from Oracle: 
2. Copy (`scp`) the tar file to the remote server
3. Unzip tar file into your JVM directory (you may need to create first)
4. 
```bash
$ sudo mkdir /usr/lib/jvm
$ sudo tar zxvf jdk-11.0.7_linux-x64_bin.tar.gz -C /usr/lib/jvm
$ sudo update-alternatives --install "/usr/bin/java" "java" "/usr/lib/jvm/jdk-11.0.7/bin/java" 1
update-alternatives: using /usr/lib/jvm/jdk-11.0.7/bin/java to provide /usr/bin/java (java) in auto mode
$ sudo update-alternatives --set java /usr/lib/jvm/jdk-11.0.7/bin/java
$ java -version
java version "11.0.7" 2020-04-14 LTS
Java(TM) SE Runtime Environment 18.9 (build 11.0.7+8-LTS)
Java HotSpot(TM) 64-Bit Server VM 18.9 (build 11.0.7+8-LTS, mixed mode)
```
 *For more in-depth doc go here:*
https://docs.datastax.com/en/jdk-install/doc/jdk-install/installOracleJdkDeb.html

