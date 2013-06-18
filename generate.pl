#!/usr/bin/env perl

use strict;
use utf8;
use DBD::SQLite;
use File::Copy;

my $conf = require 'config/bzgen.conf';
my $db = DBI->connect("dbi:SQLite:dbname=db/queue.db","","");
my $query = $db->prepare("SELECT * FROM domain WHERE (status == 0)");

$query->execute() or die($db->errstr);

while (my $row = $query->fetchrow_arrayref()) {
  open FILE, "<templates/template.$conf->{'servtype'}" or die $!;
  open CONF, ">>", $conf->{'named_path'} or die $!;
  my @lines = <FILE>;

  foreach my $i (@lines) {
    if ($i =~ /__domain__/gi) {
      $i =~ s/__domain__/@$row[1]/;
    }
    print CONF $i;
  }

  close CONF or die $!; close FILE or die $!;

  if ($conf->{'servtype'} =~ /master/) {
    copy('templates/template.zone', "$conf->{'zones_path'}/@$row[1].zone") or die $!;
  }

  my $q = $db->prepare("UPDATE domain SET status = 1 WHERE (id == @$row[0])");
  $q->execute() or die($db->errstr);

  open LOG, ">>", 'log/cron.log' or die $!;
  print LOG "@$row[1] added";
  close LOG or die $!;
}

system("rndc", "reload");

