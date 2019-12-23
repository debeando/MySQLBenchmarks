#!/usr/bin/env sysbench

local c_value_template = "###########-###########-###########-" ..
                         "###########-###########-###########-" ..
                         "###########-###########-###########-" ..
                         "###########"

function prepare()
  local drv = sysbench.sql.driver()
  local con = drv:connect()

  con:query(string.format([[
    CREATE TABLE IF NOT EXISTS sbtest (
      id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
      c  VARCHAR(120) DEFAULT '' NOT NULL,
      PRIMARY KEY (id)
    ) ENGINE=InnoDB ROW_FORMAT=DYNAMIC
  ]]))
end

function cleanup()
  local drv = sysbench.sql.driver()
  local con = drv:connect()

  con:query("DROP TABLE IF EXISTS sbtest")
end

function thread_init()
  drv = sysbench.sql.driver()
  con = drv:connect()
end

function get_c_value()
   return sysbench.rand.string(c_value_template)
end

function event ()
  query = string.format("INSERT INTO sbtest (c) VALUES ('%s')", get_c_value())

  con:query(query)
end

function thread_done()
  con:disconnect()
end

function sysbench.hooks.report_intermediate(stat)
  drv = sysbench.sql.driver()
  con = drv:connect()

  print(string.format("%.0f;%d",
    stat.time_total,
    stat.events
  ))
end

