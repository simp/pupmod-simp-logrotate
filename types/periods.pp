# Allowed time intervals for logrotate
type Logrotate::Periods = Enum[
  'hourly',
  'daily',
  'weekly',
  'monthly',
  'yearly',
]
