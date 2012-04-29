package SDLx::RollOver ;

use 5.10.1;

use strict;
use warnings;

use Carp ;

use SDL;
use SDLx::App;
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
);

has step => (
    traits  => ['Counter'],
    is      => 'rw',
    isa     => 'Int',
    default => 0,
    handles => {
        inc_step   => 'inc',
        reset_step => 'reset',
    }
);

sub new_image {
    my ($self,$image) = @_;

    croak "new_image does not match old image size"
        unless $image->w eq $self->width and $image->h eq $self->height ;

    $self->image( $image );

    $self->reset_step;    # will trigger a redraw on next loop
}

sub transition {
    my $self = shift;

    my $busy = 0;
    if ($self->step <= $self->max_steps) {
        my $max_s = $self->max_steps ;
        my $s = $self->step ;
        my $slide_mark  = int( $self->width * ($max_s -$s) / $max_s ) ;
        my $slide_width = int( $self->width / $max_s ) + 1 ;

        my $rect_to_blit = [ $slide_mark,0, $slide_width, $self->height ] ;
        $self->image->blit($self->_bg_frame, $rect_to_blit, $rect_to_blit) ;
        $self->_bg_frame->update ;
        $self->inc_step ;
        $busy = 1;
    }

    return wantarray ? ($self->_bg_frame, $busy) : $self->_bg_frame ;
}

__PACKAGE__->meta->make_immutable();

1;
