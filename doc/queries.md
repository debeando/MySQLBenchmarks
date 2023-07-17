# Queries

Used queries to get more details for each case.

Index size:

```sql
SELECT ROUND(stat_value * @@innodb_page_size / 1024 / 1024, 2) AS size_in_mb
FROM mysql.innodb_index_stats
WHERE stat_name = 'size' AND table_name = 'uuid_varchar';
```

Table size:

```sql
SELECT ROUND((data_length + index_length) / 1024 / 1024) AS size_in_mb, table_rows AS 'rows'
FROM information_schema.tables
WHERE table_name = 'uuid_varchar';
```
