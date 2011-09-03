#---------------------------------------------------
# libirc: an insanely flexible perl IRC library.   |
# Copyright (c) 2011, the NoTrollPlzNet developers |
# User.pm: the user object class.                  |
#---------------------------------------------------
package IRC::User;

use warnings;
use strict;
use base qw(IRC::EventedObject); # hopefully we can assume it is already loaded by IRC.pm

our %users;

# CLASS METHODS

sub new {
    my ($class, $nick) = @_;

    # create a new user object
    bless my $user = {
        nick => $nick
    }, $class;

    $users{lc $nick} = $user;
}

# parses a :nick!ident@host
# and finds the user
sub from_string {
    my $user_string = shift;
    $user_string =~ m/^:(.+)!(.+)\@(.+)/ or return;
    my ($nick, $ident, $host) = ($1, $2, $3);

    # find the user, set the info
    my $user = $users{lc $nick} or return; # or give up

    if (defined $user) {
        $user->{user} = $ident;
        $user->{host} = $host;
    }

    return $user
}

# parses a :nick!ident@host
# and creates a new user if it doesn't exist
# finds it if it does
sub new_from_string {
    my ($package, $user_string) = @_;
    $user_string =~ m/^:(.+)!(.+)\@(.+)/ or return;
    my ($nick, $ident, $host) = ($1, $2, $3);

    # find the user, set the info
    my $user = defined $users{lc $nick} ? $users{lc $nick} : $package->new($nick); # or create a new one

    if (defined $user) {
        $user->{user} = $ident;
        $user->{host} = $host;
    }

    return $user
}

# find a user by his nick
sub from_nick {
    my $nick = lc shift;
    exists $users{$nick} ? $users{$nick} : undef
}

# find a user by his nick
# or create one if it doesn't exist
sub new_from_nick {
    my ($package, $nick) = (shift, lc shift);
    exists $users{$nick} ? $users{$nick} : $users{$nick} = $package->new($nick)
}

# INSTANCE METHODS

# change the nickname and move the object's location
sub set_nick {
    my ($user, $newnick) = @_;
    delete $users{lc($user->{nick})};
    $user->{nick}       = $newnick;
    $users{lc $newnick} = $user;

    # tell ppl
    $user->fire_event(nick_change => $newnick);
}

1
