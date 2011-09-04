#---------------------------------------------------
# libirc: an insanely flexible perl IRC library.   |
# Copyright (c) 2011, the NoTrollPlzNet developers |
# Channel.pm: the channel object class.            |
#---------------------------------------------------
package IRC::Channel;

use warnings;
use strict;
use base qw(IRC::EventedObject);

our %channels;

# CLASS METHODS

sub new {
    my ($class, $name) = @_;

    # create a channel object
    bless my $channel = {
        name  => $name,
        users => [],
        modes => {}
    };

    $channels{lc $name} = $channel;
    return $channel
}

# lookup by channel name
sub from_name {
    my $name = lc shift;
    $name =~ s/^://;
    return $channels{$name}
}

# lookup by channel name
# or create a new channel if it doesn't exist
sub new_from_name {
    my ($package, $name) = (shift, lc shift);
    $name =~ s/^://;
    exists $channels{$name} ? $channels{$name} : $package->new($name)
}

# INSTANCE METHODS

# add a user to a channel
sub add_user {
    my ($channel, $user) = @_;
    $channel->fire_event(user_join => $user);
    push @{$channel->{users}}, $user
}

1
