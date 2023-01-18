# IHCPL

IHCPL is a programming language written in Lua. The name is an acronym that
stands for Interpreted Homoiconic Concatenative Programming Language.

## Features

The main feature of IHCPL is its metaprogrammability; at runtime, IHCPL programs
are have two things at their disposal that many languages don't.

The first thing is homoiconicity, which means the language treats blocks of code
the exact same way as it treats any other data type, which allows programs to
generate and evaluate code at runtime; LISP is the most prominent example of
homoiconicty.

The second feature IHCPL has is full access to its interpreter's inner state,
allowing programs to dynamically extend the interpreter to fit the program's
exact needs. The language's parser is internally represented as a
state-transition table, making adding new language features as easy as adding
new rows and/or columns to the table.

Another feature of IHCPL is that is it is a concatenative language; it relies
on pushing values to a stack, then popping them to perform operations when
calling functions, called words, or executing blocks of code. There is no need
to give names to a word's arguments, making it a point-free language. A program
might thus be as simple as `34 35 + .`, which pushes the numbers `34` and `35`
to the stack, then pops them, adds them up, and pushes the result(`+`), and
finally pops from the stack and prints that value, resulting in the printing
of the number `69`, which is the sum of 34 and 35.

## Usage

Simply clone the repository and type `lua ihcpl.lua` to be dropped directly into
a REPL. Try typing `34 35 +` into the prompt to get started.

## Language

### Built-in Datatypes
- Number: integers and floats; cannot contain a leading or trailing '.'
- Bool: true or false; technically defined as words equal to 1 and 0
- String: a string of characters
- Block: a block of code; blocks with names are called words

### Built-in Words
- read (void -> block): parse user input as a block and push to stack
- eval (block -> void): evaluate the block on the top of the stack
- \[ (void -> void): start of block definition
- \] (void -> block): end of block definition
- alias (block string -> void): create word from block with the name given in
the string(if its a valid word)

- if (block block bool -> void): if the value on the top of the stack is true,
eval the block that's now on the top of the stack, otherwise eval the next block
- or (bool bool -> bool): true if either argument is true
- and (bool bool -> bool): true if both arguments are true
- not (bool -> bool): negate bool

- drop (any -> void): pop a value off the stack, doing nothing with it
- dup (any -> any any): duplicate top of stack
- swap (any any -> any any): swap the top two elements
- rot> (any any any -> any any any): rotate top three elements rightwards
- rot< (any any any -> any any any): rotate top three elements leftwards
- over (any any -> any any any): copy second element to the top of stack

- + (number number -> number): add two numbers
- - (number number -> number): subtract
- * (number number -> number): multiply
- / (number number -> number): divide
- % (number number -> number): modulus

- = (any any -> bool): check if top two elements are equal
- != (any any -> bool): check if not equal
- < (any any -> bool): less than
- <= (any any -> bool): less than or equal to
- > (any any -> bool): greater than
- >= (any any -> bool): greater than or equal to

- . (any -> void): print the top of the stack
