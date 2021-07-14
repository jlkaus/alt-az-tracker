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



# generate svg in here for a single page test pattern.

# include areas of:
#   solid black
#   solid white
#   solid 90% white
#   solid 18% white
#   step-wise grayscale gradient
#   patterns of successively thick lines
#   patterns of successively thick spaces
#   patterns of successively thick lines and spaces (equal sized)
#   linear quadrature sequence of various mark widths and heights

my %c = ();
open CFGI, "<", $cfg_in or die "ERROR: Can't open $cfg_in for reading\n";
while(<CFGI>) {
    chomp;
    if(/^\s*#/) {
        # comment
    } elsif(/^\s*$/) {
        # empty
    } elsif(/^\s*([^\s=]+)\s*=\s*([^\s]*)\s*$/) {
        $c{lc $1} = $2;
    } else {
        die "ERROR: Don't understand config line [$_]\n";
    }
}
close(CFGI);

if(!defined $geometry) {
    $geometry="$c{draw_width}x$c{draw_height}+0+0";
}

my $doc = SvgGen::createDoc($geometry, $margin, "Reflective Optical Sensor Test Patterns");

foreach(sort keys %c) {
    $doc->addChild(SvgGen::createComment("$_: $c{$_}"));
}
$doc->addChild(SvgGen::createBlank());

my $pc = $doc->addChild(SvgGen::createGroup("page_container"));
my $cy = 0;

# callibration squares
$pc->addChild(SvgGen::createBlank());
my $p = $pc->addChild(SvgGen::createGroup("callibration"));
my $w = $c{draw_width}/4;
my $h = $c{cal_height};
$p->addChild(SvgGen::createShape("rect", {x=>0,y=>$cy,width=>$w, height=>$h, fill=>SvgGen::genGrey(0), "stroke-width"=>0}));
$p->addChild(SvgGen::createShape("rect", {x=>$w,y=>$cy,width=>$w, height=>$h, fill=>SvgGen::genGrey($c{cal_dark_grey}), "stroke-width"=>0}));
$p->addChild(SvgGen::createShape("rect", {x=>(2*$w),y=>$cy,width=>$w, height=>$h, fill=>SvgGen::genGrey($c{cal_light_grey}), "stroke-width"=>0}));
$p->addChild(SvgGen::createShape("rect", {x=>(3*$w),y=>$cy,width=>$w, height=>$h, fill=>SvgGen::genGrey(1.0), "stroke-width"=>0}));
$cy += $h;

# piecewise gradient
$pc->addChild(SvgGen::createBlank());
$p = $pc->addChild(SvgGen::createGroup("gradient"));
$h = $c{pwg_height};
$w = $c{draw_width}/$c{pwg_n};
my $d = 1.0/($c{pwg_n} - 1);
for(my $i = 0; $i < $c{pwg_n}; ++$i) {
    $p->addChild(SvgGen::createShape("rect", {x=>$i*$w, y=>$cy, width=>$w, height=>$h, fill=>SvgGen::genGrey($i*$d), "stroke-width"=>0}));
}
$cy += $h;

# constant repeating
$pc->addChild(SvgGen::createBlank());
$p = $pc->addChild(SvgGen::createGroup("constant"));
$h = $c{pat_height};
my $mw = $c{cr_mark_width};
my $sw = $c{cr_space_width};
for(my $cx = 0; $cx < $c{draw_width}; $cx += $mw + $sw) {
    $p->addChild(SvgGen::createShape("rect", {x=>$cx, y=>$cy, width=>$mw, height=>$h, fill=>SvgGen::genGrey(0), "stroke-width"=>0}));
}
$cy += $h;

# thickening mark
$pc->addChild(SvgGen::createBlank());
$p = $pc->addChild(SvgGen::createGroup("mark_variance"));
$h = $c{pat_height};
$mw = $c{mt_min};
my $old = $mw;
my $r = $c{mt_rate};
$sw = $c{mt_space_width};
for(my $cx = 0; $cx < $c{draw_width}; $cx += $old + $sw) {
    $p->addChild(SvgGen::createShape("rect", {x=>$cx, y=>$cy, width=>$mw, height=>$h, fill=>SvgGen::genGrey(0), "stroke-width"=>0}));
    $old = $mw;
    if($c{mt_type} eq "linear") {
        $mw += $r;
    } else {
        $mw *= $r;
    }
}
$cy += $h;

# thickening space
$pc->addChild(SvgGen::createBlank());
$p = $pc->addChild(SvgGen::createGroup("space_variance"));
$h = $c{pat_height};
$sw = $c{st_min};
$old = $sw;
$r = $c{st_rate};
$mw = $c{st_mark_width};
for(my $cx = 0; $cx < $c{draw_width}; $cx += $old + $mw) {
    $p->addChild(SvgGen::createShape("rect", {x=>$cx, y=>$cy, width=>$mw, height=>$h, fill=>SvgGen::genGrey(0), "stroke-width"=>0}));
    $old = $sw;
    if($c{st_type} eq "linear") {
        $sw += $r;
    } else {
        $sw *= $r;
    }
}
$cy += $h;

# thickening group
$pc->addChild(SvgGen::createBlank());
$p = $pc->addChild(SvgGen::createGroup("group_variance"));
$h = $c{pat_height};
$w = $c{gt_min};
$old = $w;
$r = $c{gt_rate};
for(my $cx = 0; $cx < $c{draw_width}; $cx += 2*$old) {
    $p->addChild(SvgGen::createShape("rect", {x=>$cx, y=>$cy, width=>$w, height=>$h, fill=>SvgGen::genGrey(0), "stroke-width"=>0}));
    $old = $w;
    if($c{gt_type} eq "linear") {
        $w += $r;
    } else {
        $w *= $r;
    }
}
$cy += $h;


# thickening duty cycle
$pc->addChild(SvgGen::createBlank());
$p = $pc->addChild(SvgGen::createGroup("duty_variance"));
$h = $c{pat_height};
$w = $c{dct_width};
$mw = $c{dct_min};
$r = $c{dct_rate};
for(my $cx = 0; $cx < $c{draw_width}; $cx += $w) {
    $p->addChild(SvgGen::createShape("rect", {x=>$cx, y=>$cy, width=>$mw*$w,
                                      height=>$h, fill=>SvgGen::genGrey(0), "stroke-width"=>0}));
    if($c{dct_type} eq "linear") {
        $mw += $r;
    } else {
        $mw *= $r;
    }
}
$cy += $h;

# quadrature test patterns
$pc->addChild(SvgGen::createBlank());
$p = $pc->addChild(SvgGen::createGroup("linear_quadrature"));
$cy += $c{lqp_outer_gap};
my $ah = $c{lqp_aligner_height};
my $gh = $c{lqp_gap_height};
my $ph = $c{lqp_proper_height};
$sw = $c{lqp_region_width};
my $xw = $sw/4;
my $astart = $sw * $c{lqp_align_index};

$p->addChild(SvgGen::createShape("rect", {x=>$astart, y=>$cy, width=>$sw,
                                  height=>$ah, fill=>SvgGen::genGrey(0), "stroke-width"=>0}));
$cy += $ah + $gh;

for(my $cx = 0; $cx < $c{draw_width}; $cx += $sw) {
    $p->addChild(SvgGen::createShape("rect", {x=>$cx, y=>$cy, width=>$xw * 2,
                                      height=>$ph, fill=>SvgGen::genGrey(0), "stroke-width"=>0}));
    $p->addChild(SvgGen::createShape("rect", {x=>$cx + $xw, y=>$cy+$ph, width=>$xw * 2,
                                      height=>$ph, fill=>SvgGen::genGrey(0), "stroke-width"=>0}));
}
$cy += 2*$ph + $gh;

$p->addChild(SvgGen::createShape("rect", {x=>$astart, y=>$cy, width=>$sw,
                                  height=>$ah, fill=>SvgGen::genGrey(0), "stroke-width"=>0}));




$pc->addChild(SvgGen::createBlank());

if($drawing_outline) {
    $pc->addChild(SvgGen::createShape("path",{d=>"M 0 0 l $c{draw_width} 0 l 0 $c{draw_height} l -$c{draw_width} 0 l 0 -$c{draw_height}", stroke=>"blue", fill=>"none", "stroke-width"=>0.1}));
}

open SVGO, ">",$svg_out or die "ERROR: Can't open $svg_out for writing\n" if $svg_out;
*SVGO = *STDOUT unless $svg_out;
$doc->blitDoc(*SVGO, $page_outline);
close(SVGO) if $svg_out;

exit(0);
