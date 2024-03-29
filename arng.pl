#!/usr/bin/env perl

# Simple & Capable files arranger
# https://github.com/anhsirk0/file-arranger

use strict;
use File::Find;
use File::Copy;
use File::Basename;
use File::Path qw(make_path);
use Cwd qw(getcwd);
use Getopt::Long;

my $maxdepth = 1;
my @all_files = ();
my @all_dirs = ();
my @user_ext = ();
my @user_names = ();
my @user_inames = ();
my $user_dir;
my $help;
my $revert;
my $verbose;
my $dry_run;
my $keep_log;
my $by_name;
my $no_others;
my $no_arrange;
my $delete_empty;
my $moved_files_count = 0;
my $config_dir = $ENV{HOME} . "/.config/arng";
my $config_file = $config_dir . "/arng.conf";
my $logs_dir = $config_dir . "/logs";
my $w_logfile = "arng_log_" . localtime();
$w_logfile =~ s/ /_/g; # replace spaces with underscores

# store initial & final loacation of moved files
my $files_moved_details = "";
# hash; Directory name as keys & file extensions as values
my %def_ext; # default extensions
$def_ext{"Images"} = [qw/jpg png jpeg svg webp gif ico svg/];
$def_ext{"Music"} = [qw/mp3 m3u ogg wav opus mid midi/];
$def_ext{"Videos"} = [qw/mp4 mkv avi flv ts mpeg/];
$def_ext{"Documents"} = [qw/pdf txt doc docx epub txt xlsx xls pptx ppt odt ods csv/];
$def_ext{"Compressed"} = [qw/gz xz zip rar 7z bz bz2 gz tar/];

sub read_config {
    unless (-f $config_file) { return }
    open(FH, "<" . $config_file) or die "Unable to open $config_file";
    %def_ext = ();
    while(<FH>) {
        for ($_) {
            s/\#.*//; # ignore comments
            s/\s+/ /g; # remove extra whitespace
            s/^\s+//g; # strip left whitespace
            s/\s+$//g; # strip right whitespace
        }
        my @info = split " ", $_;
        my $dir = shift @info;
        $def_ext{$dir} = \@info;
    }
}

sub print_detail {
    my ($detail) = @_;
    my $current_dir = getcwd;
    $detail =~ s/$current_dir\///g;
    $detail =~ s/\/+/\//g;
    print $detail;
}

# Max depth feature; preprocessor fn for File::Find
sub preprocess {
    my $depth = $File::Find::dir =~ tr[/][];
    return @_ if $depth < $maxdepth;
}

# Select files and directories; filtering fn for File:Find
sub wanted {
    my $name = $File::Find::name;
    my $file = (split "/", $name)[-1];
    if ($file =~ /^\./) { return } # ignore hidden files/dirs

    if (-f) {
        push(@all_files, $name);
    } elsif (-d) {
        push(@all_dirs, $name);
    }
}

# create dir if not already exist and move file to dir
sub create_dir_and_move {
    my ($new_dir, $f) = @_;
    my $dir_created;
    if ($dry_run) { # if dry run dont create dir
        $dir_created = 1 # pretend dir_created
    } else {
        $dir_created = (-d $new_dir) || make_path($new_dir);
    }
    my $file_name = (split /\//, $f)[-1];
    if ($dir_created) {
        my $new_file_path = "$new_dir/$file_name";
        if (-f $new_file_path) {
            print "$f already exists \n";
        } else {
            my $detail = "$f -> $new_file_path\n";
            if ($dry_run) { print_detail($detail); return }
            if (move($f, $new_dir)) { # if moving is successfull
                $files_moved_details .= $detail;
                if ($verbose) { print_detail($detail); }
                $moved_files_count++;
            }
        }
    } else {
        print "Unable to create directory $new_dir \n"
    }
}

# find all files this fn is also used just to find files
# and start moving them to their corresponding dir
# also find dirs
sub arrange {
    my ($dir) = @_;
    $dir ||= getcwd;
    $dir =~ s/\/+$//; # remove trailing slash(es)
    $maxdepth += tr[/][] for $dir;
    find( {
        preprocess => \&preprocess,
        wanted => \&wanted,
    }, $dir);

    unless (@all_files) { return }

    if ($by_name) { arrange_by_name($dir) ; return }
    if ($no_arrange) { return }
    foreach my $f (@all_files) {
        my $f_ext = (split /\./, $f)[-1];
        my $file_moved = 0;
        foreach my $d (keys %def_ext) {
            if (grep /$f_ext$/, @{$def_ext{$d}}) {
                my $new_dir = "$dir/$d";
                $file_moved = 1;
                create_dir_and_move($new_dir, $f);
            }
        }
        # file not in %extensions
        unless ($file_moved || $no_others) {
            my $new_dir = $dir . "/Other";
            create_dir_and_move($new_dir, $f);
        }
    }
}

sub arrange_by_name {
    my ($dir) = @_;
    my $new_dir = "$dir/$user_dir";
    my $f_moved;
    foreach my $f (@all_files) {
        my $file_name = (split "/", $f)[-1];
        foreach my $name (@user_names) {
            my $pattern = $name;
            $pattern =~ s/\*/.*/g; # wildcard to regex
            if ($file_name =~ /^$pattern$/) {
                create_dir_and_move($new_dir, $f);
                $f_moved = 1;
                last; # break out of loop
            }
        }
        if ($f_moved) { next } # file moved ; continue to next file
        foreach my $name (@user_inames) {
            my $pattern = $name;
            $pattern =~ s/\*/.*/g; # wildcard to regex
            if ($file_name =~ /^$pattern$/i) {
                create_dir_and_move($new_dir, $f);
                last; # break out of loop
            }
        }
    }
}

# restore the moved files ; require a logfile to restore
sub revert_move {
    open(FH, '<' . $revert) or die "Unable to open log file\n";
    while(<FH>) {
        my ($initial, $final) = split " -> ", $_;
        chomp $final;
        my ($file_name, $new_dir) = fileparse($initial);
        chop $new_dir;
        create_dir_and_move($new_dir, $final);
    }
}

# uses @all_dirs to remove empty dirs (rmdir only remove dir if empty)
sub delete_empty_dirs {
    my $dirs_deleted = 0;
    foreach my $dir (@all_dirs) {
        rmdir($dir) && $dirs_deleted++;
    }
    print $dirs_deleted . " Directory deleted\n"
}

sub save_log {
    unless ($files_moved_details) { return }
    unless (-d $logs_dir) { make_path $logs_dir }

    open(FH, ">" . $logs_dir . "/" . $w_logfile) or die "Unable to open $w_logfile\n";
    print FH $files_moved_details;
    close(FH);
}

# read cli args for dirs to arrange
sub start_arrange {
    # if 1 or more dirs are specified arrange them all one by one
    if (scalar @ARGV >= 1) {
        foreach my $dir (@ARGV) {
            if (-d $dir) { arrange($dir) }
        }
    } else { # if no dir is given arrange current dir
        arrange();
    }
}

sub print_help {
    my $help_text = qq{usage: arng [dirs] [options]\n
    -m, --maxdepth=INT \t\t specify maxdepth (> 1)
    -h, --help \t\t\t show this help message
    -dry, --dry-run \t\t show what will happen without moving
    -v, --verbose \t\t print file name while moving
    -rev, --revert \t\t revert the move (require a logfile)
    -log, --logfile=STR \t specify logfile (required for reverting)
    -nl, --no-log \t\t dont save log
    -nu, --no-unknown \t\t dont move unrecognised filetypes
    -na, --no-arrange \t\t dont arrange (use when you want to delete empty dirs)
    -de, --delete-empty \t delete empty directories (will also arrange)
    -ext, --extensions=STRs \t extension(s) to move (requires a Directory)
    -dir, --directory=STR \t Directory to move files (required by -ext)\n};
    print $help_text;
}

sub main {
    read_config();

    GetOptions (
        "help|h" => \$help,
        "maxdepth|max=i" => \$maxdepth,
        "revert|rev=s" => \$revert,
        "verbose|v" => \$verbose,
        "dry-run|dry" => \$dry_run,
        "no-log|nl" => \$keep_log,
        "no-unknown|nu" => \$no_others,
        "no-arrange|na" => \$no_arrange,
        "delete-empty|de" => \$delete_empty,
        "extensions|ext=s{1,}" => \@user_ext,
        "directory|dir=s" => \$user_dir,
        "name=s{1,}" => \@user_names,
        "iname=s{1,}" => \@user_inames
    ) or die("Error in command line arguments\n");

    if ($help) {
        print_help();
        exit;
    }

    if (@user_ext && $user_dir) {
        %def_ext = ();
        $def_ext{$user_dir} = \@user_ext;
        $no_others = 1;
    } elsif (@user_ext && ! $user_dir) {
        print "Must specify Extensions and Directory\n";
        print "Example: arng -ext png -dir Images\n";
        exit;
    }

    if (@user_names || @user_inames) {
        $by_name = 1;
    }

    if ($by_name && ! $user_dir) {
        print "Must specify Patterns and Directory\n";
        print "Example: arng -name Episode -dir Episodes\n";
        print "Example: arng -iname episode -dir Episodes\n";
        exit;
    }

    if ($revert) {
        revert_move();
    } else {
        start_arrange();
    }

    if ($delete_empty) {
        delete_empty_dirs();
    }

    # write info to a file
    unless ($keep_log || $dry_run) {
        save_log();
    }
    print $moved_files_count . " Files moved\n"
}

main();

