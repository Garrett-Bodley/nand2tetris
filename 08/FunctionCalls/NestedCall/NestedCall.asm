// Label
(Sys.Sys.init)
// Push Constant
@4000
D=A
@SP
A=M
M=D
@SP
M=M+1
// Pop to pointer
@SP
AM=M-1
D=M
@THIS
M=D
// Push Constant
@5000
D=A
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
// Pushing Return Address!
@Sys.RETURN.0
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
@Sys.Sys.main
0;JMP
(Sys.RETURN.0)
// Pop to temp
@6
D=A
@13
M=D
@SP
AM=M-1
D=M
@13
A=M
M=D
// Label
(Sys.LOOP)
// goto
@Sys.LOOP
0; JMP
// Label
(Sys.Sys.main)
// Push Constant
@0
D=A
@SP
A=M
M=D
@SP
M=M+1
// Push Constant
@0
D=A
@SP
A=M
M=D
@SP
M=M+1
// Push Constant
@0
D=A
@SP
A=M
M=D
@SP
M=M+1
// Push Constant
@0
D=A
@SP
A=M
M=D
@SP
M=M+1
// Push Constant
@0
D=A
@SP
A=M
M=D
@SP
M=M+1
// Push Constant
@4001
D=A
@SP
A=M
M=D
@SP
M=M+1
// Pop to pointer
@SP
AM=M-1
D=M
@THIS
M=D
// Push Constant
@5001
D=A
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
@200
D=A
@SP
A=M
M=D
@SP
M=M+1
// Pop to segment: local
@LCL
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
// Push Constant
@40
D=A
@SP
A=M
M=D
@SP
M=M+1
// Pop to segment: local
@LCL
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
// Push Constant
@6
D=A
@SP
A=M
M=D
@SP
M=M+1
// Pop to segment: local
@LCL
D=M
@3
D=D+A
@13
M=D
@SP
AM=M-1
D=M
@13
A=M
M=D
// Push Constant
@123
D=A
@SP
A=M
M=D
@SP
M=M+1
// Pushing Return Address!
@Sys.RETURN.1
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
@1
D=D-A
@ARG
M=D
@SP
D=M
@LCL
M=D
@Sys.Sys.add12
0;JMP
(Sys.RETURN.1)
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
// Push from segment: local
@LCL
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
D=A
@1
A=D+A
D=M
@SP
A=M
M=D
@SP
M=M+1
// Push from segment: local
@LCL
A=M
D=A
@2
A=D+A
D=M
@SP
A=M
M=D
@SP
M=M+1
// Push from segment: local
@LCL
A=M
D=A
@3
A=D+A
D=M
@SP
A=M
M=D
@SP
M=M+1
// Push from segment: local
@LCL
A=M
D=A
@4
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
@SP
AM=M-1
D=M
A=A-1
M=M+D
@SP
AM=M-1
D=M
A=A-1
M=M+D
@SP
AM=M-1
D=M
A=A-1
M=M+D
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
// Label
(Sys.Sys.add12)
// Push Constant
@4002
D=A
@SP
A=M
M=D
@SP
M=M+1
// Pop to pointer
@SP
AM=M-1
D=M
@THIS
M=D
// Push Constant
@5002
D=A
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
@12
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
0; JMP
