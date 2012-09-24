#!/usr/bin/perl -w

use strict;

use Data::Dumper;
use Net::Twitter::Lite;
use Try::Tiny;
use YAML;

my $cfg = YAML::LoadFile("unfollow.yml");
 
my $nt = Net::Twitter::Lite->new(
    legacy_lists_api    => 0,
    consumer_key        => $cfg->{consumer_key},
    consumer_secret     => $cfg->{consumer_secret},
    access_token        => $cfg->{access_token},
    access_token_secret => $cfg->{access_token_secret},
);

my $id    = $cfg->{user_id};
my $count = $cfg->{unfollow_count}; 

#from http://tips.kaali.co.uk/2011/05/01/how-to-bulk-unfollow-on-twitter-using-perl/
 
my $cnt       = 0;
my $followers = '';
my @friends   = ();

#-- Fetch followers
try {
    my $follow=$nt->followers_ids($id);
    my @fids= @{$follow->{ids}};
    $followers=join(' ',@fids);
      
} catch {
    print "\n\n$_\n"; 
    exit 1;

};

 
#-- Fetch friends
try {
    
    my $fi   = $nt->friends_ids($id);
    @friends = @{$f->{ids}};
}
catch {
    print "\n\n$_\n";
    exit 2;
};

 
#-- Now find which of the friends does not follow you
for my $friend (@friends) {

    if (index($followers, $friend) >=0) {

        print "\n$friend follows $id";
    }
    else{
    #-- At this point, Unfollow the Friend if you like
        eval {

            my $fname = $nt->destroy_friend($friend);
            $cnt += 1;
            print "\n$cnt. Unfollowing $fname->{screen_name}...";
        };
        print "\n$@" if $@;
        last if $cnt == $count;
    }
}
 
print "\n\n";
