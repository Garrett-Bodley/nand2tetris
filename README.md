# Nand2Tetris

This repository contains my work for the 12 Nand2Tetris projects. The projects take a bottom-up approach, starting with nothing but the elementary logic gate Nand, and finishes with compiled, java-like high-level-langauge called Jack and an accompanying Operating System/Standard Library.

## Contents
### [Part 1](#Part-I)

1. [Boolean Logic](#Boolean-Logic)
2. [Boolean Arithmetic](#Boolean-Arithmetic)
3. [Memory](#Memory)
4. [Machine Language](#Machine-Language)
5. [Computer Architecture](#Computer-Architecture)
6. [Assembler](#Assembler)

###  **[Part 2](#Part-II)**

1. [Virtual Machine I: Processing](#Virtual-Machine-I-Processing)
2. [Virtual Machine II: Control](#Virtual-Machine-II-Control)
3. [High-Level Language](#High-Level-Language)
4. [Compiler I: Syntax Analysis](#Compiler-I-Syntax-Analysis)
5. [Compiler II: Code Generation](#Compiler-II-Code-Generation)
6. [Operating System](#Operating-System)

## Part 1

The first 6 projects are focused on desiging a hardware context from scratch.

1. [Boolean Logic](#Boolean-Logic)
2. [Boolean Arithmetic](#Boolean-Arithmetic)
3. [Memory](#Memory)
4. [Machine Language](#Machine-Language)
5. [Computer Architecture](#Computer-Architecture)
6. [Assembler](#Assembler)

### Boolean Logic

Implements the following logic gates using only Nand: Not, And, Or, Xor, Multiplexer, Demultiplexer

Building a turing-complete machine requires the ability to compare binary signals. At minimum, you must be able to compare multiple values, and negate a value. Through clever combinations of comparison and negation it is possible to build every common logic gate (And, Or, Not, Xor, Nand). Data selectors (multiplexer, demultiplexer), while not strictly considered logic gates, are  useful when building more complex circuits and can similarly be constructed out of Nand gates.

Concepts: Commutative Law, Associative Law, Distributive Law, De Morgan's Law, Idempotent Law

[Contents](#Contents)

### Boolean Arithmetic

Implements a binary Half Adder, Full Adder, 16-bit Add, and culminates with an Arithmetic Logic Unit.

Using the previously designed logic gates, we take on the challenge of implementing arithmetic between two binary integers. The Half Adder adds two bits and outputs a sum and carry bit. The Full Adder adds three bits together and outputs a two-bit sum and a carry bit. By combining a Half Adder with a series of Full Adders we can build a circuit that adds binary integers of any width (8-bit, 16-bit, 32-bit, etc.).

The chapter also covers two's-complement, the most common method of representing negative numbers in binary. To convert an integer to its negative two's-complement form you negate all the bits and add one (1). Interestingly, addition between negative and positive binary integers using two's-complement "just works", making subtraction functionality simple to implement. Bitwise comparison (AND, OR, NOT) is also covered.

Concepts: Two's Complement, Binary Arithmetic, Bitwise comparison

### Memory

Implements machine memory starting with a Flip Flop and working up to a 16K, 16-bit memory chip. A Program Counter is also designed.

This chapter introduces Sequential Logic—an essential aspect of computing logic that focuses on the progression of time. The project starts with a Data Flip Flop (DFF), a foundational element provided "for free". By combining a DFF with a multiplexer we are able to construct a single-bit memory unit.

We first chain these bits to build an 8-bit memory chip, which lays the groundwork for a 16-bit register. Multiple registers can be combined to make a 64 register chip, then used to build a 512 register chip, eventually scaling up to a 16K-register chip.

The construction of these memory chips reveals a fascinating detail of how memory addresses work at the machine level. When writing a value to memory, each register within the chip receives the new value. However, the memory address functions as a selector signal for a cascade of multiplexers, effectively channeling the single-bit load signal to the targeted register. While all other registers also receive this input value, they disregard it due to the absence of a corresponding load signal.

A similar, but distinct process occurs for read operations. Each register in the chip emits its stored value with every clock cycle. This time the memory address cascades through a series of demultiplexers, devices that receive multiple inputs but emit only one. The memory address selectively guides these demultiplexers to output the value from the specifically targeted register, while disregarding values from all others.

This design detail allows for constant-time access to any memory address, a key characteristic that defines the speed and efficiency of Random Access Memory in computing systems.

Concepts: Sequential Logic, Clock Cycles, Program Counter, Memory Addresses

### Machine Language

Introduces Assembly Mneumonics for the JACK hardware platform

We familiarize ourselves with JACK machine instructions by writing two subroutines in Assembly. The first is a multiplication subroutine, multiplying the values in two pre-defined registers and storing the value in a third. The second, focused on memory-mapped IO, listens for keyboard input and paints the screen black when a key is pressed.

Concepts: Assembly Mneumonics, Jump instructions, Assembly Labels

### Computer Architecture

Construction of a general-purpose computing system.

Given a provided spec for machine instructions, we design a fully functional von-Neumann machine. Requires designing of hardware that can fetch, decode, and execute machine instructions stored in ROM as well as interact with memory-mapped IO. This chapter contextualizes the previous hardware chapters, and serves to demystify the inner workings of the CPU.

Concepts: von Neumann architecture, fetch/decode/execute routine

### Assembler

Construct an assembler that translates mneumonics into machine instructions (binary)

The construction of an assembler demystifies the mechancis of variables, labels, symbols, and jump instructions found in assembly code. These tasks are accomplished through the use of a symbol table, along with some book keeping to keep track of the current line number (lines with labels are ignored for numbering purposes).

## Part 2

After completing Part 1 we have built a fully functional CPU out of nothing but Nand gates. How do we get from assembly to high-level languages like Java, Python, Ruby, etc?

Part 2 continues our ascent through the layers of abstraction by building a VM translator—which translates VM bytecode into Assembly—followed by a compiler that turns Jack code (a high-level java-like language) into VM code.

After writing our compiler, we are not fully done. The final project involves writing an Operating System, a library of Classes that are tightly coupled to the hardware context and abstract away details of memory management, IO memory mapping, and provide a few basic primitives (strings and arrays)

1. [Virtual Machine I: Processing](#Virtual-Machine-I-Processing)
2. [Virtual Machine II: Control](#Virtual-Machine-II-Control)
3. [High-Level Language](#High-Level-Language)
4. [Compiler I: Syntax Analysis](#Compiler-I-Syntax-Analysis)
5. [Compiler II: Code Generation](#Compiler-II-Code-Generation)
6. [Operating System](#Operating-System)

### Virtual Machine I: Processing

Begin the task of translating intermediate VM code into assembly Mneumonics.

The Jack VM functions as a Stack machine, pushing and popping values to various virtual memory segments. Arithmetic or Logical operations are executed by popping the two topmost values from the stack, executing the specified instruction, and pushing the resulting value onto the stack. The VM spec specifies various memory segments which are mapped to specific address spaces on the hardware context. All of these virtual memory specifications must be realized on the hardware context through the generation of assembly code.

Concepts covered: Stack Machine, Stack Arithmetic, Virtual Memory, Assembly

### Virtual Machine II: Control

Implements branching and other control flow behavior

This project addresses the challenging question of how logical branching (if/else) and function call and return work at the machine level. Assembly routines must be developed for both conditional and unconditional branching (read: goto VM instructions). The elegant dance of function call and return, which requires pushing the current frame onto the stack, generating an assembly label to return to, and then jumping to the called function must also be implemented. The implementation of these assembly subroutines helps to highlight the cost of function calls and the utility of inlining code, or converting recursive calls into iterative implementations.

Concepts: Branching, Function call and return, Assembly routines

### High-Level Language

Introduction to Jack: a high-level Java-like programming language

We take on the task of programming a simple game in Jack in order to familiarize ourselves with the syntax of the language before the development of a Compiler. What to program is open ended: I decided to make a Snake game.

Jack's does not have a built in random number generator, so I had to make one from scratch. I ended up using a software implemented Linear Feedback Shift Register (LFSR). An LFSR shifts its prior state over, Xor's two bits together, and assigns that value to the highest (or lowest) bit. The HACK ALU lacks bit shifting, so I wrote a software implementation of bit shifting. Similarly, the ALU also lacks a Xor instruction, but thankfully we already learned how to make Xor out of Nand. There is no Nand assembly mneumonic (a tragic engineering oversight considering the name of the course), but there is an and and a negation, allowing for software implemented Nand. This can be used in a software implemented Xor, in turn used to create a software implemented LFSR, which can then be used to generate a random number for use in the game.

### Compiler I: Syntax Analysis

Build Compiler Lexer and generate an Abstract Syntax Tree

The first half of the Compiler project requires the construction of a Lexical Tokenizer, which breaks the source Jack code into a stream of tokens. These tokens are then fed into the Compilation Engine, which utilizes a Recursive Descent technique to perform syntax analysis and generate an XML syntax tree. The Jack Language utilizes an L(1) grammar, which requires a single lookahead for a handful of statements.

Concepts: Lexical Analysis, Maximal Munch, Syntactic Analysis, Error Handling

### Compiler II: Code Generation

Generate VM Code using the structure of the previously designed Lexer and AST

After successful achieving Lexical and Syntactic Analysis, our task is now to generate the appropriate VM bytecode from the generated tokens. This non-trivial task requires bookkeeping of variable, function, and class names, each mapped to a distinct segment of virtual memory. Array access and the corresponding pointer arithmetic is covered.

Concepts: Stack management, Array access, Pointers, Virtual Memory

### Operating System

Create a Standard Library/Operating System in Jack

Having now written a compiler, our final task is to construct an Operating System for the HACK platform that enables for better developer experience. Optimized multiplication, divison, and square root functions are written in a standard Math library. A memory allocator and deallocator must be designed. Systems level details re: keyboard input are abstracted away. An optimized screen API is built that can draw rasterized lines, rectangles, and circles. An Output library is built to allow printing strings to the screen. A String class with a number of utility methods are provided.

Concepts: Systems level programming, Optimization, Memory Mapping, IO drivers, Operating Systems