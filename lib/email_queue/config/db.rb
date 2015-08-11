
ActiveRecord::Base.establish_connection(
  adapter: 'mysql',
  database: 'email_queue',
  username: 'root',
  password: 'root',
  pool: 5
)

# other configuration options can be found at
# http://apidock.com/rails/ActiveRecord/Base/establish_connection/class