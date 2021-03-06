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


# FUNCTION: write_error_msg
#
#    Write an error message to stderr.
#
# PARAMETERS
#
#    %rdi - the error message
#    %rsi - the message length
#
.globl write_error_msg
.type write_error_msg, @function
write_error_msg:
        movq %rsi, %rdx
        movq %rdi, %rsi
        movq $STDERR, %rdi
        movq $SYS_WRITE, %rax
        syscall
        ret


# FUNCTION: write_int
#
#    Convert an integer to a string and wrtie to stdout.
#
# PROCEDURE
#
#    -> Take in integer
#    -> Perfom modulo division to get last digit
#    -> Convert digit to ascii character code
#    -> Store on stack
#    -> Once number reaches zero...
#    -> ...Walk back through the stack printing the characters
#
# PARAMATERS
#
#    %rdi - integer passed in to print
#
# LOCAL VARIABLES
#
#    %rax - the integer to be divided
#    %rbx - divisor, 10, to get each digit
#    %rdx - remainder of division
#
#    %r12 - count of characters in resulting string
#
.globl write_int
.type write_int, @function
write_int:
        pushq %rbp               # store base pointer of calling function
        movq %rsp, %rbp          # set this function's base pointer
        xorq %r12, %r12          # set chararcter count to zero
        movq %rdi, %rax          # place number to divide in return register

check_if_negation_sign_needed:
        testq %rax, %rax         # check if integer is negative
        jl print_negation        # if so, print a negative sign...
        jmp div_loop             # ...otherwise proceed

print_negation:
        pushq %rax               # save integer to print
        movq $NegativeSign, %rdi
        call write_char
        popq %rax                # restore integer

        neg %rax                 # with negative sign printed, make number
                                 # positive and print digits as normal
div_loop:
        movq $0, %rdx            # set remainder to zero
        movq $10, %rbx           # number to divide by

        div %rbx                 # divide number in %rax, by number in %rbx
                                 # storing result in %rax and remainder in %rdx

        addq $INT_CONVERT, %rdx  # convert to ascii digit
        pushq %rdx               # store digit on stack
        incq %r12                # increment digit counter

        cmpq $0, %rax            # check if division has reached zero
        jz next                  # if so, jump to printing loop
        jmp div_loop             # otherwise continue here

next:
        cmpq $0, %r12            # if counter reaches zero...
        jz exit                  # ...exit function
        decq %r12                # decrement char counter

        movq %rsp, %rdi          # get character
        call write_char          # print character
        addq $8, %rsp            # move stack pointer to next character
        jmp next                 # back to start of loop

exit:
        movq %rbp, %rsp          # move stack pointer back to base of frame
        popq %rbp                # restore old base pointer
        ret                      # return to calling function
