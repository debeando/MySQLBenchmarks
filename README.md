# MySQL Benchmark

Using [Sysbench](https://github.com/akopytov/sysbench) tool witch custon lua
scripts to generate any benchmarks with our graphs:

And with gnuplot we generate graphs in `.SVG` files and you can see with
[Gapplin](http://gapplin.wolfrosch.com) on Mac OS X.

Each direcyory have a specific test case.

- Primary Key: Test the best data type for this purpose.
- Random:

## Consideration

-
-
-
-

## Hardware

- db.m5.xlarge (4vCPU, 16GiB RAM, 1000 IOPS (io1), ) zone a.
- db.m6g.xlarge (4vCPU, 8GiB RAM, 1000 IOPS (io1), )

- bastion, zone a.

## Requirement

Create a RDS:

```
aws rds create-db-instance \
	--db-instance-identifier benchmark \
	--db-instance-class db.t3.micro \
	--engine mysql \
	--engine-version 8.0.28 \
	--master-username admin \
	--master-user-password admin123 \
	--allocated-storage 100 \
	--vpc-security-group-ids sg-088a458cf7e281afe \
	--availability-zone eu-west-1a \
	--db-subnet-group-name thn-stg-generic-db \
	--backup-retention-period 0 \
	--no-enable-performance-insights \
	--no-multi-az
```

Bastion

Install sysbench on your Amazon Linux:

```bash
sudo yum install gnuplot
```

```bash
sudo yum -y install git gcc make automake libtool openssl-devel ncurses-compat-libs
```

```bash
wget http://repo.mysql.com/mysql-community-release-el7-5.noarch.rpm
sudo rpm -ivh mysql-community-release-el7-5.noarch.rpm
sudo yum -y update
```

```bash
sudo yum -y install mysql-community-devel mysql-community-client mysql-community-common
```


```bash
git clone https://github.com/akopytov/sysbench
```

5. Build the binary

```bash
cd sysbench
git checkout tags/1.0.20
./autogen.sh
./configure
make
sudo make install
```

6. You can verify the installation by:

```bash
sysbench --version
```

7. Create a MySQL database and user for sysbench:

MySQL 5.x

```sql
CREATE SCHEMA sbtest;
GRANT ALL PRIVILEGES ON sbtest.* TO sbtest@'%' IDENTIFIED BY 'sbtest';
FLUSH PRIVILEGES;
```

MySQL 8.0

```sql
CREATE SCHEMA sbtest;
CREATE USER 'sbtest'@'%' IDENTIFIED WITH mysql_native_password BY 'sbtest';
GRANT ALL PRIVILEGES ON sbtest.* TO 'sbtest'@'%';
FLUSH PRIVILEGES;
```

export MYSQL_HOST="benchmark.cse2qkeganda.eu-west-1.rds.amazonaws.com"
mysql -h $MYSQL_HOST -u sbtest -psbtest -e "show databases"

join
