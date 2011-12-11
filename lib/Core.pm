#---------------------------------------------------
# ntirc: an insanely flexible IRC client.          |
# Copyright (c) 2011, the NoTrollPlzNet developers |
# Core.pm: the core components of ntirc.           |
#---------------------------------------------------

package Core;

use warnings;
use strict;

use IO::Async::Protocol::LineStream;

use Core::Handlers;
use Core::Async::IRC;

1
