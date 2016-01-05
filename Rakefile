require 'bundler'
Bundler.setup

require 'rake'
require 'rspec/core/rake_task'

$LOAD_PATH.unshift File.expand_path('../lib', __FILE__)
require 'rrrmatey/version'

task :gem => :build
task :build do
    system 'gem build rrrmatey.gemspec'
end

task :install => :build do
    system "sudo gem install rrrmatey-#{RRRMatey::VERSION}.gem"
end

task :uninstall do
    system 'sudo gem uninstall rrrmatey'
end

task :release => :build do
    system "git tag -a v#{RRRMatey::VERSION} -m 'Tagging #{RRRMatey::VERSION}'"
    system 'git push --tags'
    system "gem push rrrmatey-#{RRRMatey::VERSION}.gem"
    system "rm rrrmatey-#{RRRMatey::VERSION}.gem"
end

RSpec::Core::RakeTask.new('spec') do |spec|
    spec.pattern = "spec/**/*_spec.rb"
end

RSpec::Core::RakeTask.new('spec:progress') do |spec|
    spec.rspec_opts = %w(--format progress)
    spec.pattern = "spec/**/*_spec.rb"
end

task :default => :spec
