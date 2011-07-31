#!/usr/bin/perl
use strict;
use warnings;
use Getopt::Long;
use lib qw/lib/;
use PhotoViewer::Thumb;

my $dir = "public/images/photo";
my $result = GetOptions("dir=s" => \$dir);

PhotoViewer::Thumb::walk( $dir );

1;
