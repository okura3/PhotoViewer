package PhotoViewer;
use strict;
use warnings;
use Dancer ':syntax';
use DBI;
use Data::Page;
use PhotoViewer::Schema;
use PhotoViewer::Thumb;
use Digest::MD5 qw(md5_hex);
use File::Temp;
use File::Basename qw/basename fileparse/;
use Imager;
use HTML::Entities;
use Cwd qw/chdir getcwd/;

our $VERSION = '0.1';

sub debug_dump {
  my @data = @_;
  use Data::Dumper;
  my @caller = caller(1);
  my $debug = Data::Dumper->Dump([ \@caller, \@data ] );
  open my $debugf, ">>", "/tmp/photoviewer.txt" or die;
  print $debugf $debug, "\n";
  close $debugf;
}

my $dbh;
my $entries_per_page = 10;

sub connect_db {
  $dbh = DBI->connect("dbi:SQLite:dbname=".setting('database')) or
     die $DBI::errstr;
  return $dbh;
}

sub pager {
  my $current_page = shift;
  my ($total_entries) = $dbh->selectrow_array(
    q/select count(*) from photo/
  );
  my $page = Data::Page->new();
  $page->total_entries($total_entries);
  $page->entries_per_page($entries_per_page);
  $page->current_page($current_page);
  return $page;
}

sub selectall_entries {
  my $page = shift;
  my $entries = $dbh->selectall_arrayref(
    q/select id,dir,img from photo order by dir,img limit ? offset ?/,
    {Columns=>{}},
    $entries_per_page, $entries_per_page * ($page - 1),
  );
  return $entries;
}

before sub {
  if (!defined $dbh) {
    $dbh = connect_db();
  }
};

get '/upload' => sub {
  template 'upload', { flush => qq{} }, { layout => undef, };
};

get '/' => sub {
  return redirect "/1";
};

get qr{^/(\d+)/?$} => sub {
  my ($page) = splat;
  my $entries = selectall_entries( $page );
  template 'index', {
    entries => $entries,
    pager => pager($page),
  };
};

get qr{^/(\d+)/(\d+)/?} => sub {
  my ( $page, $offset ) = splat;
  $page   //= 1;
  $offset //= 0;
  my $pager = pager($page);
  if ( $page >= $pager->last_page ) {
    $page = $pager->last_page;
  }
  if ( $offset >= $pager->entries_on_this_page - 1 ) {
    $offset = $pager->entries_on_this_page - 1;
  }
  my $entries = selectall_entries($page);
  my $ent     = $entries->[$offset];
  my $dir     = $ent->{dir};
  my $img     = $ent->{img};

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
