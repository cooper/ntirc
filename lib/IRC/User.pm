#---------------------------------------------------
# libirc: an insanely flexible perl IRC library.   |
# Copyright (c) 2011, the NoTrollPlzNet developers |
# User.pm: the user object class.                  |
#---------------------------------------------------
package IRC::User;

use warnings;
use strict;
use base qw(IRC::EventedObject);

sub new {
    my ($class, $nick) = @_;

    # create a new user object
    bless my $user = {
        nick => $nick
    }, $class;
}

1
