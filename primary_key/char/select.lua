#!/usr/bin/env sysbench

ids = {}

function thread_init()
  drv = sysbench.sql.driver()
  con = drv:connect()
  local sql = [[
    SELECT SQL_NO_CACHE id
    FROM uuid_char
    ORDER BY RAND()
    LIMIT 1000000
  ]]

  local rs = con:query(sql)

  for i = 1, rs.nrows do
    row = rs:fetch_row()
    ids[i] = row[1]
    print(ids[i])
  end
end

function event ()
  local rnd = math.random(1, 1000000)
  local sql = [[
    SELECT SQL_NO_CACHE *
    FROM uuid_char
    WHERE id = '%s'
  ]]

  con:query(string.format(sql, ids[rnd]))
end

function thread_done()
  con:disconnect()
end

function sysbench.hooks.report_intermediate(stat)
  local seconds = stat.time_interval

  print(string.format("%.0f;%4.2f",
    stat.time_total,
    stat.events
  ))
end
