#---------------------------------------------------
# ntirc: an insanely flexible IRC client.          |
# Copyright (c) 2011, the NoTrollPlzNet developers |
# Core/Handlers.pm: core handlers for libirc.      |
#---------------------------------------------------
package Core::Handlers;

use warnings;
use strict;
use feature qw(switch);

my %handlers = (
    raw_005     => \&handle_isupport,
    raw_376     => \&handle_endofmotd,
    raw_433     => \&handle_nick_taken,
    raw_privmsg => \&handle_privmsg
);

# applies each handler to an IRC instance
sub apply_handlers {
    my $irc = shift;

    foreach my $handler (keys %handlers) {
        $irc->attach_event($handler, $handlers{$handler});
    }

    return 1
}

# handle RPL_ISUPPORT (005)
sub handle_isupport {
    my ($irc, $data, @args) = @_;

    my @stuff = @args[3..$#args];
    my $val;

    foreach my $support (@stuff) {

        # get BLAH=blah types
        if ($support =~ m/(.+?)=(.+)/) {
            $support = $1;
            $val     = $2;
        }

        # fire an event saying that we got the support string
        # for example, to update the network name when NETWORK is received.
        $irc->fire_event('isupport_got_'.lc($support), $val);

      given (uc $support) {

        # store the network name
        when ('NETWORK') {
            $irc->{network} = $val;
        }

        when ('PREFIX') {
            # prefixes are stored in $irc->{prefix}->{<status level>}
            # and their value is an array reference of [symbol, mode letter]

            # it's hard to support so many different prefixes
            # because we want pixmaps to match up on different networks.
            # the main idea is that if we can find an @, use it as 0
            # and work our way up and down from there. if we can't find
            # an @, start at the top and work our way down. this still
            # has a problem, though. networks that don't have halfop
            # will have a different pixmap for voice than networks who do.
            # so in order to avoid that we will look specially for + as well.

            # tl;dr: use 0 at @ if @ exists; otherwise start at the top and work down
            # (negative levels are likely if @ exists)

            $val =~ m/\((.+?)\)(.+)/;
            my ($modes, $prefixes, %final) = ($1, $2);

            # does it have an @?
            if ($prefixes =~ m/(.+)\@(.+)/) {
                my $current = length $1; # the number of prefixes before @ is the top level
                my @before  = split //, $1;
                my @after   = split //, $2;

                # before the @
                foreach my $symbol (@before) {
                    $final{$current} = $symbol;
                    $current--
                }

                die 'wtf..'.$current if $current != 0;
                $final{$current} = '@';
                $current--; # for the @

                # after the @
                foreach my $symbol (@after) {
                    $final{$current} = $symbol;
                    $current--
                }
            }

            # no @, so just start from the top
            else {
                my $current = length $prefixes;
                foreach my $symbol (split //, $prefixes) {
                    $final{$current} = $symbol;
                    $current--
                }
            }

            # store
            my ($i, @modes) = (0, split(//, $modes));
            foreach my $level (reverse sort { $a <=> $b } keys %final) {
                $irc->{prefix}->{$level} = [$final{$level}, $modes[$i]];
                $i++
            }

            # fire the event that says we handled prefixes
            $irc->fire_event('isupport_got_prefixes');
            
        }

        # CHANMODES tells us what modes are which.
        # we need this so we know which modes to expect to have parameters.
        # modes are stored in $irc->{chmode}->{<letter>} = { type => <type> }
        when ('CHANMODES') {

            # CHANMODES=eIb,k,fl,ACDEFGJKLMNOPQSTcgimnpstz
            # CHANMODES=
            # (0) list modes,
            # (1) modes that take parameters ALWAYS,
            # (2) modes that take parameters only when setting,
            # (3) modes that don't take parameters

            my $type = 0;
            foreach my $mode (split //, $val) {

                # next type
                if ($mode eq ',') {
                    $type++;
                    next
                }

                # store it
                $irc->{chmode}->{$mode}->{type} = $type
            }

        }

        # ugly

    } } # too much nesting

    return 1
}

sub handle_endofmotd {
    my $irc = shift;
    if ($irc->{autojoin} && ref $irc->{autojoin} eq 'ARRAY') {
        foreach my $channel (@{$irc->{autojoin}}) {
            $irc->send("JOIN $channel");
        }
        return 1
    }
    return
}

sub handle_privmsg {
    my ($irc, $data, @args) = @_;
    $data =~ s/.//;
    my $source  = $args[0];
    my $target  = $args[2];
    my $message = (split / /, $data, 4)[3];
    $message =~ s/://;
    $irc->fire_event(privmsg => $source, $target, $message);
}

sub handle_nick_taken {
    my $irc = shift;
    $irc->{temp_nick_count} = 0 unless exists $irc->{temp_nick_count};
    $irc->{temp_nick_count}++;
    my $nick = $irc->{me}->{nick};
    $irc->send("NICK ${nick}_") unless $irc->{temp_nick_count} >= 5;
}

1
