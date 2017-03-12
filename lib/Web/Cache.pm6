use v6;

use Web::Cache::Memory;
# TODO
# use Web::Cache::Disk;
# use Web::Cache::Memcached;
# use Web::Cache::Redis;

unit module Web::Cache:ver<0.000001>;

sub mod-name($backend) returns Str {
    return 'Web::Cache::' ~ $backend.tc;
}

our sub cache-create-store(Int :$size    = 1024,
                           Str :$backend = 'memory') is export returns Hash {

    my %config = size    => $size,
                 backend => $backend;

    return %{ backend => $backend,
              store   => &::(mod-name($backend) ~ '::load')(%config) };
}; 


# Set a key / value in the cache
sub cache-set(%store, Str $key, Str $content) is export returns Str {
    return &::(mod-name(%store<backend>) ~ '::set')(%store<store>, $key, $content);
}

# Get a key from the cache
sub cache-get(%store, Str $key) is export returns Str {
    return &::(mod-name(%store<backend>) ~ '::get')(%store<store>, $key);
}

# Remove a key from the cache
sub cache-remove(%store, Str $key) is export returns Str {
    return &::(mod-name(%store<backend>) ~ '::remove')(%store<store>, $key);
}

# Clear the entire cache
sub cache-clear(%store) is export returns Array {
    return &::(mod-name(%store<backend>) ~ '::clear')(%store<store>);
}

# Cache a template
sub webcache(:&content, :%store, Str :$key, Str :$expires_in) is export returns Str {
    my $content = cache-get(%store, $key);
    return $content if $content.defined;
    return cache-set( %store, $key, content );
}
