// This file is part of www.nand2tetris.org
// and the book "The Elements of Computing Systems"
// by Nisan and Schocken, MIT Press.
// File name: projects/05/CPU-external.tst

load CPU.hdl,
output-file CPU-external.out,
compare-to CPU-external.cmp,
output-list time%S0.4.0 inM%D0.6.0 instruction%B0.16.0 reset%B2.1.2 outM%D1.6.0 writeM%B3.1.3 addressM%D0.5.0 pc%D0.5.0;

// 1
set instruction %B0011000000111001, // @12345
tick, output, tock, output;
// 2
set instruction %B1110110000010000, // D=A
tick, output, tock, output;
// 3
set instruction %B0101101110100000, // @23456
tick, output, tock, output;
// 4
set instruction %B1110000111010000, // D=A-D
tick, output, tock, output;
// 5
set instruction %B0000001111101000, // @1000
tick, output, tock, output;
// 6
set instruction %B1110001100001000, // M=D
tick, output, tock, output;
// 7
set instruction %B0000001111101001, // @1001
tick, output, tock, output;
// 8
set instruction %B1110001110011000, // MD=D-1
tick, output, tock, output;
// 9
set instruction %B0000001111101000, // @1000
tick, output, tock, output;
// 10
set instruction %B1111010011010000, // D=D-M
set inM 11111,
tick, output, tock, output;
// 11
set instruction %B0000000000001110, // @14
tick, output, tock, output;
// 12
set instruction %B1110001100000100, // D;jlt
tick, output, tock, output;
// 13
set instruction %B0000001111100111, // @999
tick, output, tock, output;
// 14
set instruction %B1110110111100000, // A=A+1
tick, output, tock, output;
// 15:
set instruction %B1110001100001000, // M=D
tick, output, tock, output;
// 16
set instruction %B0000000000010101, // @21
tick, output, tock, output;
// 17
set instruction %B1110011111000010, // D+1;jeq
tick, output, tock, output;
// 18
set instruction %B0000000000000010, // @2
tick, output, tock, output;
// 19
set instruction %B1110000010010000, // D=D+A
tick, output, tock, output;
// 20
set instruction %B0000001111101000, // @1000
tick, output, tock, output;
// 21
set instruction %B1110111010010000, // D=-1
tick, output, tock, output;
// 22
set instruction %B1110001100000001, // D;JGT
tick, output, tock, output;
// 23
set instruction %B1110001100000010, // D;JEQ
tick, output, tock, output;
// 24
set instruction %B1110001100000011, // D;JGE
tick, output, tock, output;
// 25
set instruction %B1110001100000100, // D;JLT
tick, output, tock, output;
// 26
set instruction %B1110001100000101, // D;JNE
tick, output, tock, output;
// 27
set instruction %B1110001100000110, // D;JLE
tick, output, tock, output;
// 28
set instruction %B1110001100000111, // D;JMP
tick, output, tock, output;
// 29
set instruction %B1110101010010000, // D=0
tick, output, tock, output;
// 30
set instruction %B1110001100000001, // D;JGT
tick, output, tock, output;
// 31
set instruction %B1110001100000010, // D;JEQ
tick, output, tock, output;
// 32
set instruction %B1110001100000011, // D;JGE
tick, output, tock, output;
// 33
set instruction %B1110001100000100, // D;JLT
tick, output, tock, output;
// 34
set instruction %B1110001100000101, // D;JNE
tick, output, tock, output;
// 35
set instruction %B1110001100000110, // D;JLE
tick, output, tock, output;
// 36
set instruction %B1110001100000111, // D;JMP
tick, output, tock, output;
// 37
set instruction %B1110111111010000, // D=1
tick, output, tock, output;
// 38
set instruction %B1110001100000001, // D;JGT
tick, output, tock, output;
// 39
set instruction %B1110001100000010, // D;JEQ
tick, output, tock, output;
// 40
set instruction %B1110001100000011, // D;JGE
tick, output, tock, output;
// 41
set instruction %B1110001100000100, // D;JLT
tick, output, tock, output;
// 42
set instruction %B1110001100000101, // D;JNE
tick, output, tock, output;
// 43
set instruction %B1110001100000110, // D;JLE
tick, output, tock, output;
// 44
set instruction %B1110001100000111, // D;JMP
tick, output, tock, output;
// 45
set reset 1;
tick, output, tock, output;
// 46
set instruction %B0111111111111111, // @32767
set reset 0;
tick, output, tock, output;
