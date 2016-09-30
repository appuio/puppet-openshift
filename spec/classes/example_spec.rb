require 'spec_helper'

describe 'openshift' do
  context 'supported operating systems' do
    ['Debian', 'RedHat'].each do |osfamily|
      describe "openshift class without any parameters on #{osfamily}" do
        let(:params) {{ }}
        let(:facts) {{
          :osfamily => osfamily,
        }}

        it { is_expected.to compile.with_all_deps }

        it { is_expected.to contain_class('openshift::params') }
        it { is_expected.to contain_class('openshift::install').that_comes_before('openshift::config') }
        it { is_expected.to contain_class('openshift::config') }
        it { is_expected.to contain_class('openshift::service').that_subscribes_to('openshift::config') }

        it { is_expected.to contain_service('openshift') }
        it { is_expected.to contain_package('openshift').with_ensure('present') }
      end
    end
  end

  context 'unsupported operating system' do
    describe 'openshift class without any parameters on Solaris/Nexenta' do
      let(:facts) {{
        :osfamily        => 'Solaris',
        :operatingsystem => 'Nexenta',
      }}

      it { expect { is_expected.to contain_package('openshift') }.to raise_error(Puppet::Error, /Nexenta not supported/) }
    end
  end
end
