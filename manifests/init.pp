# Configure LogRotate global options
#
# Use ``logrotate::rule`` for specific configuration options.
#
# @param rotate_period
#   How often to rotate the logs
#
# @param rotate
#   The number of times to rotate the logs before removing them from the
#   system
#
# @param create
#   Create new log files if they do not exist
#
# @param compress
#   Compress the logs upon rotation
#
# @param include_dirs
#   Directories to include in your logrotate configuration
#
#   * ``/etc/logrotate.d`` is always included
#
# @param manage_wtmp
#   Set to ``false`` if you do not want ``/var/log/wtmp`` to be managed by
#   logrotate
#
# @param dateext
#   Use ``dateext`` as the suffix for rotated files
#
# @param dateformat
#   The format of the date to be appended
#
#   * Leaving as is allows for multiple rotations per day
#
# @param maxsize
#   The default maximum size of a logfile
#
# @param minsize
#   The default minimum size of a logfile
#
#   * Overrides the ``maxsize`` setting
#
# @author Trevor Vaughan <tvaughan@onyxpoint.com>
#
class logrotate (
  Enum['daily','weekly','monthly','yearly'] $rotate_period = 'weekly',
  Integer[0]                                $rotate        = 4,
  Boolean                                   $create        = true,
  Boolean                                   $compress      = true,
  Array[Stdlib::Absolutepath]               $include_dirs  = [],
  Boolean                                   $manage_wtmp   = true,
  Boolean                                   $dateext       = true,
  String                                    $dateformat    = '-%Y%m%d.%s',
  Optional[Pattern['^\d+(k|M|G)?$']]        $maxsize       = undef,
  Optional[Pattern['^\d+(k|M|G)?$']]        $minsize       = undef
) {
  package { 'logrotate': ensure => 'latest' }

  file { '/etc/logrotate.conf':
    ensure  => 'file',
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => template("${module_name}/logrotate.conf.erb")
  }

  file { '/etc/logrotate.d':
    ensure => 'directory',
    owner  => 'root',
    group  => 'root',
    mode   => '0644'
  }
}
