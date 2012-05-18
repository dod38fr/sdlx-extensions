package SDLx::SlideShow::Any ;

use 5.10.1;

use strict;
use warnings;

use Carp ;

use SDL;
use SDLx::Surface;
use SDL::Color ;

use Any::Moose;
use Any::Moose '::Util::TypeConstraints' ;
# use Any::Moose '::Meta::Attribute::Native::Trait::Array' ;

has max_steps => ( is => 'rw', isa => 'Int', required => 1 );

# tick method will draw on this surface
has surface => (
    is       => 'ro',
    isa      => 'SDLx::Surface',
    required     => 1,
);

has [qw/x y/] => (is => 'ro', isa => 'Int', default => 0 );

has [qw/width height/ ] => (
    is => 'ro', 
    isa => 'Int', 
    required => 1,
);

has 'rect' => ( is => 'ro', isa => 'ArrayRef[Int]', lazy => 1, builder => '_build_rect') ;

sub _build_rect {
    my $self = shift;
    return [ $self->x, $self->y, $self->width, $self->height] ;
}


has image => ( 
    is => 'rw', 
    isa => 'SDLx::Surface',
    # trigger are function and cannot be used by daughter classes. work around that
    trigger => sub { my $self = shift; $self->_new_image(@_) } ,
);

# step = 0 -> idle
# step > 0 and < max_steps -> transitioning
# internal
has step => (
    traits  => ['Counter'],
    is      => 'rw',
    isa     => 'Int',
    default => 0,
    handles => {
        inc_step => 'inc',
        stop     => 'reset',
    }
);

sub start {
    my $self = shift;
    say "start ",ref($self) ;
    $self->step( 1 ) ;
}

sub busy {
    my $self = shift;
    my $s = $self->step ;
    return 1 if $s and $s <= $self->max_steps ;
    return 0 ;
}

#internal
sub progress {
    my ($self,$value) = @_;
    return int($self->step * $value / $self->max_steps )  ; 
}

#internal
sub regress {
    my ($self,$value) = @_;
    return int(($self->max_steps - $self->step) * $value / $self->max_steps)  ; 
}

# WARNING: does not work (yet) with Mouse
# see https://rt.cpan.org/Ticket/Display.html?id=76880
sub _new_image {
    my ($self,$image,$old) = @_;

    $self->start;
}


__PACKAGE__->meta->make_immutable();

1;
