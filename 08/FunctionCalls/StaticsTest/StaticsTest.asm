@256
D=A
@SP
M=D
// Pushing Return Address!
@RETURN_ADDRESS.0
D=A
@SP
A=M
M=D
@SP
M=M+1
@LCL
D=M
@SP
A=M
M=D
@SP
M=M+1
@ARG
D=M
@SP
A=M
M=D
@SP
M=M+1
@THIS
D=M
@SP
A=M
M=D
@SP
M=M+1
@THAT
D=M
@SP
A=M
M=D
@SP
M=M+1
@SP
D=M
@5
D=D-A
@0
D=D-A
@ARG
M=D
@SP
D=M
@LCL
M=D
@Sys.init
0;JMP
(RETURN_ADDRESS.0)
(Sys.init)
// Push Constant
@6
D=A
@SP
A=M
M=D
@SP
M=M+1
// Push Constant
@8
D=A
@SP
A=M
M=D
@SP
M=M+1
// Pushing Return Address!
@RETURN_ADDRESS.1
D=A
@SP
A=M
M=D
@SP
M=M+1
@LCL
D=M
@SP
A=M
M=D
@SP
M=M+1
@ARG
D=M
@SP
A=M
M=D
@SP
M=M+1
@THIS
D=M
@SP
A=M
M=D
@SP
M=M+1
@THAT
D=M
@SP
A=M
M=D
@SP
M=M+1
@SP
D=M
@5
D=D-A
@2
D=D-A
@ARG
M=D
@SP
D=M
@LCL
M=D
@Class1.set
0;JMP
(RETURN_ADDRESS.1)
// Pop to temp
@5
D=A
@13
M=D
@SP
AM=M-1
D=M
@13
A=M
M=D
// Push Constant
@23
D=A
@SP
A=M
M=D
@SP
M=M+1
// Push Constant
@15
D=A
@SP
A=M
M=D
@SP
M=M+1
// Pushing Return Address!
@RETURN_ADDRESS.2
D=A
@SP
A=M
M=D
@SP
M=M+1
@LCL
D=M
@SP
A=M
M=D
@SP
M=M+1
@ARG
D=M
@SP
A=M
M=D
@SP
M=M+1
@THIS
D=M
@SP
A=M
M=D
@SP
M=M+1
@THAT
D=M
@SP
A=M
M=D
@SP
M=M+1
@SP
D=M
@5
D=D-A
@2
D=D-A
@ARG
M=D
@SP
D=M
@LCL
M=D
@Class2.set
0;JMP
(RETURN_ADDRESS.2)
// Pop to temp
@5
D=A
@13
M=D
@SP
AM=M-1
D=M
@13
A=M
M=D
// Pushing Return Address!
@RETURN_ADDRESS.3
D=A
@SP
A=M
M=D
@SP
M=M+1
@LCL
D=M
@SP
A=M
M=D
@SP
M=M+1
@ARG
D=M
@SP
A=M
M=D
@SP
M=M+1
@THIS
D=M
@SP
A=M
M=D
@SP
M=M+1
@THAT
D=M
@SP
A=M
M=D
@SP
M=M+1
@SP
D=M
@5
D=D-A
@0
D=D-A
@ARG
M=D
@SP
D=M
@LCL
M=D
@Class1.get
0;JMP
(RETURN_ADDRESS.3)
// Pushing Return Address!
@RETURN_ADDRESS.4
D=A
@SP
A=M
M=D
@SP
M=M+1
@LCL
D=M
@SP
A=M
M=D
@SP
M=M+1
@ARG
D=M
@SP
A=M
M=D
@SP
M=M+1
@THIS
D=M
@SP
A=M
M=D
@SP
M=M+1
@THAT
D=M
@SP
A=M
M=D
@SP
M=M+1
@SP
D=M
@5
D=D-A
@0
D=D-A
@ARG
M=D
@SP
D=M
@LCL
M=D
@Class2.get
0;JMP
(RETURN_ADDRESS.4)
// Label
(Sys.init$WHILE)
// goto
@Sys.init$WHILE
0; JMP
(Class1.set)
// Push from segment: argument
@ARG
A=M
D=M
@SP
A=M
M=D
@SP
M=M+1
// Pop to static
@SP
AM=M-1
D=M
@Class1.0
M=D
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
// Pop to static
@SP
AM=M-1
D=M
@Class1.1
M=D
// Push Constant
@0
D=A
@SP
A=M
M=D
@SP
M=M+1
// Saving LCL to register 14!
@LCL
D=M
@14
M=D
// Saving the return address!
@LCL
D=M
@5
A=D-A
D=M
@15
M=D
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
@ARG
D=M+1
@SP
M=D
@14
D=M
@1
A=D-A
D=M
@THAT
M=D
@14
D=M
@2
A=D-A
D=M
@THIS
M=D
@14
D=M
@3
A=D-A
D=M
@ARG
M=D
@14
D=M
@4
A=D-A
D=M
@LCL
M=D
// Going To the Return Address!
@15
A=M
0;JMP
(Class1.get)
// Push Static
@Class1.0
D=M
@SP
A=M
M=D
@SP
M=M+1
// Push Static
@Class1.1
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
M=M-D
// Saving LCL to register 14!
@LCL
D=M
@14
M=D
// Saving the return address!
@LCL
D=M
@5
A=D-A
D=M
@15
M=D
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
@ARG
D=M+1
@SP
M=D
@14
D=M
@1
A=D-A
D=M
@THAT
M=D
@14
D=M
@2
A=D-A
D=M
@THIS
M=D
@14
D=M
@3
A=D-A
D=M
@ARG
M=D
@14
D=M
@4
A=D-A
D=M
@LCL
M=D
// Going To the Return Address!
@15
A=M
0;JMP
(Class2.set)
// Push from segment: argument
@ARG
A=M
D=M
@SP
A=M
M=D
@SP
M=M+1
// Pop to static
@SP
AM=M-1
D=M
@Class2.0
M=D
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
// Pop to static
@SP
AM=M-1
D=M
@Class2.1
M=D
// Push Constant
@0
D=A
@SP
A=M
M=D
@SP
M=M+1
// Saving LCL to register 14!
@LCL
D=M
@14
M=D
// Saving the return address!
@LCL
D=M
@5
A=D-A
D=M
@15
M=D
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
@ARG
D=M+1
@SP
M=D
@14
D=M
@1
A=D-A
D=M
@THAT
M=D
@14
D=M
@2
A=D-A
D=M
@THIS
M=D
@14
D=M
@3
A=D-A
D=M
@ARG
M=D
@14
D=M
@4
A=D-A
D=M
@LCL
M=D
// Going To the Return Address!
@15
A=M
0;JMP
(Class2.get)
// Push Static
@Class2.0
D=M
@SP
A=M
M=D
@SP
M=M+1
// Push Static
@Class2.1
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
M=M-D
// Saving LCL to register 14!
@LCL
D=M
@14
M=D
// Saving the return address!
@LCL
D=M
@5
A=D-A
D=M
@15
M=D
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
@ARG
D=M+1
@SP
M=D
@14
D=M
@1
A=D-A
D=M
@THAT
M=D
@14
D=M
@2
A=D-A
D=M
@THIS
M=D
@14
D=M
@3
A=D-A
D=M
@ARG
M=D
@14
D=M
@4
A=D-A
D=M
@LCL
M=D
// Going To the Return Address!
@15
A=M
0;JMP
(INFINITE_LOOP)
@INFINITE_LOOP
0;JMP
