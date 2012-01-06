require 'bundler/gem_tasks'
require 'rspec/core/rake_task'

namespace :spec do
  task :prep_rails1 do
    puts 'Preparing environment for Rails 1.x RSpec code examples'
    ENV['RAILS_VERSION'] = '1'
    `bundle`
  end

  task :prep_rails2 do
    puts 'Preparing environment for Rails 2.x RSpec code examples'
    ENV['RAILS_VERSION'] = '2'
    `bundle`
  end

  desc 'Run RSpec code examples for Rails 1.x compatibility'
  RSpec::Core::RakeTask.new(:rails1)
  desc 'Run RSpec code examples for Rails 2.x compatibility'
  RSpec::Core::RakeTask.new(:rails2)

  Rake::Task[:rails1].enhance [:prep_rails1]

  Rake::Task[:rails2].enhance [:prep_rails2]
end

desc 'Run RSpec code examples'
task :spec        => ['spec:rails1', 'spec:rails2']
task :default     => [:spec]
