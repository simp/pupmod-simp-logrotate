[![License](http://img.shields.io/:license-apache-blue.svg)](http://www.apache.org/licenses/LICENSE-2.0.html) [![Build Status](https://travis-ci.org/simp/pupmod-simp-logrotate.svg)](https://travis-ci.org/simp/pupmod-simp-logrotate) [![SIMP compatibility](https://img.shields.io/badge/SIMP%20compatibility-4.2.*%2F5.1.*-orange.svg)](https://img.shields.io/badge/SIMP%20compatibility-4.2.*%2F5.1.*-orange.svg)

# pupmod-simp-logrotate

#### Table of Contents

1. [Description](#description)
2. [Setup - The basics of getting started with logrotate](#setup)
    * [What logrotate affects](#what-logrotate-affects)
    * [Setup requirements](#setup-requirements)
3. [Usage - Configuration options and additional functionality](#usage)
4. [Reference](#reference)
5. [Limitations - OS compatibility, etc.](#limitations)
6. [Development - Guide for contributing to the module](#development)

## Description

Configure LogRotate global options.

Use `logrotate::rule` for specific configuration options.

## Setup

### What logrotate affects

Manages the following:

* `logrotate` package
* `/etc/logrotate.conf` file
* `/etc/logrotate.d` directory and its contents

### Setup Requirements

This module requires the following:

* [puppetlabs-stdlib](https://forge.puppet.com/puppetlabs/stdlib)
* [simp-simplib](https://forge.puppet.com/simp/simplib)

## Usage

    class { 'logrotate': }

## Reference

### Public Classes

* [logrotate](https://github.com/simp/pupmod-simp-logrotate/blob/master/manifests/init.pp)

#### Parameters

* **`rotate\_period`** (`Enum['daily','weekly','monthly','yearly']`) *(defaults to: `'weekly'`)*

How often to rotate the logs

* **`rotate`** (`Integer[0]`) *(defaults to: `4`)*

The number of times to rotate the logs before removing them from the system

* **`create`** (`Boolean`) *(defaults to: `true`)*

Create new log files if they do not exist

* **`compress`** (`Boolean`) *(defaults to: `true`)*

Compress the logs upon rotation

* **`configdir`** (`Stdlib::Absolutepath`) *(defaults to: `'/etc/logrotate.d'`)*

The primary directory for configuration files.

* **`include\_dirs`** (`Array[Stdlib::Absolutepath]`) *(defaults to: `[]`)*

Directories to include in your logrotate configuration

***`$logrotate::configdir` is always included***

* **`manage\_wtmp`** (`Boolean`) *(defaults to: `true`)*

Set to `false` if you do not want `/var/log/wtmp` to be managed by logrotate

* **`dateext`** (`Boolean`) *(defaults to: `true`)*

Use `dateext` as the suffix for rotated files

* **`dateformat`** (`String`) *(defaults to: `'-%Y%m%d.%s'`)*

The format of the date to be appended

***Leaving as is allows for multiple rotations per day***

* **`maxsize`** (`Optional[Pattern['^\d+(k|M|G)?$']]`) *(defaults to: `undef`)*

The default maximum size of a logfile

* **`minsize`** (`Optional[Pattern['^\d+(k|M|G)?$']]`) *(defaults to: `undef`)*

The default minimum size of a logfile

***Overrides the `maxsize` setting***

* **`package\_ensure`** (`String`) *(defaults to: `simplib::lookup('simp_options::package_ensure', { 'default_value' => 'installed' })`)*

The ensure status of packages to be installed

* **`logger\_service`** (`String`) *(defaults to: `'rsyslog'`)*

The service that controls system logging

***This is used by the `logrotate::rule` define to note the name of the service to be restarted if, and only if, the default lastaction is enabled.***

### Defined Types

* [logrotate::rule](https://github.com/simp/pupmod-simp-logrotate/blob/master/manifests/rule.pp): Add a `logrotate` configuration

#### Parameters

* **`name`** (`String`)

Directly translates to the name of the file

* **`log\_files`** (`Array[String]`)

The log file strings for all logs to be affected by this stanza

* **`compress`** (`Optional[Boolean]`) *(defaults to: `undef`)*

If undefined it defaults to the setting in logrotate.

* **`compresscmd`** (`Optional[String]`) *(defaults to: `undef`)*
* **`uncompresscmd`** (`Optional[String]`) *(defaults to: `undef`)*
* **`compressext`** (`Optional[String]`) *(defaults to: `undef`)*
* **`compressoptions`** (`Optional[String]`) *(defaults to: `undef`)*
* **`copy`** (`Boolean`) *(defaults to: `false`)*
* **`copytruncate`** (`Boolean`) *(defaults to: `false`)*
* **`create`** (`Pattern['\d{4} .+ .+']`) *(defaults to: `'0640 root root'`)*
* **`rotate\_period`** (`Optional[Enum['daily','weekly','monthly','yearly']]`) *(defaults to: `undef`)*
* **`dateext`** (`Optional[Boolean]`) *(defaults to: `undef`)*

If set to true log files will be rotated using a date extension. If false nodateext is set and rotated logs use a number extension. If undefined it defaults to the setting in logrotate

* **`dateformat`** (`String`) *(defaults to: `'-%Y%m%d.%s'`)*
* **`delaycompress`** (`Optional[Boolean]`) *(defaults to: `undef`)*
* **`extension`** (`Optional[String]`) *(defaults to: `undef`)*
* **`ifempty`** (`Boolean`) *(defaults to: `false`)*
* **`ext\_include`** (`Array[String]`) *(defaults to: `[]`)*

Corresponds to the `include` logrotate configuration since it is a reserved word in Puppet

* **`mail`** (`Optional[Simplib::EmailAddress]`) *(defaults to: `undef`)*
* **`maillast`** (`Boolean`) *(defaults to: `true`)*
* **`maxage`** (`Optional[Integer[0]]`) *(defaults to: `undef`)*
* **`minsize`** (`Optional[Integer[0]]`) *(defaults to: `undef`)*
* **`missingok`** (`Boolean`) *(defaults to: `false`)*
* **`olddir`** (`Optional[Stdlib::Absolutepath]`) *(defaults to: `undef`)*
* **`postrotate`** (`Optional[String]`) *(defaults to: `undef`)*
* **`prerotate`** (`Optional[String]`) *(defaults to: `undef`)*
* **`firstaction`** (`Optional[String]`) *(defaults to: `undef`)*
* **`lastaction`** (`Optional[String]`) *(defaults to: `undef`)*
* **`lastaction\_restart\_logger`** (`Boolean`) *(defaults to: `false`)*

Restart `$logger_service` as a logrotate `lastaction`

***Has no effect if `$lastaction` is set***

* **`logger\_service`** (`Optional[String]`) *(defaults to: `simplib::lookup('logrotate::logger_service', {'default_value' => 'rsyslog'})`)*

The name of the service which will be restarted as a logrotate `lastaction`

***NOTE: This will default to `rsyslog` unless otherwise specified either in the call to the define or as `logrotate::logger_service`***

* **`rotate`** (`Optional[Integer[0]]`) *(defaults to: `undef`)*

The number of old log files to keep. If undefined it defaults to the setting in logrotate

* **`size`** (`Optional[Integer[0]]`) *(defaults to: `undef`)*
* **`sharedscripts`** (`Boolean`) *(defaults to: `true`)*
* **`start`** (`Integer[0]`) *(defaults to: `1`)*
* **`tabooext`** (`Array[String]`) *(defaults to: `[]`)*

## Limitations

SIMP Puppet modules are generally intended for use on Red Hat Enterprise
Linux and compatible distributions, such as CentOS. Please see the
[`metadata.json` file](./metadata.json) for the most up-to-date list of
supported operating systems, Puppet versions, and module dependencies.

## Development

Please read our [Contribution Guide](http://simp-doc.readthedocs.io/en/stable/contributors_guide/index.html).

If you find any issues, they can be submitted to our
[JIRA](https://simp-project.atlassian.net).
