# ntirc: an insanely flexible IRC client.          |
# Copyright (c) 2011, the NoTrollPlzNet developers |
# WebSocket: communication from WebKit to libirc.  |
#---------------------------------------------------
package Interface::Gtk2::WebSocket;

use warnings;
use strict;

use Net::Async::WebSocket::Server; # installed with -f

sub listen {

 my $server = Net::Async::WebSocket::Server->new(
    on_client => sub {
       my ( undef, $client ) = @_;
 
       $client->configure(
          on_frame => sub {
             my ( $self, $frame ) = @_;
             $self->send_frame( $frame );
          },
       );
    }
 );
 
 $::loop->add( $server );
 
 $server->listen(
    addr => {
        family   => 'inet',
        socktype => 'stream',
        port     => 3000,
        ip       => '0.0.0.0',
    }, 
    on_listen_error => sub { die "Cannot listen - $_[-1]" },
    on_resolve_error => sub { die "Cannot resolve - $_[-1]" },
 );

}

1
