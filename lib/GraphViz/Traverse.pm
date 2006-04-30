package GraphViz::Traverse;
#
# $Id: Traverse.pm,v 1.7 2006/04/30 06:03:17 gene Exp $
#
use strict;
use warnings;
use base qw( GraphViz );
use Carp;
our $VERSION = '0.01';
our $AUTOLOAD;

sub new {
    my( $proto, %args ) = @_;
    my $class = ref( $proto ) || $proto;
    my $self = $proto->SUPER::new( %args );

    $self->{_DEBUG} = $args{_DEBUG};

    $self->{_attributes} = {
        ( map { 'node_' . $_ => undef } qw(
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
        ) ),
        ( map { 'edge_' . $_ => undef } qw(
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
        ) )
    };

    bless $self, $class;
    return $self;
}

sub DESTROY {}

sub AUTOLOAD {
    my $self = shift;
    my $type = ref( $self ) || croak "$self is not an object";
    ( my $method = $AUTOLOAD ) =~ s/.*://;
    my $superior = "SUPER::$method";
    return exists $self->{_attributes}{$method}
        ? undef : $self->$superior(@_);
}

sub build_attributes {
    my( $self, $A, $B ) = @_;
    my $type = $B ? 'edge' : 'node';
    my %attributes = ();
    for my $method ( keys %{ $self->{_attributes} } ) {
        $self->{_attributes}{$method} = $B
            ? $self->$method( $A => $B )
            : $self->$method( $A );
    }
    return %{ $self->{_attributes} };
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

sub traverse {
    my $self = shift;
    warn "traverse() must be overridden.\n" if $self->{_DEBUG};
    return undef;
}

1;

__END__

=head1 NAME

GraphViz::Traverse - Build a GraphViz object via callback traversal

=head1 SYNOPSIS

  # Base class for GraphViz traversal modules.

=head1 DESCRIPTION

A C<GraphViz::Traverse> object represents a base class for inheriting
by other traversal modules.

=head1 PUBLIC METHODS

=head2 new

  my $g = GraphViz::Traverse->new($arguments);

Return a new GraphViz::Traverse instance.

=head2 mark_item

  $g->mark_item( $node );
  $g->mark_item( $child, $parent );

Add a node or an edge to the C<GraphViz::Traverse> object.  This
method is to be used by the C<traverse> method.

=head2 traverse

  $g->traverse($root);

Traverse a structure starting at a given root node.  This method is to
be overridden by an inheriting class with specific traversal actions.

=head1 TO DO

Document this code better.

=head1 THANK YOU

Brad Choate E<lt>bchoate@cpan.orgE<gt> for untangling my AUTOLOADing.

=head1 SEE ALSO

L<GraphViz>

L<GraphViz::Traverse::Filesystem>

=head1 COPYRIGHT

Copyright 2006, Gene Boggs, All Rights Reserved

You may use this module under the license terms of the parent
L<GraphViz> package.

=head1 AUTHOR

Gene Boggs E<lt>gene@cpan.orgE<gt>

=cut
