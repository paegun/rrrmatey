lib = File.expand_path('../lib/', __FILE__)
$:.unshift lib unless $:.include?(lib)

require 'rrrmatey/version'

Gem::Specification.new do |s|
    s.name          = 'rrrmatey'
    s.version       = RRRMatey::VERSION
    s.platform      = Gem::Platform::RUBY
    s.date          = '2015-12-15'
    s.summary       = 'Object Mapping using Ruby + Redis + Riak (including Solr)'
    s.description   = <<EOF
RRRMatey is an ODM (Object Document Mapper) Framework for Riak, using
the Basho Cache Proxy to provide reliable persistence using Riak KV with the
speed and accessibility of Redis. Riak's Solr integration provides for fast
listings as well as relations.
EOF
    s.license       = 'Apache-2.0'
    s.homepage      = 'http://rubygems.org/gems/rrrmatey'
    s.authors       = ['James Gorlick']
    s.email         = 'jgorlick@basho.com'

    s.required_ruby_version     = '>= 1.9'
    s.required_rubygems_version = '>= 1.3.6'

    s.add_dependency('riak-client', '~> 2.2')
    s.add_dependency('redis', '~> 3.2')
    s.add_dependency('json', '~> 1.7')
    s.add_dependency('xml-simple', '~> 1.1')

    s.files         = Dir.glob("lib/**/*") + %w(RELEASE_NOTES.md LICENSE.md README.md Rakefile)
    s.test_files    = Dir.glob("spec/**/*")
    s.require_path  = 'lib'
end
