use 5.006;
use strict;
use warnings;
use ExtUtils::MakeMaker;

WriteMakefile(
  NAME             => 'DBIx::SimpleMigration',
  AUTHOR           => 'Cameron Daniel <cdaniel@cpan.org>',
  VERSION_FROM     => 'lib/DBIx/SimpleMigration.pm',
  LICENSE          => 'mit',
  MIN_PERL_VERSION => '5.10.0',
  CONFIGURE_REQUIRES => {
    'ExtUtils::MakeMaker' => 0,
  },
  BUILD_REQUIRES => {
    'Test::More' => 0,
    'DBI' => 0,
    'DBD::SQLite' => 0
  },
  PREREQ_PM => {
    'SQL::SplitStatement'       => 0
  },
  dist  => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
  clean => { FILES => 'DBIx-SimpleMigration-1.0.tar.gz' },
);
