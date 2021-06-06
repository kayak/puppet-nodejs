require 'spec_helper'

describe 'nodejs::instance::pkgs', :type => :class do
  let(:title) { 'nodejs::instance::pkgs' }
  let(:facts) {{
    :osfamily => 'Debian'
  }}

  describe 'module dependency management' do
    it { should contain_package('wget') }
    it { should contain_package('tar') }
  end

  describe 'includes compiler-related dependencies' do
    let(:params) {{
      :make_install => true
    }}
    let(:facts) {{
      :osfamily => 'Debian'
    }}

    it { should contain_package('wget') }
    it { should contain_package('tar') }
  end
end
