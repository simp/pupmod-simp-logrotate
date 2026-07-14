require 'spec_helper_acceptance'

test_name 'logrotate'

describe 'logrotate class' do
  hosts.each do |host|
    context "on #{host}" do
      let(:manifest) do
        <<-EOS
          include logrotate
        EOS
      end

      let(:manifest_with_rule) do
        <<-EOS
          # explicitly turn off compression globally, so we can see
          # that our specific syslog rule that has compression enabled
          # is being run, instead of the default rule which does not
          # have compression
          class { 'logrotate': compress => false }

          # this supercedes /etc/logrotate.d/syslog
          logrotate::rule { 'syslog':
            log_files                 => [ '/var/log/messages' ],
            rotate_period             => 'daily',
            rotate                    => 7,
            lastaction_restart_logger => true,
            missingok                 => true,
            compress                  => true
          }
        EOS
      end

      # Exercise noop from a clean (uninstalled) state: on a fresh node the Sicura
      # console previews the module with `puppet apply --noop`, which must not error
      # even though nothing logrotate manages exists yet. Real idempotence is covered
      # by the applies below. A post-convergence noop check is deliberately omitted:
      # `puppet apply --noop --detailed-exitcodes` always exits 0, so it could never
      # fail and would test nothing.
      context 'in noop mode from a clean state' do
        # Setup, not an assertion: as before(:context) a failure errors this context
        # rather than aborting the whole suite under .rspec's --fail-fast. `puppet
        # resource` exits 0 whether it removes the package or finds it already absent
        # (no --detailed-exitcodes), so no acceptable_exit_codes override is needed.
        before(:context) do
          on(host, 'puppet resource package logrotate ensure=absent')
        end

        it 'applies without errors in noop mode' do
          apply_manifest_on(host, manifest, catch_failures: true, noop: true)
        end
      end

      it 'works with default values' do
        apply_manifest_on(host, manifest, catch_failures: true)
      end

      it 'is idempotent' do
        apply_manifest_on(host, manifest, catch_changes: true)
      end

      it 'creates SIMP-specific logrotate rule' do
        apply_manifest_on(host, manifest_with_rule, catch_failures: true)
      end

      it 'is idempotent with SIMP-specific logrotate rule' do
        apply_manifest_on(host, manifest_with_rule, catch_changes: true)
      end

      it 'logrotate should use SIMP rule in lieu of overlapping system rule' do
        # make sure our assumptions about the default rule are correct
        result = on(host, 'grep -l /var/log/messages /etc/logrotate.d/*')

        expect(result.stdout.split("\n").first.strip).not_to match(%r{^compress})

        result = on(host, 'logrotate -f /etc/logrotate.conf', accept_all_exit_codes: true)

        expect(result.stderr).to include('duplicate log entry for /var/log/messages')
        on(host, 'ls -l /var/log/messages*')
        on(host, 'ls -l /var/log/messages-[0-9]*\.[0-9]*\.gz')
      end
    end
  end
end
