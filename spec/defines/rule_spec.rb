require 'spec_helper'

describe 'logrotate::rule' do
  on_supported_os.each do |os, facts|
    context "on #{os}" do

      let(:title) {'test_logrotate_title'}
      let(:pre_condition) { 'include "logrotate"' }
      let(:facts) { facts }

      context 'without a lastaction specified and lastaction_restart_logger = false' do
        let(:params) {{
          :log_files => ['test1.log', 'test2.log']
        }}
        let(:content) { File.read('spec/defines/expected/rule.txt') }
        it { is_expected.to compile.with_all_deps }
        it { is_expected.to create_file('/etc/logrotate.simp.d/test_logrotate_title').with_content(content) }
        it { is_expected.to_not create_file('/etc/logrotate.simp.d/test_logrotate_title').with_content(/lastaction/) }
      end

      context 'without a lastaction specified and lastaction_restart_logger = true' do
        let(:params) {{
          :log_files                 => ['test1.log', 'test2.log'],
          :lastaction_restart_logger => true
        }}
        it { is_expected.to compile.with_all_deps }
        it { is_expected.to create_file('/etc/logrotate.simp.d/test_logrotate_title').with_content(/test1\.log.*test2\.log/) }
        if (facts[:operatingsystemmajrelease].to_s >= '7')
          it { is_expected.to create_file('/etc/logrotate.simp.d/test_logrotate_title').with_content(/lastaction\n\s+\/usr\/bin\/systemctl restart rsyslog/m) }
        else
          it { is_expected.to create_file('/etc/logrotate.simp.d/test_logrotate_title').with_content(/lastaction\n\s+\/sbin\/service rsyslog restart/m) }
        end
      end

      context 'with an alternate logger specified' do
        let(:params) {{
          :log_files                 => ['test1.log', 'test2.log'],
          :lastaction_restart_logger => true
        }}
        let(:hieradata) { 'alternate_logger' }
        if (facts[:operatingsystemmajrelease].to_s >= '7')
          it { is_expected.to create_file('/etc/logrotate.simp.d/test_logrotate_title').with_content(/lastaction\n\s+\/usr\/bin\/systemctl restart syslog/m) }
        else
          it { is_expected.to create_file('/etc/logrotate.simp.d/test_logrotate_title').with_content(/lastaction\n\s+\/sbin\/service syslog restart/m) }
        end
      end

      context 'with a lastaction specified' do
        let(:params) {{
          :log_files  => ['test1.log', 'test2.log'],
          :lastaction => 'this is a lastaction'
        }}
        it { is_expected.to compile.with_all_deps }
        it { is_expected.to create_file('/etc/logrotate.simp.d/test_logrotate_title').with_content(/lastaction\n\s+this is a lastaction/m) }
      end
      context 'with default params' do
        let(:params) {{
          :log_files => ['test1.log', 'test2.log'],
        }}
        let(:pre_condition) { 'include "logrotate"' }
        it { is_expected.to compile.with_all_deps }
        it { is_expected.to create_file('/etc/logrotate.simp.d/test_logrotate_title').with_content(/^\s*dateext\n/m) }
        it { is_expected.to create_file('/etc/logrotate.simp.d/test_logrotate_title').with_content(/^\s*rotate\s+4\n/m) }
      end
      context 'with non default parameters' do
        let(:params) {{
          :log_files => ['test1.log', 'test2.log'],
          :dateext   => false,
          :rotate    => 5
        }}
        it { is_expected.to compile.with_all_deps }
        it { is_expected.to create_file('/etc/logrotate.simp.d/test_logrotate_title').with_content(/^\s*nodateext\n/m) }
        it { is_expected.to create_file('/etc/logrotate.simp.d/test_logrotate_title').with_content(/^\s*rotate\s+5\n/m) }
      end

      context 'with su features' do
        let(:params) {{
          :log_files => ['test1.log', 'test2.log'],
          :su        => true,
          :su_user   => 'httpd',
          :su_group  => 'httpd',
        }}
        if facts[:os][:release][:major].to_i == 6
          it { is_expected.to compile.and_raise_error(/not available on EL6/) }
        else
          it { is_expected.to compile.with_all_deps }
          it { is_expected.to create_file('/etc/logrotate.simp.d/test_logrotate_title').with_content(/^\s*su httpd httpd\n/m) }
        end
      end
      # just need to add tests for $su and $shred
    end
  end
end
