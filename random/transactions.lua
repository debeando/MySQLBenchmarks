#!/usr/bin/env sysbench

local function load_data_from_file_to_random(path, type)
  print("Load data from file '" .. path .. "' to 'random' table...")

  local sql   = ""
  local drv   = sysbench.sql.driver()
  local con   = drv:connect()
  local open  = io.open
  local file  = open(path, "rb")

  if not file then return nil end

  for line in io.lines(path) do
    line = string.gsub(line, "\r", "")
    sql  = string.format([[
      INSERT IGNORE INTO random (attribute_value, attribute_type)
      VALUES ("%s", '%s')
    ]], line, type)

    con:query(sql)
  end

  file:close()
end

function prepare()
  local drv = sysbench.sql.driver()
  local con = drv:connect()

  print("Creating table 'random'...")
  con:query(string.format([[
    CREATE TABLE IF NOT EXISTS random (
      id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
      attribute_value VARCHAR(64) NOT NULL,
      attribute_type  ENUM('FirstName', 'LastName', 'DomainName', 'Device', 'Movie'),
      PRIMARY KEY (id),
      UNIQUE KEY attribute_uid (attribute_value, attribute_type)
    )
  ]]))

  load_data_from_file_to_random("domainnames.txt", "DomainName")
  load_data_from_file_to_random("firstnames.txt", "FirstName")
  load_data_from_file_to_random("lastnames.txt", "LastName")
  load_data_from_file_to_random("devices.txt", "Device")
  -- load_data_from_file_to_random("movies.txt", "Movie")

  print("Creating table 'users'...")
  con:query(string.format([[
    CREATE TABLE IF NOT EXISTS users (
      id            BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
      email         CHAR(255) NOT NULL,
      username      CHAR(255) NOT NULL,
      password_hash CHAR(64) NOT NULL,
      first_name    VARCHAR(64) NOT NULL,
      last_name     VARCHAR(64),
      status        ENUM('Enable', 'Disable', 'ChangePassword'),
      created_at    TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
      updated_at    TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
      deleted_at    TIMESTAMP NULL DEFAULT NULL,
      PRIMARY KEY (id),
      UNIQUE KEY email_uid (email),
      UNIQUE KEY username_uid (username)
    )
  ]]))

  -- device pairing
  -- orders
end

function cleanup()
  local drv = sysbench.sql.driver()
  local con = drv:connect()

  print("Dropping table 'random'...")
  con:query("DROP TABLE IF EXISTS random")

  print("Dropping table 'users'...")
  con:query("DROP TABLE IF EXISTS users")
end

function thread_init()
  drv = sysbench.sql.driver()
  con = drv:connect()

  domain_name_min = con:query_row("SELECT MIN(id) FROM random WHERE attribute_type = 'DomainName'")
  domain_name_max = con:query_row("SELECT MAX(id) FROM random WHERE attribute_type = 'DomainName'")
  first_name_min  = con:query_row("SELECT MIN(id) FROM random WHERE attribute_type = 'FirstName'")
  first_name_max  = con:query_row("SELECT MAX(id) FROM random WHERE attribute_type = 'FirstName'")
  last_name_min   = con:query_row("SELECT MIN(id) FROM random WHERE attribute_type = 'LastName'")
  last_name_max   = con:query_row("SELECT MAX(id) FROM random WHERE attribute_type = 'LastName'")

  -- print("Disable auto-commit")
  -- con:query("SET autocommit = OFF")
end

function event ()
  local status_values = {"Enable", "Disable", "ChangePassword"}
  local status_index  = math.random(3)

  local attribute_sql     = "SELECT attribute_value FROM random WHERE id = %d"
  local domain_name_index = math.random(domain_name_min, domain_name_max)
  local first_name_index  = math.random(first_name_min, first_name_max)
  local last_name_index   = math.random(last_name_min, last_name_max)
  local domain_name       = con:query_row(string.format(attribute_sql, domain_name_index))
  local first_name        = con:query_row(string.format(attribute_sql, first_name_index))
  local last_name         = nil
  local status_value      = status_values[status_index]

  pcall(function () last_name = con:query_row(string.format(attribute_sql, last_name_index)) end)

  local username      = string.format("%s.%s", first_name, last_name):lower()
  local username      = string.gsub(username,"'","")
  local email         = string.format("%s%s@%s", username, sb_rand(0, 1000), domain_name):lower()
  local password_hash = sb_rand_str(string.rep("@", sb_rand(8, 16)))

  sql = [[
    INSERT IGNORE INTO users (
      email,
      username,
      password_hash,
      first_name,
      last_name,
      status
    ) VALUES (
      '%s',
      '%s',
      MD5('%s'),
      "%s",
      "%s",
      '%s'
    )
  ]]

  con:query(string.format(sql, email, username, password_hash, first_name, last_name, status_value))

  -- Execute randomly bad query:
  if math.random(100) == 1 then
    sql = [[
      SELECT DISTINCT
        SUBSTRING_INDEX(SUBSTR(email, INSTR(email, '@') + 1),'.',1) AS domainname,
        COUNT(id)
      FROM users
      GROUP BY domainname;
    ]]

    con:query(sql)
  end
end

function thread_done()
  con:disconnect()
end
