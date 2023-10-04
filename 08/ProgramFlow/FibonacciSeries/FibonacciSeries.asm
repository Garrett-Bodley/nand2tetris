// Push from segment: argument
@ARG
A=M
D=A
@1
A=D+A
D=M
@SP
A=M
M=D
@SP
M=M+1
// Pop to pointer
@SP
AM=M-1
D=M
@THAT
M=D
// Push Constant
@0
D=A
@SP
A=M
M=D
@SP
M=M+1
// Pop to segment: that
@THAT
D=M
@13
M=D
@SP
AM=M-1
D=M
@13
A=M
M=D
// Push Constant
@1
D=A
@SP
A=M
M=D
@SP
M=M+1
// Pop to segment: that
@THAT
D=M
@1
D=D+A
@13
M=D
@SP
AM=M-1
D=M
@13
A=M
M=D
// Push from segment: argument
@ARG
A=M
D=M
@SP
A=M
M=D
@SP
M=M+1
// Push Constant
@2
D=A
@SP
A=M
M=D
@SP
M=M+1
@SP
AM=M-1
D=M
A=A-1
M=M-D
// Pop to segment: argument
@ARG
D=M
@13
M=D
@SP
AM=M-1
D=M
@13
A=M
M=D
// Label
(MAIN_LOOP_START)
// Push from segment: argument
@ARG
A=M
D=M
@SP
A=M
M=D
@SP
M=M+1
// if-goto
@SP
AM=M-1
D=M
@COMPUTE_ELEMENT
D;JNE
// goto
@END_PROGRAM
0; JMP
// Label
(COMPUTE_ELEMENT)
// Push from segment: that
@THAT
A=M
D=M
@SP
A=M
M=D
@SP
M=M+1
// Push from segment: that
@THAT
A=M
D=A
@1
A=D+A
D=M
@SP
A=M
M=D
@SP
M=M+1
@SP
AM=M-1
D=M
A=A-1
M=M+D
// Pop to segment: that
@THAT
D=M
@2
D=D+A
@13
M=D
@SP
AM=M-1
D=M
@13
A=M
M=D
// Push Pointer
@THAT
D=M
@SP
A=M
M=D
@SP
M=M+1
// Push Constant
@1
D=A
@SP
A=M
M=D
@SP
M=M+1
@SP
AM=M-1
D=M
A=A-1
M=M+D
// Pop to pointer
@SP
AM=M-1
D=M
@THAT
M=D
// Push from segment: argument
@ARG
A=M
D=M
@SP
A=M
M=D
@SP
M=M+1
// Push Constant
@1
D=A
@SP
A=M
M=D
@SP
M=M+1
@SP
AM=M-1
D=M
A=A-1
M=M-D
// Pop to segment: argument
@ARG
D=M
@13
M=D
@SP
AM=M-1
D=M
@13
A=M
M=D
// goto
@MAIN_LOOP_START
0; JMP
// Label
(END_PROGRAM)
(INFINITE_LOOP)
@INFINITE_LOOP
0; JMP
