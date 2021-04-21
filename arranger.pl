#!/usr/bin/env perl
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
my $user_dir;
my $help;
my $revert;
my $verbose;
my $logfile;
my $keep_log;
my $no_others;
my $no_arrange;
my $delete_empty;
my $moved_files_count = 0;
# store initial & final loacation of moved files
my $files_moved_details = "";
my $w_logfile = "arrange_log_" . localtime();
$w_logfile =~ s/ /_/g; # replace spaces with underscores

# hash; Directory name as keys & file extensions as values
my %def_ext;
$def_ext{"Images"} = [qw/jpg png jpeg svg webp/];
$def_ext{"Music"} = [qw/mp3 m3u ogg wav/];
$def_ext{"Videos"} = [qw/mp4 mkv avi flv/];
$def_ext{"Documents"} = [qw/pdf txt doc/];
$def_ext{"Compressed"} = [qw/gz xz zip rar 7z/];

# Max depth feature; preprocessor fn for File::Find
sub preprocess {
    my $depth = $File::Find::dir =~ tr[/][];
    return @_ if $depth < $maxdepth;
}

# Select files and directories; filtering fn for File:Find
sub wanted {
    if (-f) {
        push(@all_files, $File::Find::name);
    }
    elsif (-d) {
        push(@all_dirs, $File::Find::name);
    }
}

# create dir if not already exist and move file to dir
sub create_dir_and_move {
    my ($new_dir, $f) = @_; 
    my $dir_created = (-d $new_dir) || make_path($new_dir);
    my $file_name = (split /\//, $f)[-1];
    if ($dir_created) {
        my $new_file_path = "$new_dir/$file_name";
        if (-f $new_file_path) {
            print "$f already exists \n";
        } else {
            if (move($f, $new_dir)) {
                my $detail = "$f -> $new_file_path\n";
                $files_moved_details .= $detail;
                if ($verbose) { print $detail; }
                $moved_files_count++;
            }
        }
    } else {
        print "Unable to create directory $new_dir \n"
    }
}

# find all files and start moving them to their corresponding dir
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

    unless (@all_files) { print "No files to move\n"; exit }
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

# restore the moved files ; require a $logfile to restore
sub revert_move {
    unless ($logfile) { print "Log file is required\n"; exit }
    open(FH, '<' . $logfile) or die "Unable to open log file\n";
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
    unless (@all_dirs && $revert) {
        $no_arrange = 1;
        arrange();
    }
    foreach my $dir (@all_dirs) {
        rmdir($dir) && $dirs_deleted++;
    }
    print $dirs_deleted . " Directory deleted\n"
}

sub save_log {
    open(FH, ">" . $w_logfile) or die "Unable to open $w_logfile\n";
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
    print "usage: arranger [dirs] [options]\n\n";
    print "-m, --maxdepth=INT   specify maxdepth (> 1)\n";
    print "-m, --maxdepth=INT    \n";
}

sub main {
    GetOptions (
        "help" => \$help,
        "maxdepth=i" => \$maxdepth,
        "revert" => \$revert,
        "verbose" => \$verbose,
        "logfile=s" => \$logfile,
        "no-log" => \$keep_log,
        "no-unknown" => \$no_others,
        "no-arrange" => \$no_arrange,
        "delete-empty" => \$delete_empty,
        "extensions=s{1,}" => \@user_ext,
        "dir=s" => \$user_dir
    ) or die("Error in command line arguments\n");

    if ($help) {
        print_help();
        exit;
    }

    if ($user_dir && @user_ext) {
        %def_ext = ();
        $def_ext{$user_dir} = \@user_ext;
        $no_others = 1;
    } elsif ($user_dir || @user_ext) {
        print "Must specify Extensions and Directory\n";
        print "Example: arranger -ext png -dir Images\n";
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
    unless ($keep_log) {
        save_log();
    }
    print $moved_files_count . " Files moved\n"
}

main();

