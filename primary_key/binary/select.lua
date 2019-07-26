#!/usr/bin/env sysbench

ids = {}

function thread_init()
  drv = sysbench.sql.driver()
  con = drv:connect()
  local sql = [[
    SELECT SQL_NO_CACHE bin_to_uuid(id)
    FROM uuid_bin
    ORDER BY RAND()
    LIMIT 1000
  ]]

  local rs = con:query(sql)

  for i = 1, rs.nrows do
    row = rs:fetch_row()
    ids[i] = row[1]
    print(ids[i])
  end
end

function event ()
  local rnd = math.random(1, 1000)
  local sql = [[
    SELECT SQL_NO_CACHE *
    FROM uuid_bin
    WHERE id = uuid_to_bin('%s')
  ]]

  con:query(string.format(sql, ids[rnd]))
end

function thread_done()
  con:disconnect()
end

function sysbench.hooks.report_intermediate(stat)
  local seconds = stat.time_interval
  local cpu = getCPUUsage()

  print(string.format("%.0f;%4.2f;%0.2f",
    stat.time_total,
    stat.events,
    cpu
  ))
end

function getCPUUsage()
  local command = "ps -o pcpu -p $(pgrep mysqld) | tail -n +2"
  local handle = io.popen(command)
  local result = handle:read("*a")
  handle:close()

  return result
end
