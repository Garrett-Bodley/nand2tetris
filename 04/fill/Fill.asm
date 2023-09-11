// This file is part of www.nand2tetris.org
// and the book "The Elements of Computing Systems"
// by Nisan and Schocken, MIT Press.
// File name: projects/04/Fill.asm

// Runs an infinite loop that listens to the keyboard input.
// When a key is pressed (any key), the program blackens the screen,
// i.e. writes "black" in every pixel;
// the screen should remain fully black as long as the key is pressed. 
// When no key is pressed, the program clears the screen, i.e. writes
// "white" in every pixel;
// the screen should remain fully clear as long as no key is pressed.

// Put your code here.

// Keyboard I/O Location: 24576
// Screen Start: 16384
// Screen Size: 8192
// Screen End == Key I/O - 1

// Keyio = 24576

// @24576
// D=A
// @Keyio
// M=D

// // Screenstart = 16384
// @16384
// D=A
// @Screenstart
// M=D

// // Screenend = Keyio - 1
// @Keyio
// D=A
// @Screenend
// M=D-1

// // let i = ScreenStart

// @Screenstart
// D=M
// @i
// M=D

// let i = screenStart
// while(true){
//   if(keyIo > 0){
//     memory[i] = 1
//   }else{
//     memory[i] = 0
//   }
//   i = i + 1
//   if(i > screenEnd) i = screenStart
// }

@16384
D=A
@i
M=D

(LOOP)
  // D = keyio
  @24576
  D=M

  // if(keyio) > 0 {fill()}
  @FILL
  D; JGT

  // default behavior:
  // unfill
  @i
  D=M
  A=D
  M=0
  // increment i
  @i
  M=M+1

  @OVERFLOW_CHECK
  0; JMP

  (FILL)
  // Fill screen[i]
  @i
  D=M
  A=D
  // Paint pixel black
  M=-1
  // increment i
  @i
  M=M+1

  (OVERFLOW_CHECK)
  @i
  D=M
  // Screenend = 24575
  @24575
  // D= Screenend - i
  D=A-D
  @LOOP
  D; JGE
  
  // (HEAD_RESET)
  
  @16384
  D=A
  @i
  M=D
  @LOOP
  0; JMP
  
  
  (LOOP_END)