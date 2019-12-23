#!/usr/bin/env sysbench

function thread_init()
  drv = sysbench.sql.driver()
  con = drv:connect()
end

function event ()
  -- Maybe to optimize the second arg on math.random(1, 460000)
  -- is good to take first select max(id) from sbtest; and round.
  --
  local rnd = math.random(1, 460000)
  local sql = [[
    SELECT SQL_NO_CACHE *
    FROM sbtest
    WHERE id = %d
  ]]

  con:query(string.format(sql, rnd))
end

function thread_done()
  con:disconnect()
end

function sysbench.hooks.report_intermediate(stat)
  local seconds = stat.time_interval

  print(string.format("%.0f;%d",
    stat.time_total,
    stat.events
  ))
end
