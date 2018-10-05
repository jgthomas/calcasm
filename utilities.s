.section .data

.include "linux.s"
.include "ascii.s"
.include "logic.s"
.include "numbers.s"

.section .bss


.section .text

# Count the number of characters in a
# null-terminated string
#
# %rdi - address of a string
# %rax - count of chars
#
.globl str_len
.type str_len, @function
str_len:
        xorq %rax, %rax                     # set char counter to zero

loop:
        cmpb $NULL_TERMINATOR, (%rdi,%rax)  # compare byte against null
                                            # (%rdi,%rax) = address in %rdi
                                            # + value in %rax, goes through
                                            # addresses one byte at a time

        je end                              # if null exit
        incq %rax                           # move to next byte
        jmp loop                            # back around loop

end:
        ret


# Check if a string is made entirely of the characters 0-9
#
#
# Parameters
#
# %rdi - address of string
# %rsi - length of string
#
# Variables
#
# %rdx - current offset
# %cl - current byte being examined (first part of %rcx)
#
# Return
#
# TRUE (1) if all numerals, else FALSE (0)
#
.globl is_number
is_number:
        movq $TRUE, %rax                    # assume it is a number
        xor %rdx, %rdx                      # set offset to zero

loop_is_number:
        cmpq %rdx, %rsi
        je exit_is_number

        movb (%rdi,%rdx,1), %cl             # get current byte

        cmpb $ZERO_CHAR, %cl                # check it is a numeral
        jl not_number
        cmpb $NINE_CHAR, %cl
        jg not_number

        incq %rdx
        jmp loop_is_number

not_number:
        movq $FALSE, %rax

exit_is_number:
        ret



# Turn a string of digits into an integer
#
#
# Parameters
#
# %rdi - address of string
# %rsi - length of string
#
# Variables
#
# %r12 - store address of string
# %r13 - current offset of string
# %r14 - total
# %r15 - current power
# %bl - current byte being examined (first part of %rbx)
#
# Return
#
# integer equivalent of the string of digits
#
.globl digits_to_int
digits_to_int:
        movq %rdi, %r12        # save string address
        xor %r13, %r13         # set offset to zero
        xor %r14, %r14         # set total to zero
        movq %rsi, %r15        # set first power
        subq $1, %r15

loop_digits_to_int:
        movb (%r12,%r13,1), %bl      # get current byte
        subb $INT_CONVERT, %bl       # convert to int

        movq $DECIMAL_BASE, %rdi     # pass BASE
        movq %r15, %rsi              # pass POWER
        call base_to_power           # return BASE**POWER in %rax

        movzbq %bl, %rcx             # zero extend the multiplier
        mul %rcx                     # implicitly mul %rcx, %rax
        addq %rax, %r14              # add to running total

back_to_top:
        dec %r15
        inc %r13
        cmpq $0, %r15
        jl exit_loop_digits_to_int
        jmp loop_digits_to_int

exit_loop_digits_to_int:
        movq %r14, %rax
        ret


# Return true if string starts with negation symbol
#
# %rdi - string
#
.globl is_negative
.type is_negative, @function
is_negative:
        movq $TRUE, %rax
        cmpb $NEGATIVE_SIGN, (%rdi)
        je exit_is_negative
        movq $FALSE, %rax

exit_is_negative:
        ret


# Calculate BASE to a POWER
#
# %rdi - BASE
#
# %rsi - POWER
#
# returns BASE**POWER
#
.globl base_to_power
base_to_power:
        cmpq $0, %rsi
        je to_power_zero

        movq %rdi, %rax
        dec %rsi

loop_base_to_power:
        cmpq $0, %rsi
        je exit_base_to_power

        mul %rdi                   # implicitly mul %rdi, %rax
        dec %rsi
        jmp loop_base_to_power

to_power_zero:
        movq $1, %rax

exit_base_to_power:
        ret