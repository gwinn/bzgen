#!/usr/bin/env perl

use utf8;
use Mojolicious::Lite;
use DBD::SQLite;

our $conf = require 'config/bzgen.conf';

get '/' => {text => "Who's there?!"};

get '/*domain/*key/queue' => sub {
    my $self   = shift;
    my $domain = $self->param('domain');
    my $key    = $self->param('key');

    if $conf->{'apikey'} != $key {
      $self->render(json => {"status" => "error", "message" => "bad api key"});
    } else {

      my $db = DBI->connect("dbi:SQLite:dbname=db/queue.db","","") or app->log->debug($!);
      $db->{sqlite_unicode} = 1;
      my $query = $db->do("INSERT INTO domain (domain, status) VALUES('$domain', 0)") or app->log->debug($!);

      $query > 0
        ? $self->render(json => {"status" => "success", "message" => "$domain placed in queue"})
        : $self->render(json => {"status" => "error", "message" => "queue crushed"});
    }
};

get '/*domain/*cname/*key/update_cname' => sub {
    my $self   = shift;
    my $domain = $self->param('domain');
    my $cname  = $self->param('cname');
    my $key    = $self->param('key');

    if $conf->{'apikey'} != $key {
      $self->render(json => {"status" => "error", "message" => "bad api key"});
    } else {

      app->log->debug($domain);
      app->log->debug($cname);

      my $db = DBI->connect("dbi:SQLite:dbname=db/queue.db","","") or app->log->debug("Connection error: " . $!);
      $db->{sqlite_unicode} = 1;
      my $query = $db->do("INSERT INTO cname (domain, cname, status) VALUES('$domain', '$cname', 0)") or app->log->debug("Query error: " . $!);

      $query > 0
        ? $self->render(json => {"status" => "success", "message" => "cname record $cname for $domain placed in queue"})
        : $self->render(json => {"status" => "error", "message" => "queue crushed"});
    }
};

app->start;
