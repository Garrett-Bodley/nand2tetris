// Push Constant
@0
D=A
@SP
A=M
M=D
@SP
M=M+1
// Pop to segment: local
@LCL
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
(LOOP_START)
// Push from segment: argument
@ARG
A=M
D=M
@SP
A=M
M=D
@SP
M=M+1
// Push from segment: local
@LCL
A=M
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
// Pop to segment: local
@LCL
D=M
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
@LOOP_START
D;JNE
// Push from segment: local
@LCL
A=M
D=M
@SP
A=M
M=D
@SP
M=M+1
(INFINITE_LOOP)
@INFINITE_LOOP
0; JMP
