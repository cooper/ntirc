#---------------------------------------------------
# libirc: an insanely flexible perl IRC library.   |
# Copyright (c) 2011, the NoTrollPlzNet developers |
# Themes.pm: parses ntss files (ntirc stylesheets) |
#---------------------------------------------------
package Interface::Base::Generic::Themes;

use warnings;
use strict;
use feature 'switch';

sub parse_file {
    my ($file, $section, $content) = (shift, q.., q..);
    open my $fh, '<', $file or return;

    my %sections = (
        js   => \&handle_js,
        css  => \&handle_css,
        html => \&handle_html
    );

    while (my $line = <$fh>) {
    given (do { my $line2 = $line; $line2 =~ s/\s$//g; $line2 }) {
        when (/^==/) {
            next
        }
        when (/^\[(.*)\]$/) {
            $sections{$section}->($content) if exists $sections{$section};
            ($section, $content) = ($1, '');
            return unless $sections{$section}
        }
        default {
            if (!$section) {
                $line =~ s/\s//g;
                next unless $line;
                return;
            }
            $content .= $line
        }
    } }

    $sections{$section}->($content) if exists $sections{$section};
    $main::webview->execute('themeLoaded');
    return 1
}

sub handle_js {
    my $js = shift;
    $main::webview->execute(insertJavaScript => $js);
}

sub handle_css {
    my $css = shift;
    $main::webview->execute(insertStyleSheet => $css);
}

sub handle_html {
    my $html = shift;
    $main::webview->execute(insertHTML => $html);
}

1
