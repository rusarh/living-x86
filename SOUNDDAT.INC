; LIVINGSTONE SUPONGO
; SOUND DATA
;
;

mus01:
		db 2, 74h, 9, 0Ch, 0, 2, 0F0h, 7, 6, 0, 2, 74h, 9, 0Ch
		db 0, 2, 2Ah, 0Eh, 0Ch,	0, 2, 0E3h, 0Bh, 36h, 0, 2, 0E9h
		db 8, 0Ch, 0, 2, 0F0h, 7, 6, 0,	2, 74h,	9, 0Ch,	0, 2, 0E3h
		db 0Bh,	12h, 0,	2, 0F0h, 7, 2, 0, 2, 7Eh, 7, 2,	0, 2, 12h
		db 7, 0Ch, 0, 2, 7Eh, 7, 10h, 0, 2, 0F0h, 7, 10h, 0, 2
		db 74h,	9, 0Ch,	0, 2, 0F0h, 7, 6, 0, 2,	74h, 9,	0Ch, 0
		db 2, 2Ah, 0Eh,	0Ch, 0,	2, 97h,	0Ah, 36h, 0, 4,	0Ch, 0
		db 2, 0E3h, 0Bh, 0Ch, 0, 2, 0, 0Ah, 0Ch, 0, 2, 0F0h, 7
		db 0Ch,	0, 2, 4Bh, 5, 10h, 0, 2, 0F1h, 5, 10h, 0, 2, 0ADh
		db 6, 10h, 0, 2, 12h, 7, 48h, 0, 2, 0F1h, 5, 8,	0, 2, 0ADh
		db 6, 8, 0, 2, 12h, 7, 8, 0, 2,	7Eh, 7,	0Ch, 0,	2, 0F0h
		db 7, 0Ch, 0, 2, 0E9h, 8, 0Ch, 0, 2, 0,	0Ah, 0Ch, 0, 2
		db 3Bh,	0Bh, 12h, 0, 2,	0E9h, 8, 12h, 0, 2, 0E3h, 0Bh
		db 3Ch,	0, 2, 97h, 0Ah,	10h, 0,	2, 0E9h, 8, 10h, 0, 2
		db 0F0h, 7, 10h, 0, 2, 12h, 7, 12h, 0, 2, 7Eh, 7, 12h
		db 0, 2, 0F0h, 7, 6Ch, 0, 2, 97h, 0Ah, 10h, 0, 2, 0E9h
		db 8, 10h, 0, 2, 0F0h, 7, 10h
		db 0, 2, 12h, 7, 12h, 0, 2
		db 7Eh,	7, 12h,	0, 2, 0F0h, 7, 3Ch, 0, 8
		
mus02:
		db 2, 0E9h, 8, 0Ch
		db 0, 4, 24h, 0, 2, 0E9h, 8, 18h, 0, 2,	74h, 9,	18h, 0
		db 2, 0, 0Ah, 54h, 0, 2, 4Bh, 5, 0Ch, 0, 2, 0F1h, 5, 2Ch
		db 0, 2	dup(4),	0, 2, 0F1h, 5, 10h, 0, 2, 12h, 7, 10h
		db 0, 2, 0E9h, 8, 10h, 0, 2, 0ADh, 6, 24h, 0, 2, 0F0h
		db 7, 24h, 0, 2, 0F1h, 5, 48h, 0, 2, 0E9h, 8, 18h, 0, 2
		db 74h,	9, 18h,	0, 2, 0, 0Ah, 54h, 0, 2, 4Bh, 5, 0Ch, 0
		db 2, 0F1h, 5, 2Ch, 0, 2 dup(4), 0, 2, 0F1h, 5,	10h, 0
		db 2, 12h, 7, 10h, 0, 2, 0F1h, 5, 10h, 0, 2, 9Dh, 5, 0Ch
		db 0, 2, 0F1h, 5, 6, 0,	2, 0ADh, 6, 0Ch, 0, 2, 7Eh, 7
		db 0Ch,	0, 2, 69h, 8, 66h, 0, 2, 3Bh, 0Bh, 18h,	0, 2, 0
		db 0Ah,	18h, 0,	8
		
livingMusic:
		db 6
		dw mus01
		db 6
		dw mus01
		db 6
		dw mus02
		db 0Ah
		dw livingMusic
		
sound1:
		db 0Ch,	1
		dw loc_7F74
		db 2, 0E8h, 3, 64h, 0, 8
		
jumpSound:
		db 0Ch, 1
		dw loc_7F74
		db 2, 84h, 3, 14h, 0, 8
		
smallJumpSound:
		db 0Ch, 1
		dw loc_7F79
		db 2, 90h, 1, 14h, 0, 8
		
bombSound:
		db 0Ch, 1
		dw loc_7F73
		db	2, 84h
		db 3, 1, 0, 4, 1, 0, 2,	0E8h, 3, 1, 0, 4, 1, 0,	2, 0D0h
		db 7, 1, 0, 4, 1, 0, 2,	0B8h, 0Bh, 1, 0, 4, 1, 0, 2, 0A0h
		db 0Fh,	1, 0, 4, 1, 0, 2, 88h, 13h, 1, 0, 4, 1,	0, 2, 70h
		db 17h,	1, 0, 4, 1, 0, 2, 58h, 1Bh, 1, 0, 4, 1,	0, 2, 40h
		db 1Fh,	1, 0, 4, 1, 0, 2, 28h, 23h, 1, 0, 4
		db 1, 0, 2, 10h, 27h, 1, 0, 4, 1, 0, 8
		
muteSound:
		db 8
		
tilidamSound:
		db 6
		dw loc_7F59
		db 6
		dw loc_7F59
		db 6
		dw loc_7F59
		db 6
		dw loc_7F59
		db 8
		
loc_7F3B:
		db 0Ch, 1
		dw loc_7F77
		db 2, 64h, 0, 0Fh, 0, 8
		
positiveSound:
		db 0Ch, 1
		dw loc_7F73
		db 2, 90h, 1, 0Ah, 0, 2, 0F4h, 1, 0Ah, 0, 2, 58h, 2, 0Ah
		db 0, 8
		
loc_7F59:
		db 2, 90h, 1, 2, 0, 2, 20h, 3, 2,	0, 2, 0C8h, 0
		db 2, 0
		db 2, 90h, 1, 2, 0, 2, 40h, 6, 2,	0, 8
		
loc_7F73:				
		db 81h
		
loc_7F74:
		db 0ECh
		db 28h,	80h
		
loc_7F77:		
		db 28h, 80h
		
loc_7F79:		
		db 28h, 0B0h, 1Eh, 0C4h, 28h, 0ECh
		db 1Eh,	0CEh, 14h, 0CEh, 32h, 0ECh, 32h, 0ECh, 0Ah, 0E2h
		db 3Ch,	80h		
		
;----------------------------
; SOUND VARIABLES
soundAddr	dw 3Bh
			db 0
word_7F8E	dw 0			
word_7F90	dw 0		
word_7F92	dw 0
byte_7F94	db 1			
word_7F95	dw 0		
byte_7F97	db 1			
word_7F98	dw 640h			
;---------------------------

LOC_7F9A:				
		db 3Ah,	7Fh, 16h dup(0)
;===========================
