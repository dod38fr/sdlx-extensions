package SDLx::Fader ;

use 5.10.1;

use strict;
use warnings;

use Carp ;

use SDL;
use SDLx::App;
use SDLx::Sprite;
use SDLx::Surface;
use SDL::Color ;

use Any::Moose;
use Any::Moose '::Util::TypeConstraints' ;

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
          
has max_steps => ( is => 'rw', isa => 'Int',       default  => 26 );

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
    my $spr = SDLx::Sprite->new (
        surface => $s,
        alpha => 0xff,
    ) ;
    # disable alpha color key stuff to avoid messing up photos
    # SDL::Video::set_color_key( $s, 0, 0 );
    # SDL::Video::set_alpha($s, SDL_SRCALPHA | SDL_RLEACCEL, 0xff);
    # $s->draw_rect( undef , [ 0x80, 0x80, 0x80 ] );
    return $spr ;
} 

has image => ( 
    is => 'rw', 
    isa => 'My::Types::SDLx::Sprite',
    handles => { qw/width w height h/ } ,
    required => 1,
    coerce => 1,
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

my $white =  SDL::Color->new(0xFF, 0xFF, 0xFF); 

sub new_image {
    my ($self,$image) = @_;

    croak "new_image does not match old image size"
        unless $image->w eq $self->width and $image->h eq $self->height ;

    # blit old image
    $self->image->alpha(0xff) ;
    $self->image->draw($self->_bg_frame->surface);
    
    $self->image->surface( $image );

    $self->reset_step;    # will trigger a redraw on next loop
}

sub transition {
    my $self = shift;

    if ( $self->step <= $self->max_steps) {
        my $alpha = int($self->step * 0xFF / $self->max_steps)  ; 
        say "alpha $alpha, other ", 0xff - $alpha ;
        my $transition = SDLx::Surface->new( width=> $self->width, height=> $self->height) ;

        $self->image->alpha($alpha) ;
        $self->_bg_frame->alpha(0xff - $alpha) ;

        # draw fading image on frame
        $self->_bg_frame->surface->blit( $transition);
        $self->image    ->surface->blit( $transition);

        $self->inc_step if $self->step <= $self->max_steps;

        return $transition ;
    }
    else {
        return $self->image->surface ;
    }
}

__PACKAGE__->meta->make_immutable();

1;
