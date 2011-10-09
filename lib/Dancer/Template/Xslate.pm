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
use Dancer::FileUtils qw'path';
use Text::Xslate;

with 'Dancer::Core::Role::Template';

has engine => (
  is  => 'rw',
  isa => sub { ObjectOf( 'Text::Xslate', @_ ) },
);

sub default_tmpl_ext {".tx"}

sub init {
  my $self     = shift;
  my $charset  = $self->charset;
  my @encoding = length($charset) ? ( ENCODING => $charset ) : ();
  my %args     = ( %{ $self->config }, );
  my $views    = $self->{views} || '.';
  my $path     = [$views];
  $self->engine( Text::Xslate->new( %args, path => $path, ) );
}

sub _template_name {
  my ( $self, $view ) = @_;
  my $suffix = $self->config->{suffix} // default_tmpl_ext;
  $view .= $suffix if $view !~ /\Q$suffix\E$/;
  return $view;
}

sub view {
  my ( $self, $view ) = @_;
  $view = $self->_template_name($view);
  return $view;
}

sub render_layout {
  my ( $self, $layout, $tokens, $content ) = @_;
  my $layout_name = $self->_template_name($layout);
  my $layout_path = path( 'layouts', $layout_name );

  # FIXME: not sure if I can "just call render"
  $self->render( $layout_path, { %$tokens, content => $content } );
}

sub render {
  my ( $self, $template, $tokens ) = @_;
  my $path  = $self->engine->{path};
  my $views = File::Spec->rel2abs( $self->{views} );
  unless ( grep { $_ eq $views } @$path ) {
    my $error = qq/Couldn't change include_path to "$views"/;
    croak $error;
  }
  my $content = eval { $self->engine->render( $template, $tokens ) };
  if ( my $err = $@ ) {
    my $error = qq/Couldn't render template "$err"/;
    croak $error;
  }
  return $content;
}

1;
