package SDLx::SlideShow;

use Any::Moose;
use Any::Moose 'X::StrictConstructor' ;
use 5.10.1;
use Carp;
use SDL;
use SDLx::Surface;
use SDL::Color;

has slideshow_class => (
    is       => 'rw',
    isa      => 'Str',
    required => 1,
    trigger  => \&_new_slider,
);

sub _new_slider {
    my $self = shift;
    $self->{slider} = $self->_build_slider;
}

has image => (
    is       => 'rw',
    isa      => 'SDLx::Surface',
    handles  => {qw/width w height h/},
    required => 1,
    trigger  => \&_new_image,
);

sub _new_image {
    my ( $self, $new_image, $old_image ) = @_;

    return unless defined $old_image;

    if ( $new_image->w ne $old_image->w or $new_image->h ne $old_image->h ) {
        croak "new image does not match old image size";
    }
    else {
        $self->slider->image($new_image);
    }
}

# slider's tick method will blit on this surface (or create a new one)
has surface => (
    is      => 'ro',
    isa     => 'SDLx::Surface',
    lazy    => 1,
    builder => '_build_surface',
);

sub _build_surface {
    my $self = shift;

    my $s = SDLx::Surface->new( width => $self->width, height => $self->height );
    SDL::Video::set_color_key( $s, 0, 0 );
    SDL::Video::set_alpha( $s, SDL_RLEACCEL, 0 );
    $self->image->blit($s,undef, [ $self->x, $self->y, 0, 0 ]);
    return $s;
}

has [qw/x y/] => (is => 'ro', isa => 'Int', default => 0 );

has 'slider' => (
    is      => 'ro',
    isa     => 'SDLx::SlideShow::Any',
    handles => [qw/tick busy/],
    lazy    => 1,
    builder => '_build_slider',
);

sub _build_slider {
    my $self        = shift;
    my $slide_class = $self->slideshow_class;
    $slide_class = 'SDLx::SlideShow::' . $slide_class unless $slide_class =~ /^SDLx/;

    my $file_to_load = $slide_class . '.pm';
    $file_to_load =~ s!::!/!g;

    eval { require $file_to_load; };

    if ($@) {
        die "Could not parse $file_to_load: $@\n";
    }

    $slide_class->new( 
        image => $self->image, 
        surface => $self->surface, 
        x => $self->x , 
        y=>$self->y 
    );
}

__PACKAGE__->meta->make_immutable;    # Makes it faster at the cost of startup time

no Moose;
1;
