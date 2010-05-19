### MT::App:CLI
# AUTHOR:   Jay Allen, Endevver LLC (http://endevver.com)
# See README.txt in this package for more details

package MT::App::CLI;

use strict;
use warnings;
use Data::Dumper;
use Carp qw(longmess);
use Getopt::Long qw( :config auto_version auto_help );
use Pod::Usage;
use base 'MT::App';

# use MT::Log::Log4perl qw(l4mtdump); use Log::Log4perl qw( :resurrect );
###l4p our $logger = MT::Log::Log4perl->new();

use constant CONFIG => 'mt-config.cgi';

sub option_spec {
    return ('help|man!', 'usage|h!', 'verbose|v+' );
}

sub init {
    my $app = shift;
    ###l4p $logger ||= MT::Log::Log4perl->new(); $logger->trace();
    $app->SUPER::init(@_) or return;
    # $app->add_methods( 
    #     'default' => \&mode_default
    # );
    $app;
}

sub init_request {
    my $app = shift;
    ###l4p $logger ||= MT::Log::Log4perl->new(); $logger->trace();
    $app->init_options(@_) or return;
    require CGI;
    $app->{query} = CGI->new({ %{$app->options} });
    $app->SUPER::init_request( CGIObject => $app->{query} );
    $app->{query};
}

sub options { $_[0]->{options} }

sub init_options {
    my $app         = shift;
    ###l4p $logger ||= MT::Log::Log4perl->new(); $logger->trace();
    my %opt = ();
    my $opts_good = GetOptions(
        \%opt, $app->option_spec()
    );
    unless ( $opts_good ) {
        print STDERR join( '', @{$app->{trace}} );
        $app->show_usage({ -exitval => 2, -verbose => 0 });
    }
    $app->show_usage() if $opt{usage};
    $app->show_docs()  if $opt{help};
    $app->{options} = \%opt;
}

sub init_plugins {
    my $app = shift;
    ###l4p $logger ||= MT::Log::Log4perl->new(); $logger->trace();
    $app->SUPER::init_plugins(@_);
}

sub pre_run {
    my $app = shift;
    ###l4p $logger ||= MT::Log::Log4perl->new(); $logger->trace();
    $app->SUPER::pre_run(@_);
    my $opt = $app->options();
    my $blog_param = defined $opt->{blog}       ? $opt->{blog}
                   : defined $opt->{blog_id}    ? $opt->{blog_id}
                                                : undef;
    if ( $blog_param ) { # 0 is not valid!
        my $blog = $app->load_by_name_or_id( 'blog', $blog_param );
        $app->blog( $blog ) if $blog;
    }
}

sub mode_default {
    my $app = shift;
    ###l4p $logger ||= MT::Log::Log4perl->new(); $logger->trace();
    $app->show_usage();
}

sub post_run {
    my $app = shift;
    ###l4p $logger ||= MT::Log::Log4perl->new(); $logger->trace();
    $app->print(('OUTPUT-----'x10), "\n");
    $app->SUPER::post_run(@_);
    if ($app->{trace} &&
        (!defined $app->{warning_trace} || $app->{warning_trace})) {
        my $trace = '';
        foreach (@{$app->{trace}}) {
            $trace .= "MT DEBUG: $_\n";
            # $trace .= $logger->indent("MT DEBUG: $_\n");
        }
        $app->print_trace($trace);
    }
    # $app->{query}->save(\*STDOUT);
}

sub print_trace {
    my ($app, $trace) = @_;
    my $del = 'TRACE------'x10;
    $app->print("\n",join("\n", $del, $trace, $del), "\n");
}

sub show_error {
    my $app = shift;
    my $error = $_[0]->{error};
    my $stack = ($error and $app->param('verbose')) ? longmess() : '';
    
    $app->print("FATAL> $error (".(caller(1))[3].')'. $stack);
    return;
}

sub show_usage { 
    my $app = shift;
    ###l4p $logger ||= MT::Log::Log4perl->new(); $logger->trace();
    pod2usage({
        # Two defaults for usage, can be overriden
         -exitval => 1,
         -verbose => 0,
        # Arguments supplied by caller
         (
             @_ != 1              ? @_                    #  > 1 or 0
           : ref $_[0] eq 'HASH'  ? %{ $_[0] }            # hashref
           : ref $_[0] eq 'ARRAY' ? @{ $_[0] }            # arrayref
           : ! ref $_[0]          ? ( -message => shift ) # msg only
           : ()                                           # no args
         )
    });
}

sub show_options { 
    my $app = shift;
    ###l4p $logger ||= MT::Log::Log4perl->new(); $logger->trace();
    pod2usage(@_ ? @_ : { -exitval => 1, -verbose => 1 });
}

sub show_docs {
    my $app = shift;
    ###l4p $logger ||= MT::Log::Log4perl->new(); $logger->trace();
    pod2usage(@_ ? @_ : { -exitval => 1, -verbose => 2 });
}

sub send_http_header { }

sub takedown {
    my $app = shift;
    $app->SUPER::takedown(@_);
    $app->print("\n");
    return;
}

# mt_dir() works to locate the MT directory so that you can
# call your script from another location if you wish as such:
#
#     MT_HOME=/path/to/mt ~/mt-example.pl ARG1 ARG2
#
sub mt_dir {
    use Cwd qw( getcwd );
    use File::Basename qw(dirname);
    my @search_dirs = (getcwd, $ENV{MT_HOME});
    my $mt_dir;
    BASE: foreach my $base (@search_dirs) {
        next unless $base and -d $base;
        DIR: foreach my $dir ($base, dirname($base), dirname(dirname($base))) {
            if (-e File::Spec->catfile($dir, CONFIG)) {
                $mt_dir = $dir;
                last BASE;
            }
        }
    }    
    $ENV{MT_HOME} = $mt_dir if $mt_dir;
}

sub load_by_name_or_id {
    require MT::CLI::Util;
    MT::CLI::Util::load_by_name_or_id(@_);
}


1;
__END__


=head1 MT::App:CLI

sample - Using GetOpt::Long and Pod::Usage

=head1 SYNOPSIS

sample [options] [file ...]

 Options:
   -help            brief help message
   -man             full documentation

=head1 OPTIONS

=over 8

=item B<-help>

Print a brief help message and exits.

=item B<-man>

Prints the manual page and exits.

=back

=head1 DESCRIPTION

B<This program> will read the given input file(s) and do something
useful with the contents thereof.

=cut

