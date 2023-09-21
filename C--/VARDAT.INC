//=================================
// GAME VARIABLES 
// DATA BUFFER
//=================================
//

GAME_DATA_BUF:

CONTROL_STAT:	db 20h			
				db 0
INT_TICK:		db 33h			
				db 2 dup 0 
CONTROL_MODE:	db 1			
demoLockStat:	db 0			
				db 0
timerVar64:		db 40h			
pLIVE_COUNT:		db 3			
				db 0
				db 0
				db 0
				db 0
				db 0
			
footIndex:		db 0BEh			
				db 0

tmpObjCnt:		db 0			
				db 0
pFOOD:			dw 2929h		
byte_DDAE:		db 7			//
byte_DDAF:		db 0			
stonesFound:		db 5			
paintedWeapon:	dw 0101h			


//=============================================================================
// temp data

byte_DDB3:		db 0			
byte_DDB4:		db 0			
pSTRENGHT:		dw 16h	
byte_DDB7:		db 1			
				db 0
pSelectedWeapon:	db 3			

				db 0
raftTimeCycle:	db 5			

RAFT_COORD:		dw 0			

raftStatus:		db 0			

byte_DDBF:		db 1Ah			
byte_DDC0:		db 1Ah			
byte_DDC1:		db 0			
byte_DDC2: 		db 0

broughtStones:  	db 0 // DDC3h
			
DEMO_STATUS:		db 0 //  byte_DDC4
byte_DDC5:		db 0			
				db 0, 0
//===============================					
				db 4 dup 0 
				
tmpRandom:		dw 0D496h		 //DDCC
				db 4 dup 0 
word_DDD2:		dw 740h			
word_DDD4:		dw 220Eh		
word_DDD6:		dw 8A0Fh		
word_DDD8:		dw 0DE00h		

loc_DDDA:
			db 2 dup 0 
pSPR_XY:		dw 0
loc_DDDE:
SCORE_COUNT:	dw 0C4Eh		
loc_DDE0:	db 2 dup 0 
tmpObjAddr:	dw 0		
objXsize:	dw 1C0h			
objYsize:	dw 200h			
word_DDE8:	dw 8134h		
byte_DDEA:	db 2Dh			
byte_DDEB:	db 50h			
locProcAddr:	dw 897Fh		
demo1CmdAddr:	dw 806Eh		
word_DDF0:	dw 101h			
locDscAddr:	dw 8968h		
					
scoreSymbolsBuf: 
		db 0, 3, 1, 5, 0, 0FFh // scores symbols
loc_DDFA:
		db 0, 0, 40h, 0Ah, 1
loc_DDFF:
		db 0, 0, 40h, 7, 1
		
		db 6, 8 dup 0 
		
word_DE0D:	dw 30h		
tmpAddrDE0F:	dw 0AC8Bh	
tmpX:		db 6	// byte_DE11		
			db 0
word_DE13:	dw 0E02Eh		
word_DE15:	dw 2			
word_DE17:	dw 0			// graph buffer size
			db 16h dup 0 
word_DE2F:	dw 1F02h		
tmpFrameSize:	dw 0E06h		
byte_DE33:	db 1			
word_DE34:	dw 802h			
word_DE36:	dw 271Fh		
byte_DE38:	db 0			
tmpScrObjAddr:	dw 1C02h		
frameOffset:	dw 0C06h		
			db 2 dup 0 
word_DE3F:	dw 701h			
word_DE41:	dw 303h			
			db 2 dup 0 
byte_DE45:	db 0		

//byte_DE46	
WORK_BUF:	db 88h,	0, 0Ch,	8, 11h,	40h, 0Ch, 0, 11h, 40h, 5, 8
byte_DE52:	db 11h			
		db 40h
byte_DE54:	db 0Ch			
		db 0
		db 11h,	40h, 5,	0FFh, 7Fh, 1, 22h, 28h,	31h, 3Dh, 22h
		db 31h,	2 dup 0 , 6, 17h, 7, 4 dup 0 
byte_DE6B:	db 1		
loc_DE6C:
		db 31h,	0C8h
loc_DE6E:
		db 88h, 2 dup 0 , 73h, 23h, 49h, 9, 1, 3, 2 dup 0 
		db 73h,	23h, 49h, 9, 1,	3, 2 dup 0 , 2Dh, 0DDh,	0, 45h
		db 48h,	25h, 29h, 46h, 25h, 2 dup 0 , 2, 7, 5 dup 0 , 1
		db 59h,	97h
		
loc_DE96: db 10h dup 0 
loc_DEA6: db 10h dup 0 
loc_DEB6: db 8 dup 0 
loc_DEBE: db 8 dup 0 
loc_DEC6: db 10h dup 0 
loc_DED6: db 10h dup 0 

weaponBuf: db 10h dup 0 
		  db 10h dup 0 
		  db 08h dup 0 
			
loc_DF0E:
		db 0, 0, 31h, 0AEh, 0Dh, 88h, 0Ah, 5

loc_DF16: db 1
		db 2 dup 0 , 0AEh, 0Dh,	88h, 0Ah, 5, 1,	2 dup 0 , 9Ah
		db 11h,	0, 1Bh,	21h, 2Ah, 2Eh, 1Bh, 2Ah, 2 dup 0 , 2 dup 6 
		db 0F2h, 8Ah, 0EBh, 8Ah, 2 dup 0 , 23h,	9Bh, 88h, 0, 11h
		db 4, 1, 0F4h, 7, 1Ch, 3, 2 dup 0 , 4, 1, 0F4h,	7, 1Ch
		db 3, 2	dup 0 ,	0C4h, 2Ah, 2 dup 2 , 8,	1Fh, 27h, 2, 1Fh
		db 2 dup 0 , 6,	0Eh, 0F2h, 8Ah,	0EBh, 8Ah, 2 dup 0 , 89h
		db 0ACh, 0C8h dup 0 
BUF_CLEARED:
		db 0FFh
objectsCount:	db 3			
workBufAddr:	dw 0

word_E02A:	dw 0

			db 36h,	0DFh
			db 1Ch dup 0 
 // E04A			
locationNum:	db 36h
//  E04B
LOCK_STATUS1:	db 1			
					
LOCAT_BUF:
		db 0F1h, 0BEh, 0BDh, 0BEh, 0BDh, 0BEh, 0BDh, 0BEh, 0F1h
		db 0BEh, 0BDh, 0BEh, 0BDh, 0BEh, 0BDh, 0BEh, 0BDh, 0BEh
		db 0BDh, 0BEh, 0BDh, 0BEh, 0BDh, 0BEh, 2 dup 0BDh , 0BEh
		db 0BDh, 0BEh, 0BDh, 0BEh, 0BDh, 0BEh, 0BDh, 0BEh, 0BDh
		db 0BEh, 0BDh, 0BEh, 0BDh, 0BEh, 0BDh, 0BEh, 0BDh, 0BEh
		db 0BDh, 0BEh, 0BDh, 0BEh, 0BDh, 0BEh, 0BDh, 0BEh, 0BDh
		db 0BEh, 0BDh, 0BEh, 0BDh, 0BEh, 0BDh, 0BEh, 0BDh, 0BEh
		db 0BDh, 2 dup 0BEh , 0BDh, 0BEh, 0BDh,	0BEh, 0BDh, 0BEh
		db 0BDh, 0BEh, 0BDh, 0BEh, 0BDh, 0BEh, 0BDh, 0BEh, 0BDh
		db 0BEh, 0BDh, 0BEh, 0BDh, 0F1h, 0BDh, 0BEh, 0BDh, 0BEh
		db 0BDh, 0BEh, 0BDh, 0F1h, 0BDh, 0BEh, 7Fh, 0E2h, 7Fh
		db 0E2h, 2 dup 7Fh , 0E2h, 3 dup 7Fh , 0E2h, 7Fh, 0E2h
		db 3 dup 7Fh , 0E2h, 7Fh, 0E2h,	2 dup 7Fh , 0E2h, 2 dup 7Fh 
		db 0BEh, 0BDh, 0BEh, 0BDh, 0BEh, 0BDh, 0BEh, 0BDh, 0BEh
		db 0BDh, 0BEh, 0BDh, 0BEh, 0BDh, 0BEh, 0BDh, 18h dup 0 
		db 7Fh,	0E2h, 5	dup 7Fh , 0E2h,	4 dup 7Fh , 0E2h, 7Fh
		db 0E2h, 7Fh, 158h dup 0 , 0BDh, 0BEh, 0BDh, 0BEh, 0BDh
		db 0BEh, 0BDh, 0BEh, 0BDh, 1Fh dup 0 , 0BEh, 0BDh, 0BEh
		db 0BDh, 0BEh, 0BDh, 0BEh, 0BDh, 0BEh, 0BDh, 0BEh, 0BDh
		db 0BEh, 0BDh, 0BEh, 0BDh, 0BEh, 17h dup 0 , 0E8h, 0F1h
		db 0E8h, 0E7h, 2 dup 0E8h , 0F1h, 0E8h,	0E7h, 2	dup 0E8h 
		db 0F1h, 0E8h, 0E7h, 0E8h, 0BDh, 0BEh, 0BDh, 0BEh, 0BDh
		db 0BEh, 0BDh, 0BEh, 11h dup 0 , 0F1h, 0E7h, 2 dup 0E8h 
		db 2 dup 0F1h ,	0E7h, 2	dup 0E8h , 2 dup 0F1h ,	0E7h, 0E8h
		db 0F1h, 0E7h, 0E8h, 0E7h, 0E8h, 0E7h, 2 dup 0E8h , 0BDh
		db 0BEh, 0BDh, 0BEh, 0BDh, 0BEh, 0BDh, 0BEh, 0EAh, 0EBh
		db 9 dup 0 , 0E7h, 0E8h, 0E7h, 0E8h, 2 dup 0E7h , 0E8h
		db 0E7h, 0E8h, 2 dup 0E7h , 0E8h, 2 dup 0E7h , 0E8h, 0F1h
		db 0E8h, 0F1h, 0E7h, 0F1h, 0E7h, 0E8h, 0E7h, 0E8h, 0E7h
		db 2 dup 0E8h ,	0BDh, 0BEh, 0BDh, 0BEh,	0BDh, 0BEh, 0BDh
		db 0BEh, 5 dup 0 

// 1D-location buf	
loc_E31C:
		db 0E8h, 0E7h, 0F1h, 0E7h, 0F1h, 0E8h
		db 0E7h, 0F1h, 0E7h, 0F1h, 0E8h, 0E7h, 0F1h, 0E7h, 2 dup 0F1h 
		db 0E7h, 0E8h, 2 dup 0E7h , 0E8h, 0F1h,	0E8h, 0F1h, 0E7h
		db 0E8h, 2 dup 0E7h , 0E8h, 0E7h, 2 dup 0E8h , 0BDh, 0BEh
		db 0BDh, 0BEh, 0BDh, 0BEh
loc_E342:
		db 0BDh
loc_E343:
		db 0BEh
		
loc_E344: db 0E7h, 0E8h, 2 dup 0E7h 
		db 0E8h, 0E7h, 0E8h, 2 dup 0E7h , 0E8h,	0E7h, 0E8h, 2 dup 0E7h 
		db 0E8h, 0E7h, 0E8h, 0F1h, 0E8h, 0F1h, 0E7h, 0E8h, 3 dup 0E7h 
		db 0E8h, 0F1h, 0E8h, 0F1h, 0E7h, 0E8h, 2 dup 0E7h , 0E8h
		db 0F1h, 0E8h, 0F1h, 0E7h, 0E8h, 0E7h
		
objGraphBuf:
		db 100 dup  0 
//-============================
