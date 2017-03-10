use v6;

use Web::Cache::Memory;

unit module Web::Cache:ver<0.000001>;

sub cache-module-name($mod_name) returns Str {
    return 'Web::Cache::' ~ $mod_name.tc;
}

sub create-store($mod_name, %config) {
    &::($mod_name ~ '::load')(%config);
}

subset Backend of Str where * ~~ 'memory';
our sub cache-start(Int     :$size    = 1024,
                    Backend :$backend = 'memory') is export {

    my %config = size    => $size,
                 backend => $backend;

    my $mod_name = cache-module-name $backend;
    return %{ module => $mod_name,
              store  => create-store $mod_name, %config };
}; 


# Set a key / value in the cache
sub cache-set(%backend, $key, $content) is export {
    &::(%backend<module> ~ '::set')(%backend<store>, $key, $content);
}

# Get a key from the cache
sub cache-get(%backend, $key) is export {
    &::(%backend<module> ~ '::get')(%backend<store>, $key);
}

# Remove a key from the cache
sub cache-remove(%backend, $key) is export {
    &::(%backend<module> ~ '::remove')(%backend<store>, $key);
}

# Clear the entire cache
sub cache-clear(%backend) is export {
    &::(%backend<module> ~ '::clear')(%backend<store>);
}

# Cache a template
sub cache(:&content, :%backend, :$key, :$expires_in) is export {
    my $content = cache-get(%backend, $key);
    return $content if $content.defined;
    return cache-set( %backend, $key, content );
}
