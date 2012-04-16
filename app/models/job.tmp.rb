
  def start_from(step, initial_vars = {})
    # Parse args
    raise "EXITING: start_from expects a starting step" if step.nil?
    step_id =  step.id

    # Fork a process immediately
    forked = fork {
      # Create a new job
      job = Job.new(:step => step)
      job.save
      puts
      puts "###############################################################"
      puts "## STANDALONE JOB (j#{job.id}) FROM STEP (s#{step.id}) #{step.label}"
      puts "###############################################################"

      # Initialize job vars from initial_vars
      initial_vars.each do |name, value|
        self.set_var(name, value, step, nil)
      end

      # Start the process execution on the root step
      puts "FORK thread for step (s#{step.id}) #{step.label}"
      ret = job.run_from(step)
      puts "FORK thread ending for (s#{step.id}) #{step.label}"

      # Finish
      job.completed_at = Time.now
      job.save
      }
      
    # As we forked, we cloned each other, then forked=nil in the child, forked=ID in the parent
    Process.detach forked if forked
  
    return ret
  end

  
  def run_to(step, active_threads = nil)
    # Init
    ancestors_ids = step.ancestors.map(&:id).join(', ')
    puts "- run (r#{self.id}), step (s#{step.id}) #{step.label}, with (#{step.ancestors.size}) ancestors: #{ancestors_ids}"
    active_threads ||= {}
    
    # Stack steps dependencies recursively
    #puts "    - s#{step.id}: step has (#{step.ancestors.size}) previous steps"
    my_ancestor_threads = []
    step.ancestors.each do |ancestor|
      #puts "    - s#{step.id}: finding ancestor (s#{ancestor.id}) in active_threads containing #{active_threads.size} threads"

      # Let's see if this step is not already running in any thread
      existing_thread_for_this_ancestor = active_threads[ancestor.id]
      
      # If it's not running, let's fork it
      if existing_thread_for_this_ancestor.nil?
        active_threads[ancestor.id] = Thread.new() do
          puts "    - s#{step.id}: threading (s#{ancestor.id}) #{ancestor.label}"
          self.run_to(ancestor, active_threads)
          puts "    - s#{step.id}: thread ending for (s#{ancestor.id}) #{ancestor.label}"
        end

      else
        puts "    - s#{step.id}: attaching existing thread for (s#{ancestor.id})"
      end

      # Stack this thread into my own ancestors threads
      my_ancestor_threads << active_threads[ancestor.id]
      
    end
    
    # Wait for all my ancestors to complete
    puts "    - s#{step.id}: waiting for ancestors threads to complete"
    my_ancestor_threads.map { |thread| thread.join }
    puts "    - s#{step.id}: all ancestors completed"
    
    # Check their return status
    
    # Now we satisfied our dependencies, let's see what we have to do and create a new action
    action = actions.create(:step => step)
    action.save
    puts "    - s#{step.id}: running my own stuff as action (a#{action.id}) as a kind of (#{step.type})"
    
    # Run this step
    action.errno, action.errmsg = step.run(self, action)

    # Closing action
    action.completed_at = Time.now
    action.save

    # Finished
    puts "    - s#{step.id}: finished"
  end
