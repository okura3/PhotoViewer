package PhotoViewer;
use strict;
use warnings;
use Dancer ':syntax';
use Dancer::Plugin::Ajax;
use Dancer::Plugin::DBIC;
use Dancer::Plugin::ProxyPath;
use PhotoViewer::Schema;
use PhotoViewer::Thumb;
use Digest::MD5 qw(md5_hex);
use File::Temp;
use File::Basename qw/basename fileparse/;
use Imager;
use HTML::Entities;
use Cwd qw/chdir getcwd/;

our $VERSION = '0.1';

get '/upload' => sub {
  template 'upload', { flush => qq{} }, { layout => undef, };
};

ajax '/upload' => sub {
  my $upload = upload('filename');
  my $filename = File::Temp::tempnam( 'public/images/photo', 'up' ) . '.jpg';
  my $thumb_name;
  unless ( -f $filename ) {
    $upload->link_to($filename);
    my $cwd = getcwd();
    chdir('public/images/photo');
    $thumb_name = PhotoViewer::Thumb::thumbmake( basename($filename) );
    chdir($cwd);
    schema->resultset('Photo')->create(
      { dir => "photo",
        img => basename($filename),
      }
    );
  }

  content_type "text/json";
  return to_json {
    path     => "images/photo/",
    filename => $thumb_name,
    img      => encode_entities(qq{<img src="images/photo/$thumb_name">})
  };
};

get '/' => sub {
  return redirect "/1";
};

get qr{^/(\d+)/?$} => sub {
  my ($page) = splat;
  my $rs
      = schema->resultset('Photo')
      ->search( {}, { order_by => { -asc => [qw/dir img/] }, rows => 10 }, )
      ->page($page);
  my @entries = $rs->all();
  template 'index', { entries => \@entries, pager => $rs->pager, };
};

get qr{^/(\d+)/(\d+)/?} => sub {
  my ( $page, $offset ) = splat;
  $page   //= 1;
  $offset //= 0;
  my $rs
      = schema->resultset('Photo')
      ->search( {}, { order_by => { -asc => [qw/dir img/] }, rows => 10 }, )
      ->page($page);
  my $pager = $rs->pager;
  if ( $page >= $pager->last_page ) {
    $page = $pager->last_page;
  }
  $rs = $rs->page($page);
  if ( $offset >= $pager->entries_on_this_page - 1 ) {
    $offset = $pager->entries_on_this_page - 1;
  }
  my @entries = $rs->all();
  my $ent     = $entries[$offset];
  my $dir     = $ent->dir;
  my $img     = $ent->img;

  my $next;
  if ( $offset >= $pager->entries_on_this_page - 1 ) {
    if ( $page == $pager->last_page ) {
      $next->{offset} = $pager->entries_on_this_page - 1;
      $next->{page}   = $pager->last_page;
    }
    else {
      $next->{offset} = 0;
      $next->{page}   = $page + 1;
    }
  }
  else {
    $next->{offset} = $offset + 1;
    $next->{page}   = $page;
  }

  my $prev;
  if ( $offset == 0 ) {
    if ( $page == 1 ) {
      $prev->{page}   = 1;
      $prev->{offset} = 0;
    }
    else {
      $prev->{page}   = $page - 1;
      $prev->{offset} = 9;
    }
  }
  else {
    $prev->{page}   = $page;
    $prev->{offset} = $offset - 1;
  }
  template 'page',
      {
    dir   => $dir,
    img   => $img,
    index => { page => $page },
    prev  => {%$prev},
    nexti => {%$next},
      };
};

get qr{^/slide/?} => sub {
  template 'slide';
};

true;
