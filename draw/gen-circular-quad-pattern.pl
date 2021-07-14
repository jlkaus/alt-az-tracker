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

my $cpos = $c{draw_extent} / 2;
if(!defined $geometry) {
    $geometry="$c{draw_extent}x$c{draw_extent}+-$cpos+-$cpos";
}

my $doc = SvgGen::createDoc($geometry, $margin, "Circular Quadrature Encoder Pattern");

foreach(sort keys %c) {
    $doc->addChild(SvgGen::createComment("$_: $c{$_}"));
}
$doc->addChild(SvgGen::createBlank());

my $pc = $doc->addChild(SvgGen::createGroup("page_container"));

my $p = $pc->addChild(SvgGen::createGroup("center_hole"));
my $ihr = $c{cqp_inner_hole_radius};
$p->addChild(SvgGen::createShape("circle", {cx=>0,cy=>0, r=>$ihr,
                                            fill=>"none", stroke=>"black", "stroke-width"=>0.1}));
$p->addChild(SvgGen::createShape("path", {d=>"M 0 0 L 0 -$ihr A $ihr $ihr 0 0 1 $ihr 0 Z",
                                          fill=>"black", "stroke-width"=>0}));
$p->addChild(SvgGen::createShape("path", {d=>"M 0 0 L 0 $ihr A $ihr $ihr 0 0 1 -$ihr 0 Z",
                                          fill=>"black", "stroke-width"=>0}));

$pc->addChild(SvgGen::createBlank());

$p = $pc->addChild(SvgGen::createGroup("circular_quadrature"));
my $ra0_start=$c{cqp_inner_gap};
my $ra0_end=$ra0_start + $c{cqp_aligner_width};
my $rpa=$ra0_end + $c{cqp_gap_width};
my $rpb=$rpa + $c{cqp_proper_width};
my $rpc=$rpb + $c{cqp_proper_width};
my $ra1_start = $rpc + $c{cqp_gap_width};
my $ra1_end = $ra1_start + $c{cqp_aligner_width};
my $dp = 360.0/4/$c{cqp_region_count};

if($text_outline) {
    $p->addChild(SvgGen::createShape("circle", {cx=>0,cy=>0, r=>$ra0_start,
                                                fill=>"none", stroke=>"orange", "stroke-width"=>0.1}));
    $p->addChild(SvgGen::createShape("circle", {cx=>0,cy=>0, r=>$ra0_end,
                                                fill=>"none", stroke=>"orange", "stroke-width"=>0.1}));
    $p->addChild(SvgGen::createShape("circle", {cx=>0,cy=>0, r=>$rpa,
                                                fill=>"none", stroke=>"orange", "stroke-width"=>0.1}));
    $p->addChild(SvgGen::createShape("circle", {cx=>0,cy=>0, r=>$rpb,
                                                fill=>"none", stroke=>"orange", "stroke-width"=>0.1}));
    $p->addChild(SvgGen::createShape("circle", {cx=>0,cy=>0, r=>$rpc,
                                                fill=>"none", stroke=>"orange", "stroke-width"=>0.1}));
    $p->addChild(SvgGen::createShape("circle", {cx=>0,cy=>0, r=>$ra1_start,
                                                fill=>"none", stroke=>"orange", "stroke-width"=>0.1}));
    $p->addChild(SvgGen::createShape("circle", {cx=>0,cy=>0, r=>$ra1_end,
                                                fill=>"none", stroke=>"orange", "stroke-width"=>0.1}));
}

sub moveTo {
    my ($x, $y) = @_;
    return " M $x $y";
}

sub lineTo {
    my ($x, $y) = @_;
    return " L $x $y";
}

sub arcTo {
    my ($r, $x, $y, $neg) = @_;
    $neg = 1 if !defined $neg;
    return " A $r $r 0 0 $neg $x $y";
}

sub computeXY {
    my ($r, $phi) = @_;
    return ($r * cos(-$phi*2*$PI/360.0), $r * sin(-$phi*2*$PI/360.0));
}

sub createSector {
    my ($r1, $r2, $phi1, $phi2) = @_;
    return SvgGen::createShape("path", {d=>moveTo(computeXY($r1,$phi1)).
                                            arcTo($r1,computeXY($r1,$phi2)).
                                            lineTo(computeXY($r2,$phi2)).
                                            arcTo($r2,computeXY($r2,$phi1),0)." Z",
                                        fill=>"black", "stroke-width"=>0});
}

for(my $i = 0; $i < $c{cqp_region_count}; ++$i) {
    $p->addChild(createSector($rpa, $rpb, $i*4*$dp, $i*4*$dp + 2*$dp));
    $p->addChild(createSector($rpb, $rpc, $i*4*$dp + $dp, $i*4*$dp + 3*$dp));

    if($i == $c{cqp_align_index}) {
        $p->addChild(createSector($ra0_start, $ra0_end, $i*4*$dp, $i*4*$dp + 4*$dp));
        $p->addChild(createSector($ra1_start, $ra1_end, $i*4*$dp, $i*4*$dp + 4*$dp));
    }
}



$pc->addChild(SvgGen::createBlank());
$p = $pc->addChild(SvgGen::createGroup("page_alignment"));
my $qth = $c{quadrant_text_size};
$ihr = $c{cqp_inner_hole_radius};

$p->addChild(SvgGen::createText("I", {x=>$ihr, y=>-$ihr,
                                      fill=>"none", stroke=>"black", "stroke-width"=>0.4, style=>"font:bold ${qth}mm serif"}));
$p->addChild(SvgGen::createText("II", {x=>-$ihr - 2.2*$qth, y=>-$ihr,
                                       fill=>"none", stroke=>"black", "stroke-width"=>0.4, style=>"font:bold ${qth}mm serif"}));
$p->addChild(SvgGen::createText("III", {x=>-$ihr - 3.3*$qth, y=>$ihr + 1.85*$qth,
                                        fill=>"none", stroke=>"black", "stroke-width"=>0.4, style=>"font:bold ${qth}mm serif"}));
$p->addChild(SvgGen::createText("IV", {x=>$ihr, y=>$ihr+1.85*$qth,
                                       fill=>"none", stroke=>"black", "stroke-width"=>0.4, style=>"font:bold ${qth}mm serif"}));

if($text_outline) {
    $p->addChild(SvgGen::createShape("rect", {x=>$ihr, y=>-$ihr-1.85*$qth, width=>1.1*$qth, height=>1.85*$qth, fill=>"none", stroke=>"green", "stroke-width"=>0.1}));
    $p->addChild(SvgGen::createShape("rect", {x=>-$ihr - 2.2*$qth, y=>-$ihr-1.85*$qth, width=>2.2*$qth, height=>1.85*$qth, fill=>"none", stroke=>"green", "stroke-width"=>0.1}));
    $p->addChild(SvgGen::createShape("rect", {x=>-$ihr - 3.3*$qth, y=>$ihr, width=>3.3*$qth, height=>1.85*$qth, fill=>"none", stroke=>"green", "stroke-width"=>0.1}));
    $p->addChild(SvgGen::createShape("rect", {x=>$ihr, y=>$ihr, width=>3.2*$qth, height=>1.85*$qth, fill=>"none", stroke=>"green", "stroke-width"=>0.1}));
}

$ihr = $c{cqp_inner_hole_radius};
my $ags = $c{alignment_gap_size};
my $alm = $c{cqp_inner_gap} - $c{cqp_inner_hole_radius} - 2*$ags;
$p->addChild(SvgGen::createShape("path", {d=>"M $ihr 0 m $ags 0 l $alm 0", fill=>"none", stroke=>"black", "stroke-width"=>1}));
$p->addChild(SvgGen::createShape("path", {d=>"M -$ihr 0 m -$ags 0 l -$alm 0", fill=>"none", stroke=>"black", "stroke-width"=>1}));
$p->addChild(SvgGen::createShape("path", {d=>"M 0 $ihr m 0 $ags l 0 $alm", fill=>"none", stroke=>"black", "stroke-width"=>1}));
$p->addChild(SvgGen::createShape("path", {d=>"M 0 -$ihr m 0 -$ags l 0 -$alm", fill=>"none", stroke=>"black", "stroke-width"=>1}));

my $rem = $c{draw_extent} - $ra1_end - $ags;
$p->addChild(SvgGen::createShape("path", {d=>"M $ra1_end 0 m $ags 0 l $rem 0", fill=>"none", stroke=>"black", "stroke-width"=>1}));
$p->addChild(SvgGen::createShape("path", {d=>"M -$ra1_end 0 m -$ags 0 l -$rem 0", fill=>"none", stroke=>"black", "stroke-width"=>1}));
$p->addChild(SvgGen::createShape("path", {d=>"M 0 $ra1_end m 0 $ags l 0 $rem", fill=>"none", stroke=>"black", "stroke-width"=>1}));
$p->addChild(SvgGen::createShape("path", {d=>"M 0 -$ra1_end m 0 -$ags l 0 -$rem", fill=>"none", stroke=>"black", "stroke-width"=>1}));

#Page_Wrap_Align_Positions = 0 200 460.6
#Page_Wrap_Align_Inset = 0
#Page_Wrap_Align_Width = 75

#foreach(split / /, $c{page_wrap_align_positions}) {
#    my $ay = $_;
#    $pc->addChild(SvgGen::createShape("path", {d=> "M $c{page_wrap_align_inset} $ay ".
#                                                   "l $c{page_wrap_align_width} 0 ".
#                                                   "M $c{draw_width} $ay ".
#                                                   "m -$c{page_wrap_align_inset} 0 ".
#                                                   "l -$c{page_wrap_align_width} 0",
#                                               stroke=>"black", fill=>"none", "stroke-width"=>1}));
#}

if($drawing_outline) {
    $pc->addChild(SvgGen::createShape("path",{d=>"M -${cpos} -${cpos} l $c{draw_extent} 0 l 0 $c{draw_extent} l -$c{draw_extent} 0 l 0 -$c{draw_extent}", stroke=>"blue", fill=>"none", "stroke-width"=>0.1}));
}

open SVGO, ">",$svg_out or die "ERROR: Can't open $svg_out for writing\n" if $svg_out;
*SVGO = *STDOUT unless $svg_out;
$doc->blitDoc(*SVGO, $page_outline);
close(SVGO) if $svg_out;

exit(0);
