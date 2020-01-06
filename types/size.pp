# Size of a log in bytes, kilobytes, megabytes or gigabytes
type Logrotate::Size = Variant[ Integer[1], Pattern[/^[0-9]+[kMG]?$/]]
