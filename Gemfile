source 'https://rubygems.org'

gemspec

gem 'rake'

group :test do
    gem 'rspec', '~> 3.1.0'

    if ENV['CI']
        gem 'simplecov', :require => false
    end
end
