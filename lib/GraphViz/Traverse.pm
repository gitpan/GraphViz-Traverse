package GraphViz::Traverse;
#
# $Id: Traverse.pm,v 1.4 2006/03/06 01:23:03 gene Exp $
#
our $VERSION = '0.00_2';
use strict;
use warnings;
use base qw( GraphViz );
use Carp;

sub new {
    my( $class, %args ) = @_;
    my $proto = ref( $class ) || $class;
    my $self = $class->SUPER::new( %args );
    bless $self, $class;
    $self->_init();
    return $self;
}

sub _init {
    my $self = shift;

    # Pre-declare the node and edge methods as closures.
    no strict 'refs';
    for my $key ( qw(
        color
        distortion
        fillcolor
        fixedsize
        fontcolor
        fontname
        fontsize
        height
        href
        label
        layer
        orientation
        peripheries
        regular
        shape
        sides
        skew
        style
        target
        tooltip
        URL
        width
    ) ) {
        $self->{_node_attributes}{$key} = undef;
        *{ 'node_' . $key } = sub { return $_[0]->{$key} }
    }

    for my $key ( qw(
        arrowhead
        arrowsize
        arrowtail
        color
        constraint
        decorate
        dir
        fontcolor
        fontname
        fontsize
        headURL
        headclip
        headhref
        headlabel
        headtarget
        headtooltip
        href
        label
        labelangle
        labeldistance
        layer
        minlen
        port_label_distance
        samehead
        sametail
        style
        tailURL
        tailclip
        tailhref
        taillabel
        tailtooltip
        target
        tooltip
        URL
        weight
    ) ) {
        $self->{_edge_attributes}{$key} = undef;
        *{ 'edge_' . $key } = sub { return $_[0]->{$key} };
    }
}

sub AUTOLOAD {
    our $AUTOLOAD;
    my( $self, $value ) = @_;
    my( $type, $key ) = $AUTOLOAD =~ /::(node|edge)_(\w+)$/;
    return unless $type;
    return $self->{$key};
}

sub mark_item {
    my( $self, $node, $parent ) = @_;
    if( $parent ) {
        $self->add_edge( $parent => $node,
            $self->build_attributes( $node, $parent )
        );
    }
    else {
        $self->add_node( $node, $self->build_attributes( $node ) );
    }
}

sub build_attributes {
    my( $self, $A, $B ) = @_;
    # Are we an edge or are we a node?
    my $type = $B ? 'edge' : 'node';
    my %attributes = ();
    # Loop over each object attribute.
    for my $attr ( keys %{ $self->{ '_'. $type .'_attributes' } } ) {
        # Construct the appropriate type method.
        my $method = $type .'_'. $attr;
        # ..and then call it.
        $attributes{$attr} = $B
            ? $self->$method( $A => $B )
            : $self->$method( $A );
    }
    # Return the hash of evaluated attributes.
    return wantarray ? %attributes : \%attributes;
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
constructor, that code is used to traverse, otherwise
C<File::Find::find()> is used.

=head1 PRIVATE METHODS

=head2 _init

  $obj->_init();

Initialize the GraphViz::Traverse instance.

=head1 TO DO

Document this code.

=head1 COPYRIGHT

Copyright 2006, Gene Boggs, All Rights Reserved

=head1 LICENSE

You may use this module under the license terms of the parent
L<GraphViz> package.

=head1 AUTHOR

Gene Boggs E<lt>gene@cpan.orgE<gt>

=cut
