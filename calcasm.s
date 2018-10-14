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

ArgNumError:
        .string "usage ./calcasm NUMBER OPERATOR NUMBER"

NotNumError:
        .string "you have not entered a number"

OperatorError:
        .string "Invalid operator supplied"

ZeroDivError:
        .string "Zero division error"

.section .bss


.section .text

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
        movq ST_ARGV_1(%rbp), %rdi   # load string address into register
        call str_len                 # get length of string
        movq %rax, %rsi              # load length into register
        call is_number               # check if string is a number
        cmpq $FALSE, %rax
        je exit_num_error            # exit with error if not number
        call convert_to_int          # convert string to integer
        movq %rax, %r11              # store integer for operation

get_second_number:
        movq ST_ARGV_3(%rbp), %rdi   # load string address into register
        call str_len                 # get length of string
        movq %rax, %rsi              # load length into register
        call is_number               # check if string is a number
        cmpq $FALSE, %rax
        je exit_num_error            # exit with error if not number
        call convert_to_int          # convert string to integer
        movq %rax, %r12              # store integer for operation

get_operator:
        movq ST_ARGV_2(%rbp), %rax

        cmpb $ADD_OPERATOR, (%rax)
        je add_operation

        cmpb $SUB_OPERATOR, (%rax)
        je sub_operation

        cmpb $MUL_OPERATOR, (%rax)
        je mul_operation

        cmpb $DIV_OPERATOR, (%rax)
        movq $FALSE, %r13
        je div_operation

        cmpb $MOD_OPERATOR, (%rax)
        movq $TRUE, %r13
        je div_operation

        jmp exit_operator_error

add_operation:
        addq %r12, %r11
        movq %r11, %rdi
        jmp print_result

sub_operation:
        subq %r12, %r11
        movq %r11, %rdi
        jmp print_result

mul_operation:
        movq %r11, %rax
        mul %r12
        movq %rax, %rdi
        jmp print_result

div_operation:
        cmpq $0, %r12
        je exit_zero_div_error
        movq %r11, %rax
        movq %r12, %rbx
        div %rbx
        cmpq $TRUE, %r13
        je remainder
        jmp quotient
remainder:
        movq %rdx, %rdi
        jmp print_result
quotient:
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
        movq $ArgNumError, %rdi
        movq $38, %rsi
        call write_error_msg
        call write_newline
        jmp error_exit

exit_num_error:
        movq $NotNumError, %rdi
        movq $29, %rsi
        call write_error_msg
        call write_newline
        jmp error_exit

exit_operator_error:
        movq $OperatorError, %rdi
        movq $25, %rsi
        call write_error_msg
        call write_newline
        jmp error_exit

exit_zero_div_error:
        movq $ZeroDivError, %rdi
        movq $20, %rsi
        call write_error_msg
        call write_newline
        jmp error_exit

error_exit:
        movq $SYS_EXIT, %rax
        movq $EXIT_FAILURE, %rdx
        syscall
