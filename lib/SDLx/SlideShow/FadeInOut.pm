package SDLx::SlideShow::FadeInOut ;

use 5.10.1;

use Carp ;

use SDL;
use SDLx::Sprite;
use SDLx::Surface;
use SDL::Color ;

use Any::Moose;
use Any::Moose '::Util::TypeConstraints' ;

extends 'SDLx::SlideShow::Any' ;

subtype 'My::Types::SDLx::Sprite' => as class_type('SDLx::Sprite');
class_type('SDLx::Surface');

coerce 'My::Types::SDLx::Sprite'
    => from 'SDLx::Surface'
        => via { 
            say "coercing surf"; 
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
    $self->image->draw($s) ;
    my $spr = SDLx::Sprite->new (
        surface => $s,
        alpha => 0xff,
    ) ;
    return $spr ;
} 

has image => ( 
    is => 'rw', 
    isa => 'My::Types::SDLx::Sprite',
    handles => { qw/width w height h/ } ,
    required => 1,
    coerce => 1,
    trigger => \&_new_image ,
);

sub _new_image {
    my $self = shift ;
    my ($image,$old) = @_;

    return unless @_ > 1 ;
    $self->SUPER::_new_image(@_) ;
    
    say "fadeinout blit old image";
    $old->alpha(0xff) ;
    $old->draw($self->_bg_frame->surface);
}

sub tick {
    my $self = shift;

    if ( $self->busy ) {
        my $alpha = $self->progress( 0xFF )  ; 
        say "alpha $alpha, other ", 0xff - $alpha ;
        my $transition = $self->surface; #SDLx::Surface->new( width=> $self->width, height=> $self->height) ;

        $self->image->alpha($alpha) ;
        $self->_bg_frame->alpha(0xff - $alpha) ;
        my $tg = [ $self->x, $self->y, 0 ,0] ;

        # draw fading image on frame
        $self->_bg_frame->surface->blit( $transition, undef, $tg);
        $self->image    ->surface->blit( $transition, undef, $tg);
        $transition->update ;

        $self->inc_step;
        return $transition ;
    }
    else {
        return $self->image->surface ;
    }
}

__PACKAGE__->meta->make_immutable();

1;
