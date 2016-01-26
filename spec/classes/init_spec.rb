require 'spec_helper'

describe 'logrotate' do

  it { is_expected.to create_class('logrotate') }
  it { is_expected.to create_file('/etc/logrotate.conf').with_content(/weekly/) }
  it { is_expected.to create_file('/etc/logrotate.d').with_ensure('directory') }
  it { is_expected.to contain_package('logrotate').with_ensure('latest') }
end
