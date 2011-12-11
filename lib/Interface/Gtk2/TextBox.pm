#---------------------------------------------------
# libirc: an insanely flexible perl IRC library.   |
# Copyright (c) 2011, the NoTrollPlzNet developers |
# TextBox.pm: the channel/query textbox for GTK.   |
#---------------------------------------------------
package Interface::Gtk2::TextBox;

use warnings;
use strict;

sub new {
    my ($class, $textview);
    bless my $textbox = {
        textview => $textview
    }, $class;
}


1
