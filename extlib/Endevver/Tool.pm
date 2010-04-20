package Endevver::Tool;

use strict; use warnings; use Carp; use Data::Dumper;

use Getopt::Long qw( :config auto_version auto_help );
use Pod::Usage;

# use MT::Log::Log4perl qw( l4mtdump ); use Log::Log4perl qw( :resurrect );  our $logger;
# use MT::Log::Log4perl qw( l4mtdump ); use Log::Log4perl qw( :resurrect );
# our $logger ||= MT::Log::Log4perl->new(); $logger->trace();


use vars qw( $VERSION );
$VERSION = '0.1';

sub usage { }

sub help { }

my ($blog, $template);

sub options {
    return (
        'blog=s'        => \$blog,
        'template=s'    => \$template,
    );
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

sub main {
    my $class = shift;
    my ($verbose) = $class->SUPER::main(@_);

    if (!$blog && !$template) {
        print "Error: Either --blog or --template parameter is required.\n";
        $class->show_usage();
        exit;   
    }

    if ( $template ) {
        $template = load_by_name_or_id(undef, 'template', $template, 1);
    }
    
    $blog = $template ? $template->blog
                      : load_by_name_or_id(undef, 'blog', $blog, 1);

    if ( ! $template ) {
        my $tmpl_iter = MT->model('template')->load_iter({ blog_id => $blog->id });
        while ( my $tmpl = $tmpl_iter->() ) {
            $class->upgrade_template( $tmpl );
        }
    }
    else {
        $class->upgrade_template( $template );
    }
}

# __PACKAGE__->main() unless caller;



sub load_by_name_or_id {
    my ($self, $model, $value, $die) = @_;
    my $terms   = {};
    ###l4p $logger ||= MT::Log::Log4perl->new(); $logger->trace();

    my $termkey        = ( $value =~ m{^\d+$} ) ? 'id' : 'name';
    $terms->{$termkey} = $value;

    ###l4p $logger->debug('load_by_name_or_id params: ', l4mtdump({
    ###l4p    termkey => $termkey,
    ###l4p    value   => $value,
    ###l4p    model   => $model,
    ###l4p    die     => $die,
    ###l4p }));

    my $obj = MT->model( $model )->load( $terms );

    ###l4p $logger->debug('load_by_name_or_id result: ', l4mtdump({
    ###l4p    obj     => $obj,
    ###l4p }));

    return $obj if $obj;

    my $err = sprintf "ERROR: Failed to load %s by %s '%s': %s\n",
                     $model, $termkey, $value, MT->model( $model )->errstr || '';
    if ( ref $die eq 'CODE' ) {
        return $die->( @_, $err );
    }
    elsif ( $die ) {
        die $err;
    }
    elsif ( ref $self and $self->can('error') ) {
        return $self->error($err);
    }
    else {
        warn $err;
    }
}

sub progress {
    my $pkg = shift;
    my $msg = shift;
    print "\t* " . $msg . "\n"; # unless $sqlonly;
}

sub error {
    my $pkg = shift;
    my $err = shift;
    confess $err;
}

1;