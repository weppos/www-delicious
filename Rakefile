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
  fl.include %w(README.rdoc README CHANGELOG MIT-LICENSE)
  fl.include %w(Rakefile setup.rb)
end
RUBYFORGE_PROJECT = 'www-delicious'


desc "Run all the tests"
Rake::TestTask.new(:test) do |t|
  t.test_files  = FileList["test/unit/*.rb"]
  t.verbose     = true
end


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


desc "Generate RDoc documentation"
Rake::RDocTask.new(:rdoc) do |rdoc|
  rdoc.rdoc_dir   = 'doc'
  rdoc.title      = "#{PKG_NAME} -- #{PKG_SUMMARY}"
  rdoc.main       = "README"
  rdoc.options   << "--inline-source" << "--line-numbers"
  rdoc.options   << '--charset' << 'utf-8'
  rdoc.options   << '--force-update'
  rdoc.rdoc_files.include("README.rdoc", "README", "CHANGELOG", "MIT-LICENSE")
  rdoc.rdoc_files.include("lib/**/*.rb")
end


unless defined?(Gem)
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
    s.add_dependency('rake', '>= 0.7.3')

    s.files = PKG_FILES.to_a()

    s.has_rdoc = true
    s.rdoc_options << "--title" << "#{s.name} -- #{s.summary}"
    s.rdoc_options << "--inline-source" << "--line-numbers"
    s.rdoc_options << "--main" << "README"
    s.rdoc_options << '--charset' << 'utf-8'
    s.extra_rdoc_files = %w(README.rdoc README CHANGELOG MIT-LICENSE)

    s.test_files    = FileList["test/unit/*.rb"]

    s.author    = "Simone Carletti"
    s.email     = "weppos@weppos.net"
    s.homepage  = "http://code.simonecarletti.com/www-delicious"

  end
  
  Rake::GemPackageTask.new(GEM_SPEC) do |p|
    p.gem_spec = GEM_SPEC
    p.need_tar = true
    p.need_zip = true
  end
end


begin 
  require 'code_statistics'
  desc "Show library's code statistics"
  task :stats do
    CodeStatistics.new(["WWW::Delicious", "lib"], 
                       ["Tests", "test"]).to_s
  end
rescue LoadError
  puts "CodeStatistics (Rails) is not available"
end


desc "Generated and upload current documentation to Rubyforge"
task :upload_docs => [:clean_rdoc, :rdoc] do
  host        = "weppos@rubyforge.org"
  remote_dir  = "/var/www/gforge-projects/www-delicious/"
  local_dir   = 'doc'
  sh %{rsync -av --delete #{local_dir}/ #{host}:#{remote_dir}}
end


desc "Clean up rdoc directory"
task :clean_rdoc do
  dir = File.expand_path("doc")
  rm_rf dir
  puts "Removed rdoc directory (#{dir})"
end


desc "Clean up generated directories and files"
task :clean => [:clean_rdoc] do
  rm_rf "pkg"
  rm_rf "coverage"
end
