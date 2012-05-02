# Load the rails application
require File.expand_path('../application', __FILE__)


# Monkey-patch beanstalk
module Beanstalk
  class Pool
      # FIXME bmedici 2/5/12
      def job_stats(id)
        send_to_all_conns(:job_stats, id)
      end
  end
end  


# Initialize the rails application
Rbpm::Application.initialize!
