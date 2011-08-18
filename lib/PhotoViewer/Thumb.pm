package PhotoViewer::Thumb;
use strict;
use warnings;
use File::Find;
use Imager;

my $thumb_size = 160;

sub walk_thumbmake {
  my $file       = $_;
  my $thumb_name = thumbmake($file);
  print STDERR "save $thumb_name\n";
}

sub thumbmake {
  my $file = shift;
  return if $file =~ /^thumb_/;
  return unless $file =~ /\.jpg$/;
  return if -f "thumb_$file";
  return unless -f $file;

  my $img    = Imager->new( file => $file );
  my $width  = $img->getwidth();
  my $height = $img->getheight();
  my $scale
      = $width > $height
      ? $thumb_size / $width
      : $thumb_size / $height;
  my $thumb = $img->scale( scalefactor => $scale );

  # $thumb->filter( type => 'autolevels' );
  $thumb->write( file => "thumb_$file" );
  return "thumb_$file";
}

sub walk {
  my $dir = shift;
  find( { wanted => \&walk_thumbmake, }, $dir );
}

1;
