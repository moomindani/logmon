#!/usr/bin/perl
#
#   logmon.pl / LogMonitor
#
#   2009/06/26  ver1.0
#   2009/06/30  ver1.1 Add meta-string: <%%%%> 
#   2010/04/11  ver1.2 resolve meta-string substitution bug
#

use strict;
use Getopt::Std;

my $Conf_file;
my %Config;
my $Terminate = 0;

sub catch_hup {
    system ( "pkill -HUP -P $$" );
}

sub catch_term {
    system ( "pkill -TERM -P $$" );
    $Terminate = 1;
}

sub options {
my %opts;
    getopts ( "hcf:", \%opts );
    $Conf_file = $opts{'f'} || "/etc/logmon/logmon.conf";
    if ( $opts{'h'} ) {
        print <<EOF;
Usage: logmon [-hc] [-f config_file]
Options:
    -h: show help
    -c: check config
    -f: config file (Default: /etc/logmon/logmon.conf)
EOF
        exit 0;
    }
    return $opts{'c'};
}

sub read_conf {
my ( $target, $message, $action );
my $check_config = $_[ 0 ];

    open ( IN, "<$Conf_file" );
    while (<IN>) {
        chomp; $_ =~ s/^\s+//; $_ =~ s/\s+$//; $_=~ s/#.*$//;
        next unless ( $_ );
        if ( $_ =~ m/^:(.+)/ )     { $target  = $1; next; }
        if ( $_ =~ m/^(\(.+\))$/ ) { $message = $1; next; }
        $action  = $_;
        next unless ( $target && $message );
        push ( @{$Config{ $target }->{ $message }}, $action );
    }
    close IN;

    return unless $check_config;

    print "Config file: $Conf_file\n";
    foreach $target ( keys %Config ) {
        print "\nLogfile: $target\n";
        foreach $message ( keys %{$Config{$target}} ) {
            print "  Message: $message\n";
            foreach $action ( @{$Config{ $target }->{ $message }} ) {
                print "    Action: $action\n";
            }
        }
    }
    print "\n";
    exit 0;
}

sub watch_for {
my ( $tail_num, $target, $message, $action, $new_action );

    ( $target, $tail_num ) = @_;
    unless ( fork() ) {      # Child
        $SIG{HUP}  = \&catch_hup;
        $SIG{TERM} = \&catch_term;
        open ( IN, "tail -n$tail_num -f $target|" );
        while ( <IN> ) {
            foreach $message ( keys %{$Config{$target}} ) {
                if ( $_ =~ m/$message/ ) {
                    foreach $action ( @{$Config{ $target }->{ $message }} ) {
                        $new_action = $action;
                        $new_action =~ s/<%%%%>/$_/g;
                        system( $new_action );
                    }
                }
            }
        }
        close IN;
        exit 0;
    }
}

MAIN: {
my ( $tail_num, $target, $message );

    $SIG{HUP}  = \&catch_hup;
    $SIG{TERM} = \&catch_term;
    read_conf( options() );

    $tail_num = 0;
    while ( ! $Terminate ) {
        foreach $target ( keys %Config ) {
            watch_for( $target, $tail_num );
        }
        while ( ! system( "pgrep -P $$" ) ) {
           wait;
        }
        $tail_num = 5;
    }
}

