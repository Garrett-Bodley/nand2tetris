// This file is part of www.nand2tetris.org
// and the book "The Elements of Computing Systems"
// by Nisan and Schocken, MIT Press.
// File name: projects/04/Mult.asm

// Multiplies R0 and R1 and stores the result in R2.
// (R0, R1, R2 refer to RAM[0], RAM[1], and RAM[2], respectively.)
//
// This program only needs to handle arguments that satisfy
// R0 >= 0, R1 >= 0, and R0*R1 < 32768.

// Put your code here.

// PSEUDOCODE
// If one is zero:
// return 0

// If both are positive:
// mult = (a, b) => {
//   if(a == 0 || b == 0) return 0
//   res = 0
//   for(let i = 1; i <= b; i++){
//     res += a
//   }
//   return a < 0 || b < 0 ? -res : res
// }

// Bitwise AND does not work

// // Initialize R2 to 0
// @R2
// M=0
// @R3
// M=0


// // D = R0 AND R1
// @R0
// D=M
// @RETURNZERO
// D;JEQ
// @R1
// D=M
// @RETURNZERO
// D;JEQ

// // // If D !== 0
// // @MULTIPLY
// // D; JNE
// // // R2 = 0
// // // Return R3
// // @0
// // D=A
// // @R2
// // M=D
// // @END
// // 0; JMP

// // (ISNEG)
// // // make sure negflag is zero to start
// // @negflag
// // M=0

// // // Bitwise Or: R0|R1
// // @R0
// // D=M
// // @R1
// // D=D|M
// // // If D > 0, jump to multiplication
// // @MULTIPLY
// // D; JGT
// // // Otherwise, set negflag = 1
// // @1
// // D=A
// // @negflag
// // M=D



// (MULTIPLY)
// // Base multiplication Logic

// // let i = 0
// @0
// D=A
// @R3
// M=D
// (LOOP)
//   // load i
//   @R3
//   D=M
//   // load n
//   @R1
//   // D = i - n
//   D=D-M
//   // while ((i - n) <= 0)
//   @LOOP_END
//   D;JGE
//   // load a
//   @R0
//   D=M
//   // res = res + a
//   @R2
//   M=D+M
//   // i = i + 1
//   @R3
//   M=M+1
//   @LOOP
//   0;JMP
// (LOOP_END)

// @END
// 0;JMP

// (RETURNZERO)
// @R2
// M=0

// // @negflag
// // D=M
// // @END
// // D; JNE

// // // If A|B < 0
// // // R3 = -R3

// // @R3
// // D=!M
// // D=D+1
// // M=D

// (END)

// --------------------------

// WORKING VERSION

// Initialize R2 to 0
@R2
M=0
@R3
M=0

// if(R0 == 0) || (R1 == 0) return 0
// @R0
// D=M
// @RETURNZERO
// D;JEQ
// @R1
// D=M
// @RETURNZERO
// D;JEQ



// (MULTIPLY)
// Base multiplication Logic

// let i = 0
@0
D=A
@R3
M=D
(LOOP)
  // load i
  @R3
  D=M
  // load n
  @R1
  // D = i - n
  D=D-M
  // while ((i - n) <= 0)
  @LOOP_END
  D;JGE
  // load a
  @R0
  D=M
  // res = res + a
  @R2
  M=D+M
  // i = i + 1
  @R3
  M=M+1
  @LOOP
  0;JMP
(LOOP_END)

@END
0;JMP

// (RETURNZERO)
// @R2
// M=0

(END)

// -------------

// SUBROUTINE DRAFT

// (MULTIPLY)

// // Make 'a' a pointer to R0
// (a)
// @R0
// D=A
// @a
// M=D


// // Make 'b' a pointer to R0
// (b)
// @R1
// D=A
// @b
// M=D

// // Make 'i' a pointer to R3
// (i)
// @R3
// D=A
// @i
// M=D

// // Make 'multres' a pointer to R2
// (multres)
// @R2
// D=A
// @multres
// M=D

// (returnto)

// // Initialize multres to 0
// @multres
// D=M
// A=D
// M=0

// // if(R0 == 0) || (R1 == 0) return 0
// // LOAD 'a' into A regsiter
// @a
// // D = a.val aka address a points to
// D=M
// // A register = a.val (that same address)
// A=D
// // D register = value stored at that address
// D=M
// @RETURNZERO
// D;JEQ
// @b
// D=M
// A=D
// D=M
// @RETURNZERO
// D;JEQ

// (MULTIPLY)
// // Base multiplication Logic

// // let i = 0
// @i
// D=M
// A=D

// M=D
// (LOOP)
//   // load i
//   @i
//   D=M
//   // load n
//   @b
//   // D = i - n
//   D=D-M
//   // while ((i - n) <= 0)
//   @LOOP_END
//   D;JGE
//   // load a
//   @a
//   D=M
//   // res = res + a
//   @res
//   M=D+M
//   // i = i + 1
//   @i
//   M=M+1
//   @LOOP
//   0;JMP
// (LOOP_END)

// @END
// 0;JMP

// (RETURNZERO)
// @multres
// D=M
// @R2
// M=D

// (END)