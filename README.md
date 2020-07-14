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

# Create MySQL Database
```bash
sudo mysql
mysql> CREATE DATABASE td_coding_challenge DEFAULT CHARACTER SET utf8 COLLATE utf8_unicode_ci;
mysql> GRANT ALL ON td_coding_challenge.* TO 'digdag'@'localhost' IDENTIFIED BY 'ARMtr3@sure';
mysql> FLUSH PRIVILEGES;
mysql> exit

mysql -u digdag -p
mysql> SHOW DATABASES;
mysql> exit

```




