require 'rubygems'
require 'rake/gempackagetask'
require 'rake/testtask'
require 'rake/rdoctask'

$LOAD_PATH.unshift(File.dirname(__FILE__) + "/lib")
require 'www/delicious'


# Common package properties
PKG_NAME    = ENV['PKG_NAME'] || WWW::Delicious::GEM
PKG_VERSION = ENV['PKG_VERSION'] || WWW::Delicious::VERSION
PKG_SUMMARY = "Web service library for del.icio.us API"
PKG_FILES   = FileList[
  "Rakefile",
  "[A-Z]*",
  "lib/**/*.rb",
  # "doc/**/*", # exclude docs, it's auto generated
  "examples/**/*.rb",
  "test/**/*.rb"
]
PKG_FILES.exclude('TODO')


# 
# task::
#   :test
# desc::
#   Run all the tests
#
desc "Run all the tests"
Rake::TestTask.new(:test) do |t|
  t.libs       << "test"
  t.test_files  = FileList["test/unit/*.rb"]
  t.verbose     = true
end


# 
# task::
#   :rcov
# desc::
#   Create code coverage report
#
begin
  require 'rcov/rcovtask'

  desc "Create code coverage report"
  Rcov::RcovTask.new(:rcov) do |t|
    t.libs << "test"
    t.rcov_opts = [
      "-xRakefile"
    ]
    t.test_files = FileList[
      "test/unit/*.rb"
    ]
    t.output_dir = "coverage"
    t.verbose = true
  end
rescue LoadError
  puts "RCov is not available"
end


# 
# task::
#   :rdoc
# desc::
#   Generate RDoc documentation
#
desc "Generate RDoc documentation"
Rake::RDocTask.new(:rdoc) do |rdoc|
  rdoc.rdoc_dir   = 'doc'
  rdoc.title      = "#{PKG_NAME} -- #{PKG_SUMMARY}"
  rdoc.main       = "README"
  rdoc.options << "--title" << "#{PKG_NAME} -- #{PKG_SUMMARY}"
  rdoc.options   << "--inline-source" << "--line-numbers"
  rdoc.options   << '--charset' << 'utf-8'
  rdoc.options   << "--main" << "README"
  rdoc.template   = "#{ENV['template']}.rb" if ENV['template']
  rdoc.rdoc_files.include("README", "CHANGELOG")
  rdoc.rdoc_files.include("lib/**/*.rb")
end


if ! defined?(Gem)
  puts "Package Target requires RubyGEMs"
else

  # Package requirements
  spec = Gem::Specification.new do |s|

    ## Basic information

    s.name        = PKG_NAME
    s.version     = PKG_VERSION
    s.summary     = PKG_SUMMARY
    s.description = <<-EOF
      WWW::Delicious is a del.icio.us API client implemented in Ruby.
      It provides access to all available del.icio.us API queries 
      and returns the original XML response as a friendly Ruby object.
      EOF
    s.platform  = Gem::Platform::RUBY

    ## Dependencies and requirements

    s.required_ruby_version = '>= 1.8.6'

    s.requirements << 'Rake 0.7.3 or later'
    s.add_dependency('rake', '>= 0.7.3')

    ## Which files are to be included in this gem?

    s.files = PKG_FILES.to_a()

    ## Documentation and testing

    s.has_rdoc = true
    # Set RDoc title
    s.rdoc_options << "--title" << "#{s.name} -- #{s.summary}"
    # Show source inline with line numbers
    s.rdoc_options << "--inline-source" << "--line-numbers"
    # Make the readme file the start page for the generated html
    s.rdoc_options << "--main" << "README"
    s.rdoc_options << '--charset' << 'utf-8'
    s.extra_rdoc_files = ["CHANGELOG", "README"]

    s.test_files    = PKG_FILES.to_a

    ## Load-time details: library and application

    s.require_paths  = ["lib", "lib/www"]
    s.autorequire = 'www/delicious'

    ## Author and project details

    s.homepage  = "http://trac.weppos.net/www_delicious/"
    s.author    = "Simone Carletti"
    s.email     = "weppos@weppos.net"

  end
  
  # 
  # task::
  #   :gem
  # desc::
  #   Build the default package
  #
  Rake::GemPackageTask.new(spec) do |p|
    p.need_tar_gz = true
  end
end
