package Database::ManagedHandleConfigTest;
use strict;
use warnings;

use Moo;
use File::Temp qw( tempfile );

has config => (
    is => 'ro',
    default => sub {
        my ($fh, $filepath) = tempfile(SUFFIX => q{.sq3}, UNLINK => 1);
        return {
            default => q{db1},
            databases => {
                db1 => {
                    dsn => "dbi:SQLite:uri=file:$filepath?mode=rwc",
                },
                db2 => {
                    dsn => "dbi:SQLite:uri=file:${filepath}_2?mode=rwc",
                },
            },
        };
    },
);

1;
