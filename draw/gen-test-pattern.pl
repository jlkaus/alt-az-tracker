#!/usr/bin/perl

use strict;
use warnings;
use POSIX "fmod";
use Getopt::Long;

our $PI = 3.141592653589793;

my $margin = 0;
my $svg_out = undef;
my $cfg_in = undef;
my $page_outline = undef;

GetOptions("m|margin=f" => \$margin,
           "o|output=s" => \$svg_out,
           "p|page" => \$page_outline);

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

my $doc = createDoc($c{page_height}, $c{page_width}, $margin, "Reflective Optical Sensor Test Patterns");

foreach(sort keys %c) {
    addChild($doc, createComment("$_: $c{$_}"));
}
addChild($doc, createBlank());

my $pc = addChild($doc, createGroup("page_container"));
my $cy = 0;

# callibration squares
addChild($pc, createBlank());
my $p = addChild($pc, createGroup("callibration"));
my $w = $c{page_width}/4;
my $h = $c{cal_height};
addChild($p, createShape("rect", {x=>0,y=>$cy,width=>$w, height=>$h, fill=>genGrey(0), "stroke-width"=>0}));
addChild($p, createShape("rect", {x=>$w,y=>$cy,width=>$w, height=>$h, fill=>genGrey($c{cal_dark_grey}), "stroke-width"=>0}));
addChild($p, createShape("rect", {x=>(2*$w),y=>$cy,width=>$w, height=>$h, fill=>genGrey($c{cal_light_grey}), "stroke-width"=>0}));
addChild($p, createShape("rect", {x=>(3*$w),y=>$cy,width=>$w, height=>$h, fill=>genGrey(1.0), "stroke-width"=>0}));
$cy += $h;

# piecewise gradient
addChild($pc, createBlank());
$p = addChild($pc, createGroup("gradient"));
$h = $c{pat_height};
$w = $c{page_width}/$c{pwg_n};
my $d = 1.0/($c{pwg_n} - 1);
for(my $i = 0; $i < $c{pwg_n}; ++$i) {
    addChild($p, createShape("rect", {x=>$i*$w, y=>$cy, width=>$w, height=>$h, fill=>genGrey($i*$d), "stroke-width"=>0}));
}
$cy += $h;

# constant repeating
addChild($pc, createBlank());
$p = addChild($pc, createGroup("constant"));
$h = $c{pat_height};
my $mw = $c{cr_mark_width};
my $sw = $c{cr_space_width};
for(my $cx = 0; $cx < $c{page_width}; $cx += $mw + $sw) {
    addChild($p, createShape("rect", {x=>$cx, y=>$cy, width=>$cx + $mw > $c{page_width} ? ($c{page_width} - $cx) : $mw, height=>$h, fill=>genGrey(0), "stroke-width"=>0}));
}
$cy += $h;

# thickening mark
addChild($pc, createBlank());
$p = addChild($pc, createGroup("mark_variance"));
$h = $c{pat_height};
$mw = $c{mt_min};
my $old = $mw;
my $r = $c{mt_rate};
$sw = $c{mt_space_width};
for(my $cx = 0; $cx < $c{page_width}; $cx += $old + $sw) {
    addChild($p, createShape("rect", {x=>$cx, y=>$cy, width=>$cx + $mw > $c{page_width} ? ($c{page_width} - $cx) : $mw, height=>$h, fill=>genGrey(0), "stroke-width"=>0}));
    $old = $mw;
    if($c{mt_type} eq "linear") {
        $mw += $r;
    } else {
        $mw *= $r;
    }
}
$cy += $h;

# thickening space
addChild($pc, createBlank());
$p = addChild($pc, createGroup("space_variance"));
$h = $c{pat_height};
$sw = $c{st_min};
$old = $sw;
$r = $c{st_rate};
$mw = $c{st_mark_width};
for(my $cx = 0; $cx < $c{page_width}; $cx += $old + $mw) {
    addChild($p, createShape("rect", {x=>$cx, y=>$cy, width=>$cx + $mw > $c{page_width} ? ($c{page_width} - $cx) : $mw, height=>$h, fill=>genGrey(0), "stroke-width"=>0}));
    $old = $sw;
    if($c{st_type} eq "linear") {
        $sw += $r;
    } else {
        $sw *= $r;
    }
}
$cy += $h;

# thickening group
addChild($pc, createBlank());
$p = addChild($pc, createGroup("group_variance"));
$h = $c{pat_height};
$w = $c{gt_min};
$old = $w;
$r = $c{gt_rate};
for(my $cx = 0; $cx < $c{page_width}; $cx += 2*$old) {
    addChild($p, createShape("rect", {x=>$cx, y=>$cy, width=>$cx + $w > $c{page_width} ? ($c{page_width} - $cx) : $w, height=>$h, fill=>genGrey(0), "stroke-width"=>0}));
    $old = $w;
    if($c{gt_type} eq "linear") {
        $w += $r;
    } else {
        $w *= $r;
    }
}
$cy += $h;


# thickening duty cycle
addChild($pc, createBlank());
$p = addChild($pc, createGroup("duty_variance"));
$h = $c{pat_height};
$w = $c{dct_width};
$mw = $c{dct_min};
$r = $c{dct_rate};
for(my $cx = 0; $cx < $c{page_width}; $cx += $w) {
    addChild($p, createShape("rect", {x=>$cx, y=>$cy, width=>$cx + $mw*$w > $c{page_width} ? ($c{page_width} - $cx) : $mw*$w,
                                      height=>$h, fill=>genGrey(0), "stroke-width"=>0}));
    if($c{dct_type} eq "linear") {
        $mw += $r;
    } else {
        $mw *= $r;
    }
}
$cy += $h;

# quadrature test patterns
addChild($pc, createBlank());
$p = addChild($pc, createGroup("linear_quadrature"));
$cy += $c{lqp_outer_gap};
my $ah = $c{lqp_aligner_height};
my $gh = $c{lqp_gap_height};
my $ph = $c{lqp_proper_height};
$sw = $c{lqp_region_width};
my $xw = $sw/4;
my $astart = $sw * $c{lqp_align_index};

addChild($p, createShape("rect", {x=>$astart, y=>$cy, width=>$astart + $sw > $c{page_width} ? ($c{page_width} - $astart) : $sw,
                                  height=>$ah, fill=>genGrey(0), "stroke-width"=>0}));
$cy += $ah + $gh;

for(my $cx = 0; $cx < $c{page_width}; $cx += $sw) {
    addChild($p, createShape("rect", {x=>$cx, y=>$cy, width=>$cx + 2* $xw > $c{page_width} ? ($c{page_width} - $cx) : $xw * 2,
                                      height=>$ph, fill=>genGrey(0), "stroke-width"=>0}));
    addChild($p, createShape("rect", {x=>$cx + $xw, y=>$cy+$ph, width=>$cx + 3* $xw > $c{page_width} ? ($c{page_width} - $cx - $xw) : $xw * 2,
                                      height=>$ph, fill=>genGrey(0), "stroke-width"=>0}));
}
$cy += 2*$ph + $gh;

addChild($p, createShape("rect", {x=>$astart, y=>$cy, width=>$astart + $sw > $c{page_width} ? ($c{page_width} - $astart) : $sw,
                                  height=>$ah, fill=>genGrey(0), "stroke-width"=>0}));




addChild($pc, createBlank());

if($page_outline) {
    # Add a line around the printable pattern area, for reference.
    addChild($doc, createShape("path",{d=>"M 0 0 L $c{page_width} 0 L $c{page_width} $c{page_height} L 0 $c{page_height} L 0 0", stroke=>"red", fill=>"none", "stroke-width"=>0.1}));
}


open SVGO, ">",$svg_out or die "ERROR: Can't open $svg_out for writing\n" if $svg_out;
*SVGO = *STDOUT unless $svg_out;
blitDoc(*SVGO, $doc);
close(SVGO) if $svg_out;

exit(0);

sub genGrey {
    my ($l) = @_;
    my $v = int(255.0 * $l);
    return sprintf("#%02x%02x%02x", $v, $v, $v);
}

sub blitDoc {
    my ($fh, $doc) = @_;

    my $tw = $doc->{width} + 2*$doc->{margin};
    my $th = $doc->{height} + 2*$doc->{margin};
    my $vp = sprintf("%f %f %f %f", -$doc->{margin}, -$doc->{margin}, $tw, $th);
    print $fh "<?xml version=\"1.0\" encoding=\"UTF-8\" ?>\n";
    #print $fh "<?xml-stylesheet href='$css_out' type='text/css' ?>\n";
    print $fh "<!DOCTYPE svg PUBLIC \"-//W3C//DTD SVG 2.0//EN\" \"http://www.w3.org/Graphics/SVG/2.0/DTD/svg20.dtd\">\n";
    print $fh "<svg xmlns=\"http://www.w3.org/2000/svg\" xmlns:xlink=\"http://www.w3.org/1999/xlink\" height=\"${th}mm\" width=\"${tw}mm\" viewBox=\"${vp}\">\n";
    print $fh "    <title>$doc->{title}</title>\n\n";

    foreach(@{$doc->{children}}) {
        blitItem($fh,1,$_);
    }

    print $fh "</svg>\n";
}

sub blitItem {
    my ($fh, $depth, $item) = @_;

    if(defined $item->{prebr}) {
        print $fh "\n";
    }

    if(defined $item->{comments}) {
        foreach(@{$item->{comments}}) {
            if (defined $_) {
                print $fh " "x(4*$depth), "<!-- ",$_," -->\n";
            }
        }
    }

    if(defined $item->{tag}) {
        print $fh " "x(4*$depth), "<$item->{tag}";
        foreach(keys %{$item->{a}}) {
            if(defined $item->{a}->{$_}) {
                print $fh " $_=\"$item->{a}->{$_}\"";
            }
        }

        if(defined $item->{children}) {
            print $fh ">\n";
            foreach(@{$item->{children}}) {
                blitItem($fh, $depth+1, $_);
            }
            print $fh " "x(4*$depth), "</$item->{tag}>\n";
        } else {
            print $fh " />\n";
        }
    }
}


sub createDoc {
    my ($h, $w, $m, $title) = @_;

    return {height=> $h, width=>$w, margin=>$m, title=>$title, children=> []};
}

sub createComment {
    my ($comment) = @_;
    return {comments=>[$comment]};
}

sub createGroup {
    my ($id, $class, $comments) = @_;
    return createMulti("g", {id=>$id, class=>$class}, $comments);
}

sub createShape {
    my ($shape, $attribs, $comments) = @_;
    return createSingle($shape, $attribs, $comments);
}

sub createSingle {
    my ($tag, $attribs, $comments) = @_;
    my $tmp = {tag=>$tag, a=>{%$attribs}};
    if (defined $comments) {
        $tmp->{comments} = [@$comments];
    }
    return $tmp;
}

sub createMulti {
    my ($tag, $attribs, $comments) = @_;
    my $tmp = {tag=>$tag, a=>{%$attribs}, children=>[]};
    if(defined $comments) {
        $tmp->{comments} = [@$comments];
    }
    return $tmp;
}

sub createBlank {
    return {prebr=>1};
}

sub addChild {
    my ($parent, $child) = @_;
    push @{$parent->{children}}, $child;
    return $child;
}



__END__
print SVGO "<g id='page_container'>";
print SVGO "<g id='alignment_container'>";

for(my $current_mark = $start_fwd_mark; $current_mark < $final_fwd_mark; $current_mark += $smallest_degs) {
    my $rules = findRules($current_mark);

    my $xloc = ($current_mark - $start_fwd_mark + $smallest_degs) * $degree_width;

    print SVGO     "<g class='align_holder'>";
    if($rules->{use_numbers}) {
          print SVGO "<!-- Align: $current_mark -->";
          print SVGO "<line y1='${xloc}in' x1='0in' y2='${xloc}in' x2='6in' stroke='black' stroke-width='1px' />\n";
    }
    print SVGO     "</g>";
}

print SVGO         "</g>";

print SVGO         "<g id='ruler_container'>";

for(my $current_mark = $start_fwd_mark; $current_mark < $final_fwd_mark; $current_mark += $smallest_degs) {
    my $rules = findRules($current_mark);

    my $top_spot = 8.0 - $rules->{height};
    my $xloc = ($current_mark - $start_fwd_mark + $smallest_degs) * $degree_width;

    print SVGO     "<g class='mark_holder_$rules->{mark_class}'>";
    print SVGO     "<!-- $current_mark -->";
    if($rules->{use_numbers}) {
        print SVGO "<text y='-7.50in' x='${xloc}in' transform='rotate(90)' style='fill:#888;text-anchor:middle;font-size:5pt;font-family:serif;' >";
        print SVGO sprintf("%.0f",findFwd($current_mark));
        print SVGO "</text>\n";
        print SVGO "<text y='-7.59in' x='${xloc}in' transform='rotate(90)' style='fill:#000;text-anchor:middle;font-size:5pt;font-family:serif;' >";
        print SVGO sprintf("%.0f",findRev($current_mark));
        print SVGO "</text>\n";
    }

    print SVGO "<line y1='${xloc}in' x1='8in' y2='${xloc}in' x2='${top_spot}in' stroke='black' stroke-width='1px' />\n";
    print SVGO     "</g>";
}
print SVGO     "</g>\n";
print SVGO     "</g>\n";
print SVGO         "</svg>\n";

close(SVGO);
exit(0);
