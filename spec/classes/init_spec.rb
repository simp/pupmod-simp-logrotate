require 'spec_helper'

describe 'logrotate' do
  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }

      context 'with default parameters' do
        it { is_expected.to compile.with_all_deps }
        it { is_expected.to create_class('logrotate') }

        it do
          is_expected.to create_file('/etc/logrotate.simp.d').with({
                                                                     ensure: 'directory',
           owner: 'root',
           group: 'root',
           recurse: true,
           purge: true,
           force: true,
           mode: '0750'
                                                                   })
        end

        it do
          expected = <<EOM
# This file managed by puppet.
# Any changes that you make will be reverted on the next puppet run.

weekly
rotate 4
create
compress
dateext
dateformat -%Y%m%d.%s
include /etc/logrotate.simp.d
include /etc/logrotate.d


/var/log/wtmp {
    monthly
    minsize 1M
    create 0664 root utmp
    rotate 1
}
EOM
          is_expected.to create_file('/etc/logrotate.conf').with_content(expected)
        end

        it { is_expected.to contain_package('logrotate').with_ensure('installed') }
      end

      context 'create set to false' do
        let(:params) { { create: false } }

        it { is_expected.not_to create_file('/etc/logrotate.conf').with_content(%r{^create}) }
      end

      context 'compress set to false' do
        let(:params) { { compress: false } }

        it { is_expected.not_to create_file('/etc/logrotate.conf').with_content(%r{compress}) }
      end

      context 'dateext set to false' do
        let(:params) { { dateext: false } }

        it { is_expected.to create_file('/etc/logrotate.conf').with_content(%r{nodateext}) }
      end

      context 'dateyesterday set to true' do
        let(:params) { { dateyesterday: true } }

        it { is_expected.to create_file('/etc/logrotate.conf').with_content(%r{dateyesterday}) }
      end

      context 'dateyesterday set to false' do
        let(:params) { { dateyesterday: false } }

        it { is_expected.to create_file('/etc/logrotate.conf').without_content(%r{yesterdaynodateext}) }
      end

      context 'minsize set' do
        let(:params) { { minsize: '1M' } }

        it { is_expected.to create_file('/etc/logrotate.conf').with_content(%r{minsize 1M}) }
      end

      context 'maxsize set' do
        let(:params) { { maxsize: '1G' } }

        it { is_expected.to create_file('/etc/logrotate.conf').with_content(%r{maxsize 1G}) }
      end

      context 'both minsize and maxsize set' do
        let(:params) do
          {
            minsize: '1M',
         maxsize: '1G'
          }
        end

        it { is_expected.to create_file('/etc/logrotate.conf').with_content(%r{minsize 1M}) }
        it { is_expected.not_to create_file('/etc/logrotate.conf').with_content(%r{maxsize 1G}) }
      end

      context 'manage_wtmp set to false' do
        let(:params) { { manage_wtmp: false } }

        it { is_expected.not_to create_file('/etc/logrotate.conf').with_content(%r(/var/log/wtmp {)) }
      end
    end
  end
end
