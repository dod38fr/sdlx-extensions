#!/usr/bin/perl

use 5.010;
use strict;
use warnings;
use Test::More tests => 3;
use SDL ;
use SDL::VideoInfo;

use lib 'lib' ;

use SDLx::App ;
use SDLx::Rect ;
use SDLx::Fader ;
use SDLx::Surface ;

my $app = SDLx::App->new (
    title => 'Framily',
    flags => SDL_HWSURFACE | SDL_HWACCEL | SDL_DOUBLEBUF ,
    depth => 32 ,
    exit_on_quit => 0, # quit handle by event loop
) ;

# draw original surface
$app->draw_rect ( undef, 0x808080ff ) ;
$app->draw_rect ( SDLx::Rect->new(50,50,600,400), 0xFFFF00FF );
$app->sync ;

# create new surface to be slided over the original one
my $slide_in = SDLx::Surface->new(width => 800, height=>600) ;
$slide_in->draw_rect ( undef, 0x800080ff ) ;
$slide_in->draw_rect ( SDLx::Rect->new(100,100,60,40), 0xFF00FFFF );

my $slider = SDLx::Fader->new(image => $app) ;
ok( $slider, 'slider created with current image' );

$slider->new_image($slide_in) ;
ok( 1, 'new_image added' );

foreach my $i (1..30) {
    $slider ->transition ->blit($app) ;
    $app->sync;
    SDL::delay(10) ;
}

ok(1,"transition done") ;
sleep 1;