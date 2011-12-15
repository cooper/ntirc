#---------------------------------------------------
# ntirc: an insanely flexible IRC client.          |
# Copyright (c) 2011, the NoTrollPlzNet developers |
# WebView: a WebKitWebView subclass for ntirc.     |
#---------------------------------------------------
package Interface::Gtk2::WebKitWebView;

use warnings;
use strict;
use base 'Gtk2::WebKit::WebView';

sub new {
    my $class   = shift;
    bless my $webview = $class->SUPER::new(), $class;
    return $webview
}

sub execute {
    my ($webview, $name, @args) = @_;
    my $string = qq|$name(|;

    # add argument list
    foreach my $arg (@args) {
        $arg = IRC::Utils::escape($arg);
        $string .= qq|'$arg', |;
    }

    # remove the last extra comma and append );
    $string  =~ s/, $//;
    $string  =~ s/\n/\\\n/g;
    $string .= q|);|;
    return $webview->execute_script($string);
}

1
