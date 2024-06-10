SECTION "Debug", ROMX

; Print a single character to the screen
PrintChar:
    ld hl, $9800  ; Start of the tilemap (this address can vary depending on your setup)
    ld a, [hl]
    or a
    jr z, .print  ; If the first tile is empty, print here
.next_char
    inc hl
    ld a, [hl]
    or a
    jr nz, .next_char
.print
    ld a, [de]
    ld [hl], a
    ret

; Print a number in hex format (2 digits)
PrintHex:
    push af
    push bc
    push de
    push hl
    ld b, 2
.next_digit
    swap a
    and $0F
    cp 10
    jr c, .digit_is_num
    add a, 'A' - 10
    jr .store_digit
.digit_is_num
    add a, '0'
.store_digit
    push af
    ld de, hl
    call PrintChar
    pop af
    dec b
    jr nz, .next_digit
    pop hl
    pop de
    pop bc
    pop af
    ret
