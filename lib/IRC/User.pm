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
    my $nick = lc((split /\!/, $user_string)[0]);
    $nick =~ s/://;

    # if the user exists, return it
    return $users{$nick} if exists $users{$nick};

    # otherwise give up
    return
}

# parses a :nick!ident@host
# and creates a new user if it doesn't exist
# finds it if it does
sub new_from_string {
    my ($package, $user_string) = @_;
    my $nick = (split /\!/, $user_string)[0];
    $nick =~ s/://;

    # if the user exists, return it
    return $users{lc $nick} if exists $users{lc $nick};

    # otherwise create a new one
    $package->new($nick);

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
