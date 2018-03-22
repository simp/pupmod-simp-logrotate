# Add a LogRotate Configuration
#
# If options have a 'no' variant, then the no variant will be set if you set
# the primary value to false
#
# The ``logrotate(5)`` man page should be referenced for any undocumented
# parameter.
#
# @see logrotate(5)
#
# @param name [String]
#   Directly translates to the name of the file
#
# @param log_files
#   The log file strings for all logs to be affected by this stanza
#
# @param compress
#   If undefined it defaults to the setting in logrotate.
# @param compresscmd
# @param uncompresscmd
# @param compressext
# @param compressoptions
# @param copy
# @param copytruncate
# @param create
# @param rotate_period
# @param dateext
#   If set to true log files will be rotated using a date extension.
#   If false nodateext is set and rotated logs use a number extension.
#   If undefined it defaults to the setting in logrotate
# @param dateformat
# @param delaycompress
# @param extension
# @param ifempty
#
# @param ext_include
#   Corresponds to the ``include`` logrotate configuration since it is a
#   reserved word in Puppet
#
# @param mail
# @param maillast
# @param maxage
# @param minsize
# @param missingok
# @param olddir
# @param postrotate
# @param prerotate
# @param firstaction
# @param lastaction
#
# @param lastaction_restart_logger
#   Restart ``$logger_service`` as a logrotate ``lastaction``
#
#   * Has no effect if ``$lastaction`` is set
#
# @param logger_service
#   The name of the service which will be restarted as a logrotate ``lastaction``
#
#   * NOTE: This will default to ``rsyslog`` unless otherwise specified either
#     in the call to the define or as ``logrotate::logger_service``
#
# @param rotate
#   The number of old log files to keep.
#   If undefined it defaults to the setting in logrotate
# @param size
# @param sharedscripts
# @param start
# @param tabooext
#
# @author Trevor Vaughan <tvaughan@onyxpoint.com>
#
define logrotate::rule (
  Array[String[1]]                                    $log_files,
  Optional[Boolean]                                   $compress                  = undef,
  Optional[String[1]]                                 $compresscmd               = undef,
  Optional[String[1]]                                 $uncompresscmd             = undef,
  Optional[String[1]]                                 $compressext               = undef,
  Optional[String[1]]                                 $compressoptions           = undef,
  Boolean                                             $copy                      = false,
  Boolean                                             $copytruncate              = false,
  Pattern['\d{4} .+ .+']                              $create                    = '0640 root root',
  Optional[Enum['daily','weekly','monthly','yearly']] $rotate_period             = undef,
  Optional[Boolean]                                   $dateext                   = undef,
  String[1]                                           $dateformat                = '-%Y%m%d.%s',
  Optional[Boolean]                                   $delaycompress             = undef,
  Optional[String[1]]                                 $extension                 = undef,
  Boolean                                             $ifempty                   = false,
  Array[String[1]]                                    $ext_include               = [],
  Optional[Simplib::EmailAddress]                     $mail                      = undef,
  Boolean                                             $maillast                  = true,
  Optional[Integer[0]]                                $maxage                    = undef,
  Optional[Integer[0]]                                $minsize                   = undef,
  Boolean                                             $missingok                 = false,
  Optional[Stdlib::Absolutepath]                      $olddir                    = undef,
  Optional[String[1]]                                 $postrotate                = undef,
  Optional[String[1]]                                 $prerotate                 = undef,
  Optional[String[1]]                                 $firstaction               = undef,
  Optional[String[1]]                                 $lastaction                = undef,
  Boolean                                             $lastaction_restart_logger = false,
  Optional[String[1]]                                 $logger_service            = simplib::lookup('logrotate::logger_service', {'default_value' => 'rsyslog'}),
  Optional[Integer[0]]                                $rotate                    = undef,
  Optional[Integer[0]]                                $size                      = undef,
  Boolean                                             $sharedscripts             = true,
  Integer[0]                                          $start                     = 1,
  Array[String[1]]                                    $tabooext                  = []
) {

  include '::logrotate'

  # Use the provided lastaction.  If none provided, determine if the
  # logger_service should be restarted.
  if !$lastaction {
    if $lastaction_restart_logger {
      $_restartcmd = ('systemd' in $facts['init_systems']) ? {
        true    => "/usr/bin/systemctl restart ${logger_service}",
        default => "/sbin/service ${logger_service} restart"
      }
      $_lastaction = "${_restartcmd} > /dev/null 2>&1 || true"
    }
  }
  else {
    $_lastaction = $lastaction
  }

  $_dateext =  $dateext ? {
    undef   => $logrotate::dateext,
    default => $dateext }

  $_compress =  $compress ? {
    undef   => $logrotate::compress,
    default => $compress }

  $_rotate =  $rotate ? {
    undef   => $logrotate::rotate,
    default => $rotate }

  file { "${logrotate::configdir}/${name}":
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => template('logrotate/conf.erb')
  }
}
