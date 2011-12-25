# WWW::Delicious

*WWW::Delicious* is a Ruby client for [delicious.com](http://delicious.com) XML API.

[![Build Status](https://secure.travis-ci.org/weppos/www-delicious.png)](http://travis-ci.org/weppos/www-delicious)


*WWW::Delicious* maps all the original delicious.com API calls and provides some additional convenient methods to perform common tasks. For a full API overview, visit the official {Delicious API documentation}[http://delicious.com/help/api].

*WWW::Delicious* is compatible with all [delicious.com](http://delicious.com) API constraints, including the requirement to set a valid user agent or wait at least one second between queries.


## Requirements

* Ruby >= 1.8.6 or Ruby 1.9.x


## Installation

The best way to install *WWW::Delicious* is via [RubyGems](https://rubygems.org/).

    $ gem install www-delicious

You might need administrator privileges on your system to install the gem.


## Getting Started

In order to use this library you need a valid Delicious account.
Go to http://delicious.com and register for a new account if you don't already have one.

Then create a valid instance of `WWW::Delicious` providing your account credentials.

    require 'www/delicious'

    # create a new instance with given username and password
    d = WWW::Delicious.new('username', 'password')
  
Now you can use your instance to interact with the API interface.

### Last account update

The following example show you how to get the last account update Time.

    time = d.update # => Fri May 02 18:02:48 UTC 2008

### Reading Posts

You can fetch your posts in 3 different ways:

    # 1. get all posts
    posts = d.posts_all

    # 2. get recent posts
    posts = d.posts_recent

    # 3. get a single post (the latest one if no criteria is given)
    posts = d.posts_get(:tag => 'ruby')

Each post call accepts some options to refine your search.
For example, you can always search for posts matching a specific tag.

    posts = d.posts_all(:tag => 'ruby')
    posts = d.posts_recent(:tag => 'ruby')
    posts = d.posts_get(:tag => 'ruby')

### Creating a new Post

    # add a post from options
    d.posts_add(:url => 'http://www.simonecarletti.com/', :title => 'Cool site!')

    # add a post from WWW::Delicious::Post
    d.posts_add(WWW::Delicious::Post.new(:url => 'http://www.simonecarletti.com/', :title => 'Cool site!'))

### Deleting a Posts

    # delete given post (the URL can be either a string or an URI)
    d.posts_delete('http://www.foobar.com/')

Note. Actually you cannot delete a post from a `WWW::Delicious::Post` instance.
It means, the following example doesn't work as some ActiveRecord user might expect.

    post = WWW::Delicious::Post.new(:url => 'http://www.foobar.com/')
    post.delete

This feature is already in the TODO list. For now, use the following workaround
to delete a given Post.

    # delete a post from an existing post = WWW::Delicious::Post
    d.posts_delete(post.url)

### Tags

Working with tags it's really easy. You can get all your tags or rename an existing tag.

    # get all tags
    tags = d.tags_get

    # print all tag names
    tags.each { |t| puts t.name }

    # rename the tag gems to gem
    d.tags_rename('gems', 'gem')

### Bundles

WWW::Delicious enables you to get all bundles from given account.

    # get all bundles
    bundles = d.bundles_all

    # print all bundle names
    bundles.each { |b| puts b.name }

You can also create new bundles or delete existing ones.

    # set a new bundle for tags ruby, rails and gem
    d.bundles_set('MyBundle', %w(ruby rails gem))

    # delete the old bundle
    d.bundles_delete('OldBundle')


## Credits

* [Simone Carletti](http://www.simonecarletti.com/) <weppos@weppos.net> - The Author


## More

* [Homepage](http://www.simonecarletti.com/code/www-delicious)
* [Repository](https://github.com/weppos/www-delicious/)
* [API Documentation](http://rubydoc.info/gems/www-delicious)


## Feedback and bug reports

Please submit bug reports or feature requests to [Github Issues](https://github.com/weppos/www-delicious/issues).


## Changelog

See the CHANGELOG.md file for details.


## License

*WWW::Delicious* is copyright (c) 2009-2011 Simone Carletti. This is Free Software distributed under the MIT license.
