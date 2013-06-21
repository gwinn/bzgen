#!/usr/bin/env perl

use strict;
use utf8;
use DBD::SQLite;
use File::Copy;

our $conf = require 'config/bzgen.conf';

&domain_queue;
&cname_queue if ($conf->{'servtype'} =~ /master/);
system("rndc", "reload");

sub domain_queue {
  my $db = DBI->connect("dbi:SQLite:dbname=db/queue.db","","");
  my $query = $db->prepare("SELECT * FROM domain WHERE (status == 0)");

  $query->execute() or die($db->errstr);

  open LOG, ">>", 'log/cron.log';

  while (my $row = $query->fetchrow_arrayref()) {
    open FILE, "<templates/template.$conf->{'servtype'}";
    open CONF, ">>", $conf->{'named_path'};
    my @lines = <FILE>;

    foreach my $i (@lines) {
      if ($i =~ /__domain__/gi) {
        $i =~ s/__domain__/@$row[1]/;
      }
      print CONF $i;
    }

    close CONF; close FILE;

    if ($conf->{'servtype'} =~ /master/) {
      copy('templates/template.zone', "$conf->{'zones_path'}/@$row[1].zone");
    }

    my $q = $db->prepare("UPDATE domain SET status = 1 WHERE (id == @$row[0])");
    $q->execute() or die($db->errstr);

    print LOG "zone for @$row[1] added\n";

  }

  close LOG;
};

sub cname_queue {
  my $db = DBI->connect("dbi:SQLite:dbname=db/queue.db","","");
  my $query = $db->prepare("SELECT * FROM cname WHERE (status == 0)");

  $query->execute() or die($db->errstr);

  open LOG, ">>", 'log/cron.log';

  while (my $row = $query->fetchrow_arrayref()) {
    open ZONE, ">>", $conf->{'zones_path'} . '/' . @$row[1] . '.zone';
    print ZONE @$row[2] . "\tIN CNAME\tmail.yandex.ru.";
    close ZONE;
    my $q = $db->prepare("UPDATE cname SET status = 1 WHERE (id == @$row[0])");
    $q->execute() or die($db->errstr);
    print LOG "cname for @$row[1] added\n";
  }

  close LOG;
};

