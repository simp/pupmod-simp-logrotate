require 'spec_helper'

describe 'logrotate' do

  it { should create_class('logrotate') }
  it { should create_file('/etc/logrotate.conf').with_content(/weekly/) }
  it { should create_file('/etc/logrotate.d').with_ensure('directory') }
  it { should contain_package('logrotate').with_ensure('latest') }
end
