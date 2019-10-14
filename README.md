# Turbo Pascal Demo Program for 1980s Macintoshes

This is a very simple application to provide an example of what programming GUI applications in the mid to late 1980s was like. This can be used as a starting point for a serious application or just to look as some of the weirdness of cooperative multitasking. All this application does is create a window with one button which launches a dialog when clicked. The same dialog shows when the 'About' menu is clicked. The code provides examples of how to create windows, controls, and dialogs, how to respond to mousedown events, and how to store icons, windows, and dialogs in a resource file. Note that since the versions of MacOS this application is targeting use cooperative multitasking, the application must deal with a lot of functionality which would normally be handled by the OS in a preemtive multitasking environment.

## Requirements
* A Macintosh or emulator capable of running Macintosh System Software 4 (or possibly 3?) to MacOS 7 (possibly 8?)
* Turbo Pascal 1.1 for Macintosh (this program MAY be compatible with MPW or THINK Pascal, but this has not been tested)
* A way to load files into the emulator or Macintosh 

## Running
1. Load Demo1.pas and Demo1.r onto a Macintosh formatted floppy disk or into a Macintosh emulator (both files will need type `TEXT` and creator `TPAS` to be recognized by Turbo Pascal)
2. Launch RMaker (provided with Turbo Pascal) and open Demo1.r to compile the resource file
3. Open Demo1.pas in Turbo Pascal and select 'Run' from the 'Compile' menu

## Building
1. Follow steps 1 and 2 under 'Running'
3. Open Demo1.pas in Turbo Pascal and Select 'To Disk' under the 'Compile' menu