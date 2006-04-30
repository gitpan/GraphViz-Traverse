package GraphViz::Traverse::Filesystem;
our $VERSION = 0.01;
use strict;
use warnings;
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
        warn "$node -> $path + $_\n\tL> $parent + $name\n"
            if $self->{_DEBUG};
        $self->mark_item( $node, $path );
    };
    File::Find::find( $flag_item, $root ); 
    return 1;
}

1;

__END__

=head1 NAME

GraphViz::Traverse::Filesystem - Graph a filesystem

=head1 SYNOPSIS

  use GraphViz::Traverse::Filesystem;
  my $g = GraphViz::Traverse::Filesystem->new() or die $!;
  $g->traverse('.');
  print $g->as_debug();

=head1 DESCRIPTION

A C<GraphViz::Traverse::Filesystem> object provides methods to traverse a
file system and render it with C<GraphViz>.

Inherit this module to define and use custom B<node_*> and B<edge_*>
methods.

=head1 PUBLIC METHODS

=head2 traverse

  $g->traverse($root);

Traverse a file system starting at the given root path and populate
the C<GraphViz> object with file nodes-and path-edges.

=head1 SEE ALSO

L<GraphViz>

L<GraphViz::Traverse>

=head1 COPYRIGHT

Copyright 2006, Gene Boggs, All Rights Reserved

=head1 LICENSE

You may use this module under the license terms of the parent
L<GraphViz> package.

=head1 AUTHOR

Gene Boggs E<lt>gene@cpan.orgE<gt>

=cut
