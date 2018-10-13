.section .data

.include "linux.s"
.include "ascii.s"
.include "logic.s"
.include "numbers.s"


.section .bss



.section .text


# FUNCTION: base_to_power
#
#    Calculate BASE**POWER.
#
# PARAMETERS
#
#    %rdi - BASE
#    %rsi - POWER
#
# LOCAL VARIABLES
#
#    %rax - ongoing calculation of result
#
# RETURN
#
#    Integer result of BASE**POWER
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
