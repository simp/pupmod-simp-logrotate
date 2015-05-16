# == Define: logrotate:add
#
# Add a logrotate entry.
#
# == Parameters
#  Most options are from logrotate(5).
#
# If options have a 'no' variant, then the no variant will be set if you set
# the primary value to false
#
# [*name*]
#   Directly translates to the name of the file.
#
# [*log_files*]
#   An array that contains the log file strings for all logs to be affected
#   by this stanza.
#
# [*compress*]
# [*compresscmd*]
# [*uncompresscmd*]
# [*compressext*]
# [*compressoptions*]
# [*copy*]
# [*copytruncate*]
# [*create*]
# [*rotate_period*]
#   Can be one of 'daily', 'weekly', 'monthly', 'yearly'Can be one of 'daily', 'weekly', 'monthly', 'yearly'
#
# [*dateext*]
# [*dateformat*]
# [*delaycompress*]
# [*extension*]
# [*ifempty*]
#
# 'include'
#  A reserved word and was changed to ext_include to protect the innocent.
# [*ext_include*]
# [*mail*]
# [*maillast*]
# [*maxage*]
# [*minsize*]
# [*missingok*]
# [*olddir*]
# [*postrotate*]
# [*prerotate*]
# [*firstaction*]
# [*lastaction*]
# [*rotate*]
# [*size*]
# [*sharedscripts*]
# [*start*]
# [*tabooext*]
#
# == Authors
#
# * Trevor Vaughan <tvaughan@onyxpoint.com>
#
define logrotate::add (
  $log_files,
  $compress = true,
  $compresscmd = '',
  $uncompresscmd = '',
  $compressext = '',
  $compressoptions = '',
  $copy = false,
  $copytruncate = false,
  $create = '0640 root root',
  $rotate_period = '',
  $dateext = true,
  $dateformat = '-%Y%m%d.%s',
  $delaycompress = '',
  $extension = '',
  $ifempty = false,
  $ext_include = '',
  $mail = '',
  $maillast = true,
  $maxage = '',
  $minsize = '',
  $missingok = false,
  $olddir = '',
  $postrotate = '',
  $prerotate = '',
  $firstaction = '',
  $lastaction = '',
  $rotate = '4',
  $size = '',
  $sharedscripts = true,
  $start = '1',
  $tabooext = ''
) {

  file { "/etc/logrotate.d/$name":
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => template('logrotate/conf.erb')
  }

  validate_bool($compress)
  validate_bool($copy)
  validate_bool($copytruncate)
  if $rotate_period != '' {
    validate_array_member($rotate_period, ['daily','weekly','monthly','yearly'])
  }
  validate_bool($dateext)
  validate_bool($ifempty)
  validate_bool($maillast)
  validate_bool($missingok)
  validate_integer($rotate)
  validate_bool($sharedscripts)
  validate_integer($start)
}
