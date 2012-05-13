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

has max_steps => ( is => 'rw', isa => 'Int', default  => 26 );

has _bg_frame => (
    is       => 'ro',
    isa      => 'SDLx::Surface',
    lazy     => 1,
    builder  => '_build_bg_frame',
);

sub _build_bg_frame { 
    my $self = shift ;
    my $s =  SDLx::Surface->new( width => $self->width, height => $self->height); 
    SDL::Video::set_color_key( $s, 0, 0 );
    SDL::Video::set_alpha($s, SDL_RLEACCEL, 0);
    $self->image->blit($s) ;
    return $s ;
} 

has image => ( 
    is => 'rw', 
    isa => 'SDLx::Surface',
    handles => { qw/width w height h/ } ,
    required => 1,
    # trigger are function and cannot be used by daughter classes. work around that
    trigger => sub { my $self = shift; $self->_new_image(@_) } ,
);

# step = 0 -> idle
# step > 0 and < max_steps -> transitioning
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
    $self->step( 1 ) ;
}

sub busy {
    my $self = shift;
    my $s = $self->step ;
    return 1 if $s and $s <= $self->max_steps ;
    return 0 ;
}

sub progress {
    my ($self,$value) = @_;
    return int($self->step * $value / $self->max_steps )  ; 
}

sub regress {
    my ($self,$value) = @_;
    return int(($self->max_steps - $self->step) * $value / $self->max_steps)  ; 
}

# WARNING: does not work (yet) with Mouse
# see https://rt.cpan.org/Ticket/Display.html?id=76880
sub _new_image {
    my ($self,$image,$old) = @_;

    return unless @_ > 2 ;
    croak "new image does not match old image size"
        unless $image->w eq $old->w and $image->h eq $old->h ;

    $self->start;
}


__PACKAGE__->meta->make_immutable();

1;