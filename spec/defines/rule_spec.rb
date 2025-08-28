require 'spec_helper'

describe 'logrotate::rule' do
  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:title) { 'test_logrotate_title' }
      let(:pre_condition) { 'include "logrotate"' }
      let(:facts) { facts }

      context 'without a lastaction specified and lastaction_restart_logger = false' do
        let(:params) do
          {
            log_files: ['test1.log', 'test2.log']
          }
        end
        let(:content) { File.read('spec/defines/expected/rule.txt') }

        it { is_expected.to compile.with_all_deps }
        it { is_expected.to create_file('/etc/logrotate.simp.d/test_logrotate_title').with_content(content) }
        it { is_expected.not_to create_file('/etc/logrotate.simp.d/test_logrotate_title').with_content(%r{lastaction}) }
      end

      context 'without a lastaction specified and lastaction_restart_logger = true' do
        let(:params) do
          {
            log_files: ['test1.log', 'test2.log'],
         lastaction_restart_logger: true
          }
        end

        it { is_expected.to compile.with_all_deps }
        it { is_expected.to create_file('/etc/logrotate.simp.d/test_logrotate_title').with_content(%r{test1\.log.*test2\.log}) }
        if ((facts[:operatingsystem] == 'Amazon') && (facts[:operatingsystemmajrelease] < '3')) || (facts[:operatingsystemmajrelease].to_s >= '7')
          it { is_expected.to create_file('/etc/logrotate.simp.d/test_logrotate_title').with_content(%r{lastaction\n\s+/usr/bin/systemctl restart rsyslog}m) }
        else
          it { is_expected.to create_file('/etc/logrotate.simp.d/test_logrotate_title').with_content(%r{lastaction\n\s+/sbin/service rsyslog restart}m) }
        end
      end

      context 'with an alternate logger specified' do
        let(:params) do
          {
            log_files: ['test1.log', 'test2.log'],
         lastaction_restart_logger: true
          }
        end
        let(:hieradata) { 'alternate_logger' }

        if ((facts[:operatingsystem] == 'Amazon') && (facts[:operatingsystemmajrelease] < '3')) || (facts[:operatingsystemmajrelease].to_s >= '7')
          it { is_expected.to create_file('/etc/logrotate.simp.d/test_logrotate_title').with_content(%r{lastaction\n\s+/usr/bin/systemctl restart syslog}m) }
        else
          it { is_expected.to create_file('/etc/logrotate.simp.d/test_logrotate_title').with_content(%r{lastaction\n\s+/sbin/service syslog restart}m) }
        end
      end

      context 'with a lastaction specified' do
        let(:params) do
          {
            log_files: ['test1.log', 'test2.log'],
         lastaction: 'this is a lastaction'
          }
        end

        it { is_expected.to compile.with_all_deps }
        it { is_expected.to create_file('/etc/logrotate.simp.d/test_logrotate_title').with_content(%r{lastaction\n\s+this is a lastaction}m) }
      end

      context 'with a lastaction specified' do
        let(:params) do
          {
            log_files: ['test1.log', 'test2.log'],
         size: 1_000_000,
         minsize: '20k',
         maxsize: '1G'
          }
        end

        it { is_expected.to compile.with_all_deps }
        it { is_expected.to create_file('/etc/logrotate.simp.d/test_logrotate_title').with_content(%r{size\s1000000}) }
        it { is_expected.to create_file('/etc/logrotate.simp.d/test_logrotate_title').with_content(%r{minsize\s20k}) }
        it { is_expected.to create_file('/etc/logrotate.simp.d/test_logrotate_title').with_content(%r{maxsize\s1G}) }
      end

      context 'with default params' do
        let(:params) do
          {
            log_files: ['test1.log', 'test2.log'],
          }
        end
        let(:pre_condition) { 'include "logrotate"' }

        it { is_expected.to compile.with_all_deps }
        it { is_expected.to create_file('/etc/logrotate.simp.d/test_logrotate_title').with_content(%r{^\s*dateext\n}m) }
        it { is_expected.to create_file('/etc/logrotate.simp.d/test_logrotate_title').with_content(%r{^\s*rotate\s+4\n}m) }
      end

      context 'with non default parameters' do
        let(:params) do
          {
            log_files: ['test1.log', 'test2.log'],
         dateext: false,
         rotate: 5
          }
        end

        it { is_expected.to compile.with_all_deps }
        it { is_expected.to create_file('/etc/logrotate.simp.d/test_logrotate_title').with_content(%r{^\s*nodateext\n}m) }
        it { is_expected.to create_file('/etc/logrotate.simp.d/test_logrotate_title').with_content(%r{^\s*rotate\s+5\n}m) }
      end

      context 'with su features' do
        let(:params) do
          {
            log_files: ['test1.log', 'test2.log'],
         su: true,
         su_user: 'httpd',
         su_group: 'httpd',
          }
        end

        it { is_expected.to compile.with_all_deps }
        it { is_expected.to create_file('/etc/logrotate.simp.d/test_logrotate_title').with_content(%r{^\s*su httpd httpd\n}m) }
      end

      context 'dateyesterday set to true' do
        let(:params) do
          {
            log_files: ['test.log'],
         dateyesterday: true
          }
        end

        it { is_expected.to create_file('/etc/logrotate.simp.d/test_logrotate_title').with_content(%r{dateyesterday}) }
      end

      context 'dateyesterday set to false' do
        let(:params) do
          {
            log_files: ['test.log'],
         dateyesterday: false
          }
        end

        it { is_expected.to create_file('/etc/logrotate.simp.d/test_logrotate_title').without_content(%r{dateyesterday}) }
      end

      context 'shred set to true' do
        let(:params) do
          {
            log_files: ['test.log'],
         shred: true
          }
        end

        it { is_expected.to create_file('/etc/logrotate.simp.d/test_logrotate_title').with_content(%r{shred\n}) }
      end

      context 'shred set to true and shredcycles set' do
        let(:params) do
          {
            log_files: ['test.log'],
         shred: true,
         shredcycles: 5
          }
        end

        it { is_expected.to create_file('/etc/logrotate.simp.d/test_logrotate_title').with_content(%r{shred\n}) }
        it { is_expected.to create_file('/etc/logrotate.simp.d/test_logrotate_title').with_content(%r{shredcycles 5}) }
      end

      context 'shred set to false' do
        let(:params) do
          {
            log_files: ['test.log'],
         shred: false
          }
        end

        it { is_expected.to create_file('/etc/logrotate.simp.d/test_logrotate_title').with_content(%r{noshred}) }
      end

      context 'shred set to false and shredcycles set' do
        let(:params) do
          {
            log_files: ['test.log'],
         shred: false,
         shredcycles: 5
          }
        end

        it { is_expected.to create_file('/etc/logrotate.simp.d/test_logrotate_title').with_content(%r{noshred}) }

        it { is_expected.to create_file('/etc/logrotate.simp.d/test_logrotate_title').without_content(%r{shredcycles 5}) }
      end
    end
  end
end
