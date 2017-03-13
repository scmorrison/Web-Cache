use v6;

use Web::Cache::Memory;
# TODO
# use Web::Cache::Disk;
# use Web::Cache::Memcached;
# use Web::Cache::Redis;

unit module Web::Cache:ver<0.000001>;

# Generate full module name from $backend shortname
sub mod-name(Str $backend --> Str) {
    return 'Web::Cache::' ~ $backend.tc;
}

# Set a key / value in the cache
sub cache-set($store, $module, Str $key, Str $content --> Str) {
    return &::($module ~ '::set')($store, $key, $content);
}

# Get a key from the cache
sub cache-get($store, Str $module, Str $key --> Str) {
    return &::($module ~ '::get')($store, $key);
}

# Remove a key from the cache
sub cache-remove($store, Str $module, Str $key --> Str) {
    return &::($module ~ '::remove')($store, $key);
}

# Clear the entire cache
sub cache-clear($store, Str $module --> Array) {
    return &::($module ~ '::clear')($store);
}

# Build a new sub that provides interface to cache 
# backend module and actions.
sub create-store-sub(:$backend_module, :%config --> Block) {

    my $store_instance = &::($backend_module ~ '::load')(%config);

    return -> &content?,                  # Callback that generates the content for the cache
              :$store  = $store_instance, # Actual cache instance
              :$module = $backend_module, # Module that manages cache type
              :$action,                   # Action: only used for remove or clear
              :$key,                      # Key for cache ID
              :$expires_in --> Str {      # Expire the provided key in n seconds

        given $action {
            when 'clear' {
               cache-clear( $store, $module ).Str;
            }
            when 'remove' {
               cache-remove( $store, $module, $key );
            }
            default {
               cache-get( $store, $module, $key ) || cache-set( $store, $module, $key, content );
            }
        }
    }
}

# Cache store initialization
sub cache-create-store(Int :$size    = 1024,
                       Str :$backend = 'memory' --> Block) is export {

    my $module = mod-name($backend);
    my %config = size    => $size,
                 backend => $backend;
    return create-store-sub(backend_module => $module, config => %config);
}; 

