[![Build Status](https://travis-ci.com/jgthomas/calcasm.svg?branch=master)](https://travis-ci.com/jgthomas/calcasm)

# calcasm

Simple calculator written in x86-64 assembly

All input, output, and calculation performed in pure assembly, with Linux syscalls. C library be damned.

## supported operations

* Addition 
---
>\# ./calcasm 10 + 3

>\# 13
---

* Subtraction
---
>\# ./calcasm 25 - 8

>\# 17
---

* Multiplication
---
>\# ./calcasm 10 x 3

>\# 30
---

* Division
---
>\# ./calcasm 30 / 10

>\# 3
---

* Modulo
---
>\# ./calcasm 31 % 10

>\# 1
---

* Raising to a power
---
>\# ./calcasm 2 ^ 3

>\# 8
---

## alternative operators
---
>\# ./calcasm 10 add 3

>\# ./calcasm 25 sub 8

>\# ./calcasm 10 mul 3

>\# ./calcasm 30 div 10

>\# ./calcasm 31 mod 10

>\# ./calcasm 2 pow 3
---
