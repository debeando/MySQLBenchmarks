#!/usr/bin/env sysbench

function prepare()
  local drv = sysbench.sql.driver()
  local con = drv:connect()

  con:query(string.format([[
    CREATE TABLE IF NOT EXISTS uuid_bin (
      id BINARY(16) NOT NULL,
      PRIMARY KEY (id)
    )
  ]]))
end

function cleanup()
  local drv = sysbench.sql.driver()
  local con = drv:connect()

  con:query("DROP TABLE IF EXISTS uuid_bin")
end

function thread_init()
  drv = sysbench.sql.driver()
  con = drv:connect()
end

function thread_done()
  con:disconnect()
end

function event ()
  con:query("INSERT INTO uuid_bin VALUES (uuid_to_bin(UUID()))")
end

function sysbench.hooks.report_intermediate(stat)
  drv = sysbench.sql.driver()
  con = drv:connect()

  local size = getIDBSize()
  local cpu = getCPUUsage()

  print(string.format("%.0f;%4.2f;%d;%0.2f",
    stat.time_total,
    stat.events,
    size,
    cpu
  ))
end

function getIDBSize()
  local command = "ls -lt /usr/local/var/mysql/sbtest/uuid_bin.ibd | cut -d' ' -f8 | tr -d '\n'"
  local handle = io.popen(command)
  local result = handle:read("*a")
  handle:close()

  return result
end

function getCPUUsage()
  local command = "ps -o pcpu -p $(pgrep mysqld) | tail -n +2"
  local handle = io.popen(command)
  local result = handle:read("*a")
  handle:close()

  return result
end
