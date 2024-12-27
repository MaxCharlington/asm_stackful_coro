format ELF64 executable 3 ; Specify the output format

segment readable executable

entry $
    ; Allocate memory using mmap syscall
    mov rax, 9           ; syscall: mmap
    xor rdi, rdi         ; addr: NULL
    mov rsi, 4096        ; length: 4096 bytes
    mov rdx, 3           ; prot: PROT_READ | PROT_WRITE
    mov r10, 0x22        ; flags: MAP_PRIVATE | MAP_ANONYMOUS
    mov r8, -1           ; fd: -1
    xor r9, r9           ; offset: 0
    syscall
    ; save allocated address to the stack
    push rax
    ; Set the stack pointer to the allocated memory
    ; Increment it first to set pointer to highest address
    add rax, 4096
    mov rbx, rsp
    mov rsp, rax
    push rbx
    ; Call the function that uses the stack
    call coro
    ; Restore stack
    pop rbx
    mov rsp, rbx
    ; free memory
    pop rdi
    mov rax, 9            ; syscall: munmap
    mov rsi, 4096         ; Length: size of allocation
    syscall               ; Call kernel
    ; Exit the program
    mov rax, 60          ; syscall: exit
    xor rdi, rdi         ; exit code: 0
    syscall

coro:
    ; Use stack in coro
    push 1               ; syscall: write
    push 1               ; file descriptor: stdout
    ; Write syscall to output the message
    pop rax
    pop rdi
    lea rsi, [message]   ; pointer to the message (on the stack)
    mov rdx, message_len ; length of the message
    syscall
    ; Clean up the stack here if required
    ret

segment readable writeable

message db 'Hello from the stack!',0xA ; 0xA is \n in hex
message_len = $ - message              ; Length of the string
