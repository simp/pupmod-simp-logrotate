# AGENTS.md

This file provides guidance to AI agents when working with code in this repository.

## What this module does

`simp-logrotate` is a small SIMP Puppet module that manages the **logrotate**
log-rotation utility on Enterprise Linux. It installs the `logrotate` package,
renders the global `/etc/logrotate.conf`, and provides the `logrotate::rule`
defined type for adding per-log rotation stanzas.

The SIMP twist is where rules live: instead of dropping files directly into
`/etc/logrotate.d`, the module owns a dedicated **`/etc/logrotate.simp.d`**
directory (`manifests/init.pp:70`) that is managed with `recurse => true,
purge => true, force => true` (`init.pp:96-104`). Every rule file in that
directory **must** come from a `logrotate::rule` resource — any unmanaged file
placed there is deleted on the next Puppet run. The generated
`/etc/logrotate.conf` `include`s both `/etc/logrotate.simp.d` and the
directories in `$include_dirs` (default `['/etc/logrotate.d']`), so
distro-shipped rules under `/etc/logrotate.d` keep working alongside the
SIMP-managed ones.

### Business logic

Two things live here: one public class and one public defined type.

- **`logrotate` (`manifests/init.pp:64-105`)** — Public entry class (consumers
  `include 'logrotate'`; not `assert_private()`'d). Calls
  `simplib::assert_metadata($module_name)` (`init.pp:81`), then declares three
  resources:
  - `package { 'logrotate' }` at `$package_ensure` (`init.pp:83-85`).
  - `file { '/etc/logrotate.conf' }` (mode `0644`) rendered from
    `logrotate.conf.erb` (`init.pp:87-93`) — the global defaults
    (`$rotate_period`, `$rotate`, `$create`, `$compress`, `dateext`/`nodateext`,
    `$dateformat`, `$minsize`/`$maxsize`, the optional `/var/log/wtmp` stanza
    gated on `$manage_wtmp`, and the `include` lines).
  - `file { $configdir }` — the purged `/etc/logrotate.simp.d` directory
    (`init.pp:96-104`).
  - Notable params (`init.pp:65-78`): `$rotate_period` (`Logrotate::Periods`,
    default `'weekly'`), `$rotate` (`Integer[0]`, default `4`),
    `$include_dirs` (default `['/etc/logrotate.d']` — **if you override this,
    re-add `/etc/logrotate.d` yourself**, per the docstring at `init.pp:24-26`),
    `$configdir` (default `/etc/logrotate.simp.d`), `$package_ensure` (the seam,
    `init.pp:77`), and `$logger_service` (default `'rsyslog'`, consumed by the
    define's lastaction hook).

- **`logrotate::rule` (`manifests/rule.pp:83-171`)** — Public defined type; the
  primary API for adding a rotation stanza. It `include`s `logrotate`
  (`rule.pp:126`) and writes one file `${logrotate::configdir}/${name}`
  (mode `0644`) rendered from `conf.erb` (`rule.pp:165-170`). The resource
  title becomes the filename (`rule.pp:11-12`). Required param: `$log_files`
  (`Array[String[1]]`, `rule.pp:84`). Key behavior:
  - **`no`-variant convention**: many booleans emit their negated logrotate
    keyword when set false (`$ifempty=false`→`notifempty`, `$copy=false`→
    `nocopy`, `$compress=false`→`nocompress`, etc.) — documented at the top of
    the file (`rule.pp:1-4`) and implemented in `conf.erb`.
  - **`lastaction` / logger restart** (`rule.pp:128-141`): if you pass
    `$lastaction` it is used verbatim. Otherwise, when
    `$lastaction_restart_logger => true`, the define builds a restart command
    for `$logger_service` — `systemctl restart` when `'systemd' in
    $facts['init_systems']`, else `/sbin/service … restart` — wrapped as
    `… > /dev/null 2>&1 || true` so a restart failure never fails the rotation.
    `$lastaction_restart_logger` has **no effect** if `$lastaction` is set.
  - **`su` validation** (`rule.pp:143-151`): if `$su => true`, both `$su_user`
    and `$su_group` are required or the catalog fails with
    `'logrotate: when $su is specified, $su_user and $su_group must not be
    empty'`.
  - **Inheritance from the class** (`rule.pp:153-163`): `$dateext`, `$compress`,
    and `$rotate` fall back to the `logrotate` class values when left `undef`.
    Other rule params do not inherit — they simply stay unset.
  - **`ext_include`** (`rule.pp:100`, docstring `rule.pp:37-39`) maps to
    logrotate's `include` directive; it is spelled `ext_include` because
    `include` is a Puppet reserved word.

### Gotchas / non-obvious details

- **`/etc/logrotate.simp.d` is purged.** Anything in it not declared through
  `logrotate::rule` is removed on the next run (`init.pp:96-104`). Add rules
  with the define, not by writing files.
- **Overriding `$include_dirs` can silently drop distro rules.** The default
  includes `/etc/logrotate.d`; if you set your own list you must re-add it
  (`init.pp:21-26`).
- **`$lastaction` wins over `$lastaction_restart_logger`.** Setting an explicit
  `lastaction` disables the automatic logger-restart entirely (`rule.pp:130`).
- **`$su` needs both user and group** or the catalog hard-fails
  (`rule.pp:143-146`).
- **`$create` is a formatted string**, not separate mode/owner/group params:
  `Pattern['\d{4} .+ .+']`, default `'0640 root root'` (`rule.pp:92`).
- **No module data.** This module has **no `hiera.yaml` and no `data/`
  directory** — every default is inline in the manifests (e.g. `$package_ensure`
  at `init.pp:77`). There is nothing to look up in module data; change defaults
  in the manifest or override at the call site / site Hiera.
- **`simp/simp_options` is NOT a declared dependency** in `metadata.json`, yet
  the manifests consume the `simp_options::package_ensure` seam via
  `simplib::lookup` (provided by `simp/simplib`). `simp_options` is present only
  as a test fixture (`.fixtures.yml`).

## The `simp_options` / `simplib::lookup` seam

The module's lookup seam — the natural target for a lookup-path unit test:

| Line | Key | `default_value` |
|------|-----|-----------------|
| `init.pp:77` | `simp_options::package_ensure` | `'installed'` |
| `rule.pp:113` | `logrotate::logger_service` (module-local, not `simp_options::*`) | `'rsyslog'` |

Keep routing package state through `simplib::lookup('simp_options::package_ensure',
{ 'default_value' => ... })` with an explicit default rather than assuming
`simp_options` is included.

## Dependencies

Module dependencies (from `metadata.json`):

- `simp/simplib` `>= 4.9.0 < 6.0.0` (provides `simplib::lookup`,
  `simplib::assert_metadata`, and the `Simplib::EmailAddress` type used by
  `logrotate::rule`'s `$mail`)
- `puppetlabs/stdlib` `>= 8.0.0 < 10.0.0` (provides `Stdlib::Absolutepath`)

No optional dependencies (`metadata.json` declares no
`simp.optional_dependencies`).

Fixture-only dependency (from `.fixtures.yml`, present for test compilation,
not a runtime dep): `simp_options`.

Runtime requirement (from `metadata.json` `requirements`): `openvox
>= 8.0.0 < 9.0.0`.

Supported OS matrix (from `metadata.json`): CentOS 9/10; RedHat 8/9/10;
OracleLinux 8/9/10; Rocky 8/9/10; AlmaLinux 8/9/10.

## Repository layout

- `manifests/init.pp` — the `logrotate` class: package, `/etc/logrotate.conf`,
  and the purged `/etc/logrotate.simp.d` directory.
- `manifests/rule.pp` — the `logrotate::rule` defined type (the public API for
  adding a rotation stanza).
- `types/periods.pp` — `Logrotate::Periods`: `Enum['hourly','daily','weekly',
  'monthly','yearly']`.
- `types/size.pp` — `Logrotate::Size`: `Variant[Integer[1],
  Pattern[/^[0-9]+[kMG]?$/]]` (raw bytes or an integer with a `k`/`M`/`G`
  suffix).
- `templates/logrotate.conf.erb` — renders `/etc/logrotate.conf` (global
  settings + `include` lines + optional wtmp stanza).
- `templates/conf.erb` — renders each per-rule stanza file under
  `/etc/logrotate.simp.d/`.
- `metadata.json` — deps, OS matrix, OpenVox requirement.
- `spec/classes/`, `spec/defines/` — rspec-puppet unit tests.
- `spec/acceptance/suites/default/` — beaker acceptance suite; nodesets under
  `spec/acceptance/nodesets/`.
- `REFERENCE.md` — generated Puppet Strings reference.
- No `data/` / `hiera.yaml` (no module data), and no `lib/` (no custom Ruby
  types/providers/functions/facts). Every custom type, function, and fact the
  module uses comes from the dependencies above.
- **Acceptance runs in CI:** `.github/workflows/pr_tests.yml` has an
  `acceptance` job (matrix `almalinux9`, `almalinux10`) whose final step runs
  `bundle exec rake beaker:suites[default,<node>]` under
  `BEAKER_HYPERVISOR=vagrant_libvirt`.

## Common commands

```sh
# Install dependencies
bundle install

# Run all unit tests
bundle exec rake spec

# Run a single spec
bundle exec rspec spec/defines/rule_spec.rb

# Puppet lint
bundle exec rake lint

# Ruby lint
bundle exec rake rubocop

# Regenerate REFERENCE.md from puppet-strings docstrings
puppet strings generate --format markdown --out REFERENCE.md

# Run the default beaker acceptance suite
bundle exec rake beaker:suites[default]
```

Relevant gem pins (from `Gemfile`): `puppetlabs_spec_helper ~> 8.0.0`,
`simp-rake-helpers ~> 5.24.0`, `simp-rspec-puppet-facts ~> 4.0.0`,
`simp-beaker-helpers ~> 2.0.0`, `rubocop ~> 1.88.0`. `spec/spec_helper.rb`
requires `puppetlabs_spec_helper/module_spec_helper`.

## Conventions

- Add rotation rules with `logrotate::rule`; never write files into
  `/etc/logrotate.simp.d` directly — the directory is purged.
- Preserve the `@summary` / `@param` puppet-strings docstrings — they drive
  `REFERENCE.md`. Regenerate `REFERENCE.md` after changing docs or parameters.
- Keep the `no`-variant boolean convention (`rule.pp:1-4`): a false boolean
  emits the negated logrotate keyword in `conf.erb`.
- Continue routing package state through
  `simplib::lookup('simp_options::package_ensure', { 'default_value' => ... })`
  rather than assuming `simp_options` is included.
- `Gemfile`, `spec/spec_helper.rb`, and `.github/workflows/pr_tests.yml` carry a
  **puppetsync** notice — they are baseline-managed and the next sync overwrites
  local edits. Push changes to those files upstream to the baseline, not here.
- Match the existing 2-space Puppet indentation and aligned-arrow parameter
  style used in `manifests/`.
