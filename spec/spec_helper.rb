require 'simplecov'
require 'coveralls'
Coveralls.wear!

SimpleCov.formatter = SimpleCov::Formatter::MultiFormatter.new([
  SimpleCov::Formatter::HTMLFormatter,
  Coveralls::SimpleCov::Formatter
])
SimpleCov.start

require 'pry'
$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'rdf/vocab'
require 'TriplestoreAdapter'
