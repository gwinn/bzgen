#!/usr/bin/env perl

use utf8;
use Mojolicious::Lite;
use DBD::SQLite;

get '/' => {text => "Who's there?!"};

get '/*domain/queue' => sub {
    my $self   = shift;
    my $domain = $self->param('domain');
    my $db = DBI->connect("dbi:SQLite:dbname=db/queue.db","","");
    $db->{sqlite_unicode} = 1;
    my $query = $db->do("INSERT INTO domain (domain, status) VALUES('$domain', 0)");
    $query > 0
      ? $self->render(json => {"status" => "success", "message" => "$domain placed in queue"})
      : $self->render(json => {"status" => "error", "message" => "queue crushed"});
};

app->log->debug('Starting application.');
app->start;
