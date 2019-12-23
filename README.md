# MySQL Benchmark

Using [Sysbench](https://github.com/akopytov/sysbench) tool witch custon lua
scripts to generate any benchmarks with our graphs:

And with gnuplot we generate graphs in `.SVG` files and you can see with
[Gapplin](http://gapplin.wolfrosch.com) on Mac OS X.

Each direcyory have a specific test case.

- Primary Key: Test the best data type for this purpose.
- Random: Generate only random data.
- Row Format: Compressed VS Dynamic

## Consideration

- El número de TPS or QPS será proporcional al rendimiento ofrecido por la CPU y los IOPS entre otros.

## Install

```bash
brew install mysql@5.7
brew install sysbench
brew install gnuplot
```

## Requirement

Create a MySQL database and user for sysbench:

```bash
mysql> CREATE SCHEMA sbtest;
mysql> GRANT ALL PRIVILEGES ON sbtest.* TO sbtest@'localhost' IDENTIFIED BY 'sbtest';
mysql> FLUSH PRIVILEGES;

```
