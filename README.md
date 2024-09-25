# Snake86

## Introduction

**SNAKE86** is a 2KB hungry snake game in about 200 lines of MASM 8086
assembly. 

This program was originally a demo I made to test my understanding of Intel CPU architecture.
It took about 700 lines of code so I decided to improve its
performance and shrink the size of the source file.

Structure of the project:

- **MS-DOS**
  - **SNAKE86.ASM** - the Snake86 source file
  - **SNAKE86.TXT** - document about the executable
  - **MAKE.BAT** - batch script for compilation
- **js-dos**
  - **dosbox.conf** - configuration for js-dos backend emulator
  - **jsdos.json** - configuration for js-dos webpage
- **release** (generated after make)
  - **SNAKE86.EXE** - the Snake86 executable
  - **SNAKE86.TXT** - document about the executable
  - **snake86.jsdos** - portable js-dos bundle to run on webpages
- **dosbox.conf** - configuration for compilation (make)
- **Makefile** - you know it

## Compile Snake86

To compile Snake86 a DOS environment alongwith MASM tool 
set is needed. I would recommend **DOS-Box 0.74** and 
**MASM 6.11**. You can find these archives
[here](https://winworldpc.com/product/macro-assembler/6x).
Note that js-dos is not necessary during compilation, not even for the
generation of js-dos bundle.

Then, modify the last 2 lines of `dosbox.conf` to mount your MASM tool
installation directory and set the `PATH` environment variable. For example:

```conf
MOUNT X ~/.dosbox/MASM611
PATH=Z:\;X:\BIN;X:\BINR
```

After that, run `make` to compile Snake86.

#### Manual compilation (i.e. on Windows)

In some cases Snake86 can only be compiled manually. Run this command under
DOS environment at `MS-DOS` directory.

`ML /nologo /w SNAKE86.ASM /link /NOLOGO /F /E`

## Play Snake86

You can play Snake86 on any DOS machine and emulators like DOS-Box by running
`SNAKE86.EXE`, or load the js-dos bundle `snake86.jsdos` on your webpage.
For example, run:

`cd release; dosbox SNAKE86.EXE -exit >/dev/null &`

The goal is to grow as long as possible in a 80\*50 sandbox and avoid collison
with the wall or your body. The sandbox is made up of 4\*4 blocks - green for
snake body, red for fruit and white for the wall and our snake starts at
block(1,1) heading right with 1 length.
Eating a fruit would increment its body length by 1.

- **w**  Controls your snake to go up
- **a**  Controls your snake to go left
- **s**  Controls your snake to go down
- **d**  Controls your snake to go right
- **q**  Halt the game
- Press **any** key to quit to the command line when the game is stopped.

When the snake dies the game is stopped. It has only 1 health point so be 
careful.

Have fun if you find it interesting or useful. It feels bad to mess with all
the calling conventions, though.

**last updated on Sep 24, 2024**