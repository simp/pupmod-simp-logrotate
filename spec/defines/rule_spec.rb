require 'spec_helper'

describe 'logrotate::rule' do
  context 'supported operating systems' do
    on_supported_os.each do |os, facts|
      context "on #{os}" do

        let(:title) {'test_logrotate_title'}
        let(:pre_condition) { 'include "logrotate"' }
        let(:facts) { facts }

        context 'without a lastaction specified and lastaction_restart_logger = false' do
          let(:params) {{
            :log_files => ['test1.log', 'test2.log']
          }}
          it { is_expected.to compile.with_all_deps }
          it { is_expected.to create_file('/etc/logrotate.d/test_logrotate_title').with_content(/test1\.log.*test2\.log/) }
          it { is_expected.to_not create_file('/etc/logrotate.d/test_logrotate_title').with_content(/lastaction/) }
        end

        context 'without a lastaction specified and lastaction_restart_logger = true' do
          let(:params) {{
            :log_files                 => ['test1.log', 'test2.log'],
            :lastaction_restart_logger => true
          }}
          it { is_expected.to compile.with_all_deps }
          it { is_expected.to create_file('/etc/logrotate.d/test_logrotate_title').with_content(/test1\.log.*test2\.log/) }
          if (['RedHat', 'CentOS'].include?(facts[:operatingsystem]))
            if (facts[:operatingsystemmajrelease].to_s >= '7')
              it { is_expected.to create_file('/etc/logrotate.d/test_logrotate_title').with_content(/lastaction\n\s+\/usr\/bin\/systemctl restart rsyslog/m) }
            else
              it { is_expected.to create_file('/etc/logrotate.d/test_logrotate_title').with_content(/lastaction\n\s+\/sbin\/service rsyslog restart/m) }
            end
          end
        end

        context 'with an alternate logger specified' do
          let(:params) {{
            :log_files                 => ['test1.log', 'test2.log'],
            :lastaction_restart_logger => true
          }}
          let(:hieradata) { 'alternate_logger' }
          if (['RedHat', 'CentOS'].include?(facts[:operatingsystem]))
            if (facts[:operatingsystemmajrelease].to_s >= '7')
              it { is_expected.to create_file('/etc/logrotate.d/test_logrotate_title').with_content(/lastaction\n\s+\/usr\/bin\/systemctl restart syslog/m) }
            else
              it { is_expected.to create_file('/etc/logrotate.d/test_logrotate_title').with_content(/lastaction\n\s+\/sbin\/service syslog restart/m) }
            end
          end
        end

        context 'with a lastaction specified' do
          let(:params) {{
            :log_files   => ['test1.log', 'test2.log'],
            :lastaction  => 'this is a lastaction'
          }}
          it { is_expected.to compile.with_all_deps }
          it { is_expected.to create_file('/etc/logrotate.d/test_logrotate_title').with_content(/lastaction\n\s+this is a lastaction/m) }
        end
        context 'with default params' do
          let(:params) {{
            :log_files => ['test1.log', 'test2.log'],
          }}
          let(:pre_condition) { 'include "logrotate"' }
          it { is_expected.to compile.with_all_deps }
          it { is_expected.to create_file('/etc/logrotate.d/test_logrotate_title').with_content(/^\s*dateext\n/m) }
          it { is_expected.to create_file('/etc/logrotate.d/test_logrotate_title').with_content(/^\s*rotate\s+4\n/m) }
        end
        context 'with dateext set to false' do
          let(:params) {{
            :log_files => ['test1.log', 'test2.log'],
            :dateext   => false,
            :rotate    => 5
          }}
          it { is_expected.to compile.with_all_deps }
          it { is_expected.to create_file('/etc/logrotate.d/test_logrotate_title').with_content(/^\s*nodateext\n/m) }
          it { is_expected.to create_file('/etc/logrotate.d/test_logrotate_title').with_content(/^\s*rotate\s+5\n/m) }
        end
      end
    end
  end
end
