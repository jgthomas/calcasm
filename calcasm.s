.section .data

.include "linux.s"
.include "ascii.s"
.include "logic.s"

.equ ST_ARGC, 0
.equ ST_ARGV_0, 8
.equ ST_ARGV_1, 16
.equ ST_ARGV_2, 24
.equ ST_ARGV_3, 32

.equ ARG_NUM, 4

.equ ST_SIZE_RESERVE, 8

.equ NOT_ALL_DIGITS, -1

.equ MUL_OPERATOR, 120
.equ ADD_OPERATOR, 43

ArgNumError:
        .string "usage ./calc [number] [operator] [number]"

NotNumError:
        .string "you have not entered a number"

OperatorError:
        .string "Invalid operator supplied"

.section .bss


.section .text
#
# Command line arguments
#
# (%rsp)   = argc
# 8(%rsp)  = argv[0] = name of application
# 16(%rsp) = argv[1] = first user-passed argument
# 24(%rsp) = argv[2] = second user-passed argument
# 32(%rsp) = argv[3] = third user-passed argument
# ...and so on
#
# Sequence of pops will place first the argc value
# and then the addresses of each argument into register
#
.globl _start
_start:
        movq %rsp, %rbp              # save stack pointer
        movq ST_ARGC(%rbp), %rax
        cmpq $ARG_NUM, %rax
        jne exit_arg_error

get_first_number:
        movq ST_ARGV_1(%rbp), %rdi
        call get_number
        cmpq $NOT_ALL_DIGITS, %rax
        je exit_num_error
        movq %rax, %r11

get_second_number:
        movq ST_ARGV_3(%rbp), %rdi
        call get_number
        cmpq $NOT_ALL_DIGITS, %rax
        je exit_num_error
        movq %rax, %r12

get_operator:
        movq ST_ARGV_2(%rbp), %rax
        cmpb $ADD_OPERATOR, (%rax)
        je add_operation
        cmpb $MUL_OPERATOR, (%rax)
        je mul_operation
        jmp exit_operator_error

add_operation:
        addq %r12, %r11
        movq %r11, %rdi
        jmp print_result

mul_operation:
        movq %r11, %rax
        mul %r12
        movq %rax, %rdi
        jmp print_result

print_result:
        call write_int
        call write_newline

exit:
        movq $SYS_EXIT, %rax
        movq $EXIT_SUCCESS, %rdx
        syscall

exit_arg_error:
        movq $SYS_WRITE, %rax
        movq $STDERR, %rdi
        movq $ArgNumError, %rsi
        movq $41, %rdx
        syscall
        call write_newline
        jmp error_exit

exit_num_error:
        movq $SYS_WRITE, %rax
        movq $STDERR, %rdi
        movq $NotNumError, %rsi
        movq $29, %rdx
        syscall
        call write_newline
        jmp error_exit

exit_operator_error:
        movq $SYS_WRITE, %rax
        movq $STDERR, %rdi
        movq $OperatorError, %rsi
        movq $25, %rdx
        syscall
        call write_newline
        jmp error_exit

error_exit:
        movq $SYS_EXIT, %rax
        movq $EXIT_FAILURE, %rdx
        syscall


# Process a sting into its corresponding digit
#
# Function checks string length, and returns -1 if
# the string is not a number, otherwise it returns
# the number represented by the string as an integer.
#
# Passed in
# %rdi - input string
#
# Local parameters
# %rsi - length of string
# %r15 - save whether string starts with negative sign
#
.globl get_number
.type get_number, @function
get_number:
        call is_negative
        movq %rax, %r15

        call str_len
        movq %rax, %rsi

        cmpq $TRUE, %r15
        je handle_negative

go_get_number:
        call get_int
        cmpq $TRUE, %r15
        je make_int_negative
        jmp exit_get_number

make_int_negative:
        neg %rax
        jmp exit_get_number

handle_negative:
        cmpq $1, %rsi                   # if str len is only 1 then its just a minus sign
        jle not_number
        inc %rdi                        # move the start of the string along by one byte
        dec %rsi                        # decrement the length of the string
        jmp go_get_number

not_number:
        movq $NOT_ALL_DIGITS, %rax

exit_get_number:
        ret


# Turn string of digits into corresponding int
#
# %rdi - input string
# %rsi - length of string
#
# returns -1 if string is not all digits
# otherwise returns the integer
#
.globl get_int
.type get_int, @function
get_int:
        pushq %r15                      # save whether negative or not on stack
        call is_number
        cmpq $FALSE, %rax
        je not_all_digits

        call digits_to_int
        jmp exit_get_int

not_all_digits:
        movq $NOT_ALL_DIGITS, %rax

exit_get_int:
        popq %r15                       # restore result of negative test
        ret
