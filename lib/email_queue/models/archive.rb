module EmailQueue
  class Archive < ActiveRecord::Base
    self.table_name = 'email_queue_archive'
  end
end