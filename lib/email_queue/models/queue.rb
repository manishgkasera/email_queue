module EmailQueue
  class Queue < ActiveRecord::Base
    self.table_name = :email_queue
    enum status: [:queued, :complete, :errored]
    before_create :set_created_at
    before_save :set_updated_at

    def self.enqueue(from, to, subject, body)
      self.create!(from_email_address: from,
                   to_email_address: to,
                   subject: subject,
                   body: body
                   )
    end

    private

      def set_created_at
        self.created_at ||= Time.now
      end

      def set_updated_at
        self.updated_at = Time.now
      end
  end

end