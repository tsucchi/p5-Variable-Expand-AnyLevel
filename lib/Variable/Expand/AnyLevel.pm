package Variable::Expand::AnyLevel;
use parent qw(Exporter);
use strict;
use warnings;
our $VERSION = '0.01';
our @EXPORT_OK = qw(expand_variable expand_variable_all);
use PadWalker qw(peek_my);
use Scalar::Util qw(blessed);

=head1 NAME

Variable::Expand::AnyLevel - expand variables exist at any level.

=head1 SYNOPSIS

  use Variable::Expand::AnyLevel qw(expand_variable);
  my $value1 = 'aaa';
  my $value2 = expand_variable('$value1', 0);
  # $value2 is 'aaa';

=head1 DESCRIPTION

Variable::Expand::AnyLevel enables to expand variables which exist at any level. (level means same as Carp or PadWalker)

=cut

=head1 FUNCTIONS

=cut

=head2 expand_variable($string, $peek_level, $options_href)

Expand variable in $string which exists in $peek_level. $peek_level is same as caller().
Object(blessed reference) is not expanded, if you wish to do so, use expand_variable_all().

If $string contains no variable character, $string is colletly expanded. For example,

  my $aa = 'aa';
  my $result = $expand_variable('$aa 123', 0);

$result is expanded 'aa 123'

available options are as follows

stringify: stringify variable(1) or not(0). default value is 1

=cut

sub expand_variable {
    my ($string, $peek_level, $options_href) = @_;

    return _do_expand_variable($string, $peek_level+1, 0, $options_href);
}

=head2 expand_variable_all($variable, $peek_level)

expand variable in $variable which exists in $peek_level. $peek_level is same as caller().
Object(blessed reference) is also expanded.

Note that first parameter is not '$string'. it's '$variable'.
non-variable character in $variable is not expanded collectly. For example, 

  my $aa = SomeObj->new();
  my $result1 = $expand_variable('$aa->method1() 123', 0); # not expanded
  my $result2 = $expand_variable('$aa->method1()', 0);     # expanded

$result2 is expanded(if method1() is sufficiently implemented), but $result1 is not expanded.

=cut

sub expand_variable_all {
    my ($string, $peek_level, $options_href) = @_;

    return _do_expand_variable($string, $peek_level+1, 1, $options_href);
}

sub _do_expand_variable {
    my ($string, $peek_level, $all_flg, $options_href) = @_;

    my $walker = peek_my($peek_level + 1);
    my $value = undef;
    my $variable_gen_code = "sub {\n";
    $variable_gen_code .= "  no warnings 'all';\n";

    my %values = ();
    for my $variable_name ( keys %{ $walker } ) {
        my $sigil = substr $variable_name, 0, 1;
        next if ( !$all_flg && $sigil eq '$' && blessed( ${ $walker->{$variable_name} }) ); #exclude object if $all_flg doesn't specified.
        $values{$variable_name} = $walker->{$variable_name};
        $variable_gen_code .= "  my $variable_name = ${sigil}{ \$values{ '$variable_name' } };\n";
    }
    my $stringify = defined $options_href->{stringify} ? $options_href->{stringify} : 1;
    if ( $all_flg || !$stringify ) {
        $variable_gen_code .= "  return $string;\n";
    }
    else {
        $variable_gen_code .= "  return \"$string\";\n";
    }
    $variable_gen_code .= "}->()\n";
    #warn $variable_gen_code; use Data::Dumper; warn Dumper(\%values);
    ## no critic
    eval "\$value = $variable_gen_code";
    ## use critic
    return $value;
}


1;
__END__


=head1 AUTHOR

Takuya Tsuchida E<lt>tsucchi@cpan.orgE<gt>

=head1 SEE ALSO

L<PadWalker>

=head1 COPYRIGHT AND LICENSE

Copyright (c) 2011 Takuya Tsuchida

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
