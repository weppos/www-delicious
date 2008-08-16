require 'rubygems'
require 'echoe'

$LOAD_PATH.unshift(File.dirname(__FILE__) + "/lib")
require 'www/delicious'

 
# Common package properties
PKG_NAME = ENV['PKG_NAME'] || WWW::Delicious::GEM
PKG_VERSION = ENV['PKG_VERSION'] || WWW::Delicious::VERSION
PKG_SUMMARY = "Ruby client for del.icio.us API."
PKG_FILES = FileList.new("{lib,test}/**/*.rb") do |fl|
  fl.exclude 'TODO'
  fl.include %w(README.rdoc CHANGELOG.rdoc LICENSE.rdoc)
  fl.include %w(Rakefile setup.rb)
end
RUBYFORGE_PROJECT = 'www-delicious'
 
if ENV['SNAPSHOT'].to_i == 1
  PKG_VERSION << "." << Time.now.utc.strftime("%Y%m%d%H%M%S")
end
 
 
Echoe.new(PKG_NAME, PKG_VERSION) do |p|
  p.author        = "Simone Carletti"
  p.email         = "weppos@weppos.net"
  p.summary       = PKG_SUMMARY
  p.description   = <<-EOF
    WWW::Delicious is a del.icio.us API client implemented in Ruby. \
    It provides access to all available del.icio.us API queries \
    and returns the original XML response as a friendly Ruby object.
  EOF
  p.url           = "http://code.simonecarletti.com/www-delicious"
  p.project       = RUBYFORGE_PROJECT

  p.need_zip      = true
  p.rcov_options  = ["-x Rakefile -x mocha -x rcov"]
  p.rdoc_pattern  = /^(lib|CHANGELOG.rdoc|README.rdoc)/

  p.development_dependencies = ["rake  >=0.8",
                                "echoe >=3",
                                "mocha >=0.9"]
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
