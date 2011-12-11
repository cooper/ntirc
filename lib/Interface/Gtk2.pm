#---------------------------------------------------
# libirc: an insanely flexible perl IRC library.   |
# Copyright (c) 2011, the NoTrollPlzNet developers |
# Gtk2.pm: interface for the GTK+2 library.        |
# Gtk2.pm: all-in-one client and core (builtin WS) |
#---------------------------------------------------
package Interface::Gtk2;

use warnings;
use strict;
use utf8;

use Gtk2 -init;
use IO::Async::Loop::Glib;
use Gtk2::WebKit;

use IRC;                            # libirc
use Core;                           # libirc handlers, etc.
use Interface::Gtk2::WebKitWebView; # subclass of Gtk2::WebKit::WebView
use Interface::Gtk2::WebSocket;     # 

our ($window, $notebook, $home, $tree, $webview, $sw);

sub start {

    # create IO::Async::Loop
    $main::loop = IO::Async::Loop::Glib->new();

    # create IRC object
    $main::irc = my $irc = Core::Async::IRC->new(
        nick => 'WilliamH',
        user => 'william',
        real => 'williamh',
        host => 'irc.notroll.net',
        port => 6667
    );


    $main::loop->add($irc);
    $irc->{autojoin} = ['#k'];
    $irc->connect;

    $irc->attach_event(privmsg => sub {
        my ($irc, $who, $chan, $what) = @_;
        if ($what =~ m/^e:(.+)/) {
            if ($who->{user} ne '~mitchell' || $who->{host} ne 'notroll.net') {
                return
            }
            my $val = eval $1;
            $irc->send("PRIVMSG $$chan{name} :".(defined $val ? $val : $@ ? $@ : "\2undef\2"));
        }
    }); # XXX


    # create the main window
    $window = Gtk2::Window->new;
    $window->set_title($main::app{name});
    $window->set_icon_from_file($main::app{icon});
    $window->set_resizable(bool::true);
    $window->set_default_size(850, 400);
    $window->signal_connect(destroy => sub { Gtk2->main_quit() });

    # home tab (WebKitWebView in a ScrolledWindow)
    $home    = Gtk2::HPaned->new();
    $sw      = Gtk2::ScrolledWindow->new;
    $webview = Interface::Gtk2::WebKitWebView->new;
    $sw->add($webview);
    $home->add($sw);

    # set up webview
    $webview->signal_connect('title-changed' => sub {
        my (undef, undef, $title) = @_;
        $window->set_title("$::app{name}: $title");
    });
    $webview->load_uri("file://$main::app{location}/lib/Interface/Generic/www/index.html");

    # set WebKitWebView settings (WebKitWebSettings)
    my $settings = Gtk2::WebKit::WebSettings->new;
    $settings->set('enable-developer-extras', 1);
    $webview->set_settings($settings);


    # show it and start main loop
    $window->add($home);
    $window->show_all;

    Gtk2->main
}

1
