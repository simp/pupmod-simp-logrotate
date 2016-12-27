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
# @param compresscmd
# @param uncompresscmd
# @param compressext
# @param compressoptions
# @param copy
# @param copytruncate
# @param create
# @param rotate_period
# @param dateext
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
# @param rotate
# @param size
# @param sharedscripts
# @param start
# @param tabooext
#
# @author Trevor Vaughan <tvaughan@onyxpoint.com>
#
define logrotate::rule (
  Array[String]                                       $log_files,
  Boolean                                             $compress        = true,
  Optional[String]                                    $compresscmd     = undef,
  Optional[String]                                    $uncompresscmd   = undef,
  Optional[String]                                    $compressext     = undef,
  Optional[String]                                    $compressoptions = undef,
  Boolean                                             $copy            = false,
  Boolean                                             $copytruncate    = false,
  Pattern['\d{4} .+ .+']                              $create          = '0640 root root',
  Optional[Enum['daily','weekly','monthly','yearly']] $rotate_period   = undef,
  Boolean                                             $dateext         = true,
  String                                              $dateformat      = '-%Y%m%d.%s',
  Optional[Boolean]                                   $delaycompress   = undef,
  Optional[String]                                    $extension       = undef,
  Boolean                                             $ifempty         = false,
  Array[String]                                       $ext_include     = [],
  Optional[Simplib::EmailAddress]                     $mail            = undef,
  Boolean                                             $maillast        = true,
  Optional[Integer[0]]                                $maxage          = undef,
  Optional[Integer[0]]                                $minsize         = undef,
  Boolean                                             $missingok       = false,
  Optional[Stdlib::Absolutepath]                      $olddir          = undef,
  Optional[String]                                    $postrotate      = undef,
  Optional[String]                                    $prerotate       = undef,
  Optional[String]                                    $firstaction     = undef,
  Optional[String]                                    $lastaction      = undef,
  Integer[0]                                          $rotate          = 4,
  Optional[Integer[0]]                                $size            = undef,
  Boolean                                             $sharedscripts   = true,
  Integer[0]                                          $start           = 1,
  Array[String]                                       $tabooext        = []
) {
  file { "/etc/logrotate.d/${name}":
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => template('logrotate/conf.erb')
  }
}
