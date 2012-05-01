require 'beanstalk-client'

class Q
  
  def initialize
    @bs = Beanstalk::Pool.new(QUEUE_SERVERS)
  end
  
  def close
    @bs.close
  end
    
  def announce_worker(name)
    worker_tube = "#{WORKER_PREFIX}#{name}"
    puts "announced (#{worker_tube})"
    @bs.use(worker_tube)
    @bs.watch(worker_tube)
    # @bs.yput({
    #   :type => 'announce',
    # })
  end
  
  def list_workers
    # Init
    workers = []
    
    # Ask tubes on serverd
    tubes = @bs.list_tubes
    
    # Browse reply
    tubes.each do |server, server_tubes|
      server_tubes.each do |tube|
        if tube.start_with? WORKER_PREFIX
          offset = WORKER_PREFIX.length
          worker_ident = tube[offset..-1]
          workers << worker_ident 
        end
      end
    end
    
    # Return workers
    workers.uniq
  end

  # def push_job(job_id, reason = nil, priority = 100, ttr = JOB_DEFAULT_RELEASE_TIME)
  #   delay = 0
  #   body = {
  #     :id => job_id,
  #     :reason => reason,
  #   }
  #   @bs.use('default')
  #   @bs.yput(body, priority, delay, ttr)
  # end

  def push_job(job, priority = 100, ttr = JOB_DEFAULT_RELEASE_TIME)
    delay = 0
    body = {
      :id => job.id,
      :creator => job.creator,
      :label => job.label,
    }
    @bs.use('default')
    @bs.yput(body, priority, delay, ttr)
  end

  def pop_job(job)
    bsid = job.worker.to_i
    #@bs.use('default')
    @bs.delete(bsid) unless bsid.zero?
  end

  def reserve_job
    @bs.watch('default')
    @bs.reserve
  end
  
  def fetch_queued_jobs
    # Prepare the queue
    @bs.watch('default')
    reserved = []
    
    # Collect items in the queue
    begin
      while item = @bs.reserve(0)
        reserved << item
      end
    rescue Beanstalk::TimedOut => exception
    end
    
    # Free them back
    reserved.each do |item|
      item.release
    end
    
    reserved
  end
  
  def list_tubes
    @bs.list_tubes
  end
  
  def peek_ready
    @bs.peek_ready
  end
  
  def job_stats(job)
    @bs.job_stats(job)
  end
  
  def stats
    @bs.stats
  end
  
end
