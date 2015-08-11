module EmailQueue
  class App
    attr_reader :workers, :stop_flag, :id

    # if no worker or job is available
    # sleep for SLEEP_TIME seconds and try again
    SLEEP_TIME=2

    # id should identify the App uniqly across systems and in a system
    # and should be persistant across restarts
    #
    # no_of_workers can not the greater then or equal to number of db connections
    # as each worker will have its own db connection + one for main thread
    # by default app will have 5 db connections so we can have a max of 4 workers
    # the number of db connections is a configurable value in config/db.rb
    # after changing this value app need to be restarted
    def initialize(id, no_of_workers=4)
      @id = id
      @workers = []

      if no_of_workers > EmailQueue::Queue.connection.pool.size - 1
        raise 'Max allowed workers cannot be greater then or equal to number of db connections.'
      end

      no_of_workers.times do |i|
        @workers << Worker.new(self, i)
      end
    end

    def start
      trap('TERM') { puts 'Exiting...'; @stop_flag = true }
      trap('INT')  { puts 'Exiting...'; @stop_flag = true }

      reset_stale_jobs!
      while(!stop_flag) do
        worker = find_free_worker
        job = self.next_job(worker)
        if worker && job
          worker.free = false
          worker.do_in_background(job)
        end
      end
    end

    def stop
      @stop_flag = true
    end

    # finds the next queue item and returns the Job object which wraps the queue item
    # it will wait till an item is available
    # checks every SLEEP_TIME seconds
    #
    # we find 5 pending queue items
    # and then try to lock them one by one
    # as soon as we are able to lock any one we will return it for getting processed
    # mysql will lock implicitly the row being updated and hence no other worker/app can upadate it
    # and no explicit locking is required
    # here we are locking only one row at time and not the full table to achieve concurrency
    # we are loading 5 queue items so that if 1 is locked by other worker the probability
    # of geting the lock on the subsequent queue items increases and we spend less time waiting.
    def next_job(worker)
      while(!stop_flag) do
        base_scope = Queue.queued.where(['worker_id is null or worker_id = ?', worker.id])
        queue_item = base_scope.order(:id).limit(5).detect do |q|
          reserved_count = base_scope.where(id: q.id).update_all(worker_id: worker.id)
          reserved_count > 0
        end

        if queue_item
          queue_item.worker_id = worker.id
          queue_item.worker_id_will_change!
          return Job.new(queue_item)
        else
          sleep(SLEEP_TIME)
        end
      end
    end

    # this will be triggered by worker when the job completes
    # we are moving the processed jobs in a archive table
    # so that over actual job queue doesnt bloat up will old entried
    def job_complete(worker, job)
      Archive.create!(job.queue_item.attributes.except('created_at', 'id'))
      job.queue_item.destroy
      worker.free = true
    end

    # in case of job errors out
    # we are just moving the queue item to archive table
    # and marking the fact in the archive table
    #
    # we can easily change this behaviour by changing this function
    # if we want to support retries
    def job_errored(worker, job)
      Archive.create!(job.queue_item.attributes.except('created_at', 'id').merge('error_details' => job.error_details))
      job.queue_item.destroy
      worker.free = true
    end

    # on every app startup we reset all the stale jobs for this app
    # so that they are available for every one to process
    # we need this in case the app is crashed or killed forcefully.
    def reset_stale_jobs!
      Queue.queued.where('worker_id like :app_id', app_id: "#{self.id}-%").update_all(worker_id: nil)
    end

    private

      def find_free_worker
        while(!stop_flag) do
          if worker = @workers.find(&:free)
            return(worker)
          else
            sleep(SLEEP_TIME)
          end
        end
      end


  end
end