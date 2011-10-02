package Dancer::Template::Xslate;

BEGIN {
  $Dancer::Template::Xslate::VERSION = '0.01';
}

# ABSTRACT: Text::Xslate wrapper for Dancer

use strict;
use warnings;
use Carp;
use Moo;
use Dancer::Moo::Types;
use Text::Xslate;
use File::Spec;

with 'Dancer::Core::Role::Template';

sub debug_dump {
  use Data::Dumper;
  my @caller = caller(1);
  my $debug = Data::Dumper->Dump([ \@caller, \@_ ] );
  open my $debugf, ">>", "/tmp/photoviewer.txt" or die;
  print $debugf $debug, "\n";
  close $debugf;
}

has engine => (
    is => 'rw',
    isa => sub { ObjectOf('Text::Xslate', @_) },
);

sub default_tmpl_ext { "tt" }

sub init {
    my $self = shift;

    my $charset = $self->charset;
    my @encoding = length($charset) ? ( ENCODING => $charset ) : ();

    my %args = (
        %{$self->config},
    );
    my $views = $self->{views} || '.';
    my $path = [ $views, "$views/layouts" ];

    $self->engine( Text::Xslate->new(
      %args,
      path => $path,
      cache => 1,
      cache_dir => '/home/okura/github/PhotoViewer/xslate_cache',
      syntax => 'TTerse',
      suffix => 'tt',
      )
    );
}

sub render {
    my ($self, $template, $tokens) = @_;
    my $path = $self->engine->{path};
    my $views = File::Spec->rel2abs( $self->{views} );
    unless ( grep {$_ eq $views} @$path ) {
        my $error = qq/Couldn't change include_path to "$views"/;
        croak $error;
    }

   (undef,undef,my $_template) = File::Spec->splitpath( $template );

    my $content = eval {
        $self->engine->render($_template, $tokens)
    };

    if (my $err = $@) {
        my $error = qq/Couldn't render template "$err"/;
        croak $error;
    }

    return $content;
}

1;
