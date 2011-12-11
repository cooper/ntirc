#---------------------------------------------------
# libirc: an insanely flexible perl IRC library.   |
# Copyright (c) 2011, the NoTrollPlzNet developers |
# Wx.pm: the cross-platform GUI interface.         |
#---------------------------------------------------
package Interface::Wx;

use warnings;
use strict;

use Wx;
use Interface::Wx::App;

our ($app, $frame);

sub start {

    # create the app and window
    $app = Interface::Wx::App->new();
    $frame = Wx::Frame->new(
        undef,           # parent window
        -1,              # ID -1 means any
        $main::name,     # title
        [-1, -1],        # default position
        [550, 350],      # size
    );
    $frame->Show();

    # create menu bar
    my $menu = Wx::MenuBar->new();
    my $main = Wx::Menu->new();
    my $quit = Wx::MenuItem->new($main);
    $main->Append($quit);
    $menu->Show();
    $frame->SetMenuBar($menu);

    # run Wx loop
    $app->MainLoop();
}


1
