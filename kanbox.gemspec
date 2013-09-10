# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)

require 'kanbox/version'

Gem::Specification.new do |s|
  s.name = "kanbox"
  s.version = Kanbox::VERSION

  s.authors = ["Jason Lee"]
  s.description = "Kanbox API for Ruby."
  s.summary = "Kanbox API for Ruby"
  s.email = ["huacnlee@gmail.com"]
  s.extra_rdoc_files = ["README.md"]
  s.files = Dir.glob("{lib}/**/*") + %w(README.md)
  s.homepage = %q{https://github.com/huacnlee/kanbox}
  s.rdoc_options = ["--main"]
  s.require_paths = ["lib"]

  s.add_dependency "activesupport", ">= 3.2.0"
  s.add_dependency "oauth2"
end
