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

        expect(result.stderr).to match(%r{duplicate log entry for /var/log/messages})
        on(host, 'ls -l /var/log/messages*')
        on(host, 'ls -l /var/log/messages-[0-9]*\.[0-9]*\.gz')
      end
    end
  end
end
