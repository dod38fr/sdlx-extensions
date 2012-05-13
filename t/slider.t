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
use SDLx::SlideShow ;
use SDLx::Surface ;

my $app = SDLx::App->new (
    title => 'dumb test',
    flags => SDL_HWSURFACE | SDL_HWACCEL | SDL_DOUBLEBUF ,
    depth => 32 ,
    exit_on_quit => 0, # quit handle by event loop
) ;

my @slides ;
while (@slides < 5) {
    # create new surface to be slided over the original one
    my $slide_in = SDLx::Surface->new(width => 800, height => 600) ;
    $slide_in->draw_rect ( undef, 0x800080ff ) ;
    my $c = 100 + 30 * @slides ;
    $slide_in->draw_rect ( SDLx::Rect->new($c,$c,460,340), 0xFF00FFFF );
    push @slides, $slide_in;
}

my $test_only = shift @ARGV || '';

# my $slider = SDLx::Slider->new(image => $app) ;
foreach my $s_file (glob("lib/SDLx/SlideShow/*.pm")) {
    # draw original surface
    $app->draw_rect ( undef, 0x808080ff ) ;
    $app->draw_rect ( SDLx::Rect->new(50,50,600,400), 0xFFFF00FF );
    $app->sync ;

    my $s_class = $s_file ;
    next if $s_class =~ m!/Any.pm$!;
    say "test $test_only" if $test_only;
    next if $test_only and ($s_class !~ /$test_only/i) ;
    $s_class =~ s!.*/!!;
    $s_class =~ s!\.pm$!! ;
    my $slider = SDLx::SlideShow->new(image => $app, slideshow_class => $s_class) ;
    ok( $slider, "created $s_class slider" );
    my @l_slides = @slides ;

    while (@l_slides){
    
        foreach my $i (1.. 30) {
            $slider ->tick;
            $slider->surface ->blit($app) ;
            $app->sync;
            SDL::delay(10) ;
        }

        $slider->image(shift @l_slides) ;
    }
}

ok(1,"transition done") ;
sleep 1;
