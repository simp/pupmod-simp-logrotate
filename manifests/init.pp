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
# @param configdir
#   The primary directory for SIMP-managed configuration files.
#
# @param include_dirs
#   Directories to include in your logrotate configuration
#
#   * ``$logrotate::configdir`` is always included and is listed first
#   * Be sure to include ``/etc/logrotate.d`` in this list if you
#     override the default.
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
# @param dateyesterday
#  Say 'yesterday' instead of the date
#
# @param maxsize
#   The default maximum size of a logfile
#
# @param minsize
#   The default minimum size of a logfile
#
#   * Overrides the ``maxsize`` setting
#
# @param package_ensure
#   The ensure status of packages to be installed
#
# @param logger_service
#   The service that controls system logging
#
#   * This is used by the ``logrotate::rule`` define to note the name of the
#     service to be restarted if, and only if, the default lastaction is
#     enabled.
#
# @author https://github.com/simp/pupmod-simp-logrotate/graphs/contributors
#
#
class logrotate (
  Logrotate::Periods                 $rotate_period  = 'weekly',
  Integer[0]                         $rotate         = 4,
  Boolean                            $create         = true,
  Boolean                            $compress       = true,
  Array[Stdlib::Absolutepath]        $include_dirs   = [ '/etc/logrotate.d' ],
  Stdlib::Absolutepath               $configdir      = '/etc/logrotate.simp.d',
  Boolean                            $manage_wtmp    = true,
  Boolean                            $dateext        = true,
  String[1]                          $dateformat     = '-%Y%m%d.%s',
  Optional[Boolean]                  $dateyesterday  = undef,
  Optional[Logrotate::Size]          $maxsize        = undef,
  Optional[Logrotate::Size]          $minsize        = undef,
  String[1]                          $package_ensure = simplib::lookup('simp_options::package_ensure', { 'default_value' => 'installed' }),
  String[1]                          $logger_service = 'rsyslog'
) {

  simplib::assert_metadata($module_name)

  package { 'logrotate':
    ensure => $package_ensure
  }

  file { '/etc/logrotate.conf':
    ensure  => 'file',
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => template("${module_name}/logrotate.conf.erb")
  }

  # This is where the custom rules will go. They will be purged if not managed!
  file { $configdir:
    ensure  => 'directory',
    owner   => 'root',
    group   => 'root',
    recurse => true,
    purge   => true,
    force   => true,
    mode    => '0750'
  }
}
