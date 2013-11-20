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
use Term::ProgressBar;
use Term::ANSIColor ':constants';

use lib('lib');
use VK::MP3;

#Вывод справки
Help() if $ARGV{'h'} or $ARGV{'help'};

unless (defined $ARGV{user}) {
	say BOLD.GREEN.'Usage:'.CLEAR.' '.$0.' '.BOLD.WHITE.'--user'.CLEAR.' [ '.BOLD.WHITE.'patr14ek'.CLEAR.' | '.BOLD.WHITE.'id123'.CLEAR.' ]';
	say BOLD.GREEN.'If you want to see the help file, use:'.CLEAR.' '.$0.' [ '.BOLD.WHITE.'-help'.CLEAR.' or '.BOLD.WHITE.'-h'.CLEAR.' ]';
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

unless (-d $cfg->{path}{saveTo}) {
	mkdir($cfg->{path}{saveTo});
}

say 'Login ...';
my $vk = VK::MP3->new(login => $cfg->{user}{login}, password => $cfg->{user}{password});

my @threads;
my $playlist = $vk->get_playlist(url => 'https://vk.com/'.$ARGV{user});
my $ua = $vk->{ua};

my $userNameDirectory = $ARGV{user};
unless (-d $cfg->{path}{saveTo}.'/'.$userNameDirectory) {
	mkdir($cfg->{path}{saveTo}.'/'.$userNameDirectory);
}

for (@{$playlist}) {

	my $fileLocation;
	my $playList;
	my $fileName;

	if ($ARGV{sbp}) {
		if ($ARGV{sba}) {
			my $dirName = $_->{album}{title};
			$dirName =~ s#[\\|/|:|'|"|\]|\[|\{|\}|\+|\)|\(|\<|\>|\|]{1}#-#g;

			$playList = $_->{author};
			$playList =~ s#[\\|/|:|'|"|\]|\[|\{|\}|\+|\)|\(|\<|\>|\|]{1}#-#g;

			$fileName = $_->{name};
			$fileName =~ s#[\\|/|:|'|"|\]|\[|\{|\}|\+|\)|\(|\<|\>|\|]{1}#-#g;

			mkdir($cfg->{path}{saveTo}.'/'.$userNameDirectory.'/'.$dirName) unless (-d $cfg->{path}{saveTo}.'/'.$userNameDirectory.'/'.$dirName);
			mkdir($cfg->{path}{saveTo}.'/'.$userNameDirectory.'/'.$dirName.'/'.$playList) unless (-d $cfg->{path}{saveTo}.'/'.$userNameDirectory.'/'.$dirName.'/'.$playList);
			
			$fileLocation = $cfg->{path}{saveTo}.'/'.$userNameDirectory.'/'.$dirName.'/'.$playList.'/'.$fileName.'.mp3';
		} else {
			my $dirName = $_->{album}{title};
			$dirName =~ s#[\\|/|:|'|"|\]|\[|\{|\}|\+|\)|\(|\<|\>|\|]{1}#-#g;

			$fileName = $_->{full_name};
			$fileName =~ s#[\\|/|:|'|"|\]|\[|\{|\}|\+|\)|\(|\<|\>|\|]{1}#-#g;

			mkdir($cfg->{path}{saveTo}.'/'.$userNameDirectory.'/'.$dirName) unless (-d $cfg->{path}{saveTo}.'/'.$userNameDirectory.'/'.$dirName);
			$fileLocation = $cfg->{path}{saveTo}.'/'.$userNameDirectory.'/'.$dirName.'/'.$fileName.'.mp3';
		}
	} else {
		if ($ARGV{sba}) {
			$playList = $_->{author};
			$playList =~ s#[\\|/|:|'|"|\]|\[|\{|\}|\+|\)|\(|\<|\>|\|]{1}#-#g;

			$fileName = $_->{name};
			$fileName =~ s#[\\|/|:|'|"|\]|\[|\{|\}|\+|\)|\(|\<|\>|\|]{1}#-#g;

			mkdir($cfg->{path}{saveTo}.'/'.$userNameDirectory.'/'.$playList) unless (-d $cfg->{path}{saveTo}.'/'.$userNameDirectory.'/'.$playList);
			$fileLocation = $cfg->{path}{saveTo}.'/'.$userNameDirectory.'/'.$playList.'/'.$fileName.'.mp3';
		} else {
			$fileName = $_->{full_name};
			$fileName =~ s#[\\|/|:|'|"|\]|\[|\{|\}|\+|\)|\(|\<|\>|\|]{1}#-#g;

			mkdir($cfg->{path}{saveTo}.'/'.$userNameDirectory) unless (-d $cfg->{path}{saveTo}.'/'.$userNameDirectory);
			$fileLocation = $cfg->{path}{saveTo}.'/'.$userNameDirectory.'/'.$fileName.'.mp3';
		}
	}

	my $uri = $_->{link};
	
	push @threads, async {
		my $res = $ua->get($uri, ':content_file' => $fileLocation);
		say 'Loaded: '.$fileLocation if ($res->is_success);
		say 'Error: '.$uri.' Code:'.$res->code unless ($res->is_success);
	};
}

$_->join for (@threads);


sub Help {
say <<EOF;
# VK.com playlist downloader v0.1
# Author: SHok

Set user:
--user [ patr14ek | id123 ]

Output debug level:
--debug [ <info> | detail | debug ]

Sort tracks by artist:
-sba

Sort by playlists:
-sbp

EOF
}