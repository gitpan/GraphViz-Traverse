package GraphViz::Traverse;
#
# $Id: Template.pm,v 1.2 2004/05/23 07:58:46 gene Exp $
#
our $VERSION = '0.00_1';
use strict;
use warnings;
use base qw( GraphViz );
use Carp;
use File::Basename;
use File::Find;

our $AUTOLOAD;
sub AUTOLOAD {
    my $self = shift;
    my $type = ref($self) or croak "$self is not an object";

    my $name = $AUTOLOAD;
    $name =~ s/.*://;   # strip fully-qualified portion
    croak "Can't access '$name' field in class $type"
        unless exists $self->{_node_attributes}{$name}
            || exists $self->{_edge_attributes}{$name};

    return @_ ? $self->{$name} = shift : $self->{$name};
}

sub new {
    my $class = shift;
    my $self = $class->SUPER::new( @_ );
    bless $self, $class;
    $self->_init();
    return $self;
}

sub _init {
    my $self = shift;
    # XXX Get these attributes automatically, from GraphViz itself.
    $self->{_node_attributes} = {
        fillcolor => undef,
        height => undef,
        label => undef,
        peripheries => undef,
        style => undef,
        width => undef,
        tooltip => undef,
    };
    $self->{_edge_attributes} = {
        color => undef,
    };
}

sub traverse {
    my $self = shift;
    my $root = shift || '.';

    # Use the OO F::F here, instead of trying to be strict with $self.
    my $flag_item = sub {
        return if $_ eq '.';

        # Parse-out node name (and parent).
        my $node = $File::Find::name;
        my( $name, $path ) = fileparse( $node );
        $path =~ s/\S$//;
        my $parent = fileparse( $path );
        warn "$node -> $path + $_\n\tL> $parent + $name\n";

        $self->add_node( $node,
            $self->build_attributes( $node )
        );
        $self->add_edge( $path => $node,
            $self->build_attributes( $path => $node )
        );
    };

    # Call our user-defined method, if it exists. Otherwise assume we
    # are traversing a file system.
    exists $self->{callback}
        ? $self->callback( $flag_item, $root )
        : File::Find::find( $flag_item, $root ); 
}

sub build_attributes {
    my( $self, $A, $B ) = @_;

    my $type = $B ? 'edge' : 'node';

    my %attributes = ();

    for my $attr ( keys %{ $self->{'_'. $type .'_attributes'} } ) {
        if( $B ) {
            # Call the apropriate edge method.
            my $method = $type .'_'. $attr;
            $attributes{$attr} = $self->$method( $A => $B );
        }
        else {
            # Call the apropriate node method.
            my $method = $type .'_'. $attr;
            $attributes{$attr} = $self->$method( $A );
        }
    }

    return wantarray ? %attributes : \%attributes;
}

######################################################################
# Default attribute subroutines.
sub node_label {
#    my( $self, $node ) = @_;
    return '';
}
sub node_height { return 0.4 }
sub node_style { return 'filled' }
sub node_width { return 0.4 }
sub node_tooltip {
    my $self = shift;
    return shift;   # Hand back the node, which is the current path.
}
sub node_peripheries {
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
sub edge_color {
#    my( $self, $parent, $child ) = @_;
    return 'gray';
}

1;

__END__

=head1 NAME

GraphViz::Traverse - This package has some purpose 

=head1 SYNOPSIS

  use GraphViz::Traverse;

=head1 DESCRIPTION

A GraphViz::Traverse object represents ...

=head1 PUBLIC METHODS

=head2 new

  my $g = GraphViz::Traverse->new($arguments);

Return a new GraphViz::Traverse instance.

=head2 traverse

  $g->traverse($root);

Traverse a tree with C<GraphViz>.  If a callback is provided in the
constructor, that code is used to traverse, otherwise C<File::Find> is
used.

=head1 PRIVATE METHODS

=head2 _init

  $obj->_init();

Initialize the GraphViz::Traverse instance.

=head1 TO DO

Document this code.

Autoload the top level graph attributes as well as the nodes and edges.

=head1 COPYRIGHT

Copyright 2006, Gene Boggs, All Rights Reserved

=head1 LICENSE

You may use this module under the terms of the BSD, Artistic, or GPL 
licenses, any version.

=head1 AUTHOR

Gene Boggs E<lt>gene@cpan.orgE<gt>

=cut
