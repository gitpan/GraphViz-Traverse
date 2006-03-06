package FileSystem;
$VERSION = 0.01;
use strict;
use warnings;
use lib 'lib';
use base qw( GraphViz::Traverse );
use File::Find;
use File::Basename;

sub node_label { return '' }

sub node_height { return 0.4 }

sub node_style { return 'filled' }

sub node_width { return 0.4 }

sub node_tooltip {
    my $self = shift;
    return shift;   # Just hand back the node, which is the current path.
}

sub node_peripheries {
    # If we are executable, then we get a ring.
    my $self = shift;
    $_ = shift;
    return !-d $_ && -x $_ ? 2 : 1;
}

sub node_fillcolor {
    my $self = shift;
    $_ = shift;
    return
        -d $_ ? 'snow' :
        # perl-ish things
        /\.pod$/ ? 'cadetblue' :
        /\.pm$/  ? 'cadetblue4' :
        /\.cgi$/ ? 'cadetblue3' :
        /\.pl$/  ? 'cadetblue2' :
        # "ordinary" files
        /(?:readme|install|todo|faq|change|bugs)/i ? 'goldenrod' :
        /\.conf$/      ? 'gold' :
        /(?:\.|_)log$/ ? 'gold3' :
        /\.txt$/       ? 'gold4' :
        # html and friends
        /\.css$/   ? 'plum' :
        /\.html?$/ ? 'plum3' :
        /\.tm?pl$/ ? 'plum4' :
        # javascript
        /\.js$/ ? 'salmon' :
        # php
        /\.php$/ ? 'seagreen' :
        # images
        /\.jpe?g$/ ? 'orchid4' :
        /\.gif$/   ? 'orchid3' :
        /\.png$/   ? 'orchid1' :
        # archives
        /\.tar.gz$/ ? 'red3' :
        /\.tgz$/    ? 'red2' :
        /\.zip$/    ? 'red1' :
        /\.dump$/   ? 'pink' :
#        /\.$/ ? '' :
        'yellow';
}

sub edge_color { return 'gray' }

sub traverse {
    my( $self, $root ) = @_;
    my $flag_item = sub {
        return if $_ eq '.';
        my $node = $File::Find::name;
        my( $name, $path ) = File::Basename::fileparse( $node );
        $path =~ s/\S$//;
        my $parent = File::Basename::fileparse( $path );
        warn "$node -> $path + $_\n\tL> $parent + $name\n";
        $self->mark_item( $node, $path );
    };
    File::Find::find( $flag_item, $root ); 
}

1;
