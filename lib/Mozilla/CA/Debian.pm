use strict;
use warnings;

package Mozilla::CA::Debian;
# ABSTRACT: Like Mozilla::CA, but using certs from /etc/ssl/certs

our $VERSION = '0.001';

my $line;
my $init = sub
{
    my $code = do {
	local $/;
	qq{#line $line "}.__FILE__.qq{"\n}
	    .scalar <Mozilla::CA::Debian::DATA>
    };
    close Mozilla::CA::Debian::DATA or die;
    eval $code or die $@;
};

package # no index
    Mozilla::CA;

BEGIN {
    $INC{'Mozilla/CA.pm'} = __FILE__;
}

# Just stubs, for lazy loading

# This method exists only to trigger init when this line runs:
#     use Mozilla::CA 20160104;
# Once init ran, the method disappear, but $VERSION appears and
# UNIVERSAL::VERSION follows
sub VERSION
{
    $init->();
    goto &UNIVERSAL::VERSION
}

sub SSL_ca_file
{
    $init->();
    goto &SSL_ca_file
}

package Mozilla::CA::Debian; # For the location of the DATA handle

$line = __LINE__+2; # For proper error reports for the eval
__DATA__

package Mozilla::CA;

use strict;
use warnings;
no warnings 'redefine';
use File::Temp ();

BEGIN {
    no strict 'refs';
    # Delete the &VERSION sub
    # but we will add $VERSION below that UNIVERSAL::VERSION will use
    delete ${'Mozilla::CA::'}{'VERSION'};
}

my $SSL_ca_file;

{
    my $fh;
    ($fh, $SSL_ca_file) = File::Temp::tempfile('XXXXXXXX', SUFFIX => '.pem', TMPDIR => 1, UNLINK => 1);
    if (opendir my $certs_dir, '/etc/ssl/certs') {
	my $last_mtime = 0;
	local $/;
	while (my $f = readdir $certs_dir) {
	    next unless substr($f, -4) eq '.pem';
	    substr($f, 0, 0, '/etc/ssl/certs/');
	    if (-f $f) {
		my $mtime = (stat _)[9];
		$last_mtime = $mtime if $mtime > $last_mtime;
	    }
	    open my $fh2, '<:raw', $f or die;
	    print $fh scalar <$fh2>;
	    close $fh2;
	}
	closedir $certs_dir;
	close $fh;
	my @t = gmtime $last_mtime;
	our $VERSION = sprintf '%04d%02d%02d', $t[5]+1900, $t[4]+1, $t[3];
    }
}


sub SSL_ca_file
{
    $SSL_ca_file
}

1
