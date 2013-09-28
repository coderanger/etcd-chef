# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib/', __FILE__)
$:.unshift lib unless $:.include?(lib)

require 'etcd-chef/version'

Gem::Specification.new do |s|
  s.name        = 'etcd-chef'
  s.version     = EtcdChef::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ['Noah Kantowitz']
  s.email       = ['noah@coderanger.net']
  s.homepage    = 'http://github.com/coderanger/etcd-chef'
  s.summary     = ''
  s.description = ''

  s.files        = Dir.glob('{bin,lib}/**/*') + %w(README.md)
  s.executables  = ['etcd-chef']
  s.require_path = 'lib'

  s.add_dependency('chef')
  s.add_dependency('etcd')
end
