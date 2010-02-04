# MT::Bootstrap::CLI
#
# A subclass of MT::Bootstrap which allows for command-line MT::Apps. See
# README for further details.
#
# Author:   Jay Allen, Textura Design (http://jayallen.org)
# Date:     March 1st, 2007
#
# Released under the Artistic License
#
# $Id: CLI.pm 13 2008-02-15 04:37:53Z jay $

package MT::Bootstrap::CLI;

use strict;
use base 'MT::Bootstrap';

sub import {
    my $pkg = shift;

    die("MT_HOME environment variable not set")
        unless $ENV{MT_HOME} and -d $ENV{MT_HOME};

    # Setting GATEWAY_INTERFACE prevents MT::Bootstrap from assuming the
    # current app is running under FastCGI and is the only one of the
    # environment variables that are not used elsewhere in MT (It's only used
    # in CGI.pm which of course, isn't used in a command-line app.).
    #
    # The other variables -- HTTP_HOST, SCRIPT_FILENAME and SCRIPT_URL --
    # are all used in MT and/or MT::App.
    $ENV{GATEWAY_INTERFACE} = 0;

    $pkg->SUPER::import(@_) or return;
}

1;

