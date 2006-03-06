#!/usr/bin/perl
use strict;
use warnings;
use Test::More 'no_plan';#tests => 1;

use lib 'lib';
use_ok 'GraphViz::Traverse';

my $obj = eval { GraphViz::Traverse->new };
warn $@ if $@;
isa_ok $obj, 'GraphViz::Traverse';

ok $obj->{_node_attributes}, 'node attributes defined';
for( keys %{ $obj->{_node_attributes} } ) {
    can_ok $obj, 'node_' . $_;
}
ok $obj->{_edge_attributes}, 'edge attributes defined';
for( keys %{ $obj->{_edge_attributes} } ) {
    can_ok $obj, 'edge_' . $_;
}
