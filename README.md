bzgen
=======

Simple generator of zone files for Bind.

## Setup

* Put all files to any place you like
* Setup nginx to work with app (see nginx.conf)
* Make sure that you have Mjolicious installed
* Add generate.pl to crontab

## Usage

To control your api instances run:

`sh /path/to/servrun.sh -c <start|stop|restart> [-e <development|production|test>]`

By default environment parameter is `development`.
To change it on start or restart pass `-e` parameter as showed in example above.

## How it works

* API script recieve requests such as domain name or cname record and put data in database.
* Cron script read data from db, add records to main bind configuration file and generate dns zone files.

## TODO

* Add methods for all record types
* Make `under` sub for api key check

