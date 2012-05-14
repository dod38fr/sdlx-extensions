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

sub tick {
    my $self = shift;

    if ($self->busy) {
        my $max_s = $self->max_steps ;
        my $s = $self->step ;
        my $slide_mark  = $self->regress( $self->width ) ;
        my $slide_width = int( $self->width / $max_s ) + 1 ;

        my $from_rect = [ $slide_mark,0, $slide_width, $self->height ] ;
        my $to_rect   = [ $slide_mark + $self->x , $self->y, 0 ,0 ] ;
        $self->image->blit($self->surface, $from_rect, $to_rect) ;
        $self->surface->update ;
        $self->inc_step ;
    }

    return $self->surface ;
}

__PACKAGE__->meta->make_immutable();

1;
