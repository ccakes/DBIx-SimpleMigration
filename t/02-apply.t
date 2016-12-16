#!/usr/bin/env perl

use strict;
use warnings FATAL => 'all';

use DBI;
use DBIx::SimpleMigration;
use File::Temp 'tempdir';

use Test::More tests => 2;

#################################
## Set up
my $tmp = tempdir(CLEANUP => 1);
BAIL_OUT('Error creating temp directory') unless -d $tmp;

open F1, '>', $tmp . '/01.sql' or BAIL_OUT('Error creating temp file');
open F2, '>', $tmp . '/02.sql' or BAIL_OUT('Error creating temp file');

print F1 <<EOL;
create table aabb (id int primary key not null, name text not null);
EOL

print F2 <<EOL;
create table ccdd (id int primary key not null, name text not null);
EOL

close F1;
close F2;
#################################

my $dbh = DBI->connect('dbi:SQLite:dbname=:memory:');
my $migration = DBIx::SimpleMigration->new(
  dbh => $dbh,
  source => $tmp
);

#diag explain $migration; BAIL_OUT();

isa_ok $migration, 'DBIx::SimpleMigration', 'DBIx::SimpleMigration->new returns blessed object';
eval { $migration->apply };
is $@, '', 'No errors detected';

diag 'Error: $@' if $@ and BAIL_OUT();
