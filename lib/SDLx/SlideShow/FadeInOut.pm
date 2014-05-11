package SDLx::SlideShow::FadeInOut ;

use 5.10.1;

use Carp ;

use SDL;
use SDLx::Sprite;
use SDLx::Surface;
use SDL::Color ;

use Moose;
use Moose::Util::TypeConstraints ;

extends 'SDLx::SlideShow::Any' ;

subtype 'My::Types::SDLx::Sprite' => as class_type('SDLx::Sprite');
class_type('SDLx::Surface');

coerce 'My::Types::SDLx::Sprite'
    => from 'SDLx::Surface'
        => via { 
            my $s = SDLx::Sprite->new ( width => $_->w, height=>$_->h, alpha => 0xff, ) ;
            $_->blit($s->surface) ;
            return $s ;
        } ;
          
# holds old image
has _bg_frame => (
    is       => 'ro',
    isa      => 'SDLx::Sprite',
    lazy     => 1,
    builder  => '_build_bg_frame',
);

sub _build_bg_frame { 
    my $self = shift ;
    my $s =  SDLx::Surface->new( width => $self->width, height => $self->height); 
    $self->surface->blit($s) ;
    my $spr = SDLx::Sprite->new (
        surface => $s,
        alpha => 0xff,
    ) ;
    return $spr ;
} 

has _image => ( 
    is => 'rw', 
    isa => 'My::Types::SDLx::Sprite',
    coerce => 1,
);

sub _show_new_image {
    my ($self,$image) = @_;
    
    $self->_image($image) ;
    $self->surface->blit($self->_bg_frame->surface, $self->rect ) ;
}

sub tick {
    my $self = shift;

    $self->SUPER::tick ;

    if ( $self->busy ) {
        my $alpha = $self->progress( 0xFF )  ; 
        
        $self->_image->alpha($alpha) ;
        $self->_bg_frame->alpha(0xff - $alpha) ;

        my $transition = $self->surface;

        # draw fading image on frame
        $self->_bg_frame->surface->blit( $transition, undef, $self->rect);
        $self->_image    ->surface->blit( $transition, undef, $self->rect);
        $transition->update ;

        $self->inc_step;
    }

    return $self->surface ;

}

__PACKAGE__->meta->make_immutable();

1;
