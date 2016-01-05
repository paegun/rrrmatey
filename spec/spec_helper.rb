$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), "..", "lib"))

MODELS = File.join(File.dirname(__FILE__), "app/models")
$LOAD_PATH.unshift(MODELS)

if ENV['CI']
    require 'simplecov'
    SimpleCov.start do
        add_filter '/vendor/'
        add_filter '/spec/'
    end
end

require 'rrrmatey'
require 'rspec'
