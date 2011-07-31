#!/bin/sh
mkdir -p data
sqlite3 data/photo.sqlite <<__EOM__
create table photo (
  id integer primary key autoincrement,
  dir text,
  img text
);
__EOM__

