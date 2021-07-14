package SvgGen;

sub genGrey {
    my ($l) = @_;
    my $v = int(255.0 * $l);
    return sprintf("#%02x%02x%02x", $v, $v, $v);
}

sub blitDoc {
    my ($doc, $fh, $page_outline) = @_;

    print $fh "<?xml version=\"1.0\" encoding=\"UTF-8\" ?>\n";
    #print $fh "<?xml-stylesheet href='$css_out' type='text/css' ?>\n";
    print $fh "<!DOCTYPE svg PUBLIC \"-//W3C//DTD SVG 2.0//EN\" \"http://www.w3.org/Graphics/SVG/2.0/DTD/svg20.dtd\">\n";

    my $tw = $doc->{width} + 2*$doc->{margin};
    my $th = $doc->{height} + 2*$doc->{margin};
    my $vp = sprintf("%f %f %f %f", $doc->{startx}-$doc->{margin}, $doc->{starty}-$doc->{margin}, $tw, $th);
    my $vp2 = sprintf("%f %f %f %f", $doc->{startx}, $doc->{starty}, $doc->{width}, $doc->{height});

    my $indent = 0;
    if($doc->{margin}) {
        # Embed the real svg document inside of a new one, with a wider viewport to accomodate the margins
        print $fh " "x($indent*4), "<svg xmlns=\"http://www.w3.org/2000/svg\" xmlns:xlink=\"http://www.w3.org/1999/xlink\" ";
        print $fh "height=\"${th}mm\" width=\"${tw}mm\" viewBox=\"${vp}\">\n";
        $indent += 1;
        print $fh " "x($indent*4), "<svg x=\"$doc->{startx}\" y=\"$doc->{starty}\" height=\"$doc->{height}\" width=\"$doc->{width}\" viewBox=\"${vp2}\">\n";
    } else {
        print $fh "<svg xmlns=\"http://www.w3.org/2000/svg\" xmlns:xlink=\"http://www.w3.org/1999/xlink\" ";
        print $fh "height=\"$doc->{height}mm\" width=\"$doc->{width}mm\" viewBox=\"${vp2}\">\n";
    }


    foreach(@{$doc->{children}}) {
        _blitItem($_,$fh,$indent + 1);
    }

    if($page_outline) {
        # Add a line around the printable pattern area, for reference.
        _blitItem(SvgGen::createShape("path",{d=>"M $doc->{startx} $doc->{starty} l $doc->{width} 0 l 0 $doc->{height} l -$doc->{width} 0 l 0 -$doc->{height}", stroke=>"red", fill=>"none", "stroke-width"=>0.1}), $fh, $indent + 1);
    }

    if($doc->{margin}) {
        print $fh " "x($indent*4), "</svg>\n";
        $indent -= 1;
    }

    print $fh " "x($indent*4), "</svg>\n";
}

sub _blitItem {
    my ($item, $fh, $depth) = @_;

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

        my $has_content = undef;
        if(defined $item->{content}) {
            print $fh ">$item->{content}";
            $has_content = 1;
        }
        if(defined $item->{children}) {
            if(!$has_content) {
                print $fh ">";
            }
            print $fh "\n";
            foreach(@{$item->{children}}) {
                _blitItem($_, $fh, $depth+1);
            }
            $has_content = 1;
            print $fh " "x(4*$depth);
        }

        if($has_content) {
            print $fh "</$item->{tag}>\n";
        } else {
            print $fh " />\n";
        }
    } elsif(defined $item->{content}) {
        print $fh $item->{content};
    }
}


sub createDoc {
    my ($vp, $m, $title) = @_;

    my $w = 0;
    my $h = 0;
    my $startx = 0;
    my $starty = 0;
    if($vp =~ /^([[:digit:].]+)x([[:digit:].]+)\+([[:digit:].-]+)\+([[:digit:].-]+)$/) {
        $w = $1;
        $h = $2;
        $startx = $3;
        $starty = $4;
    } elsif($vp =~ /^([[:digit:].]+)x([[:digit:].]+)$/) {
        $w = $1;
        $h = $2;
    } else {
        die "ERROR: Don't understand document geometry: [$vp]\n";
    }

    my $self = {margin=>$m, width=>$w, height=>$h, startx=>$startx, starty=>$starty, children=> []};
    bless $self, "SvgGen";
    $self->addChild(createSingle("title"))->addContent($title);
    return $self;
}

sub createComment {
    my ($comment) = @_;
    return bless {comments=>[$comment]}, "SvgGen";
}

sub createContent {
    my ($string)  = @_;
    return bless {content=>$string}, "SvgGen";
}

sub createGroup {
    my ($id, $class, $comments) = @_;
    return createMulti("g", {id=>$id, class=>$class}, $comments);
}

sub createShape {
    my ($shape, $attribs, $comments) = @_;
    return createSingle($shape, $attribs, undef, $comments);
}

sub createText {
    my ($content, $attribs) = @_;
    return createSingle("text", $attribs, $content);
}

sub createSingle {
    my ($tag, $attribs, $content, $comments) = @_;
    my $tmp = {tag=>$tag, a=>{%$attribs}};
    if (defined $comments) {
        $tmp->{comments} = [@$comments];
    }
    if(defined $content) {
        $tmp->{content} = $content;
    }
    return bless $tmp, "SvgGen";
}

sub createMulti {
    my ($tag, $attribs, $comments) = @_;
    my $tmp = {tag=>$tag, a=>{%$attribs}, children=>[]};
    if(defined $comments) {
        $tmp->{comments} = [@$comments];
    }
    return bless $tmp, "SvgGen";
}

sub createBlank {
    return bless {prebr=>1}, "SvgGen";
}

sub addChild {
    my ($parent, $child) = @_;
    push @{$parent->{children}}, $child;
    return $child;
}

sub addContent {
    my ($parent, $content) = @_;
    $parent->{content} = "" if !defined $parent->{content};
    $parent->{content} .= $content;
    return $content;
}

1;
