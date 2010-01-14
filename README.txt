# AUTHOR:   Jay Allen, Endevver Consulting
# DATE:     July 29th, 2008
# Version:  2.0
#
# $Id$

This library enables you to easily create command-line scripts which
interface with Movable Type.


### USAGE ###

    To use this library, add the following to your code so that it runs BEFORE
    you call any Movable Type libraries.  This is best done in a BEGIN block.

    my $mt;
    BEGIN {
        use FindBin qw($Bin);
        use lib "$Bin/lib";
        use lib "$Bin/extlib";
        use MT::CLITool;
        my $mt = MT::CLITool->new() or die MT::CLITool->errstr;
    }

    The $mt variable is your MT object.  Please see EXAMPLE for other
    more advanced usage.


### EXAMPLES ###

    tools/mtclitool.pl      -   Basic example of a CLI script which uses
                                MT::CLITool to initialize an MT object.
                            
    tools/mtclitoolapp.pl   -   Example of an CLI script which initializes an 
                                MT object which is a full MT::App subclass

                            
### RELATED LIBRARIES ###

    MT::Tool -  Nascent but vigorously developed library bundled with Movable
                Type 4.x and used by a growing number of its CLI scripts.

    MT-xdk  -   Set of libraries written by Tim Appnel (http://appnel.com)
                including an MT::Tool variant.
                See http://code.google.com/p/mt-xdk/ for details