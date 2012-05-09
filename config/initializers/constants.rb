STEP_CLASSES = %w(StepStart StepEnd StepNoop StepWaiter StepFailer StepWatchfolder StepRest StepMd5 StepSetVariables StepExpectVariables StepFileMove StepFileCopy StepCplusMut StepFtpPush StepFormatsFromTargets)
LINK_CLASSES = %w(Link LinkNever LinkBlocker LinkFork LinkEvalRuby)

COLOR_CURRENT = '#5555FF'
COLOR_COMPLETED = '#44BB44'
COLOR_FAILED = '#FF0000'
COLOR_RUNNING = '#ff7000'
COLOR_DEFAULT = '#BBBBBB'

QUEUE_DEFAULT = 'default'
QUEUE_JOBS = 'jobs'

WORKER_PREFIX = "worker-"

JOB_DEFAULT_RELEASE_TIME = 300

LOGGING_TIMEFORMAT = "%Y/%m/%d %H:%M:%S"
#LOGGING_TIMEFORMAT = "%Y/%m/%d %H:%M %S.%L"    # for ruby 1.9+
