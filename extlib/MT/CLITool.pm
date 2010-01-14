package MT::CLITool;
# This should be a shared module for all MT
# command line interface (CLI) tools.
# 
# Called as such:
# 
#     use FindBin qw($Bin);
#     use lib "$Bin/lib";
#     use MT::CLITool;
#     my $mt = MT::CLITool->new() or die MT::CLITool->errstr;

use vars qw(@ISA $VERSION);
use Cwd;
use FindBin qw($Bin);
use File::Basename;
use File::Spec;

$VERSION = '2.0';

use constant CONFIG => 'mt-config.cgi';

sub new {
    my ($class, $args) = @_;

    # Locate the MT directory in use
    my $mt_dir = mt_dir()
        or die 'Could not initialize MT because MT_HOME could not be located';

    # Include lib and extlib MT directories
    unshift @INC, File::Spec->catdir($mt_dir, $_) foreach qw(lib extlib);

    require MT::ErrorHandler;
    @ISA = qw( MT::ErrorHandler );

    my ($mt_instance);
    if ($args->{init_app} or $args->{App}) {
        my $instance_class  = $args->{App} || 'MT::App::CLI';
        eval {
            require MT::Bootstrap::CLI;
            import MT::Bootstrap::CLI  (App => $instance_class);
            $mt_instance = MT->instance;            
        };
        $@ and return __PACKAGE__->error(join(': ', 
            "Could not instantiate $instance_class", ($@||undef)));
    }
    else {
        require MT;
        $mt_instance = MT->new(Config => CONFIG)
            or return __PACKAGE__->error(join(': ', 
            'Could not instantiate MT', (MT->errstr||undef)));
    }
    return $mt_instance;
}

# mt_dir() works to locate the MT directory so that you can
# call your script from another location if you wish as such:
#
#     MT_HOME=/path/to/mt ~/mt-example.pl ARG1 ARG2
#
sub mt_dir {
    my @search_dirs = (getcwd, $Bin, $ENV{MT_HOME});
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

sub confirm_action {
    my ($self, $prompt) = @_;
    require Term::ReadLine;
    my $term = new Term::ReadLine 'User prompt';
    my $OUT = $term->OUT || \*STDOUT;
    my $res;
    while ( defined ($_ = $term->readline($prompt)) ) {
        $res = $_;
        return if ! $res or $res =~ m/^n/i;
        last;
    }
    1;
}

# Need to process options
sub process_options {
    
}


1;
