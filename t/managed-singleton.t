#!perl
use strict;
use warnings;

use utf8;
use Test2::V0;
set_encoding('utf8');

use Data::Dumper;
use Scalar::Util 'refaddr';

# use Log::Any::Adapter ('Stdout', log_level => 'debug' );

use FindBin 1.51 qw( $RealBin );
use File::Spec;
my $lib_path;
BEGIN {
    $lib_path = File::Spec->catdir(($RealBin =~ /(.+)/msx)[0], q{.}, 'lib');
}
use lib "$lib_path";

BEGIN {
    {
package Database::ManagedHandleConfigTestLocal;
use strict;
use warnings;

use Moo;
use File::Temp qw( tempfile );

has config => (
    is => 'ro',
    default => sub {
        my ($fh_1, $filepath_1) = tempfile(SUFFIX => q{.sq3}, UNLINK => 1);
        my ($fh_2, $filepath_2) = tempfile(SUFFIX => q{.sq3}, UNLINK => 1);
        return {
            default => q{db1},
            databases => {
                db1 => {
                    dsn => "dbi:SQLite:uri=file:${filepath_1}?mode=rwc",
                    username => undef,
                    password => undef,
                    attr => {},
                },
                db2 => {
                    dsn => "dbi:SQLite:uri=file:${filepath_2}?mode=rwc",
                    username => undef,
                    password => undef,
                    attr => {},
                },
            },
        };
    },
);

1;
}
    ## no critic (Variables::RequireLocalizedPunctuationVars)
    $ENV{DATABASE_MANAGED_HANDLE_CONFIG} = 'Database::ManagedHandleConfigTestLocal';

    use Database::ManagedHandle;
}

# use DBI;

subtest 'Two local copies of ManagedHandle' => sub {
    # use Database::ManagedHandleConfigTest;
    # my $cfgtest = Database::ManagedHandleConfigTest->new();
    # diag Dumper $cfgtest->config;
    my $mh1 = Database::ManagedHandle->instance;
    my $dbh1 = $mh1->dbh();
    my $ary_ref = $dbh1->selectall_arrayref( 'SELECT 1' );
    # is( $ary_ref->[0]->[0], 1,
    #     '('.$test_db->driver.': '.$test_db->name.') '.'SELECT 1');
    is( $ary_ref->[0]->[0], 1, 'SELECT 1');
    my $mh2 = Database::ManagedHandle->instance();
    my $dbh2 = $mh2->dbh( 'db2' );
    my $dbh1_1 = $mh2->dbh( 'db1' );
    ok( refaddr($mh1) == refaddr($mh2), 'Managed handles are the same object' );
    ok( refaddr($dbh1) != refaddr($dbh2), 'Handles are not the same object' );
    ok( refaddr($dbh1) != refaddr($dbh1_1), 'Handles are the same object' );
    ok(1);
    done_testing;
};

use ManagedHandleTestInstance;

subtest 'ManagedHandle in a different file' => sub {
    my $mh1 = ManagedHandleTestInstance->new()->{'mh'};
    my $dbh1 = $mh1->dbh();
    my $ary_ref = $dbh1->selectall_arrayref( 'SELECT 1' );
    # is( $ary_ref->[0]->[0], 1,
    #     '('.$test_db->driver.': '.$test_db->name.') '.'SELECT 1');
    is( $ary_ref->[0]->[0], 1, 'SELECT 1');
    my $mh2 = Database::ManagedHandle->instance();
    my $dbh2 = $mh2->dbh( 'db2' );
    my $dbh1_1 = $mh2->dbh( 'db1' );
    ok( refaddr($mh1) == refaddr($mh2), 'Managed handles are the same object' );
    ok( refaddr($dbh1) != refaddr($dbh2), 'Handles are not the same object' );
    ok( refaddr($dbh1) != refaddr($dbh1_1), 'Handles are the same object' );
    ok(1);
    done_testing;
};

done_testing;
