# Nand2Tetris

  

This repository contains my work for the various Nand2Tetris projects. The projects take on a bottom-up approach, starting with nothing but the elementary logic gate "Nand", and building all the way up to a compiled, java-like high-level-langauge called Jack

  

## Part 1

The first 6 projects are focused on desiging a hardware context from scratch.

1. Boolean Logic
2. Boolean Arithmetic
3. Memory
4. Machine Language
5. Computer Architecture
6. Assembler

## Part 2

After completing Part 1 we have built a fully functional ALU out of nothing but Nand gates. How do we get from assembly to high-level languages like Java, Python, Ruby, etc?

Part 2 continues our ascent through the layers of abstraction by building a VM translator—which translates VM bytecode into Assembly—followed by a compiler that translates Jack (a high-level java-like language) into VM code.

After writing our compiler, we are not fully done. The final project involves writing an Operating System, a library of Classes that are tightly coupled to the hardware context and abstract away details of memory management, IO memory mapping, and provide a few basic primitives (strings and arrays)

1. Virtual Machine I: Processing
2. Virtual Machine II: Control
3. High-Level Language
4. Compiler 1: Syntax Analysis
5. Compiler 2: Code Generation
6. Operating System