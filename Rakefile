require 'bundler/gem_tasks'
require 'rspec/core/rake_task'

desc 'Run all specs'
task spec: ['spec:acceptance']

namespace :spec do
  desc 'Run acceptance specs – requires running instance of ArangoDB'
  RSpec::Core::RakeTask.new(:acceptance) do |task|
    task.pattern = 'spec/acceptance/**/*_spec.rb'
  end
end

task default: :spec
