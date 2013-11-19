#!/usr/bin/env perl

use strict;
use warnings;

use feature 'say';
use Coro;
use Switch;
use JSON::XS;
use Coro::LWP;
use File::Slurp;
use Data::Dumper;
use Getopt::Mini;
use LWP::UserAgent;

use lib('lib');
use VK::MP3;

unless (defined $ARGV{user}) {
	say 'Usage: '.$0.' --user [ patr14ek | id123 ]';
	exit;
}

say 'Read configuration ...';
my $cfg = undef;
eval {
	$cfg = decode_json(read_file('config.cfg'));
};
if ($@) {
	say 'Cant read config file! Error:';
	say $@;
}

say 'Login ...';
my $vk = VK::MP3->new(login => $cfg->{user}{login}, password => $cfg->{user}{password});

my @threads;
my $playlist = $vk->get_playlist(url => 'https://vk.com/'.$ARGV{user});
my $ua = $vk->{ua};

for (@{$playlist}) {

	my $fileLocation;
	if (defined $_->{album}{title}) {
		my $dirName = $_->{album}{title};
		$dirName =~ s#[\\|/|:|'|"|\]|\[|\{|\}|\+|\)|\(]{1}#-#g;

		mkdir($cfg->{path}{saveTo}.'/'.$dirName) unless (-d $cfg->{path}{saveTo}.'/'.$dirName);
		$fileLocation = $cfg->{path}{saveTo} .'/'.$dirName.'/'. $_->{name} .'.mp3'
	} else {
		mkdir($cfg->{path}{saveTo}.'/all') unless (-d $cfg->{path}{saveTo}.'/all');
		$fileLocation = $cfg->{path}{saveTo} .'/all/'. $_->{name} .'.mp3';
	}

	my $uri = $_->{link};

	push @threads, async {
		my $res = $ua->get($uri, ':content_file' => $fileLocation);
		say 'Loaded: '.$fileLocation if ($res->is_success);
		say 'Error: '.$uri.' Code:'.$res->code unless ($res->is_success);
	};
}

$_->join for (@threads);