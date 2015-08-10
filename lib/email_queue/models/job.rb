module EmailQueue
  class Job
    attr_reader :queue_item, :error_details
    def initialize(queue_item)
      @queue_item = queue_item
    end

    def process
      puts "processing ..#{queue_item.id.to_s}"
      # Mail.deliver do
      #   from     queue_item.from_email_address
      #   to       queue_item.to_email_address
      #   subject  queue_item.subject
      #   body     queue_item.body
      # end
      File.open('/tmp/a.log', 'a') do |f|
        f.write("Processing: " + queue_item.id.to_s + "\n")
      end
    end
  end
end