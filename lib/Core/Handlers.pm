#---------------------------------------------------
# ntirc: an insanely flexible IRC client.          |
# Copyright (c) 2011, the NoTrollPlzNet developers |
# Core/Handlers.pm: core handlers for libirc.      |
#---------------------------------------------------
package Core::Handlers;

use warnings;
use strict;

use Logger; # for logging "add_event" event

my %handlers = (
    raw_005     => \&handle_isupport,
    raw_376     => \&handle_endofmotd,
	 raw_privmsg => \&handle_privsg
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
    my $irc = shift;

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

1
