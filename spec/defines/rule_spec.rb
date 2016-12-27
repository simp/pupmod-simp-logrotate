require 'spec_helper'

describe 'logrotate::rule' do
  context 'supported operating systems' do
    on_supported_os.each do |os, facts|
      context "on #{os}" do
        let(:facts) { facts }

        let(:title) {'test_logrotate_title'}

        let(:params) {{
          :log_files => ['test1.log', 'test2.log']
        }}

        it { is_expected.to compile.with_all_deps }
        it { is_expected.to create_file('/etc/logrotate.d/test_logrotate_title').with_content(/test1\.log.*test2\.log/) }
      end
    end
  end
end
