.section .data

.include "linux.s"
.include "ascii.s"
.include "numbers.s"

NewLine:
        .long 0x0a

NegativeSign:
        .string "-"


.section .text

# FUNCTION: write_newline
#
#    Write a newline to stdout.
#
.globl write_newline
.type write_newline, @function
write_newline:
        movq $SYS_WRITE, %rax
        movq $STDOUT, %rdi
        movq $NewLine, %rsi
        movq $4, %rdx
        syscall
        ret


# FUNCTION: write_char
#
#    Write a single character to stdout.
#
# PARAMETERS
#
#    %rdi - the character to write
#
.globl write_char
.type write_char, @function
write_char:
        movq %rdi, %rsi
        movq $SYS_WRITE, %rax
        movq $STDOUT, %rdi
        movq $1, %rdx
        syscall
        ret


.globl write_int
.type write_int, @function
#
# PROCEDURE
#
# -> Take in integer
# -> Perfom modulo division to get last digit
# -> Convert digit to ascii character code
# -> Store on stack
# -> Once number reaches zero...
# -> ...Walk back through the stack printing the characters
#
#
# PARAMATERS
#
# %rdi - integer passed in to print
#
#
# VARIABLES
#
# %rax - result of division
# %rdx - remainder of division
# %r10 - count of characters in resulting string
#
write_int:
        pushq %rbp               # store base pointer of calling function
        movq %rsp, %rbp          # set this function's base pointer
        xorq %r10, %r10          # set chararcter count to zero
        movq %rdi, %rax          # place number to divide in return register

check_if_negation_sign_needed:
        testq %rax, %rax         # check if integer is negative
        jl print_negation        # if so, print a negative sign...
        jmp div_loop             # ...otherwise proceed

print_negation:
        pushq %rdi               # save values on stack
        pushq %rax
        movq $NegativeSign, %rdi
        call write_char
        popq %rax                # restore saved values
        popq %rdi
        neg %rax                 # with negative sign printed, make number
                                 # positive and print digits as normal
div_loop:
        movq $0, %rdx            # set remainder to zero
        movq $10, %rbx           # number to divide by

        div %rbx                 # divide number in %rax, by number in %rbx
                                 # storing result in %rax and remainder in %rdx

        addq $INT_CONVERT, %rdx  # convert to ascii digit
        pushq %rdx               # store digit on stack
        incq %r10                # increment digit counter

        cmpq $0, %rax            # check if division has reached zero
        jz next                  # if so, jump to printing loop
        jmp div_loop             # otherwise continue here

next:
        cmpq $0, %r10            # if counter reaches zero
        jz exit                  # exit function
        decq %r10                # decrement char counter

        movq $SYS_WRITE, %rax    # set write syscall
        movq $STDOUT, %rdi       # set where to write (1)
        movq %rsp, %rsi          # point to character at top of stack (2)
        movq $1, %rdx            # set size, single character (3)
        syscall

        addq $8, %rsp            # move stack pointer back to next char
        jmp next                 # back to start of loop

exit:
        movq %rbp, %rsp          # move stack pointer back to base of frame
        popq %rbp                # restore old base pointer
        ret                      # return to calling function
