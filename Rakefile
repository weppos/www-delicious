require 'rubygems'
require 'rake/gempackagetask'
require 'rake/testtask'
require 'rake/rdoctask'

$LOAD_PATH.unshift(File.dirname(__FILE__) + "/lib")
require 'www/delicious'


# Common package properties
PKG_NAME    = ENV['PKG_NAME'] || WWW::Delicious::GEM
PKG_VERSION = ENV['PKG_VERSION'] || WWW::Delicious::VERSION
PKG_SUMMARY = "Ruby client for del.icio.us API."
PKG_FILES   = FileList.new("{lib,test}/**/*.rb") do |fl|
  fl.exclude 'TODO'
  fl.include %w(README CHANGELOG MIT-LICENSE)
end
RUBYFORGE_PROJECT = 'www-delicious'


# 
# task::
#   :test
# desc::
#   Run all the tests.
#
desc "Run all the tests"
Rake::TestTask.new(:test) do |t|
  t.test_files  = FileList["test/unit/*.rb"]
  t.verbose     = true
end


# 
# task::
#   :rcov
# desc::
#   Create code coverage report.
#
begin
  require 'rcov/rcovtask'

  desc "Create code coverage report"
  Rcov::RcovTask.new(:rcov) do |t|
    t.rcov_opts   = ["-xRakefile"]
    t.test_files  = FileList["test/unit/*.rb"]
    t.output_dir  = "coverage"
    t.verbose     = true
  end
rescue LoadError
  puts "RCov is not available"
end


# 
# task::
#   :rdoc
# desc::
#   Generate RDoc documentation.
#
desc "Generate RDoc documentation"
Rake::RDocTask.new(:rdoc) do |rdoc|
  rdoc.rdoc_dir   = 'doc'
  rdoc.title      = "#{PKG_NAME} -- #{PKG_SUMMARY}"
  rdoc.main       = "README"
  rdoc.options   << "--inline-source" << "--line-numbers"
  rdoc.options   << '--charset' << 'utf-8'
  rdoc.rdoc_files.include("README", "CHANGELOG", "MIT-LICENSE")
  rdoc.rdoc_files.include("lib/**/*.rb")
end


if ! defined?(Gem)
  puts "Package Target requires RubyGEMs"
else

  # Package requirements
  GEM_SPEC = Gem::Specification.new do |s|

    s.name        = PKG_NAME
    s.version     = PKG_VERSION
    s.summary     = PKG_SUMMARY
    s.description = <<-EOF
      WWW::Delicious is a del.icio.us API client implemented in Ruby. \
      It provides access to all available del.icio.us API queries \
      and returns the original XML response as a friendly Ruby object.
      EOF
    s.platform    = Gem::Platform::RUBY
    s.rubyforge_project = RUBYFORGE_PROJECT

    s.required_ruby_version = '>= 1.8.6'
    s.requirements << 'Rake 0.7.3 or later'
    s.add_dependency('rake', '>= 0.7.3')

    s.files = PKG_FILES.to_a()

    s.has_rdoc = true
    s.rdoc_options << "--title" << "#{s.name} -- #{s.summary}"
    s.rdoc_options << "--inline-source" << "--line-numbers"
    s.rdoc_options << "--main" << "README"
    s.rdoc_options << '--charset' << 'utf-8'
    s.extra_rdoc_files = %w(README CHANGELOG MIT-LICENSE)

    s.test_files    = FileList["test/unit/*.rb"]

    s.author    = "Simone Carletti"
    s.email     = "weppos@weppos.net"
    s.homepage  = "http://code.simonecarletti.com/www-delicious"

  end
  
  # 
  # task::
  #   :gem
  # desc::
  #   Generate the GEM package and all stuff.
  #
  Rake::GemPackageTask.new(GEM_SPEC) do |p|
    p.gem_spec = GEM_SPEC
    p.need_tar = true
    p.need_zip = true
  end
end


# 
# task::
#   :clean
# desc::
#   Clean up generated directories and files.
#
desc "Clean up generated directories and files"
task :clean do
  rm_rf "pkg"
  rm_rf "doc"
  rm_rf "coverage"
end
