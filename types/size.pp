# Valid size of a log in either bytes (no suffix) or
# k, M, G for kilobytes, Megabytes or Gigabtes
type Logrotate::Size = Variant[ Integer[1], Pattern[/^[0-9]+[kGM]?$/]]
