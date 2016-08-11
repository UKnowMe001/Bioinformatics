#!/usr/bin/perl

use strict;
use warnings;
use File::Basename;
use Getopt::Long;

$| = 1;
my @backtypes = ();
my @rmtypes = ();
my ($help,$source,$destination,$backtype,$rmtype);
GetOptions(
    'help|H!' => \$help,
	'source|S=s' => \$source,
	'destination|D=s' => \$destination,
	'backtype|T1=s{1,}' => \@backtypes,
	'rmtype|T2=s{1,}' => \@rmtypes,
);

if (!defined($help) && !defined($source) && !defined($destination)) {
    print "Please use the --help or -H option to get more information about usage!\n";
} elsif (!defined($help) && !defined($destination)) {
    print "Please specify the path of destiantion!\n";
} elsif (!defined($help) && !defined($source)) {
    print "Please specify the path of source!\n";
} elsif (!defined($help) && @backtypes == 0) {
    print "Please specify at least one type of data to backup!\n";
} elsif (!defined($help) && @rmtypes == 0) {
    print "Please specify at least one type of data to remove!\n";
} elsif (defined($help)) {
    print '
Program: Data_Backup
Version: 1.0.1
Contact: Li Shengli <lishenglibio@outlook.com>

Usage:   perl backup.pl -S <path_to_source> -D <path_to_backup> -T1 <filetypes to be copied, i.e. .fastq> -T2 <filetypes to be removed, i.e. .bam>

Arguments:
    -S/--source
	    Specify the source path under which data needs to be backuped.
	-D/--destination
	    Specify the destination path under which data will be copied into.
	-T1/--backtype
	    Specify at least one type of data to backup.
	-T2/--rmtype
	    Specify at least one type of data to remove.
	-H/--help
	    Print this help information.
';
} else {
	my @backtypes1 = map{$_="\*".$_} @backtypes;
	my @rmtypes1 = map{$_="\*".$_} @rmtypes;
	&back_data($_) for (@backtypes1);
	&rm_data($_) for (@rmtypes1);
	sub back_data {
	    my $backtype = shift;
		#print "find $source -name $backtype\n";
	    my $source_files = qx{find $source -name $backtype};
		my @s_files = split(/\n\s*/,$source_files);
		for my $f (@s_files) {
		    my ($b_filename,$b_dirname,$b_suffix) = fileparse($f,qr/\.[^.]*/);
			my $check_result = &rm_check($b_filename);
			next if ($check_result);
			my $s_finalfile = basename($source);
			$b_dirname =~ s/$source//i;
			my $d_finaldir = $destination."/".$s_finalfile.$b_dirname;
			#next if ($b_suffix ~~ @rmtypes);
			system("mkdir -p $d_finaldir");
			print "Copying $f to $d_finaldir\n";
			system("cp -u $f $d_finaldir");
		}
	}
	sub rm_data {
	    my $rmtype = shift;
		my $rm_files = qx{find $source -name $rmtype};
		my @r_files = split(/\n\s*/,$rm_files);
		for my $f (@r_files) {
		    print "Removing $f\n";
			system("rm -f $f");
		}
	}
	sub rm_check {
	    my $file = shift;
		$file = s/\.[^.]*//;
		my $exist = 0;
		for my $rt (@rmtypes) {
		    if ($file =~ /\Q$rt\E/) {
			    $exist = 1;
			}
		}
		return($exist);
	}
}

