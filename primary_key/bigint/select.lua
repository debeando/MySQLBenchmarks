#!/usr/bin/env sysbench

function thread_init()
  drv = sysbench.sql.driver()
  con = drv:connect()
end

function event ()
  local rnd = math.random(1, 1000000)
  local sql = [[
    SELECT SQL_NO_CACHE *
    FROM traditional
    WHERE id = %d
  ]]

  con:query(string.format(sql, rnd))
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
