#---------------------------------------------------
# ntirc: an insanely flexible IRC client.          |
# Copyright (c) 2011, the NoTrollPlzNet developers |
# Logger.pm: a simple file logging package.        |
#---------------------------------------------------
package Logger;

use strict;
use warnings;
use feature 'switch';

my @loggers;

sub new {
    my ($class, $file, @flags) = @_;
    open my $file_handle, '>', $file;
    bless my $logger = {
        flags => \@flags,
        file  => $file_handle
    }, $class;
    push @loggers, $logger;
    return $logger
}

sub log_my {
    my ($type, $message) = @_;
    foreach my $logger (@loggers) {
        if ($type ~~ @{$logger->{flags}}) {
            my $time = time;
            print {$logger->{file}} "$time $type $message\n";
        }
    }
    return 1
}

1
