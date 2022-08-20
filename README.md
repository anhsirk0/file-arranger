<h1 align="center"><code>arng</code></h1>
<p align="center">Simple & <strong>Capable</strong> files arranger (previously <code>arranger</code>)</p>

## About
Arng is a CLI file arng written in Perl   
It cleans up your Directory by moving files to their corresponding Directory by their file extension  
jpg, png, jpeg, webp -> Images  
mp4, mkv, avi, flv -> Videos  
and other common filetype extensions  

## Features
Arng can
 - control maxdepth when arranging
 - delete empty Directories
 - save logs of what exactly happened
 - revert the move using logfile
 - move only specific files by provided file extensions & Directory
 - arrange more than one Directory
 - move unrecognised filetypes to 'Other' Directory
 - arrange files by patterns

## Installation
Its just a perl script
download it make it executable and put somewhere in your $PATH

## Via install script
```bash
bash -c "$(curl https://raw.githubusercontent.com/anhsirk0/file-arranger/master/install.sh)"
```
## Manually

with wget
``` bash
wget https://raw.githubusercontent.com/anhsirk0/file-arranger/master/arng.pl -O arng
```
### or
with curl
``` bash
curl https://raw.githubusercontent.com/anhsirk0/file-arranger/master/arng.pl --output arng
```
making it executable
```bash
chmod +x arng
```
copying it to $PATH (~/.local/bin/ , this step is optional)
```bash
cp arng ~/.local/bin/
```

## Usage

```bash
arng [dirs] [options]
```
will arrange current Directory  
see examples for detailed usage

## Examples
### adding verbose
```bash
$ arng -v
files2.mp4 -> Videos/files2.mp4
files2.mp3 -> Music/files2.mp3
files1.mp4 -> Videos/files1.mp4
files2.pl -> Other/files2.pl
files1.mp3 -> Music/files1.mp3
files1.pdf -> Documents/files1.pdf
files1.pl -> Other/files1.pl
files2.pdf -> Documents/files2.pdf
8 Files moved
```

### moving files by extensions to provided dir
```bash
$ arng -ext sh zsh fish -dir shell -v
script.sh -> shell/script.sh
script.zsh -> shell/script.zsh
script.fish -> shell/script.fish
3 Files moved
```

### reversing the move via a logfile
```bash
$ arng -rev "~/.config/arng/logs/logfile1234"
8 files moved
```

### not saving logs and not moving unrecognised filetypes to 'Other'
```bash
$ arng -nl -nu
```
or 
```bash
$ arng --no-log --no-unknown
```

### dry-run
```bash
$ arng -dry
files2.mp4 -> Videos/files2.mp4
files2.mp3 -> Music/files2.mp3
files1.mp4 -> Videos/files1.mp4
files2.pl -> Other/files2.pl
files1.mp3 -> Music/files1.mp3
files1.pdf -> Documents/files1.pdf
files1.pl -> Other/files1.pl
files2.pdf -> Documents/files2.pdf
0 Files moved
```

### deleting empty directories
```bash
$ arng --delete-empty --no-arrange
2 Directory deleted
0 files moved
```
or
```bash
$ arng -de -na
2 Directory deleted
0 files moved
```

### name/iname
```bash
$ arng -iname "episode*" -dir "Episodes" -v
episode_1.mp4 -> Episodes/episode_1.mp4
EPISODE_3.mp4 -> Episodes/EPISODE_3.mp4
episode_2.mp4 -> Episodes/episode_2.mp4
EPISODE_4.mp4 -> Episodes/EPISODE_4.mp4
4 Files moved
```

### maxdepth
```bash
$ tree
.
└── dir
    ├── subdir1
    │   ├── subdir1_file.mp3
    │   ├── subdir1_file.mp4
    │   └── subdir1_file.pdf
    └── subdir2
        ├── subdir2_file.mp3
        ├── subdir2_file.mp4
        └── subdir2_file.pdf

3 directories, 6 files
```

```bash
$ arng
0 files moved
```
```bash
$ arng --maxdepth 3 -v
dir/subdir2/subdir2_file.mp4 -> Videos/subdir2_file.mp4
dir/subdir2/subdir2_file.pdf -> Documents/subdir2_file.pdf
dir/subdir2/subdir2_file.mp3 -> Music/subdir2_file.mp3
dir/subdir1/subdir1_file.mp4 -> Videos/subdir1_file.mp4
dir/subdir1/subdir1_file.pdf -> Documents/subdir1_file.pdf
dir/subdir1/subdir1_file.mp3 -> Music/subdir1_file.mp3
6 Files moved
```
## Tweaking arng via config file
you need to create a file ~/.config/arng/arng.conf

you can download the sample config file and move it into the config Directory

```bash
wget https://raw.githubusercontent.com/anhsirk0/file-arranger/master/arng.conf
```
### or
with curl
``` bash
curl https://raw.githubusercontent.com/anhsirk0/file-arranger/master/arng.conf --output arng.conf
```

### move to config dir
```bash
mv arng.conf ~/.config/arng/arng.conf
```

## About config file
 - everything should be space separated (don't worry about extra/trailing spaces)
 - first word of line would be Directory name rest would be file extensions associated with that Directory

## Available options
**-m** or **--maxdepth=INT**   specify maxdepth (> 1)  
**-h** or **--help**    show this help message  
**-dry** or **--dry-run**    show what will happen without actually arranging  
**-v** or **--verbose**    print file name while moving  
**-rev** or **--revert**    revert the move (require a logfile)  
**-log** or **--logfile=STR**    specify logfile (required for reverting)  
**-no-log**    dont save log  
**-no-unknown**    dont move unrecognised filetypes  
**-no-arrange**    dont move any file (helpful if you only want to delete empty dirs)  
**-delete-empty**    delete empty directories (if any)  
**-ext** or **--extensions=STRs** specify extension(s) to move (requires a Directory)  
**-name=STRs** specify patterns (case sensitive) to move files (requires a Directory)  
**-iname=STRs** specify patterns (case insensitive) to move files (requires a Directory)  
**-dir** or **--directory=STR** specify the Directory to move files in (required by -ext/name/iname)  

