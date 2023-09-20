; =============== 	S O U N D      S U B R O U T I N E =======================================

proc		disableSound near

        mov	[soundStatus], 0
        jmp	turnSoundOff
endp		disableSound

; =======================================

proc		playMusic near		; CODE XREF: start+3Ep
        mov	[soundStatus], 1
        mov	bx, offset livingMusic
        jmp	short setSound
; ---------------------------------------------------------------------------
; 3E17
playSound:
        test	[soundStatus], 0FFh
        jz	short setSound
        retn
; ---------------------------------------------------------------------------

setSound:
        cli
        mov	[word_7F90], offset LOC_7F9A
        mov	[word_7F92], offset byte_3E3C
        mov	[byte_7F94], 1
        mov	[soundAddr+1], bx
        mov	[byte ptr soundAddr], 1
        sti
        retn
endp		playMusic

; ---------------------------------------------------------------------------
byte_3E3C:

        db 81h

; =============== S U B	R O U T	I N E =======================================

; SOUND processor module
; addr = sub_3E3D

proc		processSound near

; FUNCTION CHUNK AT 3F84 SIZE 00000015 BYTES

        mov	al, [byte ptr soundAddr]
        test	al, 1
        jnz	short loc_3E45
        retn
; ---------------------------------------------------------------------------

loc_3E45:
        test	al, 2
        jnz	short loc_3E65

loc_3E49:
        mov	bx, [soundAddr+1]
        mov	al, [bx]
        inc	bx
        mov	[soundAddr+1], bx
        mov	ah, 0
        mov	bx, offset soundProcOffset
        add	bx, ax
        call	[word ptr bx]
        mov	al, [byte ptr soundAddr]
        test	al, 80h
        jnz	short loc_3E49
        retn
; ---------------------------------------------------------------------------

loc_3E65:
        mov	cx, [word_7F8E]
        dec	cx
        mov	[word_7F8E], cx
        jnz	short loc_3E7A
        mov	al, [byte ptr soundAddr]
        and	al, 7Dh
        mov	[byte ptr soundAddr], al
        jmp	short loc_3E49
; ---------------------------------------------------------------------------

loc_3E7A:
        test	[soundAddr], 40h
        jnz	short locret_3E8E
        mov	ah, [byte_7F97]
        dec	ah
        jz	short loc_3E8F
        mov	[byte_7F97], ah

locret_3E8E:
        retn
; ---------------------------------------------------------------------------

loc_3E8F:
        mov	ah, [byte_7F94]
        mov	[byte_7F97], ah
        mov	bx, [word_7F95]
        mov	al, [bx]
        cmp	al, 81h
        jnz	short loc_3EA2
        retn
; ---------------------------------------------------------------------------

loc_3EA2:
        cmp	al, 80h
        jnz	short loc_3EB6
        mov	bx, [word_7F92]
        mov	[word_7F95], bx
        mov	al, [byte_7F94]
        mov	[byte_7F97], al
        mov	al, [bx]

loc_3EB6:
        cbw
        mov	cx, [word_7F98]
        add	cx, ax
        mov	[word_7F98], cx
        jmp	loc_3F84
endp		processSound

; ---------------------------------------------------------------------------
soundProcOffset:

dw offset turnSoundOff
dw offset soundProc1
dw offset soundProc2
dw offset soundProc3
dw offset soundProc4
dw offset soundProc5
dw offset soundProc6

; ---------------------------------------------------------------------------
;loc_3ED2
turnSoundOff:

        in	al, 61h		; PC/XT	PPI port B bits:
                    ; 0: Tmr 2 gate	ÍËÍ OR	03H=spkr ON
                    ; 1: Tmr 2 data	Í¼  AND	0fcH=spkr OFF
                    ; 3: 1=read high switches
                    ; 4: 0=enable RAM parity checking
                    ; 5: 0=enable I/O channel check
                    ; 6: 0=hold keyboard clock low
                    ; 7: 0=enable kbrd
        and	al, 0FCh
        out	61h, al		; PC/XT	PPI port B bits:
                    ; 0: Tmr 2 gate	ÍËÍ OR	03H=spkr ON
                    ; 1: Tmr 2 data	Í¼  AND	0fcH=spkr OFF
                    ; 3: 1=read high switches
                    ; 4: 0=enable RAM parity checking
                    ; 5: 0=enable I/O channel check
                    ; 6: 0=hold keyboard clock low
                    ; 7: 0=enable kbrd
        mov	[byte ptr soundAddr], 0
        retn
; END OF FUNCTION CHUNK	FOR disableSound
; ---------------------------------------------------------------------------
;loc_3EDE:
soundProc4:
        cmp	[word_7F90], offset LOC_7F9A
        jz	short turnSoundOff
        or	[byte ptr soundAddr], 80h
        dec	[word_7F90]
        dec	[word_7F90]
        mov	si, [word_7F90]
        mov	bx, [si]
        mov	[soundAddr+1], bx
        retn
; ---------------------------------------------------------------------------
;loc_3EFE:
soundProc3:
        or	[byte ptr soundAddr], 80h
        mov	bx, [soundAddr+1]
        mov	cx, [bx]
        inc	bx
        inc	bx
        mov	[soundAddr+1], cx
        mov	si, [word_7F90]
        mov	[si], bx
        inc	si
        inc	si
        mov	[word_7F90], si
        retn
; ---------------------------------------------------------------------------
;loc_3F1C:
soundProc6:
        mov	al, [byte ptr soundAddr]
        or	al, 80h
        mov	[byte ptr soundAddr], al
        mov	bx, [soundAddr+1]
        mov	al, [bx]
        mov	[byte_7F94], al
        mov	[byte_7F97], al
        inc	bx
        mov	cx, [bx]
        inc	bx
        inc	bx
        mov	[soundAddr+1], bx
        mov	[word_7F92], cx
        mov	[word_7F95], cx
        retn
; ---------------------------------------------------------------------------
;loc_3F42:
soundProc5:
        mov	al, [byte ptr soundAddr]
        or	al, 80h
        mov	[byte ptr soundAddr], al
        mov	bx, [soundAddr+1]
        mov	cx, [bx]
        mov	[soundAddr+1], cx
        retn
; ---------------------------------------------------------------------------
;loc_3F55:
soundProc1:
        mov al, [byte ptr soundAddr]
        and al, 3Fh
        or	al, 2
        mov	[byte ptr soundAddr], al
        mov	cx, [word_7F92]
        mov	[word_7F95], cx
        mov	al, [byte_7F94]
        mov	[byte_7F97], al
        mov	bx, [soundAddr+1]
        mov	cx, [bx]
        inc	bx
        inc	bx
        mov	ax, [bx]
        inc	bx
        inc	bx
        mov	[word_7F8E], ax
        mov	[soundAddr+1], bx
        mov	[word_7F98], cx

; START	OF FUNCTION CHUNK FOR processSound

loc_3F84:
        in	al, 61h		; PC/XT	PPI port B bits:
                    ; 0: Tmr 2 gate	ÍËÍ OR	03H=spkr ON
                    ; 1: Tmr 2 data	Í¼  AND	0fcH=spkr OFF
                    ; 3: 1=read high switches
                    ; 4: 0=enable RAM parity checking
                    ; 5: 0=enable I/O channel check
                    ; 6: 0=hold keyboard clock low
                    ; 7: 0=enable kbrd
        push	ax
        mov	al, 0B6h
        out	43h, al		; Timer	8253-5 (AT: 8254.2).
        mov	al, cl
        out	42h, al		; Timer	8253-5 (AT: 8254.2).
        mov	al, ch
        out	42h, al		; Timer	8253-5 (AT: 8254.2).
        pop	ax
        or	al, 3
        out	61h, al		; PC/XT	PPI port B bits:
                    ; 0: Tmr 2 gate OR	03H=spkr ON
                    ; 1: Tmr 2 data	Í¼  AND	0fcH=spkr OFF
                    ; 3: 1=read high switches
                    ; 4: 0=enable RAM parity checking
                    ; 5: 0=enable I/O channel check
                    ; 6: 0=hold keyboard clock low
                    ; 7: 0=enable kbrd
        retn
; END OF FUNCTION CHUNK	FOR processSound
; ---------------------------------------------------------------------------
;loc_3F99:
soundProc2:
        mov	al, [byte ptr soundAddr]
        and	al, 7Fh
        or	al, 42h
        mov	[byte ptr soundAddr], al
        mov	bx, [soundAddr+1]
        mov	ax, [bx]
        inc	bx
        inc	bx
        mov	[word_7F8E], ax
        mov	[soundAddr+1], bx
        in	al, 61h
        and	al, 0FCh	; set SPEAKER OFF
        out	61h, al
        retn
; ---------------------------------------------------------------------------
        db 7Eh,	0E4h, 0, 75h, 3, 0E9h, 0FDh
;  ===========================================================================
