#!/usr/bin/perl

use strict;
use warnings;
use POSIX "fmod";
use Getopt::Long;
use SvgGen;

our $PI = 3.141592653589793;

my $margin = 0;
my $geometry = undef;
my $svg_out = undef;
my $cfg_in = undef;
my $page_outline = undef;
my $drawing_outline = undef;
my $text_outline = undef;

GetOptions("m|margin=f" => \$margin,
           "g|geometry=s" => \$geometry,
           "o|output=s" => \$svg_out,
           "d|drawing" => \$drawing_outline,
           "p|page" => \$page_outline,
           "t|text" => \$text_outline);

$cfg_in = shift || die "ERROR: Must specify a config file\n";


my %c = ();
open CFGI, "<", $cfg_in or die "ERROR: Can't open $cfg_in for reading\n";
while(<CFGI>) {
    chomp;
    if(/^\s*#/) {
        # comment
    } elsif(/^\s*$/) {
        # empty
    } elsif(/^\s*([^\s=]+)\s*=\s*(.*?)\s*$/) {
        $c{lc $1} = $2;
    } else {
        die "ERROR: Don't understand config line [$_]\n";
    }
}
close(CFGI);

if(!defined $geometry) {
    $geometry="$c{draw_width}x$c{draw_height}+0+0";
}

my $doc = SvgGen::createDoc($geometry, $margin, "Wrapped Linear Quadrature Encoder Pattern");

foreach(sort keys %c) {
    $doc->addChild(SvgGen::createComment("$_: $c{$_}"));
}
$doc->addChild(SvgGen::createBlank());

my $pc = $doc->addChild(SvgGen::createGroup("page_container"));

my $p = $pc->addChild(SvgGen::createGroup("linear_quadrature"));
my $ax = $c{lqp_outer_gap};
my $aw = $c{lqp_aligner_width};
my $gw = $c{lqp_gap_width};
my $pw = $c{lqp_proper_width};
my $sh = $c{lqp_length}/$c{lqp_region_count};
my $xh = $sh/4;
my $astart = $sh * $c{lqp_align_index};
my $cx = $ax + $aw + $gw;

for(my $cy = 0; $cy < $c{draw_height}; $cy += $sh) {
    $p->addChild(SvgGen::createShape("rect", {y=>$cy, x=>$cx, height=>$xh * 2,
                                      width=>$pw, fill=>"black", "stroke-width"=>0}));
    $p->addChild(SvgGen::createShape("rect", {y=>$cy + $xh, x=>$cx+$pw, height=>$xh * 2,
                                      width=>$pw, fill=>"black", "stroke-width"=>0}));
}

for(my $astart = $sh * $c{lqp_align_index}; $astart < $c{draw_height}; $astart += $sh * $c{lqp_region_count}) {
    $p->addChild(SvgGen::createShape("rect", {y=>$astart, x=>$ax, height=>$sh,
                                              width=>$aw, fill=>"black", "stroke-width"=>0}));

    $p->addChild(SvgGen::createShape("rect", {y=>$astart, x=>$ax + $aw + 2*$gw + 2*$pw, height=>$sh,
                                              width=>$aw, fill=>"black", "stroke-width"=>0}));
}



$pc->addChild(SvgGen::createBlank());

#Page_Wrap_Align_Positions = 0 200 460.6
#Page_Wrap_Align_Inset = 0
#Page_Wrap_Align_Width = 75

$p = $pc->addChild(SvgGen::createGroup("page_alignment"));
foreach(split / /, $c{page_wrap_align_positions}) {
    my $ay = $_;
    $p->addChild(SvgGen::createShape("path", {d=> "M $c{page_wrap_align_inset} $ay ".
                                                  "l $c{page_wrap_align_width} 0 ".
                                                  "M $c{draw_width} $ay ".
                                                  "m -$c{page_wrap_align_inset} 0 ".
                                                  "l -$c{page_wrap_align_width} 0",
                                              stroke=>"black", fill=>"none", "stroke-width"=>1}));
}

if($drawing_outline) {
    $pc->addChild(SvgGen::createShape("path",{d=>"M 0 0 l $c{draw_width} 0 l 0 $c{draw_height} l -$c{draw_width} 0 l 0 -$c{draw_height}", stroke=>"blue", fill=>"none", "stroke-width"=>0.1}));
}

open SVGO, ">",$svg_out or die "ERROR: Can't open $svg_out for writing\n" if $svg_out;
*SVGO = *STDOUT unless $svg_out;
$doc->blitDoc(*SVGO, $page_outline);
close(SVGO) if $svg_out;

exit(0);
