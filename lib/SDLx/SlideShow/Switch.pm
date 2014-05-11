package SDLx::SlideShow::Switch ;

use 5.10.1;

use strict;
use warnings;

use Carp ;

use SDL;
use SDLx::App;
use SDLx::Surface;
use SDL::Color ;

use Moose;
use Moose::Util::TypeConstraints ;
# use Moose '::Meta::Attribute::Native::Trait::Array' ;

extends 'SDLx::SlideShow::Any' ;

# just copy the new image in one step and reset step counter
sub tick {
    my $self = shift;

    $self->SUPER::tick ;

    if ($self->busy) {
        $self->_image->blit($self->surface) ;
        $self->surface->update ;
        $self->stop ;
    }

    return $self->surface ;
}

__PACKAGE__->meta->make_immutable();

1;
