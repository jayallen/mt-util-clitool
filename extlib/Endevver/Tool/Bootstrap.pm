package Endevver::Tool::Bootstrap;
use strict;
use warnings;
use Carp qw(confess);
use Data::Dumper;

BEGIN {
    die( "Invalid MT_HOME: Please set your MT_HOME environment variable "
        ."with the path to your MT/Melody install." )
        unless $ENV{MT_HOME} and -d $ENV{MT_HOME};
    use File::Spec;
    unshift @INC, File::Spec->catdir( $ENV{MT_HOME}, $_ )
        foreach qw( lib extlib );
}

use base qw( MT::Bootstrap );

sub import {
    my $pkg = shift;

    # Setting GATEWAY_INTERFACE prevents MT::Bootstrap from assuming the
    # current app is running under FastCGI and is the only one of the
    # environment variables that are not used elsewhere in MT (It's only used
    # in CGI.pm which of course, isn't used in a command-line app.).
    #
    # The other variables -- HTTP_HOST, SCRIPT_FILENAME and SCRIPT_URL --
    # are all used in MT and/or MT::App.
    $ENV{GATEWAY_INTERFACE} = 0;

    my @rc = $pkg->SUPER::import(@_) or return;
    print 'Import return: '.Dumper(\@rc);
    return @rc;
}

1;
