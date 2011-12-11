#---------------------------------------------------
# libirc: an insanely flexible perl IRC library.   |
# Copyright (c) 2011, the NoTrollPlzNet developers |
# Channel.pm: the channel object class.            |
#---------------------------------------------------
package IRC::Channel;

use warnings;
use strict;
use base qw(IRC::EventedObject IRC::Functions::Channel);

# CLASS METHODS

sub new {
    my ($class, $irc, $name) = @_;

    # create a channel object
    bless my $channel = {
        name   => $name,
        users  => [],
        modes  => {},
        events => {},
        status => {}
    };

    $channel->{irc} = $irc; # creates a looping reference XXX
    $irc->{channels}->{lc $name} = $channel;

    # fire new channel event
    $irc->fire_event(new_channel => $channel);

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

    # don't add if already there
    return if grep { $_ == $user } @{$channel->{users}};

    $channel->fire_event(user_join => $user);
    push @{$channel->{users}}, $user
}

sub remove_user {
    my ($channel, $user) = @_;
    $channel->fire_event(user_part => $user);
    @{$channel->{users}} = grep { $_ != $user } @{$channel->{users}};
}

# change the channel topic
sub set_topic {
    my ($channel, $topic, $setter, $time) = @_;

    # fire a "changed" event
    # but not if this is the first time the topic has been set
    $channel->fire_event(topic_changed => $topic, $setter, $time) if exists $channel->{topic};

    $channel->{topic} = {
        topic  => $topic,
        setter => $setter,
        time   => $time
    }
}

# set a user's channel status
sub set_status {
    my ($channel, $user, $level) = @_;

    # add the user to the status array
    push @{$channel->{status}->{$level}}, $user;

    # fire event
    $channel->fire_event(set_user_status => $user, $level);
}

1
