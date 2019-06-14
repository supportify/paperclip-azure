# frozen_string_literal: true

Gem::Specification.new do |s|
  s.name        = 'paperclip-azure'
  s.version     = '1.0.0'
  s.date        = '2010-04-28'
  s.author      = 'Nephroflow'
  s.summary     = 'Hola!'
  s.description = 'A simple hello world gem'
  s.files       = ['lib/paperclip-azure.rb']
  s.homepage    =
    'https://github.com/dtielens/paperclip-azure'
  s.license = 'MIT'

  s.add_dependency('azure', '~> 0.7')
  s.add_dependency('azure-storage', '~> 0.15.0.preview')
  s.add_dependency('hashie', '~> 3.6.0')
  s.add_dependency('addressable', '~> 2.6.0')
end
