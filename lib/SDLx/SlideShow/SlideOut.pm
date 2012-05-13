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

sub transition {
    my $self = shift;

    if ($self->busy) {
        my $transition = SDLx::Surface->new( width=> $self->width, height=> $self->height) ;
        SDL::Video::set_alpha($transition, SDL_RLEACCEL, 0xff);
        my $slide_mark = $self->progress( $self->width ) ;

        $self->_bg_frame->blit($transition,
            [ $slide_mark,0, $self->width + $slide_mark, $self->height ],  # source
        ) ;
        $self->_bg_frame->update ;
        $self->inc_step ;
        return $transition ;
    }
    else {
        return $self->image ;
    }
}

__PACKAGE__->meta->make_immutable();

1;
