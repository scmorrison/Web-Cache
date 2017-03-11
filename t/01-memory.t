use v6;
use lib 'lib';

use Test;
use Web::Cache;

plan 7;

my $key = "web-cache-test-key";
my $content = q:to/EOS/; 
  <html>
    <head>
      <title>Web::Cache Test</title>
      <body>
        This is only a test.
      </body>
  </html>
EOS


# Memory
constant memory = cache-start(size    => 2048,
                              backend => 'memory');

is memory<module>, 'Web::Cache::Memory', 'memory 1/7: load memory backend';

# Memory: set
my $m1 = cache-set(memory, $key, $content);
is $m1, $content, 'memory 2/7: cache set key';

# Memory: get
my $m2 = cache-get(memory, $key);
is $m2, $content, 'memory 3/7: cache get key';

# Memory: remove
my $m3 = cache-remove(memory, $key);
is $m3, $content, 'memory 4/7: cache remove key';

# Memory: webcache initial key insert
my $m4 = webcache(key     => $key,
                  backend => memory,
                  content => { $content });
is $m4, $content, 'memory 5/7: webcache initial key insert';

# Memory: webcache subsequent key insert
my $m5 = webcache(key     => $key,
                  backend => memory,
                  content => { $content });
is $m5, $content, 'memory 6/7: webcache subsequent key insert';

# Memory: webcache clear
my $m6 = cache-clear(memory);
is $m6, (), 'memory 7/7: cache clear';
