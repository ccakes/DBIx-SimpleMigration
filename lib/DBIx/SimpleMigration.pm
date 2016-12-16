package DBIx::SimpleMigration;

use 5.10.0;
use strict;
use warnings;

use Carp;
use File::Basename;

use DBIx::SimpleMigration::Client;
use DBIx::SimpleMigration::Migration;

our $VERSION = '1.0';

sub new {
  my $self = bless {}, shift;
  return unless @_ % 2 == 0;
  my %args = @_;

  croak __PACKAGE__ . '->new: dbh option missing or not a DBI object'
    unless ($args{dbh} && ref($args{dbh}) eq 'DBI::db');

  confess __PACKAGE__ . '->new: source dir missing or does not exist'
    unless ($args{source} && -d $args{source});

  $self->{_source} = $args{source};

  my %options = (
    migrations_table => 'migrations',
    migrations_schema => 'simplemigration',
  );

  if ($args{options}) {
    # http://stackoverflow.com/questions/350018/how-can-i-combine-hashes-in-perl
    @options{keys %{$args{options}}} = values %{$args{options}};
  }
  $self->{_options} = \%options;

  my $class = 'DBIx::SimpleMigration::Client::' . $args{dbh}->{Driver}->{Name};
  eval "require $class; $class->import";
  if ($@) {
    $class = 'DBIx::SimpleMigration::Client';
  }

  $self->{_client} = $class->new(
    dbh => $args{dbh}->clone({
      AutoCommit => 0,
      RaiseError => 1
    }), # new handle with AutoCommit off
    options => \%options
  );

  return $self;
}

sub apply {
  my ($self) = @_;

  if (!$self->{_client}->_migrations_table_exists) {
    $self->{_client}->_create_migrations_table;
  }

  my $dir = $self->{_source};
  my @files = sort <$dir/*.sql>;

  my $applied_migrations = $self->{_client}->_applied_migrations;

  foreach my $file (@files) {
    my ($filename) = fileparse($file);
    next if exists $applied_migrations->{$filename};

    my $migration = DBIx::SimpleMigration::Migration->new(
      client => $self->{_client},
      file => $file
    );

    $migration->apply;
  }

  $self->{_client}->{dbh}->disconnect if $self->{_client}->{dbh};
}

1;
