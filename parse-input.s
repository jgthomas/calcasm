.section .data

.include "linux.s"
.include "ascii.s"
.include "logic.s"
.include "numbers.s"

.equ NOT_ALL_DIGITS, -1

.section .bss


.section .text

# FUNCTION: str_len
#
#    Count the number of characters in a null-terminated string.
#
# PARAMETERS
#
#    %rdi - address of a string
#
# LOCAL VARIABLES
#
#    %rax - count of chars
#
# RETURN
#
#    Number of chars in the string
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


# FUNCTION: is_number
#
#    Check if a string is made entirely of the characters 0-9.
#    Allows for negative numbers starting with '-'.
#
# PARAMETERS
#
#    %rdi - address of string
#    %rsi - length of string
#
# LOCAL VARIABLES
#
#    %rdx - current offset
#    %cl - current byte being examined (first part of %rcx)
#
# RETURN
#
#    TRUE (1) if all numerals, else FALSE (0)
#
.globl is_number
.type is_number, @function
is_number:
        movq $TRUE, %rax                    # assume it is a number
        xor %rdx, %rdx                      # set offset to zero

check_if_negative:
        movb (%rdi,%rdx,1), %cl             # get first byte
        cmpb $NEGATIVE_SIGN, %cl            # check if negation sign
        je check_length
        jmp loop_is_number

check_length:
        cmpq $1, %rsi                       # if negative but only one char long
        je not_number                       # then string is just a minus sign
        incq %rdx                           # ...else move to second char

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


# FUNCTION: convert_to_int
#
#    Convert a string into the integer represented by its digits.
#
# PARAMETERS
#
#    %rdi - input string
#    %rsi - length of string
#
# LOCAL VARIABLES
#
#    %r15 - save whether string starts with negative sign
#
# RETURN
#
#    The integer represented by the string
#
.globl convert_to_int
.type convert_to_int, @function
convert_to_int:
        call is_negative
        movq %rax, %r15
        cmpq $TRUE, %r15
        je handle_negative

go_convert_to_int:
        call digits_to_int
        cmpq $TRUE, %r15
        je make_int_negative
        jmp exit_convert_to_int

make_int_negative:
        neg %rax
        jmp exit_convert_to_int

handle_negative:
        inc %rdi               # move the start of the string along by one byte
        dec %rsi               # decrement the length of the string
        jmp go_convert_to_int

exit_convert_to_int:
        ret


# FUNCTION: is_negative
#
#    Check if string starts with negation symbol.
#
# PARAMETERS
#
#    %rdi - string
#
# RETURN
#
#    TRUE (1) if starts with negation, else FALSE (0)
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


# FUNCTION: digits_to_int
#
#    Turn a string of digits into an integer.
#
# PARAMETERS
#
#    %rdi - address of string
#    %rsi - length of string
#
# LOCAL VARIABLES
#
#    %r12 - store address of string
#    %r13 - current offset of string
#    %r14 - total
#    %r15 - current power
#    %bl - current byte being examined (first part of %rbx)
#
# RETURN
#
#    Integer equivalent of the string of digits
#
.globl digits_to_int
.type digits_to_int, @function
digits_to_int:
        pushq %r15             # save whether negative
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
        popq %r15                    # restore record of whether negative
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
.type base_to_power, @function
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
