use strict;
use warnings;

package Mozilla::CA::Debian;
# ABSTRACT: Like Mozilla::CA, but using certs from /etc/ssl/certs

our $VERSION = '0.002';

package # no-index
    Mozilla::CA;

sub SSL_ca_file {
    '/etc/ssl/certs/ca-certificates.crt'
}

BEGIN {
    $INC{'Mozilla/CA.pm'} = __FILE__;
    our $VERSION = do {
	my @t = gmtime((stat SSL_ca_file())[9]);
	sprintf '%04d%02d%02d', $t[5]+1900, $t[4]+1, $t[3]
    };
}

1
