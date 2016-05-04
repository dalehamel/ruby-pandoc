lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'ruby-pandoc/version'

Gem::Specification.new do |s|
  s.name        = 'ruby-pandoc'
  s.version     = RubyPandoc::VERSION
  s.date        = Time.now
  s.summary     = 'Pandoc wrapper for ruby'
  s.description = 'Fork of pandoc-ruby, lightweight pandoc wrapper for ruby'
  s.authors     = ['Dale Hamel']
  s.email       = 'dale.hamel@srvthe.net'
  s.files       = Dir['lib/**/*']
  s.homepage    =
    'https://github.com/dalehamel/ruby-pandoc'
  s.license = 'MIT'
  s.add_development_dependency 'pry', ['=0.10.3']
  s.add_development_dependency 'pry-byebug', ['=3.3.0']
  s.add_development_dependency 'simplecov', ['=0.10.0']
  s.add_development_dependency 'rspec', ['=3.2.0']
  s.add_development_dependency('mocha', '~> 1.1', '>= 1.1.0')
  s.add_development_dependency('rake', '~> 10.4', '>= 10.4.2')
  s.add_development_dependency('rdoc', '~> 4.2', '>= 4.2.0')
  s.add_development_dependency('minitest', '~>5.8.3', '>= 5.8.3')
end
