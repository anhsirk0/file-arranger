<h1 align="center"><code>Arranger</code></h1>
<p align="center">Simple & <strong>Capable</strong> files arranger</p>

## About
Arranger is a CLI file arranger written in Perl   
It cleans up your Directory by moving files to their corresponding Directory by their file extension  
jpg, png, jpeg webp -> Images  
mp4, mkv, avi, flv -> Videos  
and other common filetype extensions  

## Features
Arranger can
 - control maxdepth when arranging
 - delete empty Directories
 - save logs of what exactly happend
 - revert the move using logfile
 - move only specific files by provided file extensions & Directory
 - arrange more than one Directory
 - move unrecognised filetypes to 'Other' Directory

## installation
Its just a perl script
download it make it executable and put somewhere in your $PATH

with wget
``` bash
wget https://raw.githubusercontent.com/anhsirk0/file-arranger/master/arranger.pl -O arranger
```
### or
with curl
``` bash
curl https://raw.githubusercontent.com/anhsirk0/file-arranger/master/arranger.pl --output arranger
```
making it executable
```bash
chmod +x arranger
```

## Usage

```bash
arranger [dirs] [options]
```
will arrange current Directory  
see examples for detailed usage

## Screenshots
### arranger with no arguements
![out1.png](https://github.com/anhsirk0/file-arranger/blob/master/screenshots/out1.png)

### arranger moving specific files to provided dir
> arranger -ext py -dir Python
![out2.png](https://github.com/anhsirk0/file-arranger/blob/master/screenshots/out2.png)

### arranger reversing the move via a logfile
> arranger -rev -logfile arrange_log
![out3.png](https://github.com/anhsirk0/file-arranger/blob/master/screenshots/out3.png)

### arranger not saving logs and not moving unrecognised filetypes to 'Other'
> arranger -no-log -no-unknown
![out4.png](https://github.com/anhsirk0/file-arranger/blob/master/screenshots/out4.png)

### arranger arranging given Directories
> arranger folder1 folder2
![out5.png](https://github.com/anhsirk0/file-arranger/blob/master/screenshots/out5.png)

### arranger dry-run
> arranger -dry-run
![dry.png](https://github.com/anhsirk0/file-arranger/blob/master/screenshots/dry.png)

### arranger name/iname
> arranger -name "Episode.*" -dir "Episodes"
> arranger -iname "episode.*" -dir "Episodes"
![name.png](https://github.com/anhsirk0/file-arranger/blob/master/screenshots/name.png)

## Examples
```bash
arranger mydir1 mydir2 mydir3
```
>will arrange mydir1 mydir2 mydir3 Directories one by one


```bash
arranger -no-log
```
>arrange current Directory and wont save logfile


```bash
arranger -delete-empty 
```
>arrange current Directory and also delete empty Directories 


```bash
arranger -delete-empty -no-arrange
```
>only delete empty Directories , wont arrange


```bash
arranger -no-unknown 
```
>arrange current Directory and wont move files with unrecognised extensions


```bash
arranger -ext pl -dir "Perl" 
```
>move all files with pl extension to Directory 'Perl'


```bash
arranger -ext jpg png jpeg svg -dir "Images" 
```
>move all files with any of {jpg, png, jpeg, svg} extension to Directory 'Images'


```bash
arranger -name ".*Season.*1.*" -dir "Season_1" 
```
```bash
arranger -iname ".*season.*1.*" -dir "Season_1" 
```
```bash
arranger -iname "episode.*" ".*part.*" -name ".*Videos.*" -dir "Episodes_Parts_and_Videos" 
```
>move all files with given regex pattern  to Directory 'Season_1'
>name for case sensitive regex matches and iname for case insensitive
>you can use multiple patterns for both -name and -iname 
>you dont need to specify ^ (start of line) and $ (end of line)
**You should be careful while using name/iname , it doesnot match wildcards**  
**It only match regex patterns**

## Tweaking arranger via config file
you need to create a file ~/.config/arranger/arranger.conf

you can download the sample config file and move it into the config Directory

```bash
wget https://raw.githubusercontent.com/anhsirk0/file-arranger/master/arranger.conf
```
### or
with curl
``` bash
curl https://raw.githubusercontent.com/anhsirk0/file-arranger/master/arranger.conf --output arranger.conf
```

### move to config dir
```bash
mv arranger.conf ~/.config/arranger/arranger.conf
```

## About config file
 - everything should be single space separated(no trailing spaces)
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
**-dir** or **--directory=STR** specify the Directory to move files in (required by -ext)  

