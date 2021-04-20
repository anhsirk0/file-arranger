<h1 align="center"><code>Arranger</code></h1>
<p align="center">Simple & <strong>Capable</strong> files arranger</p>

## About
Arranger is a CLI file arranger written in Perl (for portability)  
It cleans up your Directory by moving files to their corresponding Directory by their file extension  
jpg, png, jpeg webp -> Images  
mp4, mkv, avi, flv -> Videos  
and other common filetype extensions  

### Features
Arranger can
 - control maxdepth
 - delete empty Directories
 - save logs of what exactly happend
 - revert the move using logfile
 - move only specific files by provided file extensions & Directory
 - move more than one Directory
 - move unrecognised filetypes to 'Other' Directory

### installation
Its just a perl script
download it make it executable and put in your path folder

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

### usage

```bash
arranger
```
will arrange current Directory


```bash
arranger mydir1 mydir2 mydir3
```
will arrange mydir1 mydir2 mydir3 Directories one by one


```bash
arranger -no-log
```
arrange current Directory and wont save logfile


```bash
arranger -delete-empty 
```
arrange current Directory and also delete empty Directories 



```bash
arranger -delete-empty -no-arrange
```
only delete empty Directories , wont arrange


```bash
arranger -no-unknown 
```
arrange current Directory and wont move files with unrecognised extensions


```bash
arranger -ext pl -dir "Perl" 
```
move all files with pl extension to Directory 'Perl'


```bash
arranger -ext jpg png jpeg svg -dir "Images" 
```
move all files with any of {jpg, png, jpeg, svg} extension to Directory 'Images'




