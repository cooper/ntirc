#---------------------------------------------------
# libirc: an insanely flexible perl IRC library.   |
# Copyright (c) 2011, the NoTrollPlzNet developers |
# Channel.pm: the channel object class.            |
#---------------------------------------------------
package IRC::Channel;

use warnings;
use strict;
use base qw(IRC::EventedObject);

# CLASS METHODS

sub new {
    my ($class, $irc, $name) = @_;

    # create a channel object
    bless my $channel = {
        name   => $name,
        users  => [],
        modes  => {},
        events => {}
    };

    $channel->{irc} = $irc; # creates a looping reference XXX
    $irc->{channels}->{lc $name} = $channel;
    return $channel
}

# lookup by channel name
sub from_name {
    my ($irc, $name) = (shift, lc shift);
    $name =~ s/^://;
    return $irc->{channels}->{$name}
}

# lookup by channel name
# or create a new channel if it doesn't exist
sub new_from_name {
    my ($package, $irc, $name) = (shift, shift, lc shift);
    $name =~ s/^://;
    exists $irc->{channels}->{$name} ? $irc->{channels}->{$name} : $package->new($irc, $name)
}

# INSTANCE METHODS

# add a user to a channel
sub add_user {
    my ($channel, $user) = @_;
    $channel->fire_event(user_join => $user);
    push @{$channel->{users}}, $user
}

# change the channel topic
sub set_topic {
    my ($channel, $topic) = @_;
    $channel->{topic} = $topic;

    # fire an event
    $channel->fire_event(topic_changed => $topic);
}

1
