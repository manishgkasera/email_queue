require "email_queue/version"

require "active_record"
require "mysql"
require "mail"
require "hirb"
Hirb.enable

require "email_queue/config/mail"
require "email_queue/config/db"
require "email_queue/schema"

require "email_queue/models/queue"
require "email_queue/models/archive"
require "email_queue/models/app"
require "email_queue/models/worker"
require "email_queue/models/job"

ActiveRecord::Base.logger = Logger.new(STDOUT)

module EmailQueue
end
