package Bit::Vector::Named;

use strict;
use warnings;
use Carp;
use Bit::Vector;
use vars qw($VERSION $AUTOLOAD);
$VERSION = '0.01_01';


=head1 NAME

Bit::Vector::Named - Named bit vectors

=head1 DESCRIPTION

Allows user-defined labels to be used to describe bit vectors.
Derived from Bit::Vector.

=head1 SYNOPSIS

use Bit::Vector::Named;
my $labels = {
	'read' => 1,
	'write' => 2,
	'execute' => 4,
	'rw' => 3,
	'all4' => 15,
};
my $vector = new Bit::Vector::Named(size => 8, labels => $labels);

	$vector->set('all4');
	unless($vector->has('rw')) { print "bizzare vector math!" }

=head1 METHODS

=over 4

=item B<new>

my $labels = {
	'read' => 1,
	'write' => 2,
	'execute' => 4,
	'rw' => 3,
	'all4' => 15,
};
my $vector = new Bit::Vector::Named(size=>16, labels => $labels);

Creates a new bit vector of size size. The 'labels' argument takes a 
reference to a hash of names and corresponding values, which are then 
used as aliases for those values. Size is rounded up to a multiple of 8.

=cut

sub new {
    my ($class, %args) = @_;
    my $self = {};
    bless $self, $class;
    # check labels hashref for bounds of values and adjust vec size
    $args{size} = 8 unless($args{size} and $args{size} > 7);
	my $maxnum = 1 << 8;
	if($args{labels}) {
		foreach my $name(keys %{$args{labels}}) {
			$maxnum = $args{labels}->{$name} 
				if($maxnum < $args{labels}->{$name});
		}
		my $numbits = 8;
		while($maxnum > (1 << $numbits)) { ++$numbits }
		$args{size} = $numbits;
	}
    $self->{size} = int( ($args{size} + 7) / 8 ) * 8;
    # load the underlying vector object (use relationship)
    $self->{vector} = new Bit::Vector($self->{size});
    $self->{labels} = ( $args{labels} ) ? $args{labels} : {};
    return $self;
}

=item B<set>

$vector->set('rw');

Sets the vector bits corresponding to those set in the named argument. 
If the argument is not a label hash key, assumes the argument is a numeric
decimal literal and passes it to the underlying Bit::Vector.

=cut

sub set {
	my($self, $name_or_pos, $value) = @_;
	my $val = $self->{labels}->{$name_or_pos};
	$val = $name_or_pos unless defined $val;
	$self->{vector}->Or( $self->{vector}, 
		Bit::Vector->new_Dec($self->{size}, $val) );
	return $self;
}

=item B<clear>

$vector->clear('read');

Clears the vector bits corresponding to those set in the named argument.
If the argument is not a label hash key, assumes the argument is a numeric
decimal literal and passes it to the underlying Bit::Vector.

=cut

sub clear {
	my($self, $name_or_pos, $value) = @_;
	my $val = $self->{labels}->{$name_or_pos};
	$val = $name_or_pos unless defined $val;
	$self->{vector}->AndNot( $self->{vector}, 
		Bit::Vector->new_Dec($self->{size}, $val) );
	return $self;
}

=item B<is>

if( $vector->is('w') ) { print "The vector equals 2." }

Returns true if the vector equals the value of the label argument.
If the argument is not a label hash key, assumes the argument is a numeric
decimal literal and passes it to the underlying Bit::Vector.

=cut

sub is {
	my ($self, $named_val) = @_;
	my $val = $self->{labels}->{$named_val};
	$val = $named_val unless defined $val;
	my $vc = Bit::Vector->new_Dec($self->{size}, $val);
	if($self->{vector}->equal($vc)) { return 1 } else {	return }
}

=item B<has>

unless($vector->has('r') { print "Vector 1 bit not set." }

Returns true if the vector contians the bit pattern given by the argument.
If the argument is not a label hash key, assumes the argument is a numeric
decimal literal and passes it to the underlying Bit::Vector.

=cut

sub has {
	my($self, $named_val) = @_;
	my $val = $self->{labels}->{$named_val};
	$val = $named_val unless defined $val;
	my $vc1 = Bit::Vector->new_Dec($self->{size}, $val);
	my $vc2 = $self->{vector}->Clone;
	$vc2->And($vc1, $vc2);
	if( $vc2->equal($vc1) ) { return 1 } else { return }
}

=item B<equal>

if($vec1->equal($vec2)) { do_stuff() }

returns true if $vec1 is equal to $vec2

=cut

sub equal {
	my($self, $vec2) = @_;
	return ($self->{vec}->equal($vec2->{vec}));
}

=item B<Clone>

my $vec2 = $vector->Clone();

Copying constuctor.

=cut

sub Clone {
	my $self = shift;
	my $newvec = new Bit::Vector::Named( 
		size => $self->{size}, labels => $self->{labels} );
	$newvec->{vector} = $self->{vector}->Clone;
	return $newvec;
}

=item B<Other methods>

Functionally, if not via the usual mechanisms, this class is a derived 
from Bit::Vector. The package will therefore pass method calls it does
not overload to the base class for processing. This means a bad function 
call may die as a call to Bit::Vector, with error messages from that package.

=cut

sub AUTOLOAD {
	my ($self, $arg1, $arg2) = @_;
	my($vector, $bvec1, $bvec2, $method, $retval, $evalstr);
	$vector = $self->{vector};
	$bvec1 = $arg1->{vector} if(defined $arg1);
	$bvec2 = $arg2->{vector} if(defined $arg2);
	$AUTOLOAD =~ m/.+::.+::.+::(.+)/;
	$method = $1;
	$evalstr = '$retval = $vector->' . $method;
	if(defined $bvec2) { $evalstr .= '($bvec1, $bvec2);' }
	elsif(defined $bvec1) { $evalstr .= '($bvec1);' }
	else { $evalstr .=';' }
	eval $evalstr;
	return $retval;
}

sub DESTROY {}

=back

=head1 SEE ALSO

=over 4

=item B<Bit::Vector>

=back

=head1 AUTHOR

William Herrera (wherrera@skylightview.com)

=head1 SUPPORT

Questions, feature requests and bug reports should go to wherrera@skylightview.com

=head1 COPYRIGHT

     Copyright (C) 2004 William Hererra.  All Rights Reserved.

This module is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

=cut

1;

