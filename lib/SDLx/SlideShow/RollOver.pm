package SDLx::SlideShow::RollOver ;

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

sub transition {
    my $self = shift;

    if ($self->busy) {
        my $max_s = $self->max_steps ;
        my $s = $self->step ;
        my $slide_mark  = $self->regress( $self->width ) ;
        my $slide_width = int( $self->width / $max_s ) + 1 ;

        my $rect_to_blit = [ $slide_mark,0, $slide_width, $self->height ] ;
        $self->image->blit($self->_bg_frame, $rect_to_blit, $rect_to_blit) ;
        $self->_bg_frame->update ;
        $self->inc_step ;
    }

    return $self->_bg_frame ;
}

__PACKAGE__->meta->make_immutable();

1;
