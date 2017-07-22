    BITS 16
    
;0x000b8000 -- framebuffer address
start:
    mov ax, 07c0h           ; 4K stack space after the bootloader -- code is running at 0x07c0
    add ax, 288             ; (4098 + 512)/16 bytes per paragraph
    mov ss, ax              ; sets up the stack
    mov sp, 4096            ; moves the stack pointer
    
    mov ax, 07c0h           ; set data segment to where we're loaded
    mov ds, ax
    
    call cls                ; clear the screen
    
    mov si, splash_text     ; put string position into SI
    call fb_print           ; call print_string routine
    
    jmp $
    
    text db "w", 0
    splash_text: db "Welcome to Bum'dOS v1", 10, 10, 13, "The only time you can truly say an OS is bumting.", 0
    cursor: dw 0x00
    char: db 0
    
cls:
    mov ah,00h              ; change graphics mode clears screen
    mov al,03h              ; text mode -- 80x25, 16 colours
    int 10h                 ; BIOS interrupt
    ret
    
fb_print:
    mov cx, 0xb800
    mov es, cx          ; set es
    mov bx, [cursor]
    ;mov bx, [cursor]        ; get current cursor position
    
.repeat:
    lodsb                   ; get byte from string in SI to AL
    cmp al, 0               ; if it is equal to 0...
    je .done                ; jump to .done
    ;mov ah, al               ; move al up to ah
    mov ah, 0x24            ; colour code
    mov [es:bx], ax            ; move ax into framebuffer
    add [cursor], word 2  ; increment cursor
    mov bx, [cursor]
    jmp .repeat
    
.done:
    ret
    
print:
    mov ah, 0Eh             ; Put 0Eh in ah -- Tells BIOS to print character in AL at INT 10h
    
.repeat:
    lodsb                   ; load a byte from the string in SI to AL
    cmp al, 0               ; if AL == 0...
    je .done                ; jump to done...
    int 10h                 ; else call the BIOS interrupt to print AL...
    jmp .repeat             ; and repeat.
    
.done:
    ret                     ; return from CALL
    

    times 510-($-$$) db 0   ; fill the rest of the boot sector with 0s
    dw 0xAA55               ; and add a boot sector signature.