#!/usr/bin/env sysbench

function prepare()
  local drv = sysbench.sql.driver()
  local con = drv:connect()

  con:query(string.format([[
    CREATE TABLE IF NOT EXISTS uuid_char (
      id CHAR(36) NOT NULL,
      PRIMARY KEY (id)
    )
  ]]))
end

function cleanup()
  local drv = sysbench.sql.driver()
  local con = drv:connect()

  con:query("DROP TABLE IF EXISTS uuid_char")
end

function thread_init()
  drv = sysbench.sql.driver()
  con = drv:connect()
end

function event ()
  con:query("INSERT INTO uuid_char VALUES (UUID())")
end

function thread_done()
  con:disconnect()
end

function sysbench.hooks.report_intermediate(stat)
  drv = sysbench.sql.driver()
  con = drv:connect()

  print(string.format("%.0f;%4.2f",
    stat.time_total,
    stat.events
  ))
end
