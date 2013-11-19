use strict;
use warnings;
 
use ExtUtils::MakeMaker;
 
WriteMakefile(
  NAME          => 'VkPlayListDownloader',
  AUTHOR        => 'SHok',
  LICENSE       => 'perl_5',
  PREREQ_PM     => {
    'VK::MP3'           => 0.03,
    'Coro'              => 6.33,
    'Switch'            => 2.16,
    'JSON::XS'          => 3.01,
    'Coro::LWP'         => 6.33,
    'File::Slurp'       => 9999.19,
    'Data::Dumper'      => 2.145,
    'Getopt::Mini'      => 0.02,
    'LWP::UserAgent'    => 6.05,
  }
);