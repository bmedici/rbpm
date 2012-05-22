STEP_CLASSES = %w(StepStart StepEnd StepNoop StepWaiter StepFailer StepWatchfolder StepRest StepMd5 StepSetVariables StepExpectVariables StepFileMove StepFileCopy StepCplusMut StepFtpPush StepFormatsFromTargets)
LINK_CLASSES = %w(Link LinkNever LinkBlocker LinkFork LinkEvalRuby)

COLOR_CURRENT = '#5555FF'
COLOR_COMPLETED = '#44BB44'
COLOR_FAILED = '#FF0000'
COLOR_RUNNING = '#ff7000'
COLOR_DEFAULT = '#BBBBBB'

# Defaults
DEFAULT_TIMEOUT = 3


# Basic workerd config
WORKER_LOGFORMAT = "%Y/%m/%d %H:%M:%S"
WORKER_REBOOT_DELAY = 5
WORKER_PREFIX = "worker-"

QUEUE_DEFAULT = 'default'
QUEUE_JOBS = 'jobs'
JOB_RELEASE_DEFAULT = 180
JOB_PRIORITY_DEFAULT = 100
JOB_PRIORITY_FORKED = 200
JOB_PRIORITY_PUSHED = 500

#LOGGING_TIMEFORMAT = "%Y/%m/%d %H:%M:%S"
#LOGGING_TIMEFORMAT = "%Y/%m/%d %H:%M %S.%L"    # for ruby 1.9+
