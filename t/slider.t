#!/usr/bin/perl

use 5.010;
use strict;
use warnings;
use Test::More tests => 3;
use SDL ;
use SDL::VideoInfo;

use lib 'lib' ;
use Moose ;

use SDLx::App ;
use SDLx::Rect ;
use SDLx::SlideShow ;
use SDLx::Surface ;
use SDLx::Text ;

my $app = SDLx::App->new (
    title => 'dumb test',
    flags => SDL_HWSURFACE | SDL_HWACCEL | SDL_DOUBLEBUF ,
    depth => 32 ,
    exit_on_quit => 0, # quit handle by event loop
) ;

my $test_only = shift @ARGV || '';

# my $slider = SDLx::Slider->new(image => $app) ;
foreach my $s_file (glob("lib/SDLx/SlideShow/*.pm")) {
    my $s_class = $s_file ;
    next if $s_class =~ m!/Any.pm$!;
    say "test $test_only" if $test_only;
    next if $test_only and ($s_class !~ /$test_only/i) ;
    $s_class =~ s!.*/!!;
    $s_class =~ s!\.pm$!! ;

    for (my $c = 0; $c < 200 ; $c+= 50 ){
    # draw original surface
        $app->draw_rect ( undef, 0x808080ff ) ;
        $app->draw_rect ( SDLx::Rect->new(50,50,600,400), 0xFFFF00FF );
        $app->sync ;
        my ($x, $y)= ( $c * 1.2, $c ) ;
    
        my @slides ;
        while (@slides < 5) {
            # create new surface to be slided over the original one
            my ($w,$h) = ( 800 - $c* 1.5 , 600 - $c * 1.5 ) ;
            my $slide_in = SDLx::Surface->new( width => $w, height => $h ) ;
            if (@slides) {
                $slide_in->draw_rect ( undef, 0x800080ff ) ;
                my $c2 = 100 + 30 * @slides ;
                $slide_in->draw_rect ( SDLx::Rect->new($c2,$c2,260,140), 0xFF00FFFF );
                my $texter = SDLx::Text->new(
                    font    => '/usr/share/fonts/truetype/msttcorefonts/comic.ttf',
                    color   => [ 0xff, 0xff, 0xff] ,
                    size    => 50,
                    h_align => 'left',
                    text    => "nb ". scalar @slides ,
                );
                $texter->write_xy($slide_in, 10,10) ;
            }
            else {
                $app->blit($slide_in, [ $x, $y, $w,$h] ) ;
            }
            push @slides, $slide_in;
        }

        my $slider = SDLx::SlideShow->new(
            image => shift @slides, 
            surface => $app, 
            slideshow_class => $s_class,
            x => $c * 1.2,
            y => $c,
        ) ;
        ok( $slider, "created $s_class slider with c $c" );
        
        while (@slides){
            foreach my $i (1.. 30) {
                $slider ->tick;
                # $slider->surface ->blit($app) ;
                $app->sync;
                SDL::delay(20) ;
            }

            $slider->image(shift @slides) ;
        }
    }
}

ok(1,"transition done") ;
sleep 1;
