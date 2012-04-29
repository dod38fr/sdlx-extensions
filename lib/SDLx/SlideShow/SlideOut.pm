package SDLx::Slider ;

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

has max_steps => ( is => 'rw', isa => 'Int',       default  => 26 );

# holds old and new image side by side
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
    $s->draw_rect( undef , [ 0x80, 0x80, 0x80 ] );
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

has background_color => (
    is => 'rw',
    isa => 'ArrayRef',
    default => sub { [ 20, 50, 170, 255 ]  } ,
) ;


my $white =  SDL::Color->new(0xFF, 0xFF, 0xFF); 

sub new_image {
    my ($self,$image) = @_;

    croak "new_image does not match old image size"
        unless $image->w eq $self->width and $image->h eq $self->height ;

    # blit old image
    $self->image->blit($self->_bg_frame);
    
    $self->image( $image );

    $image -> blit ( 
        $self->_bg_frame, 
        undef,              # source 
        [ $self->width + 1 , 0, $self->width, $self->height]
    ) ;

    $self->reset_step;    # will trigger a redraw on next loop
}

sub transition {
    my $self = shift;

    if ($self->step <= $self->max_steps) {
        my $transition = SDLx::Surface->new( width=> $self->width, height=> $self->height) ;
        SDL::Video::set_alpha($transition, SDL_RLEACCEL, 0xff);
        my $slide_mark = int( $self->width * $self->step / $self->max_steps ) ;

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
