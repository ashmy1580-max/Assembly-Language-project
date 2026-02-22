.model small
.stack 100h

.data
    ; --- MESSAGES ---
    msgMenu         db 10, 13, '===== AIRLINE RESERVATION ====', 10, 13
                    db '1. Add Reservation', 10, 13
                    db '2. Show All', 10, 13
                    db '3. Search (Full Passport)', 10, 13
                    db '4. Exit', 10, 13
                    db 'Choice: $'
    
    msgName         db 10, 13, 'Name: $'
    msgPass         db 10, 13, 'Passport: $'
    msgDep          db 10, 13, 'From: $'
    msgArr          db 10, 13, 'To: $'
    
    msgSearch       db 10, 13, 'Enter Passport to Search: $'
    msgFound        db 10, 13, '>> RECORD FOUND!', 10, 13, '$'
    msgNotFound     db 10, 13, '>> NOT FOUND.', 10, 13, '$'
    msgSaved        db 10, 13, '>> Reservation Saved.', 10, 13, '$'
    msgFull         db 10, 13, '>> Error: List Full.', 10, 13, '$'
    
    newline         db 10, 13, '$'
    dash            db ' - $'
    to              db  ' TO $'  
                  
    user            db 'Name: $' 
    pass            db ' Passport number: $'
    
    

    ; --- DATA ARRAYS ---
    ; 3 slots, 20 bytes each. Initialized with '$'
    names           db 200 dup('$')
    passports       db 200 dup('$')
    departures      db 200 dup('$')
    arrivals        db 200 dup('$')
    
    ; --- VARIABLES ---
    count           db 0
    max_res         db 10
    current_idx     dw 0    ; Holds current array index (0, 20, 40)
    
    ; --- SEARCH BUFFER ---
    ; Temporary storage for the passport user wants to find
    temp_pass       db 20 dup('$') 

.code
main proc
    mov ax, @data
    mov ds, ax

MENU:
    lea dx, msgMenu     ; Show Menu
    mov ah, 09h
    int 21h
    
    mov ah, 01h         ; Input Choice
    int 21h
    
    cmp al, '1'
    je ADD_RES
    cmp al, '2'
    je SHOW_ALL
    cmp al, '3'
    je SEARCH_FULL
    cmp al, '4'
    je EXIT_PROG
    jmp MENU

; ---------------------------------------------------------
; 1. ADD RESERVATION
; ---------------------------------------------------------
ADD_RES:
    mov al, count
    cmp al, max_res
    jae FULL_ERR
    
    ; Calculate Offset: AX = count * 20
    mov al, count
    mov bl, 20
    mul bl
    mov current_idx, ax

    ; -- Input Name --
    lea dx, msgName
    mov ah, 09h
    int 21h
    
    lea si, names           ; Load Name Array
    add si, current_idx     ; Go to correct slot
    call GET_INPUT          ; Use simple input block (defined below)

    ; -- Input Passport --
    lea dx, msgPass
    mov ah, 09h
    int 21h
    
    lea si, passports
    add si, current_idx
    call GET_INPUT

    ; -- Input Departure --
    lea dx, msgDep
    mov ah, 09h
    int 21h
    
    lea si, departures
    add si, current_idx
    call GET_INPUT

    ; -- Input Arrival --
    lea dx, msgArr
    mov ah, 09h
    int 21h
    
    lea si, arrivals
    add si, current_idx
    call GET_INPUT

    inc count
    lea dx, msgSaved
    mov ah, 09h
    int 21h
    jmp MENU

FULL_ERR:
    lea dx, msgFull
    mov ah, 09h
    int 21h
    jmp MENU

; ---------------------------------------------------------
; 2. SHOW ALL
; ---------------------------------------------------------
SHOW_ALL:
    cmp count, 0
    je NOT_FOUND_MSG
    
    mov cl, count       ; Loop Counter
    mov ch, 0
    mov bx, 0           ; Index starts at 0

SHOW_LOOP:
    lea dx, newline
    mov ah, 09h
    int 21h 
    
    lea dx,user
    mov ah,09h
    int 21h
    
    ; Print Name
    lea dx, names
    add dx, bx
    mov ah, 09h
    int 21h
    
    lea dx, PASS
    mov ah, 09h
    int 21h
    
    ; Print Passport
    lea dx, passports
    add dx, bx
    mov ah, 09h
    int 21h 
    
    lea dx, dash
    mov ah, 09h
    int 21h
    
    ; print departure city
    lea dx,departures 
    add dx, bx
    mov ah, 09h
    int 21h
    
    lea dx, to
    mov ah, 09h
    int 21h
    
     ; print arrival city
    lea dx,arrivals 
    add dx, bx
    mov ah, 09h
    int 21h 
    
    ; Move to next record (Index + 20)
    add bx, 20
    loop SHOW_LOOP
    jmp MENU

; ---------------------------------------------------------
; 3. SEARCH (FULL PASSPORT MATCH)
; ---------------------------------------------------------
SEARCH_FULL:
    cmp count, 0
    je NOT_FOUND_MSG

    ; 1. Clear the temp_pass buffer first (overwrite with $)
    mov cx, 20
    mov si, 0
CLEAR_BUF:
    mov temp_pass[si], '$'
    inc si
    loop CLEAR_BUF

    ; 2. Ask user for Passport to search
    lea dx, msgSearch
    mov ah, 09h
    int 21h
    
    lea si, temp_pass   ; Store input in temp_pass
    call GET_INPUT
    
    ; 3. Start Searching
    mov cl, count       ; Outer Loop Counter (Number of bookings)
    mov ch, 0
    mov bx, 0           ; Points to start of a record in 'passports' (0, 20, 40)

SEARCH_OUTER:
    ; Check if passports[BX] matches temp_pass
    mov si, 0           ; Character index (0 to 19)

COMPARE_CHAR:
    ; Get char from stored passports
    ; Logic: address = passports + BX + SI
    lea di, passports
    add di, bx
    add di, si
    mov al, [di]        ; AL = Stored character
    
    ; Get char from input
    mov ah, temp_pass[si] ; AH = Input character
    
    ; Compare
    cmp al, ah
    jne MISMATCH        ; If chars differ, stop checking this person
    
    ; If chars match, check if we reached end ($)
    cmp al, '$'
    je FOUND            ; If we matched up to $, it's a full match!
    
    inc si
    jmp COMPARE_CHAR    ; Check next character

MISMATCH:
    add bx, 20          ; Move BX to next person
    dec cl              ; Decrement total counter
    jnz SEARCH_OUTER    ; Continue if more people left
    
    jmp NOT_FOUND_MSG   ; If loop ends, nobody found

FOUND:
    lea dx, msgFound
    mov ah, 09h
    int 21h
    
    ; Print Details of the found person (BX holds the correct index)
    lea dx, newline
    mov ah, 09h
    int 21h
    
    lea dx, names       ; Print Name
    add dx, bx
    mov ah, 09h
    int 21h
    
    lea dx, dash
    mov ah, 09h
    int 21h
    
    lea dx, departures  ; Print Route
    add dx, bx
    mov ah, 09h
    int 21h
    
    lea dx, dash
    mov ah, 09h
    int 21h
    
    lea dx, arrivals
    add dx, bx
    mov ah, 09h
    int 21h
    
    jmp MENU

NOT_FOUND_MSG:
    lea dx, msgNotFound
    mov ah, 09h
    int 21h
    jmp MENU

EXIT_PROG:
    mov ah, 4ch
    int 21h

; --- HELPER: SIMPLE INPUT ROUTINE ---
; Note: This is a label, not a formal PROC, but we use CALL/RET 
; to keep code clean. It acts like a "Service Routine" (Topic 3).
GET_INPUT:
    ; Reads chars into [SI] until Enter is pressed
NEXT_CHAR:
    mov ah, 01h
    int 21h
    cmp al, 13          ; Check for Enter Key
    je INPUT_DONE
    mov [si], al
    inc si
    jmp NEXT_CHAR
INPUT_DONE:
    ret                 ; Return to where it was called

main endp
end main