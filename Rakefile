require 'rubygems'
require 'rubygems/package_task'
require 'bundler'

$:.unshift(File.dirname(__FILE__) + "/lib")
require 'www/delicious'


# Common package properties
PKG_NAME    = ENV['PKG_NAME']    || WWW::Delicious::GEM
PKG_VERSION = ENV['PKG_VERSION'] || WWW::Delicious::VERSION


# Run test by default.
task :default => :test


spec = Gem::Specification.new do |s|
  s.name              = PKG_NAME
  s.version           = PKG_VERSION
  s.summary           = "Ruby client for delicious.com API."
  s.description       = "WWW::Delicious is a delicious.com API client implemented in Ruby."

  s.author            = "Simone Carletti"
  s.email             = "weppos@weppos.net"
  s.homepage          = "http://www.simonecarletti.com/code/www-delicious"
  s.rubyforge_project = "www-delicious"

  # Add any extra files to include in the gem (like your README)
  s.files             = `git ls-files`.split("\n")
  s.test_files        = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.require_paths     = %w( lib )

  # If your tests use any gems, include them here
  s.add_development_dependency("mocha")
end

Gem::PackageTask.new(spec) do |pkg|
  pkg.gem_spec = spec
end

desc "Build the gemspec file #{spec.name}.gemspec"
task :gemspec do
  file = File.dirname(__FILE__) + "/#{spec.name}.gemspec"
  File.open(file, "w") {|f| f << spec.to_ruby }
end

desc "Remove any temporary products, including gemspec"
task :clean => [:clobber] do
  rm "#{spec.name}.gemspec" if File.file?("#{spec.name}.gemspec")
end

desc "Remove any generated file"
task :clobber => [:clobber_package]

desc "Package the library and generates the gemspec"
task :package => [:gemspec]


require 'rake/testtask'

Rake::TestTask.new do |t|
  t.libs << "test"
  t.test_files = FileList["test/**/*_test.rb"]
  t.verbose = !!ENV["VERBOSE"]
  t.warning = !!ENV["WARNING"]
end


require 'yard'
require 'yard/rake/yardoc_task'

YARD::Rake::YardocTask.new(:yardoc) do |y|
  y.options = ["--output-dir", "yardoc"]
end

namespace :yardoc do
  task :clobber do
    rm_r "yardoc" rescue nil
  end
end

task :clobber => "yardoc:clobber"


desc "Open an irb session preloaded with this library"
task :console do
  sh "irb -rubygems -I lib -r www/delicious.rb"
end
