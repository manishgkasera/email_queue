module EmailQueue
  class Worker
    attr_reader :app, :id
    attr_accessor :free

    def initialize(app, id)
      @app = app
      @id = "#{app.id}-#{id}"
      @free = true
    end

    def do_in_background(job)
      t = Thread.new do
        job.process
        if job.error_details
          app.job_errored(self, job)
        else
          app.job_complete(self, job)
        end

        ActiveRecord::Base.connection.close
      end
      t.abort_on_exception = true
    end
  end
end