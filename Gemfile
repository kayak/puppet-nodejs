source 'https://rubygems.org'

puppetVersion = ENV.key?('PUPPET_VERSION') ? ENV['PUPPET_VERSION'] : '~> 6.22.1'

group :devel do
  gem 'rake'

  gem 'puppet', puppetVersion
  gem 'puppet-lint'
  gem 'puppet-syntax'
  gem 'rspec-puppet'
  gem 'puppetlabs_spec_helper'
  gem 'iconv'

  gem 'webmock'
  gem 'puppet-blacksmith'

  gem 'coveralls', require: false

  gem 'rubocop'

  gem 'metadata-json-lint'

  gem 'pdk', git: 'https://github.com/puppetlabs/pdk', ref: '97e28b28b57f6a77aec0788fa3858bf624ce57f8'
end

group :beaker do
  gem 'beaker'
  gem 'beaker-rspec'
  gem 'beaker-puppet'
  gem 'beaker-docker'
  gem 'beaker-puppet_install_helper'
  gem 'beaker-module_install_helper'
  gem 'serverspec'
end
