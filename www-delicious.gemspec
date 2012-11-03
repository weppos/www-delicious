# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = "www-delicious"
  s.version = "0.4.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Simone Carletti"]
  s.date = "2012-11-03"
  s.description = "WWW::Delicious is a delicious.com API client implemented in Ruby."
  s.email = "weppos@weppos.net"
  s.files = [".gitignore", ".travis.yml", "CHANGELOG.md", "Gemfile", "Gemfile.lock", "LICENSE", "README.md", "Rakefile", "lib/www/delicious.rb", "lib/www/delicious/bundle.rb", "lib/www/delicious/element.rb", "lib/www/delicious/errors.rb", "lib/www/delicious/post.rb", "lib/www/delicious/tag.rb", "lib/www/delicious/version.rb", "test/fixtures/net_response_invalid_account.yml", "test/fixtures/net_response_success.yml", "test/online_test.rb", "test/test_helper.rb", "test/testcases/element/bundle.xml", "test/testcases/element/invalid_root.xml", "test/testcases/element/post.xml", "test/testcases/element/post_unshared.xml", "test/testcases/element/post_with_unresolvable_href.xml", "test/testcases/element/tag.xml", "test/testcases/response/bundles_all.xml", "test/testcases/response/bundles_all_empty.xml", "test/testcases/response/bundles_delete.xml", "test/testcases/response/bundles_set.xml", "test/testcases/response/bundles_set_error.xml", "test/testcases/response/posts_add.xml", "test/testcases/response/posts_all.xml", "test/testcases/response/posts_all_empty.xml", "test/testcases/response/posts_dates.xml", "test/testcases/response/posts_dates_with_tag.xml", "test/testcases/response/posts_delete.xml", "test/testcases/response/posts_get.xml", "test/testcases/response/posts_get_empty.xml", "test/testcases/response/posts_get_with_tag.xml", "test/testcases/response/posts_recent.xml", "test/testcases/response/posts_recent_with_tag.xml", "test/testcases/response/tags_get.xml", "test/testcases/response/tags_get_empty.xml", "test/testcases/response/tags_rename.xml", "test/testcases/response/update.delicious1.xml", "test/testcases/response/update.xml", "test/www/delicious/bundle_test.rb", "test/www/delicious/post_test.rb", "test/www/delicious/tag_test.rb", "test/www/delicious_test.rb", "www-delicious.gemspec"]
  s.homepage = "http://www.simonecarletti.com/code/www-delicious"
  s.require_paths = ["lib"]
  s.rubyforge_project = "www-delicious"
  s.rubygems_version = "1.8.15"
  s.summary = "Ruby client for delicious.com API."
  s.test_files = ["test/fixtures/net_response_invalid_account.yml", "test/fixtures/net_response_success.yml", "test/online_test.rb", "test/test_helper.rb", "test/testcases/element/bundle.xml", "test/testcases/element/invalid_root.xml", "test/testcases/element/post.xml", "test/testcases/element/post_unshared.xml", "test/testcases/element/post_with_unresolvable_href.xml", "test/testcases/element/tag.xml", "test/testcases/response/bundles_all.xml", "test/testcases/response/bundles_all_empty.xml", "test/testcases/response/bundles_delete.xml", "test/testcases/response/bundles_set.xml", "test/testcases/response/bundles_set_error.xml", "test/testcases/response/posts_add.xml", "test/testcases/response/posts_all.xml", "test/testcases/response/posts_all_empty.xml", "test/testcases/response/posts_dates.xml", "test/testcases/response/posts_dates_with_tag.xml", "test/testcases/response/posts_delete.xml", "test/testcases/response/posts_get.xml", "test/testcases/response/posts_get_empty.xml", "test/testcases/response/posts_get_with_tag.xml", "test/testcases/response/posts_recent.xml", "test/testcases/response/posts_recent_with_tag.xml", "test/testcases/response/tags_get.xml", "test/testcases/response/tags_get_empty.xml", "test/testcases/response/tags_rename.xml", "test/testcases/response/update.delicious1.xml", "test/testcases/response/update.xml", "test/www/delicious/bundle_test.rb", "test/www/delicious/post_test.rb", "test/www/delicious/tag_test.rb", "test/www/delicious_test.rb"]

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_development_dependency(%q<rake>, [">= 0"])
      s.add_development_dependency(%q<mocha>, [">= 0"])
      s.add_development_dependency(%q<yard>, [">= 0"])
    else
      s.add_dependency(%q<rake>, [">= 0"])
      s.add_dependency(%q<mocha>, [">= 0"])
      s.add_dependency(%q<yard>, [">= 0"])
    end
  else
    s.add_dependency(%q<rake>, [">= 0"])
    s.add_dependency(%q<mocha>, [">= 0"])
    s.add_dependency(%q<yard>, [">= 0"])
  end
end
