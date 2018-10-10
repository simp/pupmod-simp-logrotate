[![License](https://img.shields.io/:license-apache-blue.svg)](http://www.apache.org/licenses/LICENSE-2.0.html)
[![CII Best Practices](https://bestpractices.coreinfrastructure.org/projects/73/badge)](https://bestpractices.coreinfrastructure.org/projects/73)
[![Puppet Forge](https://img.shields.io/puppetforge/v/simp/logrotate.svg)](https://forge.puppetlabs.com/simp/logrotate)
[![Puppet Forge Downloads](https://img.shields.io/puppetforge/dt/simp/logrotate.svg)](https://forge.puppetlabs.com/simp/logrotate)
[![Build Status](https://travis-ci.org/simp/pupmod-simp-logrotate.svg)](https://travis-ci.org/simp/pupmod-simp-logrotate)

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
* `/etc/logrotate.simp.d` directory and its contents

### Setup Requirements

This module requires the following:

* [puppetlabs-stdlib](https://forge.puppet.com/puppetlabs/stdlib)
* [simp-simplib](https://forge.puppet.com/simp/simplib)

## Usage

```puppet
class { 'logrotate': }
```

## Reference

See [REFERENCE.md](REFERENCE.md).

## Limitations

SIMP Puppet modules are generally intended for use on Red Hat Enterprise
Linux and compatible distributions, such as CentOS. Please see the
[`metadata.json` file](./metadata.json) for the most up-to-date list of
supported operating systems, Puppet versions, and module dependencies.

## Development

Please read our [Contribution Guide](http://simp-doc.readthedocs.io/en/stable/contributors_guide/index.html).

If you find any issues, they can be submitted to our
[JIRA](https://simp-project.atlassian.net).
