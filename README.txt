# AUTHOR:   Jay Allen, Endevver Consulting
# DATE:     February 4th, 2010
# Version:  3.0

This library enables you to easily create command-line scripts which
interface with Movable Type.


### USAGE ###

    To use this library, create a command-line script like so customizing
    the package name on the last line with your desired package name for
    your script's lib module:

        #!/usr/bin/perl
        use strict;
        use FindBin qw($Bin);
        use lib "$Bin/../lib";
        BEGIN {
            my $mtdir = $ENV{MT_HOME} ? "$ENV{MT_HOME}/" : '';
            unshift @INC, "$mtdir$_" foreach qw(lib extlib );
        }
        use MT::Bootstrap::CLI App => 'MyPlugin::Tool::MyCommand';

    Then, create a module with the chosen package name containing your
    script's core code.
    
    **NOTE: Will complete soon.  The overhaul is extensive and
    everything below here needs a rewrite.**

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