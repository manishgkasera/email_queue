module EmailQueue
  class App
    attr_reader :workers, :stop_flag, :id

    # if no worker or job is available
    # sleep for SLEEP_TIME seconds and try again
    SLEEP_TIME=2

    # id should identify the App uniqly across systems and in a system
    # and should be persistant across restarts
    def initialize(id, no_of_workers)
      @id = id
      @workers = []

      if no_of_workers > EmailQueue::Queue.connection.pool.size - 1
        raise 'Max allowed workers cannot be greater then db connection pool size.'
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
        worker.free = false
        worker.do_in_background(job)
      end
    end

    def stop
      @stop_flag = true
    end

    # finds the next queue item and returns the Job object which wraps the queue item
    # it will wait till an item is available
    # checks every SLEEP_TIME seconds
    def next_job(worker)
      while(!stop_flag) do
        puts "reserving job for worker....#{worker.id}"
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
          puts "Waiting for job....sleeping-#{worker.id}"
          sleep(SLEEP_TIME)
        end
      end
    end

    def job_complete(worker, job)
      Archive.create!(job.queue_item.attributes.except('created_at', 'id'))
      job.queue_item.destroy
      worker.free = true
    end

    def job_errored(worker, job)
      Archive.create!(job.queue_item.attributes.except('created_at', 'id').merge('error_details' => job.error_details))
      job.queue_item.destroy
      worker.free = true
    end

    def reset_stale_jobs!
      Queue.queued.where('worker_id like :app_id', app_id: "#{self.id}-%").update_all(worker_id: nil)
    end

    private

      def find_free_worker
        while(!stop_flag) do
          if worker = @workers.find(&:free)
            return(worker)
          else
            puts "Waiting for worker....sleeping"
            sleep(SLEEP_TIME)
          end
        end
      end


  end
end