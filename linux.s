# syscall codes 64-bit
.equ SYS_READ, 0
.equ SYS_WRITE, 1
.equ SYS_OPEN, 2
.equ SYS_CLOSE, 3
.equ SYS_BRK, 12
.equ SYS_EXIT, 60

# exit codes
.equ EXIT_SUCCESS, 0
.equ EXIT_FAILURE, 1

# standard streams
.equ STDIN, 0
.equ STDOUT, 1
.equ STDERR, 2

# file permissions
.equ BASIC_PERMS, 0666

# file status
.equ END_OF_FILE, 0

# SYSCALL OPTIONS

# open
.equ O_RDONLY, 0
.equ O_WRONLY, 1
.equ O_RDWR, 2
.equ O_CREAT_WRONLY_TRUNC, 03101
.equ O_CREAT, 0101

.equ FAILED_TO_OPEN, -1
