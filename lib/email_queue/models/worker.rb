module EmailQueue
  class Worker
    attr_reader :app, :id
    attr_accessor :free

    # id is used to lock the queue item for this perticular worker
    # i have ansured the uniqueness of id for workers within a app
    # app id uniqueness is to ensured by the user
    def initialize(app, id)
      @app = app
      @id = "#{app.id}-#{id}"
      @free = true
    end

    # we create a thread the do the actual processing of the job
    # in backgound, threads if used with active record creates a new db connection by default
    # so we are closing the same when the work is done.
    # the thread also notifies the app for job completion or error condition
    # app in turn can mark the job as complete and mark the worker as free.
    def do_in_background(job)
      return if job.nil?
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