package SDLx::SlideShow::SlideOut ;

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

extends 'SDLx::SlideShow::Any' ;

has _bg_frame => (
     is       => 'ro',
     isa      => 'SDLx::Surface',
     lazy     => 1,
     builder  => '_build_bg_frame',
);
 
sub _build_bg_frame { 
    my $self = shift ;
    my $s =  SDLx::Surface->new( width => 2 * $self->width, height => $self->height); 
    # disable alpha color key stuff to avoid messing up photos
    SDL::Video::set_color_key( $s, 0, 0 );
    SDL::Video::set_alpha($s, SDL_RLEACCEL, 0);
    return $s ;
}

sub _new_image {
    my $self = shift ;
    my ($image,$old) = @_;

    say "blitting in double sized bg_frame" ;
    # blit old image on left side of double sized bg_frame
    $old->blit($self->_bg_frame) if defined $old ;
    
    # blit new image on right side of double sized bg_frame
    $image -> blit ( 
        $self->_bg_frame, 
        undef,              # source 
        [ $self->width , 0, $self->width, $self->height]
    ) ;

    $self->SUPER::_new_image(@_) ;
}

sub tick {
    my $self = shift;

    if ($self->busy) {
        SDL::Video::set_alpha($self->surface, SDL_RLEACCEL, 0xff);
        my $slide_mark = $self->progress( $self->width ) ;

        $self->_bg_frame->blit($self->surface,
            [ $slide_mark,0, $self->width, $self->height ],  # source
            [ $self->x, $self->y,0,0]
        ) ;
        $self->surface->update ;
        $self->inc_step ;
        return $self->surface ;
    }
    else {
        return $self->image ;
    }
}

__PACKAGE__->meta->make_immutable();

1;
