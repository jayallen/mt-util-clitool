#!/usr/bin/perl

use strict;
use FindBin qw($Bin);
use lib "$Bin/lib";
use MT::CLITool;

my %app = (
    'generic' => { init_app => 1 },
    'cms' => { App => 'MT::App::CMS' },
    'search' => { App => 'MT::App::Search' },
);

# Set the app to use
$active_app = 'generic'

# Initializing the app with a general MT::App::CLI instance
my $app = MT::CLITool->new( $app{$active_app} ) or die MT::CLITool->errstr;

$app->print('YO');

__END__

# $TM_FILEPATH search=soldier  limit=3 format=json

$TM_FILEPATH mode=belly
