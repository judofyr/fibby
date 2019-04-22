# -*- encoding: utf-8 -*-
require 'date'

Gem::Specification.new do |s|
  s.name          = 'fibby'
  s.version       = ENV['FIBBY_VERSION'] || "1.master"
  s.date          = Date.today.to_s

  s.authors       = ['Magnus Holm']
  s.email         = ['judofyr@gmail.com']
  s.summary       = 'Composable form library'
  s.homepage      = 'https://github.com/judofyr/fibby'

  s.require_paths = %w(lib)
  s.files         = Dir["lib/**/*.rb"] + Dir["*.md"]
  s.license       = '0BSD'

  s.add_runtime_dependency 'ippon'
end

