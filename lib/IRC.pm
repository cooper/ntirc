#---------------------------------------------------
# libirc: an insanely flexible perl IRC library.   |
# Copyright (c) 2011, the NoTrollPlzNet developers |
#---------------------------------------------------
package IRC;

use warnings;
use strict;
use base qw(IRC::EventedObject);

use IRC::EventedObject;
use IRC::User;
use IRC::Channel;

our $VERSION = '0.1';

# create a new IRC instance
sub new {
    my ($class, %opts) = @_;

    # XXX users will probably make a reference chain
    # $irc->{users}->[0]->{irc}->{users} and so on
    bless my $irc = {
        users    => {},
        channels => {},
        events   => {}
    }, $class;

    # create an IRC::User instance for myself
    $irc->{me} = IRC::User->new($opts{nick});

    return $irc
}

# parse a raw piece of IRC data
sub parse {
    my ($irc, $data) = @_;

    $data =~ s/(\0|\r)//g; # remove unwanted characters

    # parse one line at a time
    if ($data =~ m/\n/) {
        $irc->parse($_) foreach split "\n", $data;
        return
    }

    my @args = split /\s/, $data;
    return unless defined $args[0];

    if ($args[0] eq 'PING') {
        $irc->send("PONG $args[1]");
    }

    # if there is no parameter, there's nothing to parse.
    return unless defined $args[1];

    my $command = lc $args[1];

    # fire the raw_* event (several of which fire more events from there on)
    $irc->fire_event("raw_$command", $data, @args);
    $irc->fire_event('raw', $data, @args); # for anything

}

# shortcut to the 'send' event
sub send {
    shift->fire_event(send => @_);
}

1
