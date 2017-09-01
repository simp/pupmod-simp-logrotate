require 'spec_helper'

describe 'logrotate' do
  context 'supported operating systems' do
    on_supported_os.each do |os, facts|
      context "on #{os}" do
        let(:facts) { facts }

        it { is_expected.to compile.with_all_deps }
        it { is_expected.to create_class('logrotate') }
        it { is_expected.to create_file('/etc/logrotate.conf').with_content(/weekly/) }
        it { is_expected.to create_file('/etc/logrotate.d').with_ensure('directory') }
        it { is_expected.to contain_package('logrotate').with_ensure('latest') }

        context "dateext set to false" do
          let(:params) {{
            :dateext => false
          }}

          it { is_expected.to create_file('/etc/logrotate.conf').with_content(/nodateext/)}
        end
      end
    end
  end
end
