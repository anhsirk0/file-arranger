<h1 align="center"><code>Arranger</code></h1>
<p align="center">Simple & <strong>Capable</strong> files arranger</p>

## About
Arranger is a CLI file arng written in Perl   
It cleans up your Directory by moving files to their corresponding Directory by their file extension  
jpg, png, jpeg webp -> Images  
mp4, mkv, avi, flv -> Videos  
and other common filetype extensions  

## Features
Arranger can
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

## Screenshots
### with no arguements
![out1.png](https://github.com/anhsirk0/file-arranger/blob/master/screenshots/out1.png)

### adding verbose
> arng -v
![out6.png](https://github.com/anhsirk0/file-arranger/blob/master/screenshots/out6.png)

### moving specific files to provided dir
> arng -ext py -dir Python
![out2.png](https://github.com/anhsirk0/file-arranger/blob/master/screenshots/out2.png)

### reversing the move via a logfile
> arng -rev -logfile arrange_log
![out3.png](https://github.com/anhsirk0/file-arranger/blob/master/screenshots/out3.png)

### not saving logs and not moving unrecognised filetypes to 'Other'
> arng -no-log -no-unknown
![out4.png](https://github.com/anhsirk0/file-arranger/blob/master/screenshots/out4.png)

### arranging given Directories
> arng dir1 dir2
![out5.png](https://github.com/anhsirk0/file-arranger/blob/master/screenshots/out5.png)

### dry-run
> arng -dry-run
![dry.png](https://github.com/anhsirk0/file-arranger/blob/master/screenshots/dry.png)

### deleting empty directories
> arng -de -no-arrange
![delete.png](https://github.com/anhsirk0/file-arranger/blob/master/screenshots/delete.png)

### name/iname
> arng -name "Episode.*" -dir "Episodes"
> arng -iname "episode.*" -dir "Episodes"
![name.png](https://github.com/anhsirk0/file-arranger/blob/master/screenshots/name.png)

## Examples
```bash
arng mydir1 mydir2 mydir3
```
>will arrange mydir1 mydir2 mydir3 Directories one by one


```bash
arng -no-log
```
>arrange current Directory and dont save logfile


```bash
arng -delete-empty 
```
>arrange current Directory and also delete empty Directories 


```bash
arng -delete-empty -no-arrange
```
>only delete empty Directories , dont arrange


```bash
arng -no-unknown 
```
>arrange current Directory and dont move files with unrecognised extensions


```bash
arng -ext pl -dir "Perl" 
```
>move all files with pl extension to Directory 'Perl'


```bash
arng -ext jpg png jpeg svg -dir "Images" 
```
>move all files with any of {jpg, png, jpeg, svg} extension to Directory 'Images'


```bash
arng -name "*Season*1*" -dir "Season_1" 
```
```bash
arng -iname "*season*1*" -dir "Season_1" 
```
```bash
arng -iname "episode*" "*part*" -name "*Videos*" -dir "Episodes_Parts_and_Videos" 
```
>move all files with given regex pattern  to Directory 'Season_1'  
>name for case sensitive regex matches and iname for case insensitive  
>you can use multiple patterns for both -name and -iname   
>no need to specify ^ (start of line) and $ (end of line)  
>wildcard support is now added  

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

