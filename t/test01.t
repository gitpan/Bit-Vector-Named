# t/test01.t - check module load and run

use Test::More tests => 15;

BEGIN { use_ok( 'Bit::Vector::Named' ); }

my $labels = {
	'nil' => 0,
	'read' => 1,
	'write' => 2,
	'execute' => 4,
	'own' => 8,
	'rw' => 3,
	'weo' => 14,
	'all4' => 15,
};

my $vector = new Bit::Vector::Named(size => 16, labels => $labels);

isa_ok($vector, 'Bit::Vector::Named');

ok($vector->set('all4'), "Set bits");
ok($vector->has('rw'), "Check has" );
ok($vector->is('all4'), "Check is");
$vector->clear('read');
ok(!$vector->has('read'), "Check clear");
ok($vector->is('weo'), "Check is again");
my $vec2 = $vector->Clone;
my $vec3 = $vec2->Clone;
$vec3->set(31);
ok($vec2->equal($vector), "Check equals");
ok(! $vec2->equal($vec3), "Check equals not");
ok($vec3->has('all4'), "Check has with alternate initialization");
ok($vec2->is('weo'), "Check the copy");
my $vec4 = new Bit::Vector::Named(size => 16, labels => $labels);
$vec2->And($vec2, $vec4);
ok($vec2->is('nil'), "Check after passthrough to Bit::Vector");
ok($vector->is('weo'), "Check original for no side effects");
ok($vector->to_Enum eq '1-3', "Check for passthrough stringification");
ok(join(" ", sort keys %{$vector->to_Hash()}) eq 'execute nil own weo write', 
	"Test hash stringification");
