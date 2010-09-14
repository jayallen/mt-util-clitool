package MT::CLI::Util;

use strict; use warnings; use Carp; use Data::Dumper;

use MT::Log::Log4perl qw( l4mtdump ); use Log::Log4perl qw( :resurrect );
###l4p our $logger ||= MT::Log::Log4perl->new(); $logger->trace();

sub load_by_name_or_id {
    my ($self, $model, $value, $die) = @_;
    ###l4p $logger ||= MT::Log::Log4perl->new(); $logger->trace();
    ###l4p $logger->debug('Looking to load by name or id: ', l4mtdump({model=>$model,val=>$value}));

    my $class = MT->model( $model );
    my ($terms, $termkey);
    if ( defined $model and defined $value ) {
        $terms             = {};
        $termkey           = ( $value =~ m{^\d+$} ) ? 'id' : 'name';
        $terms->{$termkey} = $value;
        my $obj            = $class->load( $terms );
        ###l4p $logger->debug('Loaded object: ', $obj ? l4mtdump($obj) : 'NONE');
        return $obj if $obj;
    }

    my $err
        = sprintf "ERROR: Failed to load %s by %s '%s': %s\n",
             $model, $termkey, $value, $class->errstr || '';

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

sub confirm_action {
    my ($self, $prompt) = @_;
    my $term = $self->{term_interface} ||= do {
        require Term::ReadLine;
        Term::ReadLine->new('User prompt');
    };
    my $OUT = $term->OUT || \*STDOUT;
    my $res;
    while ( defined ($_ = $term->readline($prompt)) ) {
        $res = $_;
        return if ! $res or $res =~ m/^n/i;
        last;
    }
    1;
}


1;
