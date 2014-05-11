package SDLx::SlideShow;

use Moose;
use MooseX::StrictConstructor ;
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

has max_steps => ( is => 'rw', isa => 'Int', default  => 26 );

# slider's tick method will blit on this surface
has surface => (
    is      => 'ro',
    isa     => 'SDLx::Surface',
    required    => 1,
);

has [qw/x y/] => (is => 'ro', isa => 'Int', default => 0 );

has width => (
    is => 'ro', 
    isa => 'Int', 
    lazy => 1,
    builder => '_build_width' ,
);

sub _build_width {
    my $self = shift;
    $self->surface->w ;
}

has height => (
    is => 'ro', 
    isa => 'Int', 
    lazy => 1,
    builder => '_build_height'
);

sub _build_height {
    my $self = shift;
    $self->surface->h ;
}

has 'slider' => (
    is      => 'ro',
    isa     => 'SDLx::SlideShow::Any',
    handles => [qw/tick busy image sliding/],
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
        surface => $self->surface, 
        max_steps => $self->max_steps,
        x => $self->x , 
        y => $self->y ,
        height => $self->height,
        width => $self->width,
    );
}

__PACKAGE__->meta->make_immutable;    # Makes it faster at the cost of startup time

no Moose;
1;
