use v6;

use Web::Cache::Memory;
# TODO
# use Web::Cache::Disk;
# use Web::Cache::Memcached;
# use Web::Cache::Redis;

unit module Web::Cache:ver<0.000001>;

sub cache-module-name($mod_name) returns Str {
    return 'Web::Cache::' ~ $mod_name.tc;
}

sub create-store($mod_name, %config) {
    return &::($mod_name ~ '::load')(%config);
}

our sub cache-start(Int :$size    = 1024,
                    Str :$backend = 'memory') is export returns Hash {

    my %config   = size    => $size,
                   backend => $backend;
    my $mod_name = cache-module-name $backend;

    return %{ module => $mod_name,
              store  => create-store $mod_name, %config };
}; 


# Set a key / value in the cache
sub cache-set(%backend, Str $key, Str $content) is export returns Str {
    return &::(%backend<module> ~ '::set')(%backend<store>, $key, $content);
}

# Get a key from the cache
sub cache-get(%backend, Str $key) is export returns Str {
    return &::(%backend<module> ~ '::get')(%backend<store>, $key);
}

# Remove a key from the cache
sub cache-remove(%backend, Str $key) is export returns Str {
    return &::(%backend<module> ~ '::remove')(%backend<store>, $key);
}

# Clear the entire cache
sub cache-clear(%backend) is export returns Array {
    return &::(%backend<module> ~ '::clear')(%backend<store>);
}

# Cache a template
sub webcache(:&content, :%backend, Str :$key, Str :$expires_in) is export returns Str {
    my $content = cache-get(%backend, $key);
    return $content if $content.defined;
    return cache-set( %backend, $key, content );
}
