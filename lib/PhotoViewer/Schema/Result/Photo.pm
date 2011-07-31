package PhotoViewer::Schema::Result::Photo;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Core';


=head1 NAME

PhotoViewer::Schema::Result::Photo

=cut

__PACKAGE__->table("photo");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 dir

  data_type: 'text'
  is_nullable: 0

=head2 img

  data_type: 'text'
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "dir",
  { data_type => "text", is_nullable => 0 },
  "img",
  { data_type => "text", is_nullable => 0 },
);
__PACKAGE__->set_primary_key("id");


# Created by DBIx::Class::Schema::Loader v0.07010 @ 2011-05-03 14:53:01
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:6LmDrM3OBrO4zuT/N43hBQ


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
