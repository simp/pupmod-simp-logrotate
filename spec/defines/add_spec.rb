require 'spec_helper'

describe 'logrotate::add' do

  let(:title) {'test_logrotate_title'}
  let(:params) {{
    :log_files => ['test1.log', 'test2.log']
  }}

  it { should create_file('/etc/logrotate.d/test_logrotate_title').with_content(/test1\.log.*test2\.log/) }
end
