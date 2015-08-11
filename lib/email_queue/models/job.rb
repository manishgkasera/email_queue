module EmailQueue
  class Job
    attr_reader :queue_item, :error_details
    def initialize(queue_item)
      @queue_item = queue_item
    end

    # the actual sending of email happens here
    # the smtp or other configuration can be changed from config/mail.rb file.
    #
    # the queue implementation is generic enough to support other types of jobs
    # except the schema and the below function
    def process
      mail = Mail.new
      mail.from = queue_item.from_email_address
      mail.to = queue_item.to_email_address
      mail.subject = queue_item.subject
      mail.body = queue_item.body
      begin
        mail.deliver!
      rescue => e
        @error_details = e.message
      end
    end
  end
end