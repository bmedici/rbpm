module Exceptions
  class JobFailedParamError < StandardError
  end
  class JobFailedStepRun < StandardError
  end
  class DocumentBuildThumbMissingFile < StandardError
  end
  class SvnRepoCatReturnsNothing < StandardError
  end
  class SvnRepoListReturnsNothing < StandardError
  end
  class SvnRepoMissingUrl < StandardError
  end
  class SvnRepoUpdateFailed < StandardError
  end
  class SvnRepoCheckoutFailed < StandardError
  end
  class SvnRepoInfoFailed < StandardError
  end
  class SvnCommandNotFound < StandardError
  end
  class SvnRepoCheckoutNotFound < StandardError
  end
end