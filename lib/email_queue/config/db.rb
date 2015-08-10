ActiveRecord::Base.establish_connection(
  adapter: 'mysql',
  database: 'email_queue',
  username: 'root',
  password: 'root',
  pool: 5
)