# XXX XXX XXX XXX XXX XXX XXX XXX XXX XXX XXX XXX XXX #
# XXX this doesn't have anything to do with ntirc.XXX #
# XXX it's just an IRC bot interface to libirc    XXX #
# XXX to practice on before we implement GTK. XXX XXX #
# XXX XXX XXX XXX XXX XXX XXX XXX XXX XXX XXX XXX XXX #

package Interface::Bot;

use warnings;
use strict;
use IO::Socket::INET;

my $irc = IRC->new();

my $socket = IO::Socket::INET->new(
    PeerAddr => 'irc.alphachat.net',
    PeerPort => 6667,
    Type     => SOCK_STREAM,
    Proto    => 'tcp'
);

# libirc will tell us what to send
$irc->attach_event(send => \&send_data);

# attach the core handler events
$irc->Core::Handlers::apply_handlers();

$irc->{autojoin} = ['#nt'];
$irc->send('NICK testbot');
$irc->send('USER testbot * * :testbot');

# send data to the socket
sub send_data {
    my ($irc, $data) = @_;
    print $socket $data,"\r\n";
}

while (my $line = <$socket>) {
    $irc->parse($line);
}

1
