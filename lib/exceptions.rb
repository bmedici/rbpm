module Exceptions
  class UnhandledException < StandardError
  end
  class WorkerFailedJobNotfound < StandardError
  end
  class JobFailedParamError < StandardError
  end
  class JobFailedStepRaised < StandardError
  end
  class JobFailedStepRun < StandardError
  end
end