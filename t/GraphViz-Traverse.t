BEGIN {
    use strict;
    use Test::More 'no_plan';#tests => 1;
    use_ok 'GraphViz::Traverse';
}

my $obj = eval { GraphViz::Traverse->new };
warn $@ if $@;
isa_ok $obj, 'GraphViz::Traverse';

__END__
my %args = ();
$obj = eval {
    GraphViz::Traverse->new(%args);
};
warn $@ if $@;
isa_ok $obj, 'GraphViz::Traverse';
