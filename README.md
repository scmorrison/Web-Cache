Web::Cache [![Build Status](https://travis-ci.org/scmorrison/perl6-Web-Cache.svg?branch=master)](https://travis-ci.org/scmorrison/perl6-Web-Cache)
===

Web::Cache is a Perl 6 web framework independant LRU caching module.

**note:** this is very much a work in progress. Ideas, issues, and pull-requests welcome.

Usage
=====

```perl6
# Bailador example
use v6;
use Bailador;
use Web::Cache;

Bailador::import; # for the template to work

# Configure cache backend
constant memory = cache-start size    => 2048,
                              backend => 'memory';

# TODO: Create multiple cache stores using different
#       backends. This will enable caching certain 
#       content to different stores.

# Cached templates!
get / ^ '/template/' (.+) $ / => sub ($x) {
    my $template = 'tmpl.tt';
     
    # Any code passed as the `content` parameter
    # will be run on initial cache insert only.
    # Once cache expiration is supported, this code
    # will re-run again when the key expires.
    cache backend => memory,
          key     => [$template, $x].join('-'),
          content => { template($template, %{ name => $x }) };
}

baile;
```

Config
======

Currently only memory caching is supported. 


```perl6
# Configure cache backend
constant memory = cache-start size    => 2048,
                              backend => 'memory';
```

Installation
============

## Manual

```
git clone https://github.com/scmorrison/perl6-Web-Cache.git
cd perl6-Web-Cache/
zef install .
```

## zef (coming soon)
```
# zef install Web::Config
```

Todo
====

* Support additional backends (disk, Memcached, Redis)
* Cache key generator
* Partial / fragment support
* Tests

Requirements
============

* [Perl 6](http://perl6.org/)

AUTHORS
=======

* Sam Morrison

Copyright and license
=====================

Copyright 2017 Sam Morrison

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.
