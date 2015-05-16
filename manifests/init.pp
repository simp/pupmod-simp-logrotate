# == Class: logrotate
#
# Set up the basics of the logrotate space.
#
# This does not allow for specialized log rotation. You should use
# logrotate::add for that.
#
# == Parameters
#
# [*rotate_period*]
#   How often to rotate the logs.
#
# [*rotate*]
#   The number of times to rotate the logs before removing them from the
#   system.
#
# [*create*]
#   Whether or not to create new log files if they do not exist.
#
# [*compress*]
#   Whether or not to compress the logs upon rotation.
#
# [*include_dirs*]
#   Directories to include in your logrotate configuration as an array.
#   /etc/logrotate.d is always included.
#
# [*manage_wtmp*]
#   /var/log/wtmp is traditionally managed by /etc/logrotate.conf. Set this
#   to false if you do not want this to happen.
#
# [*dateext*]
#   Whether or not to use 'dateext' as the suffix for rotated files.
#
# [*dateformat*]
#   The format of the date to be appended. Leaving as is allows for multiple
#   rotations per day.
#
# [*max_size*]
#   The default maximum size of a logfile, set to 500M to attempt to prevent
#   /var/log from filling.
#
# == Authors
#
# * Trevor Vaughan <tvaughan@onyxpoint.com>
#
class logrotate (
  $rotate_period = 'weekly',
  $rotate = '4',
  $create = true,
  $compress = true,
  $include_dirs = '',
  $manage_wtmp = true,
  $dateext = true,
  $dateformat = '-%Y%m%d.%s',
  $max_size = '500M'
) {

  file { '/etc/logrotate.conf':
    ensure  => 'file',
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => template('logrotate/logrotate.conf.erb')
  }

  file { '/etc/logrotate.d':
    ensure => 'directory',
    owner  => 'root',
    group  => 'root',
    mode   => '0644'
  }

  package { 'logrotate': ensure => 'latest' }

  validate_array_member($rotate_period, ['daily','weekly','monthly','yearly'])
  validate_integer($rotate)
  validate_bool($create)
  validate_bool($compress)
  validate_bool($manage_wtmp)
  validate_bool($dateext)
}
