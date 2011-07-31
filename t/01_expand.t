#!/usr/bin/perl -w
use strict;
use warnings;
use Test::More;

use Variable::Expand::AnyLevel qw(expand_variable expand_variable_all);
use t::Obj;

my $value = 'value';
is( expand_variable('$value aaa', 0), 'value aaa');
#is( expand_variable_all('$value aaa', 0), 'value aaa');


my @array_values = (
    'AAA',
    'BBB',
);
is( expand_variable('$array_values[0]', 0), 'AAA');
is( expand_variable('$array_values[1]', 0), 'BBB');

is( expand_variable_all('$array_values[0]', 0), 'AAA');
is( expand_variable_all('$array_values[1]', 0), 'BBB');

my %hash_value = (
    AAA => '111',
    BBB => '222',
);
is( expand_variable('$hash_value{AAA}', 0), '111');
is( expand_variable('$hash_value{BBB}', 0), '222');
is( expand_variable_all('$hash_value{AAA}', 0), '111');
is( expand_variable_all('$hash_value{BBB}', 0), '222');


is( expand_variable('$hash_value{$array_values[0]}', 0), '111');
is( expand_variable_all('$hash_value{$array_values[0]}', 0), '111');

my $obj = t::Obj->new();
is( expand_variable('$obj->aaa()', 0), undef);     # not expanded.
is( expand_variable_all('$obj->aaa()', 0), '111'); # expanded

test_for_level();

sub test_for_level {
    local $Test::Builder::Level = $Test::Builder::Level + 1;
    is( expand_variable('$value', 1), 'value');#level is up
}


done_testing();