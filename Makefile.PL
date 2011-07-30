use inc::Module::Install;
name     'Variable-Expand-AnyLevel';
all_from 'lib/Variable/Expand/AnyLevel.pm';

requires 'PadWalker';
requires 'parent';

tests    't/*.t';
author_tests 'xt';

test_requires 'Test::More';
auto_set_repository;
#auto_include;
WriteAll;
