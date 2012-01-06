source "http://rubygems.org"

# Specify your gem's dependencies in puppet_master.gemspec
gemspec

group :test do
  case rails_version = ENV['RAILS_VERSION'] or '2'
  when '1'
    gem 'actionpack', '>= 1.13.6'
  when '2'
    gem 'actionpack', '>= 2.3.8'
  end
end
