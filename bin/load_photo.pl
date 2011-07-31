#!/usr/bin/perl
use strict;
use warnings;
use File::Find;
use DBI;
use autodie;

my $dbh = DBI->connect( "dbi:SQLite:data/photo.sqlite",
  '', '', { RaiseError => 1, PrintError => 0, AutoCommit => 0 } );

$dbh->do("delete from photo");
my $sth = $dbh->prepare("insert into photo (dir, img) values (?,?)");

chdir qq{public/images};
find( \&wanted, qq{photo} );

$dbh->commit;
$dbh->disconnect;
exit;

sub wanted {
  my $file = $_;
  return if $file !~ /\.jpg$/;
  return if $file =~ /^thumb_/;
  my $dir = $File::Find::dir;
  $sth->execute( $dir, $file );
}

