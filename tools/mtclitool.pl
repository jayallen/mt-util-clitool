#!/usr/bin/perl
use strict;
use FindBin qw($Bin);
use lib "$Bin/lib";
use MT::CLITool;

our $mt = MT::CLITool->new() or die MT::CLITool->errstr;

##############
# UNIT TESTS #
##############

# Print out MT variables
show_variables();

sub show_variables {    
    my %variables = (
        '$MT::SCHEMA_VERSION'                => $MT::SCHEMA_VERSION,
        '$MT::VERSION'                       => $MT::VERSION,
        '$ENV{MT_HOME}'                      => $ENV{MT_HOME},
        'MT->config'                         => MT->config,
        '$mt->config->Database'              => $mt->config->Database,
        '$MT::PRODUCT_CODE v$MT::VERSION_ID'
                                => "$MT::PRODUCT_CODE v$MT::VERSION_ID",
        );

    while (my ($str, $val) = each %variables) {
        printf "%-40s %s\n", $str, $val;
    }
}
