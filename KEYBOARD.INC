
KEYBOARD_TABLE:

WEAP1_BUTTON	db 2			; '1'
WEAP2_BUTTON	db 3			; '2'
WEAP3_BUTTON	db 4			; '3'
WEAP4_BUTTON	db 5			; '4'
byte_7D0B	db 18h			; 'O'                 0001 1000
byte_7D0C	db 19h			; 'P'                 0001 1001
byte_7D0D	db 10h			; 'Q'                 0001 0000
byte_7D0E	db 1Eh			; 'A'                 0001 1110
FIRE_BUTTON	db 39h			; SPACE
BREAK_BUTTON	db 46h		; SCROLL LOCK
byte_7D11	db 1Ch			; Up Arrow
byte_7D12	db 12h,	13h, 1Fh ; 'E' 'R' 'S'
DEMO_BUTTON	db 20h				; 'D'
byte_7D16	db 38h,	1Dh, 53h	; ALT CTRL DEL
byte_7D19	db 3Bh			; 'F1'

; non-standart scancodes handling
;#    the Schneider/Amstrad PC1512 PC keyboards contain extra keys
;#	  a mouse, and a digital joystick, which are handled like extra keys.
;#	  The joysticks motion scancodes are converted into standard arrow
;#	  keys by the BIOS, and the joystick and mouse button scan codes are
;#	  converted to FFFFh codes in the BIOS keyboard buffer.
; 77h Joyst But1
; 78h Joyst But2
; 79h Joyst Right
; 7Ah Joyst Left
; 7Bh Joyst Up
; 7Ch Joyst Down
; 7Dh right mouse
; 7Eh left mouse

byte_7D1A	db 7Ah			; left   0111 1010   ; 04Bh
byte_7D1B	db 79h			; right  0111 1001   ; 04Dh
byte_7D1C	db 7Ch			; up     0111 1100   ; 048h
byte_7D1D	db 7Bh			; down   0111 1011   ; 050h

byte_7D1E	db 77h			; SPACE ; left /right ?
byte_7D1F	db 78h			; SPACE ; -/-/-/-
            db 0
