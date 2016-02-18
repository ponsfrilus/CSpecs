#!/usr/bin/perl
#Usage : sprunge [- | file]
use strict;

use LWP::UserAgent;
use HTTP::Request::Common qw{ POST };

local $/;
my $ua = LWP::UserAgent->new();

while (<>) {
    print STDERR "uploading \n";
    my $req = POST("http://sprunge.us", [ "sprunge" => $_ ] );
    my $sprunge_url = $ua->request($req)->content();
    print $sprunge_url
}
