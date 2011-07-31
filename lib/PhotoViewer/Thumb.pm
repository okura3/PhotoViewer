package PhotoViewer::Thumb;
use strict;
use warnings;
use File::Find;
use Imager;

my $thumb_size = 160;

sub thumbmake {
  my $file = $_;
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
  print STDERR "save thumb_$file\n";
}

sub walk {
  my $dir = shift;
  find( { wanted => \&thumbmake, }, $dir );
}

1;
