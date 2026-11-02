;
; LIVINGSTONE I PRESUME
; OPERA SOFT S.A. 1986
;
;
        Ideal
        model tiny

        include	"LSTONE.inc"
        include "LSTONE.def"

segment		_03C8 byte public 'CODE'
        assume cs:_03C8
        org 100h
        assume es:nothing, ss:nothing, ds:_03C8

        public start
proc		start near
        push	cs

        sub	ax, ax
        push	ax

        mov	[cs:dwSTACK], sp
        mov	ax, cs
        add	ax, 0
        mov	es, ax
        assume es:_03C8
        mov	ds, ax
        mov	ss, ax
        assume ss:_03C8
        mov	si, offset GAME_DATA_BUF	; clear	temp buffer
        mov	[word ptr si], 0
        mov	di, offset GAME_DATA_BUF + 1
        mov	cx, 8F3h
        cld
        rep movsb

        call	setVideoMode
        call	resetLives
        call	isFirePressed
        call	paintScreen__

startScreen:
        mov	sp, [cs:dwSTACK]
        call	clearGameData
        call	updateObjShadowTiles
        call	setInterrupts__
        call	playMusic
        call	clearProvisionStates

        mov	ah, 3Dh
        mov	[locationNum], ah
        call	resetLives
        call	setDemoParam__
        call	paintScreen2__
        call	checkRaft
        call	PrepareLocation__
        call	locationRoutine
        call	paintLocation__

        mov	ah, 0
        mov	[byte ptr cs:demo1Counter], ah ; reset Stanley dance count :)

playStartDance:
        call	mainCycle
        mov	ah, [CONTROL_MODE]
        cmp	ah, 0FFh
        jnz	short checkStartCycles

        call	setDemoParam__

checkStartCycles:
        cmp	[byte ptr cs:demo1Counter], 4 ; check for start screen the demo commands loop count
        jz	short setDemoMode__ ; GO TO DEMO MODE

        test	[DEMO_BUTTON], 80h ; CHECK FOR DEMO KEY is PRESSED
        jnz	short setDemoMode__

        call	isFirePressed
        jz	short playStartDance

        mov	ah, 0		; GAME MODE
        jmp	short loc_18F

; ---------------------------------------------------------------------------

setDemoMode__:
        mov	ah, 1		; DEMO_MODE

loc_18F:
        mov	[byte ptr cs:demo1Counter+1], ah ; set or reset demo mode
        call	prepareDemoPar
        call	paintScreen__
        mov	ah, 6 ; SET START LOCATION
        mov	[locationNum], ah
        mov	ah, 1
        mov	[CONTROL_MODE], ah

        xor	ah, ah
        mov	[demoLockStat], ah

        mov	[byte ptr paintedWeapon], ah
        mov	[byte ptr paintedWeapon+1], ah

        call	updateObjShadowTiles
        call	setNextLoc
        jmp	startScreen
endp		start


; =============== S U B	R O U T	I N E =======================================


proc		resetLives near	;
        mov	ah, 7
        mov	[pLIVE_COUNT], ah
        mov	bx, 0
        mov	[paintedWeapon], bx
endp		resetLives


; =============== S U B	R O U T	I N E =======================================


proc		clearBuf	near
        call	clearWorkbuf
        mov	bx, 0
        mov	[SCORE_COUNT], bx
endp		clearBuf	;


; =============== S U B	R O U T	I N E =======================================

proc		setParam	near
        mov	ah, 1
        mov	[objectsCount], ah
        mov	bx, offset WORK_BUF
        mov	[workBufAddr], bx
        mov	bx, 0
        mov	[word_E02A], bx
        mov	[byte_DE6B], ah
        retn
endp		setParam


; =============== S U B	R O U T	I N E =======================================


proc		setDemoParam__ near
        xor	ah, ah
        mov	[CONTROL_MODE], ah
        mov	[stonesFound], ah
        mov	[DEMO_STATUS], ah

        inc	ah
        mov	[demoLockStat], ah

        mov	bx, offset START_SCR_CMD
        mov	[demo1CmdAddr], bx
        retn
endp		setDemoParam__


; =============== S U B	R O U T	I N E =======================================


proc		clearWorkbuf near	;
        mov	bx, offset WORK_BUF	; memset (DE46H, 0, 480)
        mov	[byte ptr bx], 0
        mov	dx, offset WORK_BUF + 1
        mov	cx, 1DFh
        xchg	si, bx
        xchg	di, dx
        cld
        rep movsb
        xchg	si, bx
        xchg	di, dx
        mov	bx, offset BUF_CLEARED
        mov	[byte ptr bx], 0FFh ; set cleared flag
        retn
endp		clearWorkbuf


; =============== S U B	R O U T	I N E =======================================


proc		clearGameData near
        push	di		; memset (DDB3H, 0, 20)
        push	si
        mov	si, offset byte_DDB3
        mov	[byte ptr si], 0
        mov	di, offset byte_DDB3 + 1
        mov	cx, 14h
        cld
        rep movsb
        pop	si
        pop	di
        retn
endp		clearGameData


; =============== S U B	R O U T	I N E =======================================


proc		clearProvisionStates near	;
        mov	al, cl
        mov	cx, 13h
        mov	di, offset provisionStatePtrs

loc_243:				;
        mov	bx, [di]
        and	[byte ptr bx], 7Fh
        inc	di
        inc	di
        loop	loc_243
        mov	cl, al
        retn
endp		clearProvisionStates

; ---------------------------------------------------------------------------

dwSTACK	dw 0F6h			;

; =============== S U B	R O U T	I N E =======================================


proc		setNextLoc	near
        call	nextLocProc
endp		setNextLoc	;

; =============== S U B	R O U T	I N E =======================================
; MAIN GAME CYCLE
; sub_254

proc		mainCycle	near

        mov	[SMALL_TICK], 0 ; reset timer
        call	demoProc ; Stanley move
        call	foodWaterProc ; food water
        call	weaponProc ; weapon
        call	locationObjProc ; raft ?
        call	stanleyProc ; Stanley proc
        call	execObjectsProc ; enemies proc !
        call	sub_A6E ; check point to next room
        call	sub_3641 ; paint animation objects
        call	sub_CBC ; keyb check ?

loc_274:
        cmp	[SMALL_TICK], 3 ; WAIT FOR NEXT TICK
        jb	short loc_274

        mov	ah, [demoLockStat]
        or	ah, ah
        jz	short mainCycle
        retn
endp		mainCycle


; =============== S U B	R O U T	I N E =======================================

proc		stanleyProc	near

        mov	bx, offset byte_DDB3
        test	[byte ptr bx], 2
        jz	short loc_28D
        retn
; ---------------------------------------------------------------------------
loc_28D:
        test	[byte ptr bx], 80h
        jz	short loc_29F
endp		stanleyProc


; =============== S U B	R O U T	I N E =======================================
; 292

proc		setWeaponStat	near

        mov	si, offset weaponBuf
        test	[byte ptr si], 80h
        jnz	short loc_29B
        retn
; ---------------------------------------------------------------------------

loc_29B:
        or	[byte ptr si], 10h
        retn
endp		setWeaponStat

; ---------------------------------------------------------------------------
; START	OF FUNCTION CHUNK FOR stanleyProc

loc_29F:
        mov	si, offset WORK_BUF
        test	[byte ptr bx], 20h
        jz	short loc_2AA
        jmp	setStanleyEat
; -----------------------------

loc_2AA:
        test	[byte ptr si+24h], 4
        jz	short loc_2B3
        jmp	stanleyDrown
; -----------------------------

loc_2B3:
        test	[byte ptr si+24h], 1
        jz	short loc_2BC
        jmp	swampProc
; ----------------------------

loc_2BC:
        call	checkGround
        mov	[footIndex], ah

        cmp	ah, 8Ah ; check for water
        jnz	short checkSwamp
        jmp	stanleyDrown
; ----------------------------

checkSwamp:
        cmp	ah, 89h ; check for swamp
        jnz	short loc_2D3
        jmp	swampProc
; ---------------------------------------------------------------------------

loc_2D3:
        call	checkBlockCollision ; check collision on right-left ?

        test	[byte ptr si+24h], 2
        jz	short loc_2DF
        jmp	loc_683
; ---------------------------------------------------------------------------

loc_2DF:
        mov	bx, offset byte_DDB3
        test	[byte ptr bx], 10h
        jz	short loc_2EA
        jmp	stunnedStanley
; ---------------------------------------------------------------------------

loc_2EA:
        call	stanleyFire
        test	[byte ptr OBJ_STATUS], 2
        jz	short loc_2F6
        jmp	weaponUsed
; ---------------------------------------------------------------------------

loc_2F6:
        test	[byte ptr OBJ_STATUS], 4
        jz	short loc_2FF
        jmp	stanleyThrow
; ---------------------------------------------------------------------------

loc_2FF:
        call	stanleyUp
        test	[byte ptr OBJ_STATUS], 8
        jz	short loc_30B
        jmp	loc_4E1
; ---------------------------------------------------------------------------

loc_30B:
        test	[byte ptr OBJ_STATUS], 40h
        jz	short loc_32C
        and	[byte ptr OBJ_STATUS], 0FEh

        mov	ah, [CONTROL_STAT]
        test	ah, 8 ; check right status
        jz	short testStanleyLeft

        jmp	stanleyRight  ; is RIGHT pressed
; ---------------------------------------------------------------------------
testStanleyLeft:
        test	ah, 4 ; check left status
        jz	short loc_329
        jmp	stanleyLeft
; ---------------------------------------------------------------------------

loc_329:
        jmp	loc_5F9
; ---------------------------------------------------------------------------

loc_32C:
        test	[byte ptr OBJ_STATUS], 1
        jnz	short loc_371
        test	[byte ptr si+24h], 40h
        jz	short loc_339
        retn
; ---------------------------------------------------------------------------

loc_339:
        mov	bx, offset startJumpRightTiles
        test	[byte ptr DIRECTION], 80h
        jz	short loc_345
        mov	bx, offset startJumpLeftTiles

loc_345:
        call	getFramesPar
        call	checkFrames
        jb	short loc_34E
        retn
; ---------------------------------------------------------------------------

loc_34E:
        mov	ah, [OBJ_STATUS]
        or	ah, [si+24h]
        test	[byte ptr DIRECTION], 80h
        jnz	short loc_365
        test	ah, 20h
        jz	short loc_36E

        mov	[byte ptr DIRECTION], 1
        jmp	short loc_36E
; ---------------------------------------------------------------------------

loc_365:
        test	ah, 10h
        jz	short loc_36E
        mov	[byte ptr DIRECTION], 0FFh

loc_36E:

        jmp	sub_1E64
; ---------------------------------------------------------------------------

loc_371:
        call	checkJumpTiles
        test	[byte ptr si+24h], 80h
        jz	short loc_37E
        mov	[byte ptr si+14h], 7Fh

loc_37E:
        test	[byte ptr DIRECTION], 80h
        jnz	short loc_393
        test	[byte ptr OBJ_STATUS], 20h
        jnz	short loc_3B7
        test	[byte ptr si+24h], 20h ; check right block
        jz	short loc_391
        retn
; ---------------------------------------------------------------------------

loc_391:
        jmp	short loc_3A0
; ---------------------------------------------------------------------------

loc_393:
        test	[byte ptr OBJ_STATUS], 10h
        jnz	short loc_3B7
        test	[byte ptr si+24h], 10h ; check left block
        jz	short loc_3A0
        retn
; ---------------------------------------------------------------------------

loc_3A0:
        call	sub_1E29
        mov	ah, [si+14h]
        test	ah, 80h
        jz	short loc_3B2
        add	ah, 3
        mov	[si+14h], ah
        retn
; ---------------------------------------------------------------------------

loc_3B2:
        mov	[byte ptr si+14h], 7Fh
        retn
; ---------------------------------------------------------------------------

loc_3B7:
        and	[byte ptr OBJ_STATUS], 0FEh
        retn

; END OF FUNCTION CHUNK	FOR stanleyProc

; =============== S U B	R O U T	I N E =======================================
; 3BC

proc		checkJumpTiles	near

        mov	bx, offset rightJumpTiles
        test	[byte ptr DIRECTION], 80h
        jz	short loc_3C8
        mov	bx, offset leftJumpTiles

loc_3C8:
        test	[byte ptr si+14h], 80h
        jz	short loc_3CF
        dec	bx ; set falling tile

loc_3CF:
        mov	ah, [bx]
        mov	[FRAME_NUM], ah
        retn
endp		checkJumpTiles

; ==============================================

; Stanley in the swamp

swampProc:

        test	[byte ptr si+24h], 1
        jnz	short loc_3F8
        call	setswampPar

        mov	dl, 1 ; + 1 step
        test	[byte ptr DIRECTION], 80h
        jz	short loc_3E8
        mov	dl, 0FFh ; -1 step

loc_3E8:
        mov	ah, [X_COORD]
        add	ah, dl
        mov	[X_COORD], ah
        mov	[byte ptr si+0Bh], 0
        mov	[byte ptr si+2], 14h ; pause counter

loc_3F8:
        mov	bx, offset swampDieTiles
        call	getFramesPar
        call	checkFrames
        jb	short loc_404
        retn
; ----------

loc_404:
        dec	[byte ptr si+2]
        jnz	short locret_40C

        jmp	respawnStanley

locret_40C:
        retn

; ==============================================
;Stanley drowned

stanleyDrown:
        test	[byte ptr si+24h], 4 ; check for drown
        jnz	short loc_432

        inc	[byte ptr Y_COORD]
        inc	[byte ptr Y_COORD]
        or	[byte ptr si+24h], 4 ; set drown
        call	sub_E31
        jb	short loc_432

        call	getStanleyCoord
        inc	dh
        dec	bh
        mov	ch, 8
        mov	cl, 0
        xor	ah, ah
        call	sub_DFA

loc_432:
        mov	si, offset WORK_BUF
        mov	bx, offset leftDieTiles
        test	[byte ptr DIRECTION], 80h
        jz	short loc_441
        mov	bx, offset rightDieTiles

loc_441:
        call	getFramesPar
        call	checkFrames
        jnb	short loc_44D
        or	ah, ah
        jnz	short loc_461

loc_44D:
        call	checkGround
        cmp	ah, 8Ah ; check for water
        jz	short loc_456
        retn
; ------------
loc_456:
        test	[byte ptr si+15h], 1
        jnz	short loc_45D
        retn
; ----------------------------

loc_45D:
        inc	[byte ptr Y_COORD] ; Stanley lowered the river bed

        retn
; ---------------------------------------------------------------------------

loc_461:
        mov	ah, 8
        call	sub_1072
        jnb	short loc_46B
        jmp	respawnStanley
; ---------------------------------------------------------------------------

loc_46B:
        or	[byte ptr di], 10h
        jmp	respawnStanley
; ---------------------------------------------------------------------------

setStanleyEat:
        mov	bx, offset stanleyEatLeftTiles
        test	[byte ptr DIRECTION], 80h
        jz	short loc_47D
        mov	bx, offset stanleyEatRightTiles

loc_47D:
        call	getFramesPar
        jmp	checkFrames

; ============================================================================

stanleyRight:
        mov	ah, 40h
        mov	[si+0Dh], ah
        mov	ah, [FRAME_PAUSE]
        cmp	ah, 0Ch
        jz	short loc_495
        inc	ah
        mov	[FRAME_PAUSE],	ah

loc_495:
        mov	bx, offset loc_80C3
        call	getFramesPar
        call	checkFrames
        jb	short loc_4A1
        retn
; ---------------------------------------------------------------------------

loc_4A1:
        mov	ah, [si+24h]
        or	ah, [OBJ_STATUS]
        test	ah, 20h
        jz	short loc_4AD
        retn
; ---------------------------------------------------------------------------

loc_4AD:
        inc	[byte ptr X_COORD]

        stc
        retn
; ===============================================

stanleyLeft:

        mov	ah, 40h
        mov	[si+0Dh], ah
        mov	ah, [FRAME_PAUSE]
        cmp	ah, 0Ch
        jz	short loc_4C4
        inc	ah
        mov	[FRAME_PAUSE], ah

loc_4C4:
        mov	bx, offset loc_80F0
        call	getFramesPar
        call	checkFrames
        jb	short loc_4D0
        retn
; ---------------------------------------------------------------------------

loc_4D0:
        mov	ah, [si+24h]
        or	ah, [OBJ_STATUS]
        test	ah, 10h ; left block
        jz	short loc_4DC
        retn
; ---------------------------------------------------------------------------

loc_4DC:
        dec	[byte ptr X_COORD]
        stc
        retn
; ==========================================================================

loc_4E1:
        test	[byte ptr si+24h], 00001000b ; 10h
        jnz	short loc_538
        mov	ah, [FRAME_PAUSE]
        or	ah, ah
        jnz	short loc_4F8

loc_4EE:
        xor	ah, ah
        mov	[FRAME_PAUSE],	ah
        and	[byte ptr OBJ_STATUS], 11110111b ; 7Fh
        retn
; ---------------------------------------------------------------------------

loc_4F8:
        dec	ah
        mov	[FRAME_PAUSE],	ah
        mov	ah, [OBJ_STATUS]
        or	ah, [si+24h]
        test	ah, 10000000b
        jnz	short loc_4EE
        test	[byte ptr DIRECTION], 80h
        jnz	short loc_51E

        mov	ah, [OBJ_STATUS]
        or	ah, [si+24h]
        test	ah, 20h
        jnz	short loc_4EE

        mov	bx, offset loc_80C8
        jmp	short loc_52C
; ---------------------------------------------------------------------------

loc_51E:
        mov	ah, [OBJ_STATUS]
        or	ah, [si+24h]
        test	ah, 10h
        jnz	short loc_4EE
        mov	bx, offset loc_80F5

loc_52C:
        call	getFramesPar
        mov	[FRAME_NUM], cl
        call	sub_1E64
        jmp	checkJumpTiles
; ---------------------------------------------------------------------------

loc_538:
        dec	[byte ptr si+12h]
        jz	short loc_53E
        retn
; ---------------------------------------------------------------------------

loc_53E:
        and	[byte ptr si+24h], 0F7h
        and	[byte ptr OBJ_STATUS], 0F7h
        retn
; ---------------------------------------------------------------------------

stanleyThrow:
        mov	bx, offset rightStartThrowTile
        test	[byte ptr DIRECTION], 80h
        jz	short loc_553
        mov	bx, offset leftStartThrowTile

loc_553:
        call	getFramesPar
        call	checkFrames
        jb	short loc_55C
        retn
; ---------------------------------------------------------------------------

loc_55C:
        or	ah, ah
        jnz	short loc_561
        retn
; ---------------------------------------------------------------------------

loc_561:
        mov	[FRAME_NUM], ah
        and	[byte ptr OBJ_STATUS], 0FBh
        and	[byte ptr si+24h], 0F7h
        call	sub_939
        xor	ah, ah
        mov	[byte ptr pSTRENGHT], ah
        retn
; END OF FUNCTION CHUNK	FOR stanleyProc

; =============== S U B	R O U T	I N E =======================================
; jump routine

proc		stanleyUp	near

        test	[byte ptr OBJ_STATUS], 8
        jz	short loc_57D
        retn
; ---------------------------------------------------------------------------

loc_57D:
        mov	ah, [CONTROL_STAT]
        test	ah, 1 ; check for up-key pressed
        jz	short stanleyDown
        test	[byte ptr OBJ_STATUS], 40h
        jnz	short loc_58D
        retn
; ---------------------------------------------------------------------------

loc_58D:
        mov	bx, offset loc_80C8
        test	[byte ptr DIRECTION], 80h
        jz	short loc_599
        mov	bx, offset loc_80F5

loc_599:
        call	getFramesPar
        or	[byte ptr OBJ_STATUS], 8
        call	checkFrames
        mov	ah, [si+2]
        or	ah, ah
        jz	short loc_5B0
        mov	bx, offset smallJumpSound
        jmp	playSound
; ---------------------------------------------------------------------------

loc_5B0:
        mov	ah, [Y_COORD]
        sub	ah, 2
        jnb	short loc_5B9
        retn
; ---------------------------------------------------------------------------

loc_5B9:
        mov	cl, 1
        test	[byte ptr DIRECTION], 80h
        jz	short loc_5C3
        mov	cl, 0FFh

loc_5C3:
        mov	[DIRECTION], cl
        or	[byte ptr si+24h], 8
        mov	[byte ptr si+12h], 8
        dec	[byte ptr Y_COORD]	; sub-jump :)
        dec	[byte ptr Y_COORD]
        mov	bx, offset jumpSound
        jmp	playSound
; ---------------------------------------------------------------------------

stanleyDown:
        test	ah, 2
        jnz	short loc_5E0
        retn
; ---------------------------------------------------------------------------

loc_5E0:
        test	[byte ptr OBJ_STATUS], GROUND_BIT
        jnz	short loc_5E7
        retn
; ---------------------------------------------------------------------------

loc_5E7:
        mov	bx, offset loc_80CD
        test	[byte ptr si+13h], 80h
        jz	short loc_5F3
        mov	bx, offset loc_80FA

loc_5F3:
        call	getFramesPar
        jmp	checkFrames
endp		stanleyUp

; ==============================================
; START	OF FUNCTION CHUNK FOR stanleyProc

loc_5F9:
        mov	ah, [CONTROL_STAT]
        and	ah, 0Fh
        jz	short loc_603
        retn
; ---------------------------------------------------------------------------

loc_603:
        mov	ah, 40h
        mov	[si+0Dh], ah
        xor	ah, ah
        mov	[FRAME_PAUSE], ah
        test	[byte ptr DIRECTION], 80h
        mov	bx, offset rightThrowTiles
        jz	short loc_619
        mov	bx, offset leftThrowTiles

loc_619:
        mov	ah, [bx]
        mov	[FRAME_NUM], ah
        retn

; END OF FUNCTION CHUNK	FOR stanleyProc

; =============== S U B	R O U T	I N E =======================================


proc		getFramesPar	near

        mov	dl, [bx]
        inc	bx
        mov	cl, [bx]
        inc	bx
        mov	ch, [bx]
        inc	bx
        mov	ah, [bx]
        or	ah, ah
        jz	short loc_631
        mov	[DIRECTION], ah

loc_631:
        inc	bx
        mov	ah, [bx]
        or	ah, ah
        jnz	short loc_639
        retn
; ---------------------------------------------------------------------------

loc_639:
        mov	[si+14h], ah
        retn
endp		getFramesPar

; ---------------------------------------------------------------------------
; START	OF FUNCTION CHUNK FOR stanleyProc

respawnStanley:
        call	hat__
        mov	ah, [pLIVE_COUNT]

loc_644:
        dec	ah
        mov	[pLIVE_COUNT], ah
        cmp	ah, 0FFh
        jnz	short resurrectStanley

        jmp	startScreen
; ---------------------------------------------------------------------------

resurrectStanley:
        mov	ah, 3Ch
        mov	[byte ptr pFOOD], ah
        mov	[byte ptr pFOOD+1], ah

        mov	si, offset WORK_BUF

        mov	[byte ptr OBJ_STATUS], 0
        mov	[byte ptr si+24h], 0
        or	[byte ptr si], 20h

        call	sub_3641

        mov	si, offset WORK_BUF
        and	[byte ptr si], 0DFh

        call	getRespawnCoord
        xor	ah, ah
        mov	[byte_DDB3], ah
        mov	[footIndex], ah
        jmp	checkRaft
; ---------------------------------------------------------------------------

loc_683:
        test	[byte ptr OBJ_STATUS], 40h
        jnz	short loc_690
        mov	[byte ptr si+14h], 7Fh
        jmp	sub_1E64
; ---------------------------------------------------------------------------

loc_690:
        mov	bx, offset leftDieTiles
        test	[byte ptr DIRECTION], 80h
        jz	short loc_69C
        mov	bx, offset rightDieTiles

loc_69C:
        call	getFramesPar
        call	checkFrames
        jb	short loc_6A5
        retn
; ---------------------------------------------------------------------------

loc_6A5:
        or	ah, ah
        jz	short locret_6AB
        jmp	short respawnStanley
; ---------------------------------------------------------------------------

locret_6AB:
        retn
; ===========================================================================

stunnedStanley:
        test	[byte ptr OBJ_STATUS], GROUND_BIT
        jnz	short stunNow

        mov	[byte ptr si+14h], 7Fh
        jmp	sub_1E64
; ---------------------------------------------------------------------------

stunNow:
        mov	bx, offset leftStunnedTiles
        test	[byte ptr DIRECTION], 80h
        jz	short loc_6C5
        mov	bx, offset rightStunnedTiles

loc_6C5:
        call	getFramesPar
        call	checkFrames
        jb	short loc_6CE
        retn
; ---------------------------------------------------------------------------

loc_6CE:
        dec	[byte ptr FRAME_PAUSE] ; count stun time
        jz	short endStun
        retn
; ---------------------------------------------------------------------------

endStun:
        mov	bx, offset byte_DDB3
        and	[byte ptr bx], 0EFh
        retn
; END OF FUNCTION CHUNK	FOR stanleyProc

; =============== S U B	R O U T	I N E =======================================

proc		stanleyFire	near

        test	[byte ptr OBJ_STATUS], 2
        jz	short loc_6E2
        retn
; --------------------
loc_6E2:
        test	[byte ptr OBJ_STATUS], FIRE_BIT
        jz	short loc_6E9
        retn
; --------------------

loc_6E9:
        mov	ah, [CONTROL_STAT]
        test	ah, 10h
        jz	short setStanleyFire
        mov	ah, [byte ptr paintedWeapon]
        test	ah, 4
        jz	short checkStrenght__
        or	[byte ptr OBJ_STATUS], 2
        jmp	short loc_748

endp		stanleyFire


; =============== S U B	R O U T	I N E =======================================

proc		checkStrenght__	near

        mov	ah, [byte ptr pSTRENGHT]
        or	ah, ah
        jnz	short loc_70C
        call	clearStrenght__

loc_70C:
        mov	ah, [byte ptr pSTRENGHT]
        cmp	ah, 3Ch
        jb	short addCount
        retn
; ---------------------------------------------------------------------------

addCount:
        inc	ah
        inc	ah
        mov	[byte ptr pSTRENGHT], ah
        jmp	paintStrenght__

endp		checkStrenght__

; ---------------------------------------------------------------------------
; START	OF FUNCTION CHUNK FOR stanleyFire

setStanleyFire:

        mov	ah, [byte ptr pSTRENGHT]
        or	ah, ah
        jnz	short strenghtNotZero
        retn
; ---------------------------------------------------------------------------

strenghtNotZero:
        mov	ah, [OBJ_STATUS]
        and	ah, 0F1h
        or	ah, FIRE_BIT
        mov	[OBJ_STATUS], ah
        mov	bx, offset rightFireTiles
        test	[byte ptr DIRECTION], 80h
        jz	short setFireFrame
        mov	bx, offset leftFireTiles

setFireFrame:
        mov	ah, [bx]
        mov	[FRAME_NUM], ah
        retn

; ===================================================

loc_748:
        mov	bx, offset loc_812A
        mov	[word_DDE8], bx
        call	getObjCoord
        mov	cl, 7
        mov	ah, 0FBh
        jnz	short loc_763
        mov	cx, offset loc_812F
        mov	[word_DDE8], cx
        mov	cl, 0
        mov	ah, 1

loc_763:
        push	ax
        add	ah, dh
        mov	dh, ah
        push	cx
        mov	cx, 1C0h
        add	bx, cx
        pop	cx
        mov	ch, 4
        pop	ax
        test	[byte ptr OBJ_STATUS], 40h
        jz	short loc_786
        push	si
        mov	si, offset weaponBuf
        call	sub_DFA
        mov	ah, 4
        call	addObject
        pop	si
        retn
; ---------------------------------------------------------------------------

loc_786:
        and	[byte ptr OBJ_STATUS], 0FDh
        jmp	clearStrenght__

; END OF FUNCTION CHUNK	FOR stanleyFire

; =============== S U B	R O U T	I N E =======================================
; check ground
;
; output:
; AH = sprite under object
; set GROUND_BIT status if sprite = 0A2h

proc		checkGround	near

        mov	ah, [OBJ_STATUS]
        and	ah, 0Fh
        mov	[OBJ_STATUS], ah

        call	getObjSize
        call	checkRoomBorder
        call	getObjCoord

        mov	cx, 20h
        add	bx, cx ; add 32 bytes

        mov	cx, [objYsize]
        add	bx, cx

        xchg	dx, bx
        mov	cx, [objXsize]
        shr	cx, 1
        add	bx, cx

        xchg	dx, bx
        mov	ch, bh
        mov	cl, dh
        call	getAddrByCoord
        mov	ah, [bx]
        cmp	ah, 0A2h
        jnb	short loc_7C5

        retn
;-------------
loc_7C5:
        or	[byte ptr OBJ_STATUS], GROUND_BIT
        retn
endp		checkGround

; =============== S U B	R O U T	I N E =======================================

proc		getObjSize	near

        mov	bx, offset animObjSizes
        mov	dl, [OBJ_NUM]
        shl	dl, 1 ; dl * 2
        mov	dh, 0
        add	bx, dx ; get object addr

        mov	dh, [bx]
        inc	bx
        mov	dl, [bx]

        mov	bl, dh
        mov	bh, 0

        add	bx, bx
        add	bx, bx
        add	bx, bx
        add	bx, bx
        add	bx, bx ; bx * 5

        mov	[objYsize], bx
        mov	bh, 0
        mov	bl, dl

        add	bx, bx
        add	bx, bx
        add	bx, bx
        add	bx, bx
        add	bx, bx ; bx * 5

        mov	[objXsize], bx
        retn
endp		getObjSize

; =============== S U B	R O U T	I N E =======================================

proc		checkRoomBorder	near
        mov	ah, [si+24h]
        and	ah, 0Fh
        mov	[si+24h], ah

        mov	ah, [Y_COORD]
        cmp	ah, 1 ; checking ceiling
        jnb	short loc_814
        call	stanleyBlockDown

loc_814:
        mov	dx, [objYsize]
        mov	bh, [Y_COORD]
        mov	bl, [si+0Dh]
        add	bx, dx
        mov	dx, 1300h
        sbb	bx, dx
        jb	short loc_82A
        call	stanleyBlockUp

loc_82A:
        mov	bx, [si+0Bh]
        mov	ah, bh
        cmp	ah, 1
        jnb	short loc_837
        call	stanleyBlockLeft

loc_837:
        mov	dx, [objXsize]
        add	bx, dx
        mov	ah, 26h
        sub	ah, bh
        jb	short stanleyBlockRight
        retn
; ---------------------------------------------------------------------------

stanleyBlockRight:
        or	[byte ptr si+24h], 20h
        retn
endp		checkRoomBorder


; =============== S U B	R O U T	I N E =======================================


proc		stanleyBlockDown	near
        or	[byte ptr si+24h], 80h
        retn
endp		stanleyBlockDown


; =============== S U B	R O U T	I N E =======================================


proc		stanleyBlockLeft	near
        or	[byte ptr si+24h], 10h
        retn
endp		stanleyBlockLeft


; =============== S U B	R O U T	I N E =======================================

proc		stanleyBlockUp	near
        or	[byte ptr si+24h], 40h
        retn
endp		stanleyBlockUp

; =============== S U B	R O U T	I N E =======================================
; 858

proc		checkBlockCollision	near

        mov	ch, [Y_COORD]
        mov	cl, [X_COORD]
        call	getAddrByCoord
        mov	ah, 10h
        mov	[byte ptr word_DDD8], ah
        mov	di, offset blockTypes
        mov	dh, 0

loc_86C:
        push	bx
        inc	di
        mov	ah, 0FFh
        mov	dl, [di]
        cmp	ah, dl
        jz	short loc_88C
        add	bx, dx
        mov	ah, [bx]
        cmp	ah, 0B9h
        pop	bx
        jb	short loc_86C
        mov	ah, [byte ptr word_DDD8]
        or	ah, [OBJ_STATUS]
        mov	[OBJ_STATUS], ah
        jmp	short loc_86C
; ---------------------------------------------------------------------------

loc_88C:
        pop	bx
        mov	ah, [byte ptr word_DDD8]
        shl	ah, 1
        mov	[byte ptr word_DDD8], ah
        jnb	short loc_86C

        retn
endp		checkBlockCollision


; =============== S U B	R O U T	I N E =======================================


proc		nextLocProc	near
        call	updateObjShadowTiles
        call	clearBuf
        call	clearGameData

loc_8A3:
        call	disableSound

        xor	ah, ah
        mov	[byte_DDAF], ah
        mov	[byte_DDB4], ah
        call	setParam
        call	PrepareLocation__
        call	locationRoutine
        jmp	paintLocation__

endp		nextLocProc

; ---------------------------------------------------------------------------
setLoc0Raft:
        mov	ch, 10h ; set raft coord
        mov	cl, 14h
        jmp	short raftWait
; ---------------------------------------------------------------------------
loc_08C2:
        mov	ch, 4
        mov	cl, 0FDh
        jmp	short loc_8F0
; ---------------------------------------------------------------------------
loc_08C8:
        mov	ch, 10h
        mov	cl, 5
        jmp	short loc_8F0
; ---------------------------------------------------------------------------
loc_08CE:
        mov	ch, 0Eh
        mov	cl, 0Ch
        jmp	short loc_8F0
; ---------------------------------------------------------------------------
loc_08D4:
        mov	ch, 0Eh
        mov	cl, 7
        jmp	short loc_8F0
; ---------------------------------------------------------------------------
loc_08DA:
        mov	ah, [raftStatus]
        or	ah, ah
        jz	short locret_8E5
        jmp	raftProc
; ---------------------------------------------------------------------------

locret_8E5:
        retn
; ---------------------------------------------------------------------------

raftWait:
        mov	ah, [footIndex]
        cmp	ah, 0D9h
        jz	short loc_8F0
        retn
; ---------------------------------------------------------------------------

loc_8F0:

        mov	ah, [raftStatus]
        or	ah, ah
        jz	short startRaft
        retn
; ---------------------------------------------------------------------------

startRaft:
        mov	[RAFT_COORD], cx
        mov	ah, 1
        mov	[raftStatus], ah

        mov	ah, 5
        mov	[raftTimeCycle], ah
        retn
; ---------------------------------------------------------------------------
loc_90A:

db 80
db 40
db 20
db 10

; =============== S U B	R O U T	I N E =======================================
; weapon proc

proc		weaponProc	near


        mov	ah, [byte ptr paintedWeapon]
        and	ah, 0F0h
        mov	dl, ah
        mov	ah, [pSelectedWeapon]
        mov	bx, offset loc_90A - 1
        mov	cl, ah
        mov	ch, 0
        add	bx, cx
        mov	ah, [bx]
        and	ah, dl
        mov	ah, [pSelectedWeapon]
        jz	short loc_930
        xor	ah, ah

loc_930:
        or	ah, dl
        mov	[byte ptr paintedWeapon], ah

        jmp	weaponSubProc

endp		weaponProc


; =============== S U B	R O U T	I N E =======================================


proc		sub_939	near

        mov	ah, [byte ptr paintedWeapon]
        and	ah, 0Fh
        jnz	short loc_943
        retn
; ---------------------------------------------------------------------------

loc_943:
        mov	dx, 28h
        call	sub_D06
        xchg	dx, bx
        mov	si, offset WORK_BUF
        add	si, dx
        test	[byte ptr si], 80h
        jz	short loc_956
        retn
; ---------------------------------------------------------------------------

loc_956:
        mov	bx, offset paintedWeapon
        mov	ah, [byte ptr paintedWeapon]
        and	ah, 0Fh
        cmp	ah, 1
        jnz	short loc_9B0
        test	[byte ptr bx], 80h
        jz	short loc_96B
        retn
; ---------------------------------------------------------------------------

loc_96B:
        mov	ah, 84h
        mov	[byte_DDB7], ah
        mov	ah, [byte ptr pSTRENGHT]
        shl	ah, 1
        neg	ah
        call	getStanleyCoord
        jnz	short loc_98E
        inc	dh
        inc	dh
        mov	ah, 1
        mov	[byte_DDB7], ah
        mov	ah, [byte ptr pSTRENGHT]
        shl	ah, 1

loc_98E:
        inc	bh

        mov	ch, 1
        mov	cl, 0
        call	sub_DFA
        mov	ah, [byte ptr pSTRENGHT]
        shl	ah, 1
        mov	[byte_DDEA], ah
        mov	[byte_DDEB], ah
        mov	ah, 1
        call	addObject
        mov	bx, offset sound1
        jmp	playSound
; ---------------------------------------------------------------------------

loc_9B0:
        cmp	ah, 2
        jnz	short loc_9E7
        test	[byte ptr bx], 40h
        jz	short loc_9BB
        retn
; ---------------------------------------------------------------------------

loc_9BB:
        call	getStanleyCoord
        mov	cl, 1
        jnz	short loc_9C8
        inc	dh
        inc	dh
        mov	cl, 0

loc_9C8:
        inc	bh
        mov	ch, 2
        mov	ah, [byte ptr pSTRENGHT]
        shl	ah, 1
        test	cl, 1
        jz	short loc_9D9
        neg	ah

loc_9D9:
        call	sub_DFA
        mov	ah, 2
        call	addObject
        mov	bx, offset loc_7F3B
        jmp	playSound
; ---------------------------------------------------------------------------

loc_9E7:
        cmp	ah, 3
        jz	short loc_9ED
        retn
; ---------------------------------------------------------------------------

loc_9ED:
        test	[byte ptr bx], 20h
        jz	short loc_9F3
        retn
; ---------------------------------------------------------------------------

loc_9F3:
        mov	ah, [byte ptr pSTRENGHT]
        neg	ah
        call	getStanleyCoord
        jnz	short loc_A04
        inc	dh
        inc	dh
        neg	ah

loc_A04:
        dec	bh
        jnz	short loc_A09
        retn
; ---------------------------------------------------------------------------

loc_A09:
        test	bh, 80h
        jz	short loc_A0F
        retn
; ---------------------------------------------------------------------------

loc_A0F:
        mov	cl, 0
        mov	ch, 3
        call	sub_DFA
        mov	ah, [byte ptr pSTRENGHT]
        shl	ah, 1
        neg	ah
        mov	[si+14h], ah
        mov	ah, 3
        jmp	addObject

endp		sub_939

; ===========================================================================

loc_A26:
        mov	ah, 7
        call	sub_1072

        jb	short loc_A2E
        retn
; ---------------------------------------------------------------------------

loc_A2E:
        mov	bx, offset byte_DDB3
        test	[byte ptr bx], 1
        jz	short loc_A37
        retn
; ---------------------------------------------------------------------------

loc_A37:
        call	getRandom
        and	ah, 7Fh
        cmp	ah, 0Ch
        jz	short loc_A43
        retn
; ---------------------------------------------------------------------------

loc_A43:
        call	sub_E31
        jnb	short loc_A49
        retn
; ---------------------------------------------------------------------------

loc_A49:
        or	[byte ptr bx], 1
        push	di
        mov	di, [locDscAddr]
        mov	dx, 6
        add	di, dx
        call	sub_DAF
        pop	di
        mov	cl, 4
        mov	ah, [X_COORD]
        cmp	ah, 14h
        jnb	short loc_A66
        mov	cl, 8

loc_A66:
        mov	[si+2],	cl
        mov	[byte ptr si+20h], 0Fh
        retn

; =============== S U B	R O U T	I N E =======================================


proc		sub_A6E	near
        mov	bx, offset byte_DDB3
        test	[byte ptr bx], 80h ; test to next location
        jz	short loc_A77

        retn
; -----------------------------

loc_A77:
        mov	si, offset WORK_BUF
        mov	ah, [si+24h]
        and	ah, 70h
        jnz	short loc_A83
        retn
; -----------------------------
loc_A83:
        mov	di, [locDscAddr]
        test	ah, 40h
        jnz	short loc_AE1
        test	ah, 20h
        jnz	short loc_ABB

        call	sub_BA9
        jnz	short loc_A97
        retn
; ---------------------------
loc_A97:
        mov	dx, 0
        mov	ah, [si+0Eh]
        cmp	ah, 0Ah
        jnb	short loc_AA5
        mov	dx, 1
loc_AA5:
        add	di, dx
        mov	ah, [di]
        cmp	ah, 0FFh
        jnz	short loc_AB7
        and	[byte ptr OBJ_STATUS], 0FEh
        mov	[byte ptr X_COORD], 0
        retn
; -------------------------
loc_AB7:
        mov	dl, 25h
        jmp	short loc_B0C
; ------------------------
loc_ABB:
        call	sub_B9A
        jz	short loc_AC1
        retn
; ------------------------
loc_AC1:
        mov	dx, 2
        mov	ah, [si+0Eh]
        cmp	ah, 0Ah
        jb	short loc_ACF
        mov	dx, 3
loc_ACF:
        add	di, dx
        mov	ah, [di]
        cmp	ah, 0FFh
        jnz	short loc_ADD
        and	[byte ptr OBJ_STATUS], 0FEh
        retn
; ------------------------
loc_ADD:
        mov	dl, 0
        jmp	short loc_B0C
; ------------------------

loc_AE1:
        test	[byte ptr si+14h], 80h
        jz	short loc_AE8
        retn
; -----------------------
loc_AE8:
        mov	dx, 3
        add	di, dx
        mov	ah, [di]
        cmp	ah, 0FFh
        jnz	short loc_AF5
        retn
; -----------------------

loc_AF5:
        test	ah, 40h
        jnz	short loc_AFB
        retn
; -----------------------

loc_AFB:
        and	ah, 0BFh
        mov	[locationNum], ah
        mov	[byte ptr si+0Eh], 0
        mov	[byte ptr si+0Dh], 40h
        jmp	short loc_B38
; ------------------------

loc_B0C:
        cmp	ah, 0FEh
        jnz	short loc_B19
        mov	ah, 0FFh
        mov	[byte_DDC5], ah
        jmp	short loc_B38
; -------------------------
loc_B19:
        test	ah, 80h
        pushf
        and	ah, 7Fh
        mov	[locationNum], ah
        popf
        jz	short loc_B31
        mov	[byte ptr si+0Eh], 0
        mov	[byte ptr si+0Dh], 0C0h
        inc	dl

loc_B31:
        mov	[byte ptr si+0Bh], 0
        mov	[X_COORD], dl

loc_B38:
        and	[byte ptr OBJ_STATUS], 0FDh
        call	checkRaft
        call	updateObjShadowTiles
        mov	si, offset WORK_BUF
        or	[byte ptr si], 40h

        call	copy8bytesUp
        call	sub_E82
        xor	ah, ah
        mov	[byte_DDB3], ah

loc_B54:
        mov	bx, offset loc_DE6E
        mov	[byte ptr bx], 0
        mov	dx, offset loc_DE6E + 1
        mov	cx, 1B7h
        xchg	si, bx
        xchg	di, dx
        cld
        rep movsb
        xchg	si, bx
        xchg	di, dx
        mov	ah, [locationNum]
        cmp	ah, 1Ch ; GODNESS LOCATION
        jz	short loc_B79
        cmp	ah, 3Ch ; FINAL LOCATION (FINAL)
        jnz	short loc_B7F
loc_B79:
        mov	bx, offset WORK_BUF
        mov	[byte ptr bx], 0
loc_B7F:
        jmp	loc_8A3

endp		sub_A6E


; =============== S U B	R O U T	I N E =======================================


proc		checkRaft	near

        mov	ah, [raftStatus]
        or	ah, ah
        jz	short loc_B8D
        call	raftRepaint

loc_B8D:
        xor	ah, ah
        mov	[raftStatus], ah
        mov	ah, 5
        mov	[raftTimeCycle], ah
        retn
endp		checkRaft


; =============== S U B	R O U T	I N E =======================================


proc		sub_B9A	near
        mov	ah, [footIndex]
        cmp	ah, 0D9h
        jnz	short loc_BA4
        retn
; ---------------------------------------------------------------------------

loc_BA4:
        test	[byte ptr DIRECTION], 80h
        retn
endp		sub_B9A


; =============== S U B	R O U T	I N E =======================================


proc		sub_BA9	near
        mov	ah, [footIndex]
        cmp	ah, 0D9h
        jz	short loc_BB7
        test	[byte ptr DIRECTION], 80h
        retn
; ---------------------------------------------------------------------------

loc_BB7:
        or	ah, ah
        retn
endp		sub_BA9

; =============== S U B	R O U T	I N E =======================================

proc		demoProc	near

        mov	ah, [CONTROL_MODE]
        or	ah, ah
        jz	short loc_BC8
        call	checkControls__
        jmp	loc_250E
; ---------------------------------------------------------------------------

loc_BC8:
        mov	si, offset WORK_BUF
        mov	ah, [OBJ_STATUS]
        and	ah, 0FDh
        or	ah, [si+24h]
        and	ah, 0Fh
        jz	short loc_BDA
        retn
; ---------------------------------------------------------------------------

loc_BDA:
        mov	bx, [demo1CmdAddr]
        mov	ah, [bx]
        cmp	ah, 0FFh ; check end of demo
        jnz	short loc_BF5

        mov	[CONTROL_MODE], ah
        xor	ah, ah
        mov	[DEMO_STATUS], ah
        inc	[cs:demo1Counter]
        retn
; ---------------------------------------------------------------------------

loc_BF5:
        test	ah, 80h
        jz	short loc_C0C

        and	ah, 0Fh
        mov	[pSelectedWeapon], ah
        push	bx
        call	weaponProc
        pop	bx
endp		demoProc

; =============== S U B	R O U T	I N E =======================================


proc		setDemoAddr	near
        inc	bx
        mov	[demo1CmdAddr], bx
        retn
endp		setDemoAddr

; ---------------------------------------------------------------------------
; START	OF FUNCTION CHUNK FOR demoProc
; PLAY DEMO ON START PAGE
loc_C0C:
        mov	ah, [DEMO_STATUS]
        or	ah, ah
        jnz	short loc_C1D
        mov	ah, [bx]
        mov	[DEMO_STATUS], ah
        call	setDemoAddr

loc_C1D:
        mov	ah, [bx]
        mov	[CONTROL_STAT], ah
        mov	ah, [DEMO_STATUS]
        dec	ah
        mov	[DEMO_STATUS], ah
        jz	short loc_C30
        retn
; ---------------------------------------------------------------------------

loc_C30:
        jmp	short setDemoAddr
; END OF FUNCTION CHUNK	FOR demoProc

; =============== S U B	R O U T	I N E =======================================
; DL = delay
;

proc		checkFrames	near
        inc	ch
        mov	ah, [FRAME_NUM]
        cmp	ah, cl
        jb	short loc_C3F
        cmp	ah, ch
        jb	short loc_C71

loc_C3F:
        mov	[FRAME_NUM], cl
        xor	ah, ah
        mov	[si+15h], ah
        retn
endp		checkFrames


; =============== S U B	R O U T	I N E =======================================

proc		setFrameNum	near

        inc	ch
        mov	ah, [FRAME_NUM]
        cmp	ah, cl
        jb	short loc_C55
        cmp	ah, ch
        jb	short loc_C71

loc_C55:
        mov	ah, cl
        or	ah, ah
        jz	short loc_C62
        mov	ah, [FRAME_NUM]
        add	ah, cl
        jmp	short loc_C67
; ---------------------------------------------------------------------------

loc_C62:
        mov	ah, [FRAME_NUM]
        sub	ah, ch

loc_C67:
        mov	[FRAME_NUM], ah
        mov	[byte ptr si+15h], 0
        xor	ah, ah
        retn
; ---------------------------------------------------------------------------

loc_C71:
        mov	ah, [si+15h]
        cmp	ah, dl
        jnb	short loc_C7E
        inc	[byte ptr si+15h]
        xor	ah, ah
        retn
; ---------------------------------------------------------------------------

loc_C7E:
        mov	ah, [FRAME_NUM]
        inc	ah
        cmp	ah, ch
        jnb	short loc_C91
        mov	[FRAME_NUM], ah
        xor	ah, ah
        mov	[si+15h], ah
        stc
        retn
; ---------------------------------------------------------------------------

loc_C91:
        dec	ch
        mov	ah, ch
        mov	[FRAME_NUM], cl
        mov	[byte ptr si+15h], 0
        stc
        retn
endp		setFrameNum


; =============== S U B	R O U T	I N E =======================================
; input:
; CX = sprite coord
; output:
; BX = offset in location(room) buffer
;
proc		getAddrByCoord near

        mov	bl, ch
        mov	bh, 0		; BX=CH*4+CH*3+CL
        add	bx, bx
        add	bx, bx
        add	bx, bx
        mov	dh, bh
        mov	dl, bl
        add	bx, bx
        add	bx, bx
        add	bx, dx
        mov	ch, 0
        add	bx, cx
        mov	dx, offset LOCAT_BUF
        add	bx, dx
        retn
endp		getAddrByCoord


; =============== S U B	R O U T	I N E =======================================


proc		sub_CBC	near
        test	[CONTROL_STAT], 20h
        jz	short loc_CC6
        jmp	startScreen
; ---------------------------------------------------------------------------

loc_CC6:
        call	test7D11__
        jnz	short loc_CCC
        retn
; ---------------------------------------------------------------------------

loc_CCC:
        call	test7D11__
        jnz	short loc_CCC

loc_CD1:
        call	test7D11__
        jz	short loc_CD1

loc_CD6:
        call	test7D11__
        jnz	short loc_CD6
        retn
endp		sub_CBC


; =============== S U B	R O U T	I N E =======================================
; random?

proc		getRandom	near

        or	ah, ah
        push	bx
        push	dx
        mov	dx, [tmpRandom]
        mov	bh, dl
        mov	bl, 0FDh
        mov	ah, dh
        sbb	bx, dx
        sbb	ah, 0
        sbb	bx, dx
        sbb	ah, 0
        mov	dl, ah
        mov	dh, 0
        sbb	bx, dx
        jnb	short loc_CFD
        inc	bx

loc_CFD:
        mov	[tmpRandom], bx
        mov	ah, bl
        pop	dx
        pop	bx
        retn
endp		getRandom

; =============== S U B	R O U T	I N E =======================================

proc		sub_D06	near
        push	cx
        mov	bx, 0
        mov	ch, 8

loc_D0C:
        rcr	ah, 1
        jnb	short loc_D12
        add	bx, dx

loc_D12:
        rcl	dx, 1
        dec	ch
        jnz	short loc_D0C
        pop	cx
        retn
endp		sub_D06

; ---------------------------------------------------------------------------

loc_D1A:
        dec	cx
        mov	ah, ch
        or	ah, cl
        jnz	short loc_D1A
        retn
; ---------------------------------------------------------------------------
        mov	bh, 0
        add	bx, bx
        add	bx, bx
        add	bx, bx
        add	bx, bx
        retn

; =============== S U B	R O U T	I N E =======================================


proc		paintBottomPanel__ near	;

        mov	ah, [bx]	; ; get	sprite number from [bx]
        cmp	ah, 0FFh	; ; check the end of sprite buffer
        jnz	short loc_D35
        retn
; ---------------------------------------------------------------------------

loc_D35:
        or	ah, ah ; if (AH == 0) set sprite pos command
        jz	short setSpritePos
        push	bx
        mov	al, ah
        mov	ah, 0
        call	typeBuf2Sprite__
        pop	bx
        inc	bx
        jmp	short paintBottomPanel__
; ---------------------------------------------------------------------------

setSpritePos:
        inc	bx		; byte code array = 0,x,y  where 0 is code for position	indication
                    ; read sprite position
        mov	ah, [bx]
        inc	bx
        mov	[byte ptr pSPR_XY+1], ah
        mov	ah, [bx]
        mov	[byte ptr pSPR_XY], ah
        inc	bx
        jmp	short paintBottomPanel__
endp		paintBottomPanel__


; =============== S U B	R O U T	I N E =======================================

proc		typeBuf2Sprite__ near
        mov	cx, [pSPR_XY]	; //CL = x ; CH	 = y
                    ; CX = *DDDC;
                    ; AL = sprite number;
                    ;
                    ; paint_sprite(cx);
                    ;
                    ; x++;
                    ; if (x	> 40) goto end
                    ; x = 0;
                    ; y++;
                    ; if (y	> 24) goto end

        call	writeSpriteBuf2__ ; Draw character AH at CX
        mov	cx, [pSPR_XY]
        inc	cl
        mov	ah, 27h
        cmp	ah, cl
        jnb	short endTyping
        mov	cl, 0
        inc	ch
        mov	ah, 18h
        cmp	ah, ch
        jnb	short endTyping
        mov	cx, 0

endTyping:
        mov	[pSPR_XY], cx
        retn
endp		typeBuf2Sprite__


; =============== S U B	R O U T	I N E =======================================
; dx = si + 3
; bx = si + 11 (dec)
; cx = 8
;
; si = bx  = (si + 3)
; di = dx  = (si + 11)
; copy (si+3, si+Bh, 8)
; si = si + 3
; di = si + 11
;

proc		copy8bytesUp	near

        push	si
        pop	bx
        mov	cx, 3
        add	bx, cx
        push	bx
        pop	dx
        mov	cx, 8
        add	bx, cx
        xchg	si, bx
        xchg	di, dx
        cld
        rep movsb
        xchg	si, bx
        xchg	di, dx
        retn
endp		copy8bytesUp

; =============== S U B	R O U T	I N E =======================================
; dx = si + 3
; bx = si + 11 (dec)
; cx = 8
;
; si = dx  = (si + 3)
; di = bx  = (si + 11)
; copy (si+Bh, si+3, 8)
; si = si + 11
; di = si + 3
;
proc		copy8bytesDown	near

        push	si
        pop	bx
        add	bx, 3
        push	bx
        pop	dx
        mov	cx, 8
        add	bx, cx
        xchg	dx, bx
        xchg	si, bx
        xchg	di, dx
        cld
        rep movsb
        xchg	si, bx
        xchg	di, dx
        retn
endp		copy8bytesDown


; =============== S U B	R O U T	I N E =======================================


proc		sub_DAF	near

        call	clear26Bytes
        mov	ah, [di-1]
        mov	[si+0Ah], ah
        mov	ah, [di]
        mov	[si+7],	ah
        mov	cl, ah
        mov	ah, [di+1]
        mov	[si+8],	ah
        mov	ah, [di+2]
        mov	[si+3],	ah
        mov	ah, [di+3]
        mov	[si+4],	ah
        mov	ah, [di+4]
        mov	[si+5],	ah
        mov	ah, [di+5]
        mov	[si+6],	ah
        mov	ah, [di+6]
        mov	[si+22h], ah
        add	ah, 7
        mov	[si+20h], ah
        mov	ah, [di+7]
        mov	[si+23h], ah
        adc	ah, 0
        mov	[si+21h], ah
        mov	ah, [si+8]
        jmp	short loc_E12
endp		sub_DAF


; =============== S U B	R O U T	I N E =======================================


proc		sub_DFA	near

        call	clear26Bytes
        mov	[si+7],	ch
        mov	[si+8],	cl
        mov	[si+3],	dl
        mov	[si+4],	dh
        mov	[si+5],	bl
        mov	[si+6],	bh
        mov	[si+13h], ah

loc_E12:
        call	getObjAddr

        jmp	copy8bytesDown

endp		sub_DFA


; =============== S U B	R O U T	I N E =======================================

proc		clear26Bytes	near
        push	si
        push	di
        push	cx
        push	si
        mov	[byte ptr si], 0
        pop	di
        inc	di
        mov	cx, 26h
        cld
        rep movsb
        pop	cx
        pop	di
        pop	si
        or	[byte ptr si], 80h ; set work flag
        or	[byte ptr si], 40h
        retn
endp		clear26Bytes


; =============== S U B	R O U T	I N E =======================================
;; ENEMIES PROC

proc		sub_E31	near

        mov	si, offset loc_DF0E
        mov	dx, 28h
        mov	ch, 7

loc_E39:
        test	[byte ptr si], 80h
        jz	short loc_E46
        add	si, dx
        dec	ch
        jnz	short loc_E39
        stc
        retn
; ---------------------------------------------------------------------------

loc_E46:
        push	di
        push	bx
        mov	ah, 64h
        call	addObject
        pop	bx
        pop	di
        or	ah, ah
        retn
endp		sub_E31


; =============== S U B	R O U T	I N E =======================================


proc		sub_E52	near
        test	[byte ptr si+24h], 80h
        jz	short loc_E59
        retn
; ---------------------------------------------------------------------------

loc_E59:
        mov	[byte ptr si+14h], 0C0h
        retn
endp		sub_E52


; =============== S U B	R O U T	I N E =======================================


proc		sub_E5E	near
        test	[byte ptr OBJ_STATUS], 40h
        jz	short loc_E65
        retn
; ---------------------------------------------------------------------------

loc_E65:
        mov	[byte ptr si+14h], 40h
        retn
endp		sub_E5E


; =============== S U B	R O U T	I N E =======================================


proc		sub_E6A	near
        mov	[byte ptr si+13h], 40h
        push	cx
        call	sub_1E64
        pop	cx
        jmp	setFrameNum
endp		sub_E6A


; =============== S U B	R O U T	I N E =======================================


proc		sub_E76	near
        mov	[byte ptr si+13h], 0C0h
        push	cx
        call	sub_1E64
        pop	cx
        jmp	setFrameNum
endp		sub_E76


; =============== S U B	R O U T	I N E =======================================


proc		sub_E82	near
        mov	ah, [byte_DDC5]
        cmp	ah, 0FFh
        jz	short loc_EAA
        push	di
        push	cx
        mov	di, offset loc_DDFA
        mov	ch, 4
        mov	si, offset WORK_BUF
        push	si

loc_E96:
        mov	ah, [si+0Bh]
        mov	[di], ah
        inc	di
        inc	si
        dec	ch
        jnz	short loc_E96
        pop	si
        mov	ah, [DIRECTION]
        mov	[di], ah
        pop	cx
        pop	di
        retn
; ---------------------------------------------------------------------------

loc_EAA:
        mov	bx, offset loc_DDFF
        mov	dx, offset loc_DDFA
        mov	cx, 5
        xchg	si, bx
        xchg	di, dx
        cld
        rep movsb
        xchg	si, bx
        xchg	di, dx
        mov	ah, [bx]
        mov	[locationNum], ah
        xor	ah, ah
        mov	[byte_DDC5], ah
        jmp	short getRespawnCoord
endp		sub_E82

; =============== S U B	R O U T	I N E =======================================
proc		sub_ECC	near
        mov	bx, offset loc_DDFA
        mov	dx, offset loc_DDFF
        mov	cx, 5
        xchg	si, bx
        xchg	di, dx
        cld
        rep movsb
        xchg	si, bx
        xchg	di, dx
        mov	ah, [locationNum]
        xchg	dx, bx
        mov	[bx], ah
        xchg	dx, bx
        retn
endp		sub_ECC
; =============== S U B	R O U T	I N E =======================================


proc		getRespawnCoord	near

        mov	si, offset WORK_BUF
        mov	bx, offset loc_DDFA
        mov	ch, 4

loc_EF3:
        mov	ah, [bx]
        mov	[si+0Bh], ah
        inc	bx
        inc	si
        dec	ch
        jnz	short loc_EF3
        mov	si, offset WORK_BUF
        mov	ah, [bx]
        mov	[DIRECTION], ah
        or	[byte ptr si], 40h
        jmp	copy8bytesUp
endp		getRespawnCoord


; =============== S U B	R O U T	I N E =======================================

proc		sub_F0C	near

        mov	ah, [byte_DE54]
        sub	ah, [Y_COORD]
        jb	short loc_F16
        retn
; -----------
loc_F16:
        neg	ah
        retn
endp		sub_F0C


; =============== S U B	R O U T	I N E =======================================

proc		sub_F19	near

        mov	ah, [byte_DE52]
        sub	ah, [X_COORD]
        jb	short loc_F23
        retn
; ---------------------------------------------------------------------------
loc_F23:
        neg	ah
        retn
endp		sub_F19

; ---------------------------------------------------------------------------
; START	OF FUNCTION CHUNK FOR sub_1F12

loc_F26:

proc		sub_F26	near
        or	ah, ah
        mov	di, offset WORK_BUF
        test	[byte ptr di], 80h
        jnz	short loc_F31
        retn
; ---------------------------------------------------------------------------

loc_F31:
        mov	ah, [di+24h]
        and	ah, 3
        jz	short loc_F3A
        retn
; ---------------------------------------------------------------------------

loc_F3A:
        jmp	short loc_F43
endp		sub_F26

; =============== S U B	R O U T	I N E =======================================

proc		sub_F3C	near

        mov	ch, 16h
        mov	cl, 10h
        jmp loc_FAB
        nop
; ---------------------------------------------------------------------------

loc_F43:
        mov	ah, [di+10h]
        cmp	ah, 4
        jz	short loc_F50
        cmp	ah, 15h
        jnz	short sub_F3C

loc_F50:
        inc	[byte ptr di+0Eh]
        inc	[byte ptr di+0Eh]
        call	sub_F3C
        dec	[byte ptr di+0Eh]
        dec	[byte ptr di+0Eh]
        retn
; ---------------------------------------------------------------------------

loc_F60:
        mov	di, offset loc_DE6E
        or	ah, ah
        test	[byte ptr di], 80h
        jnz	short loc_F6B
        retn
; ---------------------------------------------------------------------------

loc_F6B:
        mov	ch, 8
        mov	cl, 8
        jmp	short loc_FAB
; ---------------------------------------------------------------------------

loc_F71:
        mov	di, offset loc_DEBE
        or	ah, ah
        test	[byte ptr di], 80h
        jnz	short loc_F7C
        retn
; ---------------------------------------------------------------------------

loc_F7C:
        mov	ah, [di+0Fh]
        cmp	ah, 6
        jz	short loc_F94
        mov	ch, 7
        mov	cl, 6
        jmp	short loc_FAB
; ---------------------------------------------------------------------------
        jb	short loc_F8D
        retn
; ---------------------------------------------------------------------------

loc_F8D:
        mov	[byte ptr di+0Fh], 6
        or	ah, ah
        retn
; ---------------------------------------------------------------------------

loc_F94:
        mov	ch, 14h
        mov	cl, 14h
        jmp	short loc_FAB
; ---------------------------------------------------------------------------

loc_F9A:
        mov	di, offset loc_DE96
        or	ah, ah
        test	[byte ptr di], 80h
        jnz	short loc_FA5
        retn
; ---------------------------------------------------------------------------

loc_FA5:
        mov	ch, 3
        mov	cl, 8
        jmp	short $+2

loc_FAB:
        push	dx
        push	bx
        mov	bx, [si+0Bh]
        rcl	bx, 1
        mov	ah, bh
        rcl	bx, 1
        add	ah, bh
        pop	bx
        mov	bh, ah
        add	ah, bl
        mov	bl, ah
        mov	dx, [di+0Bh]
        rcl	dx, 1
        mov	ah, dh
        rcl	dx, 1
        add	ah, dh
        mov	dh, ah
        add	ah, cl
        mov	dl, ah
        call	sub_3942
        pop	dx
        jb	short loc_FD7
        retn
; -----------------------
loc_FD7:
        mov	bh, [si+0Eh]
        mov	bl, [si+0Dh]
        add	bx, bx
        add	bx, bx
        add	bx, bx
        mov	ah, bh
        add	ah, dl
        mov	bl, ah
        push	bx
        mov	bh, [di+0Eh]
        mov	bl, [di+0Dh]
        add	bx, bx
        add	bx, bx
        add	bx, bx
        mov	dh, bh
        mov	ah, bh
        add	ah, ch
        mov	dl, ah
        pop	bx
        jmp	sub_3942

endp		sub_F3C

; =============== S U B	R O U T	I N E =======================================


proc		sub_1002 near		; CODE XREF: birdProc+Fp
        call	getRandom
        and	ah, 1Fh
        or	ah, 1
        mov	dh, 8
        test	ah, 10h
        jnz	short loc_1014
        mov	dh, 4

loc_1014:
        mov	[si+2],	dh
        mov	[si+20h], ah
        retn
endp		sub_1002


; =============== S U B	R O U T	I N E =======================================


proc		birdProc near

        mov	bx, offset byte_DDB3
        test	[byte ptr bx], 80h
        jnz	short loc_102D
        mov	ah, [si+20h]
        or	ah, ah
        jnz	short loc_102D
        call	sub_1002

loc_102D:
        test	[byte ptr si+2], 1
        jz	short loc_1036
        call	sub_E52

loc_1036:
        test	[byte ptr si+2], 2
        jz	short loc_103F
        call	sub_E5E

loc_103F:
        test	[byte ptr si+2], 8
        jz	short loc_1048
        call	sub_E6A

loc_1048:
        test	[byte ptr si+2], 4
        jz	short loc_1051
        call	sub_E76

loc_1051:
        jnb	short loc_1056
        dec	[byte ptr si+20h]

loc_1056:
        call	checkGround
        test	[byte ptr OBJ_STATUS], GROUND_BIT
        jnz	short loc_1060
        retn
; ---------------------------------------------------------------------------

loc_1060:
        test	[byte ptr si+2], 1
        jz	short loc_1067
        retn
; ---------------------------------------------------------------------------

loc_1067:
        and	[byte ptr si+2], 0FDh
        or	[byte ptr si+2], 1
        jmp	copy8bytesDown
endp		birdProc


; =============== S U B	R O U T	I N E =======================================
; input:
; AH = obj num
;
; output:
; DI = obj buf ptr

proc		sub_1072 near

        push	cx
        push	dx
        mov	ch, 0Ch
        mov	dx, 28h
        mov	di, offset WORK_BUF

loc_107C:
        test	[byte ptr di], 80h
        jz	short loc_1086
        cmp	ah, [di+0Fh]
        jz	short loc_1090

loc_1086:
        add	di, dx
        dec	ch
        jnz	short loc_107C
        stc
        pop	dx
        pop	cx
        retn
; ---------------------------------------------------------------------------

loc_1090:
        pop	dx
        pop	cx
        or	ah, ah
        retn
endp		sub_1072


; =============== S U B	R O U T	I N E =======================================


proc		sub_1095 near
        push	cx
        push	dx
        mov	ch, 0Ch
        mov	dx, 28h
        mov	di, offset WORK_BUF

loc_109F:
        test	[byte ptr di], 80h
        jz	short loc_10A9
        cmp	ah, [di+12h]
        jz	short loc_10B3

loc_10A9:
        add	di, dx
        dec	ch
        jnz	short loc_109F
        stc
        pop	dx
        pop	cx
        retn
; ---------------------------------------------------------------------------

loc_10B3:
        pop	dx
        pop	cx
        or	ah, ah
        retn
endp		sub_1095


; =============== S U B	R O U T	I N E =======================================


proc		stanleyDied near

        push	si
        mov	si, offset WORK_BUF
        or	[byte ptr si+24h], 2
        mov	[byte ptr OBJ_STATUS], 0
        call	setWeaponStat
        mov	bx, offset byte_DDB3
        or	[byte ptr bx], 8
        pop	si
        retn
endp		stanleyDied


; =============== S U B	R O U T	I N E =======================================


proc		setswampPar near		;
        push	si
        mov	si, offset WORK_BUF
        or	[byte ptr si+24h], 1
        mov	[byte ptr OBJ_STATUS], 0
        call	setWeaponStat
        pop	si
        retn
endp		setswampPar


; =============== S U B	R O U T	I N E =======================================


proc		sub_10E0 near
        push	si
        mov	si, offset WORK_BUF
        mov	[byte ptr si+2], 0Fh
        mov	[byte ptr OBJ_STATUS], 0
        call	setWeaponStat
        pop	si
        mov	bx, offset byte_DDB3
        or	[byte ptr bx], 10h
        mov	ah, [byte ptr pFOOD+1]
        or	ah, ah
        jz	short loc_1104
        dec	ah
        mov	[byte ptr pFOOD+1], ah

loc_1104:
        mov	ah, [byte ptr pFOOD]
        cmp	ah, 2
        jnb	short loc_110E
        retn
; ---------------------------------------------------------------------------

loc_110E:
        sub	ah, 2
        mov	[byte ptr pFOOD], ah
        retn
endp		sub_10E0


; =============== S U B	R O U T	I N E =======================================

proc		execObjectsProc near

        mov	bx, offset objectsCount
        mov	ah, [bx] ; get count
        mov	[tmpObjCnt], ah ; save count
        inc	bx ; set addr to workbuf
        mov	[tmpObjAddr], bx ; save addr

loc_1124:
        mov	si, [tmpObjAddr]
        mov	dx, [si]
        mov	si, 0
        add	si, dx
        test	[byte ptr si], 80h
        jz	short loc_1149

        mov	ah, [OBJ_NUM]
        shl	ah, 1 ; obj_num * 2
        push	di
        mov	di, offset objProcPtrs
        mov	dl, ah
        mov	dh, 0
        add	di, dx
        mov	bx, [di] ; get specific object routine adress
        pop	di
        call	jmpObjProc

loc_1149:
        mov	bx, [tmpObjAddr]
        inc	bx
        inc	bx
        mov	[tmpObjAddr], bx

        mov	ah, [tmpObjCnt]
        dec	ah
        mov	[tmpObjCnt], ah
        jnz	short loc_1124

        retn
endp		execObjectsProc
; ---------------------------
; 1160
proc		jmpObjProc near
        jmp	bx
endp		jmpObjProc

; =============== S U B	R O U T	I N E =======================================

bumerangProc:
        call	sub_1D61
        mov	ah, [X_COORD]
        cmp	ah, 28h
        jnb	short loc_1178

        call	checkGround
        mov	ah, [si+24h]
        and	ah, 0F0h
        jz	short loc_1184

loc_1178:
        or	[byte ptr si], 10h
        mov	bx, offset paintedWeapon
        and	[byte ptr bx], 7Fh
        jmp	copy8bytesDown
; ---------------------------------------------------------------------------

loc_1184:
        mov	ah, [byte_DDB7]
        cmp	ah, 1
        jz	short loc_119B

        cmp	ah, 84h
        jz	short loc_119B

        mov	bl, 6
        mov	dl, 8
        call	sub_F26
        jb	short loc_1178

loc_119B:
        mov	cx, 300h
        mov	dl, 0
        call	setFrameNum
        mov	bx, offset paintedWeapon
        test	[byte ptr bx], 80h
        jnz	short loc_1178
        retn
; ---------------------------------------------------------------------------
; 11AC

rifleProc:

        call	sub_1E0F
        call	sub_1E41
        call	checkGround

        mov	ah, [X_COORD]
        cmp	ah, 26h
        jb	short loc_11C1

loc_11BD:
        or	[byte ptr si], 10h
        retn
; ---------------------------------------------------------------------------

loc_11C1:
        mov	ah, [OBJ_STATUS]
        or	ah, [si+24h]
        test	ah, 40h
        jnz	short loc_11BD
        retn

; ===========================================================================

bombProc:

        test	[byte ptr si+14h], 80h
        jnz	short loc_11D7

        mov	ah, 7Fh
        jmp	short loc_11DD
; ---------------------------------------------------------------------------

loc_11D7:
        mov	ah, [si+14h]
        add	ah, 3

loc_11DD:
        mov	[si+14h], ah
        call	sub_1E29
        call	checkGround
        mov	ah, [si+24h]
        and	ah, 0F0h
        jnz	short loc_11FF

        test	[byte ptr OBJ_STATUS], GROUND_BIT
        jnz	short loc_11F5
        retn
; ---------------------------------------------------------------------------
loc_11F5:
        mov	[byte ptr OBJ_NUM], 6 ;6 - explosion
        mov	bx, offset bombSound
        jmp	playSound
; ---------------------------------------------------------------------------

loc_11FF:
        or	[byte ptr si], 10h
        jmp	copy8bytesDown
; ---------------------------------------------------------------------------

explosionProc:
        mov	bl, 10h
        mov	dl, 16h
        call	sub_F26
        jnb	short loc_1212
        pop	bx
        jmp	stanleyDied
; ---------------------------------------------------------------------------

loc_1212:
        mov	cx, 300h
        mov	dl, 3
        call	checkFrames
        jb	short loc_121D
        retn
; ---------------------------------------------------------------------------

loc_121D:
        or	ah, ah
        jnz	short loc_1222
        retn
; ---------------------------------------------------------------------------

loc_1222:
        or	[byte ptr si], 10h
        retn
; ---------------------------------------------------------------------------
; ---------------------------------------------------------------------------
; START	OF FUNCTION CHUNK FOR stanleyProc

weaponUsed:
        mov	si, offset weaponBuf
        mov	[word_DDD8], si
        test	[byte ptr si], 40h
        jz	short loc_1235
        call	sub_131E

loc_1235:
        test	[byte ptr OBJ_STATUS], 8
        jnz	short loc_1262
        mov	ah, [CONTROL_STAT]
        test	ah, 10h
        jz	short loc_125C
        call	checkStrenght__

        mov	si, offset WORK_BUF
        mov	bx, offset rightThrowTiles
        test	[byte ptr DIRECTION], 80h
        jz	short loc_1256
        mov	bx, offset leftThrowTiles

loc_1256:
        mov	ah, [bx]
        mov	[FRAME_NUM], ah
        retn
; ---------------------------------------------------------------------------

loc_125C:
        or	[byte ptr OBJ_STATUS], 8
        jmp	short $+2

loc_1262:
        mov	cx, 600h
        test	[byte ptr DIRECTION], 80h
        jz	short loc_126E
        mov	cx, 0D07h

loc_126E:
        mov	dl, 1
        call	setFrameNum
        jb	short loc_1276
        retn
; ---------------------------------------------------------------------------

loc_1276:
        or	ah, ah
        jz	short loc_127D
        jmp	short loc_12F8
        nop
; ---------------------------------------------------------------------------

loc_127D:
        mov	ah, [FRAME_NUM]
        cmp	ah, 1
        jz	short loc_128A
        cmp	ah, 8
        jnz	short loc_129E

loc_128A:
        mov	si, offset WORK_BUF
        mov	bx, offset loc_80C9
        cmp	ah, 1
        jz	short loc_1298
        mov	bx, offset leftFallTiles

loc_1298:
        mov	cl, [bx]
        mov	[FRAME_NUM], cl
        retn
; ---------------------------------------------------------------------------

loc_129E:
        call	checkGround
        call	getObjCoord
        mov	di, [word_DDE8]
        jnz	short loc_12B8
        mov	ah, [si+24h]
        and	ah, 0B0h
        jnz	short loc_12B8
        mov	ah, [di]
        add	ah, dh
        mov	dh, ah

loc_12B8:
        dec	bh
        call	sub_1DD4
        mov	si, offset WORK_BUF
        test	[byte ptr DIRECTION], 80h
        jnz	short loc_12D6
        mov	ah, [si+24h]
        or	ah, [OBJ_STATUS]
        and	ah, 0A0h
        jz	short loc_12D4
        jmp	loc_136E
; ---------------------------------------------------------------------------

loc_12D4:
        jmp	short loc_12E4
; ---------------------------------------------------------------------------

loc_12D6:
        mov	ah, [si+24h]
        or	ah, [OBJ_STATUS]
        and	ah, 90h
        jz	short loc_12E4
        jmp	loc_136E
; ---------------------------------------------------------------------------

loc_12E4:
        call	getObjCoord
        mov	ah, [di]
        add	ah, dh
        mov	dh, ah
        dec	bh
        call	sub_1DD4
        inc	di
        mov	[word_DDE8], di
        retn
; ---------------------------------------------------------------------------

loc_12F8:
        mov	si, offset WORK_BUF
        mov	ah, [byte ptr pSTRENGHT]
        shl	ah, 1
        mov	[si+14h], ah
        neg	[byte ptr si+14h]
        sub	ah, 0Ch
        or	ah, 1
        test	[byte ptr DIRECTION], 80h
        jz	short loc_1315
        neg	ah

loc_1315:
        mov	[DIRECTION], ah
        or	[byte ptr OBJ_STATUS], 1
        jmp	short loc_136E

; END OF FUNCTION CHUNK	FOR stanleyProc

; =============== S U B	R O U T	I N E =======================================

proc		sub_131E near
        mov	ch, 6
        mov	ah, [FRAME_NUM]
        or	ah, ah
        jz	short loc_1329
        mov	ch, 0

loc_1329:
        call	getObjCoord
        mov	ah, ch
        add	ah, dh
        cmp	ah, 27h
        jnb	short loc_136E
        mov	cl, ah
        mov	ch, bh
        mov	[word_DDD4], bx
        mov	[word_DDD6], cx
        mov	cl, dh
        call	getAddrByCoord
        mov	ch, 6

loc_1348:
        mov	ah, [bx]
        cmp	ah, 0B9h
        jnb	short loc_136E
        inc	bx
        dec	ch
        jnz	short loc_1348
        mov	bx, [word_DDD4]
        mov	cx, [word_DDD6]
        mov	dx, 140h
        add	bx, dx
        mov	ch, bh
        call	getAddrByCoord
        mov	ah, [bx]
        cmp	ah, 0A2h
        jb	short loc_136E
        retn
; ---------------------------------------------------------------------------
loc_136E:
        mov	si, offset WORK_BUF
        and	[byte ptr OBJ_STATUS], 0FDh
        mov	si, [word_DDD8]
        or	[byte ptr si], 10h
        xor	ah, ah
        mov	[byte ptr pSTRENGHT], ah
        retn
endp		sub_131E

; ---------------------------------------------------------------------------

score100Proc:

        mov	cx, [word_DDF0]
        mov	dl, 0Ah ; delay
        call	checkFrames
        jb	short loc_138F
        retn
; ---------------------------------------------------------------------------

loc_138F:
        mov	dl, ah
        shl	dl, 1
        mov	dh, 0
        mov	bx, offset scoreHelperData
        add	bx, dx
        mov	dx, [bx]
        mov	bx, [SCORE_COUNT]
        add	bx, dx
        mov	[SCORE_COUNT], bx
        or	[byte ptr si], 10h
        jmp	scoreProc
; ---------------------------------------------------------------------------
; ---------------------------------------------------------------------------

score250Proc:

        mov	dl, 3
        mov	cx, 300h
        test	[byte ptr si+2], 8
        jnz	short loc_13BA
        mov	cx, 704h

loc_13BA:
        call	birdProc
        mov	ah, [si+24h]
        and	ah, 0F0h
        jz	short loc_13D7
        mov	bx, offset byte_DDB3
        test	[byte ptr bx], 80h
        jz	short loc_13D0
        jmp	loc_146C
; ---------------------------------------------------------------------------

loc_13D0:
        or	[byte ptr si], 10h
        and	[byte ptr bx], 0FEh
        retn
; ---------------------------------------------------------------------------

loc_13D7:
        mov	bx, offset byte_DDB3
        test	[byte ptr bx], 80h
        jnz	short loc_1436
        call	getRandom
        and	ah, 1Fh
        or	ah, 1
        cmp	ah, 0Fh
        jnz	short loc_1407
        call	sub_F19
        mov	[si+20h], ah
        mov	dl, 8
        jnb	short loc_13F9
        mov	dl, 4

loc_13F9:
        call	sub_F0C
        mov	ah, 2
        jnb	short loc_1402
        mov	ah, 1

loc_1402:
        or	ah, dl
        mov	[si+2],	ah

loc_1407:
        mov	bl, 10h
        mov	dl, 10h
        call	sub_1F40
        jb	short loc_1466
        mov	bl, 10h
        mov	dl, 10h
        call	sub_F26
        jb	short loc_141A
        retn
; ---------------------------------------------------------------------------

loc_141A:
        mov	bx, offset byte_DDB3
        test	[byte ptr bx], 20h
        jz	short loc_1423
        retn
; ---------------------------------------------------------------------------

loc_1423:
        or	[byte ptr bx], 80h
        call	getStanleyCoord
        dec	bh
        dec	bh
        call	sub_1DD4
        mov	ah, 9
        mov	[si+2],	ah

loc_return:

        retn
; ---------------------------------------------------------------------------

loc_1436:
        and	[byte ptr bx], 0DFh
        call	getObjCoord
        inc	bh
        inc	bh
        push	si
        mov	si, offset WORK_BUF
        call	sub_1DD4
        mov	bx, offset rightJumpTiles
        test	[byte ptr DIRECTION], 80h
        jz	short loc_1453
        mov	bx, offset leftJumpTiles

loc_1453:
        mov	ah, [bx]
        mov	[FRAME_NUM], ah
        pop	si

        mov	ah, [locationNum]
        cmp	ah, 39h ; CHECK FOR EAGLE VALLEY LOCATION
        jnz	short locret_1465
        jmp	loc_1653
; ---------------------------------------------------------------------------

locret_1465:
        retn
; ---------------------------------------------------------------------------

loc_1466:
        mov	ch, 1
        mov	cl, 1
        jmp	short loc_148B
; ---------------------------------------------------------------------------

loc_146C:
        call	updateObjShadowTiles
        call	checkRaft
        mov	si, offset WORK_BUF
        mov	[byte ptr si], 0


        mov	ah, 39h ; SET EAGLE VALLEY LOCATION
        mov	[locationNum], ah
        mov	bx, offset byte_DDB3
        and	[byte ptr bx], 0EFh
        pop	bx
        call	loc_B54
        jmp	sub_E82
; ---------------------------------------------------------------------------
; ---------------------------------------------------------------------------
; START	OF FUNCTION CHUNK FOR sub_1FA6

loc_148B:
        mov	[word_DDF0], cx
        mov	[byte ptr OBJ_NUM], 5
        mov	dl, 0Ah
        call	checkFrames
        mov	bx, offset tilidamSound
        jmp	playSound

; END OF FUNCTION CHUNK	FOR sub_1FA6
; ---------------------------------------------------------------------------

booblesProc:

        mov	cl, 0
        mov	ch, 3
        mov	dl, 4
        call	checkFrames
        call	getStanleyCoord
        inc	dh
        jmp	sub_1DD4

; =============== S U B	R O U T	I N E =======================================

proc		foodWaterProc near
        mov	ah, [demoLockStat]
        or	ah, ah
        jz	short loc_14B8
        retn
; ---------------------------------------------------------------------------

loc_14B8:
        call	sub_1B7A
        jnz	short loc_14BE
        retn
; ---------------------------------------------------------------------------

loc_14BE:
        mov	ah, [byte_DDC1]
        inc	ah
        mov	[byte_DDC1], ah
        cmp	ah, 3
        jz	short loc_14CE
        retn
; ---------------------------------------------------------------------------

loc_14CE:
        xor	ah, ah
        mov	[byte_DDC1], ah
        mov	ah, [byte ptr pFOOD]
        or	ah, ah
        jz	short loc_14E2
        dec	ah
        mov	[byte ptr pFOOD], ah

loc_14E2:
        mov	ah, [byte ptr pFOOD+1]
        or	ah, ah
        jz	short loc_14F0
        dec	ah
        mov	[byte ptr pFOOD+1], ah

loc_14F0:
        call	paintFood__
        mov	ah, [byte ptr pFOOD]
        or	ah, ah ; food over ?
        jnz	short loc_14FE
        jmp	stanleyDied
; ---------------------------------------------------------------------------

loc_14FE:
        call	paintWater__
        mov	ah, [byte ptr pFOOD+1]
        or	ah, ah ; water over ?
        jnz	short locret_150C
        jmp	stanleyDied
; ---------------------------------------------------------------------------

locret_150C:
        retn
endp		foodWaterProc

; ===========================================================================

raftProc:
        mov	cx, [RAFT_COORD]
        mov	ah, cl
        cmp	ah, MAX_X_SPR
        jb	short loc_1527
        add	ah, 0Ah
        cmp	ah, MAX_X_SPR
        jb	short loc_1527
        xor	ah, ah
        mov	[raftStatus], ah
        retn
; -------------
loc_1527:
        mov	ah, [raftTimeCycle]
        inc	ah
        mov	[raftTimeCycle], ah
        cmp	ah, 6
        jz	short loc_1537
        retn
; ----------

loc_1537:
        xor	ah, ah
        mov	[raftTimeCycle], ah
        mov	cx, [RAFT_COORD]
        test	cl, 80h
        jnz	short loc_1573
        inc	ch
        call	getAddrByCoord
        mov	ah, [bx]
        or	ah, ah
        jnz	short loc_156A
        mov	ah, 3
        mov	[raftStatus], ah
        call	raftRepaint
        mov	cx, [RAFT_COORD]
        inc	ch
        mov	[RAFT_COORD], cx
        call	raftProc2
        jmp	loc_161A
; ------------------

loc_156A:
        mov	ah, [raftStatus]
        cmp	ah, 2
        jz	short loc_15A4

loc_1573:
        mov	cx, [RAFT_COORD]
        mov	ah, 0Ah
        add	ah, cl
        cmp	ah, 28h
        jnb	short loc_158B
        mov	cl, ah
        call	getAddrByCoord
        mov	ah, [bx]
        or	ah, ah
        jnz	short loc_15A4

loc_158B:
        mov	ah, 1
        mov	[raftStatus], ah
        call	raftRepaint
        mov	cx, [RAFT_COORD]
        inc	cl
        mov	[RAFT_COORD], cx
        call	raftProc2
        jmp	 short loc_161A
        nop
; -----------

loc_15A4:
        mov	cx, [RAFT_COORD]
        dec	cl
        call	getAddrByCoord
        mov	ah, [bx]
        or	ah, ah
        jnz	short loc_15CB
        mov	ah, 2
        mov	[raftStatus], ah
        call	raftRepaint
        mov	cx, [RAFT_COORD]
        dec	cl
        mov	[RAFT_COORD], cx
        call	raftProc2
        jmp	short loc_161A
; ------------------------

loc_15CB:
        mov	ah, 3
        mov	[raftStatus], ah
        retn

; =============== S U B	R O U T	I N E =======================================


proc		raftRepaint near

        mov	cx, [RAFT_COORD]
        mov	ah, 0Ah

loc_15D8:
        push	ax
        push	cx
        mov	ah, cl
        cmp	ah, 28h
        jnb	short loc_15EB
        xor	ah, ah
        call	setSpriteAtAddr
        xor	ah, ah
        call	writeSprite2Buf2__

loc_15EB:
        pop	cx
        inc	cl
        pop	ax
        dec	ah
        jnz	short loc_15D8
        retn
endp		raftRepaint


; =============== S U B	R O U T	I N E =======================================


proc		raftProc2 near

        mov	di, offset RAFT_SPR
        mov	cx, [RAFT_COORD]

loc_15FB:
        mov	ah, [di]
        or	ah, ah
        jnz	short loc_1602
        retn
; ---------------------------------------------------------------------------
loc_1602:
        push	cx
        mov	ah, cl
        cmp	ah, 28h
        jnb	short loc_1614
        mov	ah, [di]
        call	setSpriteAtAddr
        mov	ah, [di]
        call	writeSprite2Buf2__

loc_1614:
        inc	di
        pop	cx
        inc	cl
        jmp	short loc_15FB
endp		raftProc2
; ---------------------------------------------------------------------------
loc_161A:
        mov	ah, [footIndex]
        cmp	ah, 0D9h
        jz	short loc_1624
        retn
; ---------------------------------------------------------------------------

loc_1624:
        mov	si, offset WORK_BUF
        mov	di, offset weaponBuf
        mov	ah, [raftStatus]
        cmp	ah, 1
        jnz	short loc_163A
        inc	[byte ptr X_COORD]
        inc	[byte ptr WX_COORD]
        retn
; ---------------------------------------------------------------------------

loc_163A:
        cmp	ah, 2
        jnz	short loc_1646
        dec	[byte ptr X_COORD]
        dec	[byte ptr WX_COORD]
        retn
; ---------------------------------------------------------------------------

loc_1646:
        cmp	ah, 3
        jz	short loc_164C
        retn
; ---------------------------------------------------------------------------

loc_164C:
        inc	[byte ptr Y_COORD] ; set Stanley coord to raft coord
        inc	[byte ptr WY_COORD]
        retn
; ---------------------------------------------------------------------------
loc_1653:
        mov	[byte ptr si+2], 8
        mov	ah, [X_COORD]
        cmp	ah, 1Ch
        jnb	short loc_1660
        retn
; ---------------------------------------------------------------------------
loc_1660:
        or	[byte ptr si], 10h
        mov	bx, offset byte_DDB3
        and	[byte ptr bx], 7Fh
        and	[byte ptr bx], 0FEh
        retn
; ---------------------------------------------------------------------------
loc_166D:

        test	[byte ptr OBJ_STATUS], 80h
        jnz	short loc_16C1

        mov	bl, 0Fh
        mov	dl, 16h
        call	sub_F26
        jnb	short loc_168F

        mov	bx, offset byte_DDB3
        or	[byte ptr bx], 20h
        mov	[byte ptr FRAME_PAUSE], 4Bh
        mov	[byte ptr OBJ_STATUS], 0FFh
        push	si
        call	setWeaponStat
        pop	si

loc_168F:
        test	[byte ptr si+24h], 1
        jnz	short loc_16B0
        mov	cx, 100h
        call	sub_F19
        jnb	short loc_16A0
        mov	cx, 403h

loc_16A0:
        or	ah, ah
        jnz	short loc_16AA
        or	[byte ptr si+24h], 1
        jmp	short loc_16B0
; ---------------------------
loc_16AA:
        mov	dl, 7 ; delay
        call	checkFrames
        retn
; ---------------------------
loc_16B0:
        mov	ch, 2
        mov	cl, 2
        mov	dl, 28h
        call	checkFrames
        jb	short loc_16BC
        retn
; --------------------------
loc_16BC:
        and	[byte ptr si+24h], 0FEh
        retn
; --------------------------

loc_16C1:
        call	getObjCoord
        mov	ah, 2
        mov	cx, 100h
        cmp	ah, [FRAME_NUM]
        jnb	short loc_16D3
        mov	ah, 0FEh
        mov	cx, 403h

loc_16D3:
        push	si
        add	dh, ah
        mov	si, offset WORK_BUF
        neg	ah
        mov	[DIRECTION], ah
        call	sub_1DD4
        pop	si
        dec	[byte ptr si+2]
        jz	short loc_16E9
        jmp	short loc_16AA
; ---------------------------------------------------------------------------

loc_16E9:				; CODE XREF: _03C8:16E5j
        mov	[byte ptr OBJ_STATUS], 0
        pop	bx
        jmp	respawnStanley
; ===========================================================================
; 16F1

switchProc:
        test	[byte ptr si+24h], 80h ; check current switch status
        jz	short loc_16F8
        retn
; ---------------------------------------------------------------------------

loc_16F8:
        mov	bl, 0Ah
        mov	dl, 0Fh
        call	loc_F60
        jb	short switchOpen
        retn
; ---------------------------------------------------------------------------

switchOpen:
        or	[byte ptr si+24h], 80h ; set status
        inc	[byte ptr FRAME_NUM]

        mov	bx, offset positiveSound
        call	playSound

        mov	bl, [si+22h]
        mov	bh, [si+23h]

        jmp	bx
; ---------------------------------------------------------------------------
; 1717h

trolleyProc:

        inc	[byte ptr si+0Eh]
        mov	bl, 12h
        mov	dl, 10h
        call	sub_F26
        dec	[byte ptr si+0Eh]
        jnb	short loc_172A
        pop	bx

        jmp	stanleyDied
; ---------------------------------------------------------------------------

loc_172A:
        mov	cl, 0
        mov	ch, 1
        mov	dl, 0
        call	checkFrames
        jb	short loc_1736
        retn
; ---------------------------------------------------------------------------

loc_1736:
        call	sub_1E41
        call	checkGround
        mov	ah, [si+24h]
        and	ah, 0F0h
        jnz	short loc_1745
        retn
; ---------------------------------------------------------------------------

loc_1745:
        or	[byte ptr si], 10h
        jmp	copy8bytesDown
; ---------------------------------------------------------------------------

loc_174B:

        call	sub_2295
        jnz	short loc_1751
        retn
; ---------------------------------------------------------------------------

loc_1751:
        or	[byte ptr si], 10h
        jmp	copy8bytesDown
; ---------------------------------------------------------------------------

downArchProc:

        mov	bl, 6
        mov	dl, 10h
        call	sub_F26
        jnb	short loc_1774
        pop	bx
        call	stanleyDied

loc_1764:
        or	[byte ptr si], 10h
        mov	ah, [byte_DDAF]
        dec	ah
        mov	[byte_DDAF], ah
        jmp	copy8bytesDown
; ---------------------------------------------------------------------------

loc_1774:
        inc	[byte ptr Y_COORD]
        call	checkGround
        mov	ah, [OBJ_STATUS]
        test	ah, GROUND_BIT
        jnz	short loc_1764
        retn
; ---------------------------------------------------------------------------

loc_1783:

        mov	cl, 0
        mov	ch, 1
        mov	dl, 8
        jmp	setFrameNum
; ---------------------------------------------------------------------------

loc_178C:

        mov	bl, 9
        mov	dl, 0Ch
        call	sub_F26
        jnb	short loc_1799
        pop	bx
        jmp	stanleyDied
; ---------------------------------------------------------------------------

loc_1799:
        test	[byte ptr si+2], 80h
        jnz	short loc_17BC
        mov	dl, 0FFh
        test	[byte ptr DIRECTION], 80h
        jnz	short loc_17A9
        mov	dl, 1

loc_17A9:
        mov	ah, [X_COORD]
        add	ah, dl
        mov	[X_COORD], ah
        cmp	ah, 13h
        jnz	short loc_17BF
        or	[byte ptr si+2], 80h
        jmp	short loc_17BF
; ---------------------------------------------------------------------------

loc_17BC:
        inc	[byte ptr si+0Eh]

loc_17BF:
        mov	cx, 100h
        mov	dl, 0
        call	setFrameNum
        call	checkGround
        mov	ah, [si+24h]
        and	ah, 0F0h
        jnz	short loc_17D3
        retn
; ---------------------------------------------------------------------------

loc_17D3:
        mov	bx, offset byte_DDB4
        dec	[byte ptr bx]
        or	[byte ptr si], 10h
        retn
; ---------------------------------------------------------------------------

loc_17DC:
        test	[byte ptr si+2], 80h
        jnz	short loc_17FA
        mov	dl, 2
        mov	cl, 0
        mov	ch, 3
        call	checkFrames
        jb	short loc_17EE
        retn
; ---------------------------------------------------------------------------

loc_17EE:
        or	ah, ah
        jnz	short loc_17F3
        retn
; ---------------------------------------------------------------------------

loc_17F3:
        mov	[FRAME_NUM], ah
        or	[byte ptr si+2], 80h

loc_17FA:
        mov	bl, 3
        mov	dl, 3
        call	sub_F26
        jnb	short loc_1807
        pop	bx
        jmp	stanleyDied
; ---------------------------------------------------------------------------

loc_1807:
        call	sub_1E29
        call	checkGround
        mov	ah, [si+24h]
        and	ah, 0B0h
        jnz	short loc_1816
        retn
; ---------------------------------------------------------------------------

loc_1816:
        or	[byte ptr si], 10h
        retn
; ---------------------------------------------------------------------------
loc_181A:
        test	[byte ptr si+24h], 80h
        jz	short loc_1829
        mov	[byte ptr si+0Dh], 0
        mov	[byte ptr si+0Bh], 0
        retn
; ---------------------------------------------------------------------------

loc_1829:
        mov	ah, [si+0Eh]
        or	ah, ah
        mov	cl, 0
        jz	short loc_1834
        mov	cl, 0C0h

loc_1834:
        mov	[si+14h], cl
        mov	ah, [X_COORD]
        cmp	ah, [si+2]
        mov	ch, 0
        jz	short loc_1843
        mov	ch, 60h

loc_1843:
        mov	[si+13h], ch
        mov	ah, cl
        or	ah, ch
        jz	short loc_184F
        jmp	sub_1E29
; ---------------------

loc_184F:
        or	[byte ptr si+24h], 80h
        retn
; ============================================================================
checkPit:
        mov	ah, [footIndex]
        cmp	ah, 0CAh ; check cave ground
        jnb	short loc_185E
        retn
; -------------------------

loc_185E:
        cmp	ah, 0CDh ; check cave ground
        jb	short fellToPit
        retn
; -------------------------

fellToPit:
        call	sub_ECC
        call	getRandom
        mov	dl, 37h ; 		CAVE1
        test	ah, 1
        jz	short goToLoc
        mov	dl, 3Ah	;		CAVE2
; =======================================
goToLoc:
        mov	ah, dl
        mov	[locationNum], ah
        call	nextLocProc
        call	sub_E82
        retn
; =======================================

checkWell1:
        mov	ah, [footIndex]
        cmp	ah, 0F5h
        jnb	short loc_188A
        retn
; ---------------------
loc_188A:
        cmp	ah, 0F8h
        jb	short loc_1890
        retn
; ---------------------
loc_1890:
        mov	dl, 2Ch ; catacomb locations
        jmp	short goToLoc

; =======================================

checkWell2:
        mov	ah, [footIndex]
        cmp	ah, 0F5h
        jnb	short loc_189E
        retn
; ------------
loc_189E:
        cmp	ah, 0F8h
        jb	short loc_18A4
        retn
; ------------
loc_18A4:
        mov	dl, 35h ; trap
        jmp	short goToLoc

; =======================================

checkPaling:
        mov	ah, [footIndex]
        cmp	ah, 0F9h
        jnb	short loc_18B2
        retn
loc_18B2:
        cmp	ah, 0FBh
        jnb	short locret_18BA
        jmp	stanleyDied

locret_18BA:
        retn

;== ROOM 23 ===============================

checkFire:
        mov	ah, [footIndex]
        cmp	ah, 8Bh
        jnb	short loc_18C5
        retn
loc_18C5:
        cmp	ah, 8Eh
        jnb	short locret_18CD
        jmp	stanleyDied

locret_18CD:
        retn

; == ROOM 1D ========================================
loc_18CE:
        mov	di, offset loc_80A4
        jmp	short loc_18E0

; == ROOM 1E ========================================
loc_18D3:
        mov	di, offset loc_80AB
        jmp	short loc_18E0

; == ROOM 1F ========================================
loc_18D8:
        mov	di, offset loc_80B2
        jmp	short loc_18E0

; == ROOM 20 ========================================
loc_18DD:
        mov	di, offset loc_80B9
loc_18E0:
        mov	ah, [byte_DDAF]
        cmp	ah, 3
        jb	short checkSlab
        retn
; ---------------------------------------------------------------------------
checkSlab:
        mov	ah, [footIndex]
        cmp	ah, 0C0h
        jnb	short loc_18F4
        retn
; --------------------------------------------------------------------------
loc_18F4:
        cmp	ah, 0C2h
        jb	short loc_18FA
        retn
; ---------------------------------------------------------------------------
loc_18FA:
        mov	ah, 1
        mov	[byte ptr word_DDD8], ah
        mov	ah, 22h
        mov	[byte ptr word_DDD8+1],	ah
        mov	si, offset WORK_BUF
        mov	ah, [X_COORD]
        sub	ah, 6
        jnb	short loc_1913
        xor	ah, ah

loc_1913:
        inc	di
        test	[byte ptr di], 80h
        jz	short loc_191A
        retn
; ----------------------------------

loc_191A:
        cmp	ah, [di]
        jnb	short loc_1913

loc_191E:
        test	[byte ptr di], 80h
        jz	short loc_1924
        retn
; ----------------------------------

loc_1924:
        mov	ah, [byte_DDAF]
        cmp	ah, 3
        jnz	short loc_192E
        retn
; --------------------------

loc_192E:
        call	sub_E31
        jnb	short loc_1934
        retn
; --------------------------

loc_1934:
        mov	ah, [byte_DDAF]
        inc	ah
        mov	[byte_DDAF], ah
        mov	ah, [byte ptr word_DDD8]
        mov	bh, ah
        mov	ah, [di]
        mov	dh, ah
        mov	ah, [byte ptr word_DDD8+1]
        mov	ch, ah
        xor	ah, ah
        mov	bl, ah
        mov	dl, ah
        mov	cl, ah
        inc	di
        call	sub_DFA
        jmp	short loc_191E

; ===================================
; location trolley subs
;
trolleyRunProc:
        mov	ah, 18h
        call	sub_1072
        jb	short loc_1964
        retn

; ---------------------------------------------------------------------------

loc_1964:
        call	getRandom
        cmp	ah, 0FBh
        jnb	short loc_196D
        retn
; ---------------------------------------------------------------------------

loc_196D:
        mov	si, offset WORK_BUF
        mov	dh, 0
        mov	dl, 60h
        mov	ah, [X_COORD]
        cmp	ah, 14h
        jnb	short loc_1980
        mov	dh, 24h
        mov	dl, 0A0h

loc_1980:
        mov	[word_DDD8], dx
        call	sub_E31
        jnb	short loc_198A
        retn
; ---------------------------------------------------------------------------

loc_198A:
        xor	ah, ah
        mov	[si+25h], ah
        mov	dx, [word_DDD8]
        mov	bh, 10h
        mov	bl, 40h
        mov	ah, dl
        mov	ch, 18h
        mov	cl, bl
        mov	dl, bl
        jmp	sub_DFA

; ======================================

loc_19A2:
        mov	ah, 19h ;  dust smoke
        call	sub_1072
        jb	short loc_19AA
        retn

; ---------------------------------------------------------------------------

loc_19AA:
        call	sub_1EEE
        or	ah, ah
        jnz	short loc_19B2
        retn
; ---------------------------------------------------------------------------

loc_19B2:
        call	getRandom
        or	ah, ah
        jz	short loc_19BA
        retn
; ---------------------------------------------------------------------------

loc_19BA:
        mov	ah, 19h
        mov	[byte ptr word_DDD2], ah
        call	sub_19F0
        mov	di, offset loc_8B2D
        jmp	loc_2127
; ---------------------------------------------------------------------------

loc_19C9:
        mov	ah, 21h
        call	sub_1072
        jb	short loc_19D1
        retn
; ---------------------------------------------------------------------------

loc_19D1:
        call	sub_1EEE
        or	ah, ah
        jz	short loc_19D9
        retn
; ---------------------------------------------------------------------------

loc_19D9:
        call	getRandom
        or	ah, ah
        jz	short loc_19E1
        retn
; ---------------------------------------------------------------------------

loc_19E1:
        mov	ah, 21h
        mov	[byte ptr word_DDD2], ah
        call	sub_19F0
        mov	di, offset loc_8B36
        jmp	loc_2127

; =============== S U B	R O U T	I N E =======================================


proc		sub_19F0 near

        mov	[word_DDD8], cx
        call	sub_E31
        jnb	short loc_19FA
        retn
; ---------------------------------------------------------------------------

loc_19FA:
        mov	bx, [word_DDD8]
        mov	dh, bl
        mov	ah, [byte ptr word_DDD2]
        mov	ch, ah
        xor	ah, ah
        mov	cl, ah
        mov	bl, ah
        mov	dl, ah
        call	sub_DFA
        call	sub_1FB4
        jmp	sub_1FC8
endp		sub_19F0


; =============== S U B	R O U T	I N E =======================================

proc		sub_1A17 near
        call	getRandom
        cmp	ah, 19h
        jb	short sub_1A20
        retn
endp		sub_1A17

; =============== S U B	R O U T	I N E =======================================

proc		sub_1A20 near
        mov	ah, [byte_DDB4]
        cmp	ah, 4
        retn
endp		sub_1A20

; ---------------------------------------------------------------------------

loc_1A28:
        call	sub_1A17
        jb	short loc_1A2E
        retn
; ---------------------------------------------------------------------------

loc_1A2E:
        mov	ch, 1
        mov	cl, 0
        mov	ah, 27h
        mov	[byte ptr word_DDD2], ah
        call	sub_19F0
        mov	[byte ptr si+13h], 7Fh
        mov	bx, offset byte_DDB4
        inc	[byte ptr bx]
        call	sub_1A20
        jb	short loc_1A4A
        retn
; ---------------------------------------------------------------------------

loc_1A4A:
        mov	ch, 1
        mov	cl, 24h
        call	sub_19F0
        mov	[byte ptr si+13h], 81h
        mov	bx, offset byte_DDB4
        inc	[byte ptr bx]
        retn
; ---------------------------------------------------------------------------

loc_1A5B:
        mov	ah, 0Ah
        call	sub_1072
        jnb	short loc_1A63
        retn
; ---------------------------------------------------------------------------

loc_1A63:
        mov	ah, [di+10h]
        cmp	ah, 2
        jz	short locret_1A6E
        jmp	loc_1CA1
; ---------------------------------------------------------------------------

locret_1A6E:
        retn
; ---------------------------------------------------------------------------

loc_1A6F:
        mov	ah, 0Ah
        call	sub_1072
        jnb	short loc_1A77
        retn

; ---------------------------------------------------------------------------

loc_1A77:
        mov	ah, [di+10h]
        cmp	ah, 2
        jz	short locret_1A82
        jmp	loc_1CB8
; ---------------------------------------------------------------------------

locret_1A82:				; CODE XREF: _03C8:1A7Dj
        retn
; ---------------------------------------------------------------------------
;============================================================================
godnessRoomProc:

        mov	bx, offset byte_DDB3
        test	[byte ptr bx], 2
        jnz	short loc_1A9D
        or	[byte ptr bx], 2
        mov	ah, [stonesFound]
        mov	[broughtStones ], ah
        or	ah, ah
        jz	short loc_1AEB
        jmp	playMusic
; ---------------------------------------------------------------------------

loc_1A9D:				; CODE XREF: _03C8:1A89j
        mov	ah, [broughtStones]
        or	ah, ah
        jz	short loc_1AEB
        mov	ah, [byte_DDC2]
        inc	ah
        mov	[byte_DDC2], ah
        cmp	ah, 32h
        jz	short loc_1AB5
        retn
; ---------------------------------------------------------------------------

loc_1AB5:				; CODE XREF: _03C8:1AB2j
        xor	ah, ah
        mov	[byte_DDC2], ah
        mov	ah, [broughtStones]
        dec	ah
        mov	[broughtStones], ah
        call	sub_E31
        call	getStanleyCoord
        inc	bh
        inc	dh
        xor	ah, ah
        mov	cl, ah
        mov	ch, 33h
        call	sub_DFA
        mov	ah, [broughtStones]
        inc	ah
        mov	dl, ah
        add	ah, ah
        add	ah, dl
        add	ah, 0Ah
        mov	[si+2],	ah
        retn
; ------------

loc_1AEB:
        mov	ah, [byte_DDC2]
        inc	ah
        mov	[byte_DDC2], ah
        jz	short loc_1AF8
        retn
; -----------

loc_1AF8:
        call	updateObjShadowTiles
        mov	ch, 5
        mov	di, offset stoneStatePtrs

loc_1B00:
        mov	bl, [di]
        mov	bh, [di+1]
        inc	di
        inc	di
        test	[byte ptr bx], 80h
        jz	short loc_1B22
        dec	ch
        jnz	short loc_1B00
        mov	ah, 1Dh				; FIRST ROOM AFTER GODNESS
        mov	[locationNum], ah
        mov	si, offset WORK_BUF
        mov	di, offset room_1D_defs
        call	sub_DAF
        jmp	loc_B38
; ------------------
loc_1B22:
        mov	ah, ch
        mov	dx, 7
        call	sub_D06
        xchg	dx, bx
        mov	di, offset loc_8CD4
        add	di, dx
        mov	ah, [di]
        mov	[locationNum], ah
        inc	di
        mov	si, offset WORK_BUF
        call	sub_DAF
        jmp	loc_B38
; ---------------------------------------------------------------------------
loc_1B41:
        mov	ah, [CONTROL_MODE]
        cmp	ah, 0FFh
        jz	short loc_1B5F
        or	ah, ah
        jnz	short loc_1B4F
        retn
; ---------------------------------------------------------------------------

loc_1B4F:				; CODE XREF: _03C8:1B4Cj
        xor	ah, ah
        mov	[CONTROL_MODE], ah
        mov	bx, offset FINAL_SCR_CMD
        mov	[demo1CmdAddr], bx
        jmp	playMusic
; ---------------------------------------------------------------------------

loc_1B5F:				; CODE XREF: _03C8:1B48j
        call	sub_1BA1
        call	sub_1B89
        call	sub_1BB9
        call	sub_1B89
        call	sub_1BCE
        call	sub_1B89
        call	sub_1B89
        call	paintScreen__
        jmp	startScreen

;---------------------------------------------------------------------------
; =============== S U B	R O U T	I N E =======================================


proc		sub_1B7A near		; CODE XREF: foodWaterProc:loc_14B8p
                    ; _03C8:loc_1B8Fp
        mov	bx, offset timerVar64
        test	[byte ptr bx], 40h
        jnz	short loc_1B83
        retn
; ---------------------------------------------------------------------------

loc_1B83:				; CODE XREF: sub_1B7A+6j
        pushf
        and	[byte ptr bx], 0BFh
        popf
        retn
endp		sub_1B7A

; ---------------------------------------------------------------------------
proc		sub_1B89 near		;

        mov	ah, 5
        mov	[byte ptr word_DDD8], ah

loc_1B8F:
        call	sub_1B7A
        jz	short loc_1B8F
        mov	ah, [byte ptr word_DDD8]
        dec	ah
        mov	[byte ptr word_DDD8], ah
        jnz	short loc_1B8F
        retn
endp		sub_1B89
; ---------------------------------------------------------------------------
proc		sub_1BA1 near

        call	sub_E31
        call	getStanleyCoord
        dec	bh
        dec	bh
        dec	bh
        dec	dh
        mov	ch, 36h
        mov	cl, 0
        call	sub_DFA
        jmp	sub_3641

endp		sub_1BA1
; ---------------------------------------------------------------------------
proc		sub_1BB9 near

        call	sub_E31
        mov	bh, 8
        mov	bl, 0
        mov	dh, 20h
        mov	dl, 0
        mov	ch, 37h
        mov	cl, 0
        call	sub_DFA
        jmp	sub_3641

endp		sub_1BB9
; ---------------------------------------------------------------------------
proc		sub_1BCE near
        mov	ah, 36h
        call	sub_1072
        mov	[byte ptr di+10h], 1
        mov	ah, 37h
        call	sub_1072
        mov	[byte ptr di+10h], 1
        jmp	sub_3641
endp		sub_1BCE
; ---------------------------------------------------------------------------
        push	si
        push	di
        mov	si, offset LOCAT_BUF
        mov	di, offset LOCAT_BUF + 1
        mov	cx, 31Fh
        mov	[byte ptr si], 0
        cld
        rep movsb
        pop	si
        pop	di
        retn

; =============== S U B	R O U T	I N E =======================================
; 1B7F
;
;loc_0set:
;		db 0FFh, 11h, 81h, 81h
;		db 3  ; - count (CH register)
;		db 80h, 07, 004, 00, 24h, 0, 03, 00
;		db 00,  01, 0Ch, 00, 00, 03, 0A0h, 01 ; monkey here ( 0Ch)
;		db 7Fh, 8Ah, 0, 2Fh, 0, 0, 7, 0, 11h, 0B2h ; fish (02Fh)
;		db 8Bh
;		db 3
;		dw loc_08BC
;		dw loc_08DA
;		dw loc_A26

proc		locationRoutine near
        mov	ah, [locationNum]
        shl	ah, 1 ; *2
        mov	dh, 0
        mov	dl, ah ;
        mov	di, offset locPointers
        add	di, dx ; calculate address of location objects description
        mov	dx, [di]
        mov	[locDscAddr], dx
        push	dx
        pop	di
        mov	dx, 4
        add	di, dx ; add addr to description
        mov	ah, [di] ; get desc count
        mov	ch, ah ; get cycles count
        inc	di ; get next 'instruction'
        or	ah, ah ; check for desc end
        jz	short setLocProcAddr

loc_1C1C:
        push	cx
        inc	di
        test	[byte ptr di-1], 80h
        jnz	short loc_1C42
        xor	ah, ah
        cmp	ah, [di]
        jnz	short loc_1C3A
        mov	si, offset WORK_BUF
        test	[byte ptr si], 80h
        jnz	short loc_1C42
        call	sub_DAF
        call	sub_E82
        jmp	short loc_1C42
; ---------------------------------------------------------------------------

loc_1C3A:				; CODE XREF: locationRoutine+31j
        call	sub_E31
        jb	short loc_1C42
        call	sub_DAF

loc_1C42:

        mov	dx, 8
        add	di, dx
        pop	cx
        dec	ch
        jnz	short loc_1C1C  ; go to next desc

setLocProcAddr:				; CODE XREF: locationRoutine+23j
        mov	[locProcAddr], di
        retn
endp		locationRoutine


; =============== S U B	R O U T	I N E =======================================


proc		locationObjProc near		; CODE XREF: mainCycle+Ep
        mov	di, [locProcAddr]
        mov	ah, [di] ; get a procedures count
        or	ah, ah	; if != 0  jmp to cycle
        jnz	short loc_1C5C
        retn
; ---------------------------------------------------------------------------

loc_1C5C:
        mov	ch, ah	; set cycles count
        inc	di

loc_1C5F:
        push	cx
        push	di
        call	goLocationRoutine ; jmp to addr
        pop	di
        inc	di
        inc	di
        pop	cx
        dec	ch
        jnz	short loc_1C5F
        retn
endp		locationObjProc


; =============== S U B	R O U T	I N E =======================================
; 1C6D

proc		goLocationRoutine near

        mov	bx, [di]
        jmp	bx

endp		goLocationRoutine


; =============== S U B	R O U T	I N E =======================================

proc		setSpriteAtAddr near

        push	bx
        push	cx
        push	dx
        call	getAddrByCoord
        mov	[bx], ah
        pop	dx
        pop	cx
        pop	bx
        retn
endp		setSpriteAtAddr

; ---------------------------------------------------------------------------
; START	OF FUNCTION CHUNK FOR PrepareLocation__

checkLocation__:
        mov	ah, [locationNum]
        cmp	ah, 2Dh ; room with stakes 1
        jnz	short loc_1C89
        jmp	short stakesRoom1
        nop
; ---------------------------------------------------------------------------

loc_1C89:
        cmp	ah, 2Fh ; room with stakes 2
        jnz	short loc_1C91
        jmp	stakesRoom2
; ---------------------------------------------------------------------------

loc_1C91:
        cmp	ah, 31h ; room with switch 1
        jnz	short loc_1C98
        jmp	short switchRoom1
; ---------------------------------------------------------------------------

loc_1C98:
        cmp	ah, 32h ; room with switch 2
        jnz	short locret_1CA0
        jmp	switchRoom2
; ---------------------------------------------------------------------------

locret_1CA0:
        retn
; END OF FUNCTION CHUNK	FOR PrepareLocation__
; ---------------------------------------------------------------------------

; eyes proc

loc_1CA1:
        mov	ah, [byte_DDBF]
        cmp	ah, 1Ah
        jnz	short loc_1CAB
        retn
; ---------------------------------------------------------------------------

loc_1CAB:
        inc	ah
        mov	[byte_DDBF], ah
        add	ah, 6
        mov	cl, ah
        jmp	short loc_1CCF
; ---------------------------------------------------------------------------
loc_1CB8:
        mov	ah, [byte_DDC0]
        cmp	ah, 1Ah
        jnz	short loc_1CC2
        retn
; ---------------------------------------------------------------------------

loc_1CC2:
        inc	ah
        mov	[byte_DDC0], ah
        sub	ah, 21h
        neg	ah
        mov	cl, ah

loc_1CCF:
        mov	ch, 10h
        mov	ah, 0F9h
        call	setSpriteAtAddr
        mov	ah, 0F9h
        call	writeSprite2Buf2__
        inc	ch
        mov	ah, 0FAh
        call	setSpriteAtAddr
        mov	ah, 0FAh
        jmp	writeSprite2Buf2__

; ---------------------------------------------------------------------------
; START	OF FUNCTION CHUNK FOR PrepareLocation__

switchRoom1:
        mov	ch, 0FAh
        mov	cl, 0F9h
        mov	[word_DDD8], cx
        jmp	short loc_1CF8
; ---------------------------------------------------------------------------

stakesRoom1:
        mov	cx, 0
        mov	[word_DDD8], cx

loc_1CF8:
        mov	ah, [byte_DDBF]
        or	ah, ah
        jnz	short loc_1D01
        retn
; ---------------------------------------------------------------------------

loc_1D01:
        mov	ch, ah

loc_1D03:
        push	cx
        mov	ah, ch
        add	ah, 6
        mov	cl, ah
        mov	ch, 10h
        mov	ah, [byte ptr word_DDD8]
        call	setSpriteAtAddr
        inc	ch
        mov	ah, [byte ptr word_DDD8+1]
        call	setSpriteAtAddr
        pop	cx
        dec	ch
        jnz	short loc_1D03
        retn
; ---------------------------------------------------------------------------

switchRoom2:
        mov	ch, 0FAh
        mov	cl, 0F9h
        mov	[word_DDD8], cx
        jmp	short loc_1D34
; ---------------------------------------------------------------------------

stakesRoom2:
        mov	cx, 0
        mov	[word_DDD8], cx

loc_1D34:
        mov	ah, [byte_DDC0]
        or	ah, ah
        jnz	short loc_1D3D
        retn
; ---------------------------------------------------------------------------

loc_1D3D:
        mov	ch, ah

loc_1D3F:
        push	cx
        mov	ah, ch
        sub	ah, 21h
        neg	ah
        mov	cl, ah
        mov	ch, 10h
        mov	ah, [byte ptr word_DDD8]
        call	setSpriteAtAddr
        inc	ch
        mov	ah, [byte ptr word_DDD8+1]
        call	setSpriteAtAddr
        pop	cx
        dec	ch
        jnz	short loc_1D3F
        retn
; END OF FUNCTION CHUNK	FOR PrepareLocation__

; =============== S U B	R O U T	I N E =======================================

proc		sub_1D61 near
        mov	bx, offset paintedWeapon
        test	[byte ptr bx], 80h
        jz	short loc_1D6A
        retn
; ---------------------------------------------------------------------------

loc_1D6A:
        mov	ah, [byte_DDB7]
        cmp	ah, 5
        jnz	short loc_1D7A

loc_1D73:
        mov	bx, offset paintedWeapon
        or	[byte ptr bx], 80h
        retn
; ---------------------------------------------------------------------------

loc_1D7A:
        cmp	ah, 80h
        jz	short loc_1D73
        and	ah, 0Fh
        cmp	ah, 1
        jnz	short loc_1D8F
        dec	[byte ptr si+13h]
        dec	[byte ptr si+14h]
        jmp	short loc_1DAF
; ---------------------------------------------------------------------------

loc_1D8F:
        cmp	ah, 2
        jnz	short loc_1D9C
        dec	[byte ptr si+13h]
        inc	[byte ptr si+14h]
        jmp	short loc_1DAF
; ---------------------------------------------------------------------------

loc_1D9C:
        cmp	ah, 3
        jnz	short loc_1DA9
        inc	[byte ptr si+13h]
        inc	[byte ptr si+14h]
        jmp	short loc_1DAF
; ---------------------------------------------------------------------------

loc_1DA9:
        inc	[byte ptr si+13h]
        dec	[byte ptr si+14h]

loc_1DAF:
        mov	ah, [byte_DDEA]
        dec	ah
        mov	[byte_DDEA], ah
        jz	short loc_1DBE
        jmp	sub_1E41
; ---------------------------------------------------------------------------

loc_1DBE:
        mov	ah, [byte_DDEB]
        mov	[byte_DDEA], ah
        mov	bx, offset byte_DDB7
        test	[byte ptr bx], 80h
        jnz	short loc_1DD1
        inc	[byte ptr bx]
        retn
; ---------------------------------------------------------------------------

loc_1DD1:
        dec	[byte ptr bx]
        retn
endp		sub_1D61


; =============== S U B	R O U T	I N E =======================================


proc		sub_1DD4 near

        mov	[si+0Bh], dl
        mov	[X_COORD], dh
        mov	[si+0Dh], bl
        mov	[si+0Eh], bh
        retn
endp		sub_1DD4


; =============== S U B	R O U T	I N E =======================================


proc		getStanleyCoord near

        push	si
        mov	si, offset WORK_BUF
        call	getObjCoord
        pop	si
        retn
endp		getStanleyCoord


; =============== S U B	R O U T	I N E =======================================
; input:
; SI = object addr
;
; output:
; DK = X coord
; BX = Y coord

proc		getObjCoord near

        mov	dx, [si+0Bh] ; get x
        mov	bx, [si+0Dh] ; get y
        test	[byte ptr DIRECTION], 80h
        retn
endp		getObjCoord

; ---------------------------------------------------------------------------
        mov	ah, [si+13h]
        cmp	ah, 7Fh
        jnz	short loc_1DFE
        retn
; ---------------------------------------------------------------------------

loc_1DFE:
        inc	[byte ptr si+13h]
        retn
; ---------------------------------------------------------------------------
        mov	ah, [si+13h]
        cmp	ah, 81h
        jnz	short loc_1E0B
        retn
; ---------------------------------------------------------------------------

loc_1E0B:
        dec	[byte ptr si+13h]
        retn

; =============== S U B	R O U T	I N E =======================================


proc		sub_1E0F near

        mov	ah, [si+14h]
        cmp	ah, 7Fh
        jnz	short loc_1E18
        retn
; ---------------------------------------------------------------------------

loc_1E18:
        inc	[byte ptr si+14h]
        retn
endp		sub_1E0F


; =============== S U B	R O U T	I N E =======================================


proc		sub_1E1C near

        mov	ah, [si+14h]
        cmp	ah, 81h
        jnz	short loc_1E25
        retn
; ---------------------------------------------------------------------------

loc_1E25:
        dec	[byte ptr si+14h]
        retn
endp		sub_1E1C


; =============== S U B	R O U T	I N E =======================================


proc		sub_1E29 near

        call	sub_1E64
        mov	cl, [DIRECTION]
        mov	bl, [si+0Bh]
        mov	bh, [X_COORD]

        call	sub_1E81
        add	bx, cx

        mov	[si+0Bh], bl
        mov	[X_COORD], bh
        retn
endp		sub_1E29


; =============== S U B	R O U T	I N E =======================================


proc		sub_1E41 near
        call	sub_1E29
        add	bx, cx
        mov	[si+0Bh], bl
        mov	[X_COORD], bh
        retn
endp		sub_1E41

; ---------------------------------------------------------------------------
        mov	ah, [DIRECTION]
        or	ah, ah
        jz	short sub_1E64
        test	ah, 80h
        jz	short loc_1E5D
        inc	ah
        jmp	short loc_1E5F
; ---------------------------------------------------------------------------

loc_1E5D:
        dec	ah

loc_1E5F:
        mov	[DIRECTION], ah
        jmp	short sub_1E29

; =============== S U B	R O U T	I N E =======================================
; ?  collision detect on down ?

proc		sub_1E64 near

        mov	cl, [DIRECTION]
        mov	bx, [X_RESERVE]
        call	sub_1E81
        add	bx, cx
        mov	[X_COORD2], bx
        mov	cl, [si+14h]
        call	sub_1E81
        mov	bx, [Y_RESERVE]
        add	bx, cx
        mov	[Y_COORD2], bx
        retn
endp		sub_1E64


; =============== S U B	R O U T	I N E =======================================


proc		sub_1E81 near
        xchg	ax, cx
        cbw
        xchg	ax, cx
        retn
endp		sub_1E81

; ---------------------------------------------------------------------------
; jmp

loc_1E85:

        mov	bx, [si+22h]
        mov	dx, 5
        add	bx, dx
        mov	bx, [bx]

        jmp	bx

; =============== S U B	R O U T	I N E =======================================


proc		sub_1E91 near

        mov	bx, [si+22h]
        mov	dl, [bx]
        test	[byte ptr DIRECTION], 80h
        jz	short loc_1E9E
        inc	bx
        inc	bx

loc_1E9E:
        inc	bx
        mov	cx, [bx]
        inc	bx
        jmp	setFrameNum
endp		sub_1E91

; ---------------------------------------------------------------------------
; jmp

loc_1EA5:

        test	[byte ptr si+24h], 80h
        jnz	short loc_1EC7
        call	sub_1F12
        jnb	short loc_1EB4
        pop	bx
        jmp	stanleyDied
; ---------------------------------------------------------------------------

loc_1EB4:
        call	sub_1E91
        jb	short loc_1EBA
        retn
; ---------------------------------------------------------------------------

loc_1EBA:
        or	ah, ah
        jnz	short loc_1EBF
        retn
; ---------------------------------------------------------------------------

loc_1EBF:
        or	[byte ptr si], 20h
        or	[byte ptr si+24h], 80h
        retn
; ---------------------------------------------------------------------------

loc_1EC7:				; CODE XREF: _03C8:1EA9j
        call	sub_1EEE
        or	ah, ah
        jz	short loc_1ECF
        retn
; ---------------------------------------------------------------------------

loc_1ECF:				; CODE XREF: _03C8:1ECCj
        and	[byte ptr si], 0DFh
        or	[byte ptr si], 40h
        call	sub_1ED9
        retn

; =============== S U B	R O U T	I N E =======================================


proc		sub_1ED9 near
        mov	[si+4],	cl
        mov	[X_COORD], cl
        mov	[si+6],	ch
        mov	[si+0Eh], ch
        and	[byte ptr si+24h], 7Fh
        mov	[byte ptr FRAME_NUM], 0
        retn
endp		sub_1ED9


; =============== S U B	R O U T	I N E =======================================


proc		sub_1EEE near		; CODE XREF: _03C8:loc_1EC7p
        call	getRandom
        and	ah, 1Fh
        cmp	ah, 14h
        jb	short loc_1EFA
        retn
; ---------------------------------------------------------------------------

loc_1EFA:				; CODE XREF: sub_1EEE+9j
        mov	ch, ah
        call	getRandom
        and	ah, 3Fh
        cmp	ah, 25h
        jb	short loc_1F08
        retn
; ---------------------------------------------------------------------------

loc_1F08:				; CODE XREF: sub_1EEE+17j
        mov	cl, ah
        push	cx
        call	getAddrByCoord
        pop	cx
        mov	ah, [bx]
        retn
endp		sub_1EEE


; =============== S U B	R O U T	I N E =======================================


proc		sub_1F12 near

        call	sub_1F18
        jmp	loc_F26
endp		sub_1F12


; =============== S U B	R O U T	I N E =======================================


proc		sub_1F18 near

        mov	dx, [si+20h]
        mov	di, 0
        add	di, dx
        mov	bl, [di]
        mov	dl, [di+1]
        retn
endp		sub_1F18


; =============== S U B	R O U T	I N E =======================================


proc		sub_1F26 near
        mov	ah, [si+24h]
        add	ah, 2
        mov	bh, 0
        mov	bl, ah
        mov	dx, [si+20h]
        add	bx, dx
        xchg	dx, bx
        mov	di, 0
        add	di, dx
        retn
endp		sub_1F26


; =============== S U B	R O U T	I N E =======================================


proc		sub_1F3D near

        call	sub_1F18

endp		sub_1F3D


; =============== S U B	R O U T	I N E =======================================


proc		sub_1F40 near
        mov	[word_DDD4], bx
        mov	[word_DDD6], dx
        call	loc_F60
        jnb	short loc_1F4E
        retn
; ---------------------------------------------------------------------------

loc_1F4E:
        mov	bx, [word_DDD4]
        mov	dx, [word_DDD6]
        call	loc_F9A
        jnb	short loc_1F5C
        retn
; ---------------------------------------------------------------------------

loc_1F5C:
        mov	bx, [word_DDD4]
        mov	dx, [word_DDD6]
        jmp	loc_F71
endp		sub_1F40

; ---------------------------------------------------------------------------
; jmp

loc_1F67:
        mov	ch, 4
        mov	cl, 0Ch
        mov	ah, 0Eh
        jmp	short loc_1F83
; ---------------------------------------------------------------------------
; jmp

loc_1F6F:
        mov	ch, 4
        mov	cl, 19h
        mov	ah, 0Eh
        jmp	short loc_1F83
; ---------------------------------------------------------------------------
loc_1F77:
        mov	ch, 5
        mov	cl, 0
        jmp	short loc_1F81
; ---------------------------------------------------------------------------
; jmp
loc_1F7D:
        mov	ch, 0Ah
        mov	cl, 26h

loc_1F81:
        mov	ah, 5

loc_1F83:
        mov	al, ah
        push	cx
        xor	ah, ah
        call	setSpriteAtAddr
        xor	ah, ah
        call	writeSprite2Buf2__
        inc	cl
        xor	ah, ah
        call	setSpriteAtAddr
        xor	ah, ah
        call	writeSprite2Buf2__
        pop	cx
        inc	ch
        mov	ah, al
        dec	ah
        jnz	short loc_1F83
        retn

; =============== S U B	R O U T	I N E =======================================


proc		sub_1FA6 near		; CODE XREF: _03C8:2017p _03C8:204Fp
                    ; _03C8:2079p _03C8:2087p _03C8:208Cp ...

; FUNCTION CHUNK AT 148B SIZE 00000013 BYTES

        call	sub_1F3D
        jb	short loc_1FAC
        retn
; ---------------------------------------------------------------------------

loc_1FAC:				; CODE XREF: sub_1FA6+3j
        mov	ch, 2
        mov	cl, 2
        pop	bx
        jmp	loc_148B
endp		sub_1FA6 ; sp-analysis failed


; =============== S U B	R O U T	I N E =======================================


proc		sub_1FB4 near		; CODE XREF: sub_1FF1+Ap
                    ; sub_2000:loc_2006p _03C8:loc_201Ap
                    ; _03C8:22DFp
        call	sub_F19
        call	sub_200E
        jb	short loc_1FC0
        mov	[si+13h], dl
        retn
; ---------------------------------------------------------------------------

loc_1FC0:				; CODE XREF: sub_1FB4+6j
        mov	ah, dl
        neg	ah
        mov	[si+13h], ah
        retn
endp		sub_1FB4


; =============== S U B	R O U T	I N E =======================================


proc		sub_1FC8 near		; CODE XREF: sub_2000+9p _03C8:201Dp
                    ; _03C8:22E2p
        call	sub_F0C
        call	sub_200E
        jb	short loc_1FD4
        mov	[si+14h], dl
        retn
; ---------------------------------------------------------------------------

loc_1FD4:				; CODE XREF: sub_1FC8+6j
        neg	ah
        mov	[si+14h], ah
        retn
endp		sub_1FC8


; =============== S U B	R O U T	I N E =======================================


proc		sub_1FDA near		; CODE XREF: _03C8:2052p
        call	sub_F0C
        cmp	ah, 3
        jb	short loc_1FE3
        retn
; ---------------------------------------------------------------------------

loc_1FE3:				; CODE XREF: sub_1FDA+6j
        call	sub_F19
        mov	dl, 60h
        jnb	short loc_1FEC
        mov	dl, 0A0h

loc_1FEC:				; CODE XREF: sub_1FDA+Ej
        mov	[si+13h], dl
        stc
        retn
endp		sub_1FDA


; =============== S U B	R O U T	I N E =======================================


proc		sub_1FF1 near		; CODE XREF: _03C8:208Fp _03C8:209Ap
        call	sub_F0C
        jb	short loc_1FF7
        retn
; ---------------------------------------------------------------------------

loc_1FF7:				; CODE XREF: sub_1FF1+3j
        mov	[byte ptr si+14h], 0E0h
        call	sub_1FB4
        stc
        retn
endp		sub_1FF1


; =============== S U B	R O U T	I N E =======================================


proc		sub_2000 near		; CODE XREF: _03C8:20C4p
        call	sub_F0C
        jb	short loc_2006
        retn
; ---------------------------------------------------------------------------

loc_2006:				; CODE XREF: sub_2000+3j
        call	sub_1FB4
        call	sub_1FC8
        stc
        retn
endp		sub_2000


; =============== S U B	R O U T	I N E =======================================


proc		sub_200E near
        pushf
        mov	dl, ah
        add	dl, dl
        add	dl, ah
        popf
        retn
endp		sub_200E

; ---------------------------------------------------------------------------
; jmp

loc_2017:
        call	sub_1FA6

loc_201A:
        call	sub_1FB4
        call	sub_1FC8

loc_2020:
        mov	ah, [byte_DDB3]
        and	ah, 18h
        jz	short loc_202A
        retn
; ---------------------------------------------------------------------------

loc_202A:
        call	sub_1E91
        jb	short loc_2030
        retn
; ---------------------------------------------------------------------------

loc_2030:
        test	[byte ptr FRAME_NUM], 1
        jnz	short loc_2037
        retn
; ---------------------------------------------------------------------------

loc_2037:
        call	getRandom
        cmp	ah, 0AAh
        jb	short loc_204A
        mov	ah, [si+2]
        cmp	ah, 2
        jnb	short loc_204A
        jmp	loc_20CD
; ---------------------------------------------------------------------------

loc_204A:				; CODE XREF: _03C8:203Dj _03C8:2045j
                    ; _03C8:2075j
        and	[byte ptr FRAME_NUM], 0FEh
        retn
; ---------------------------------------------------------------------------
; jmp

loc_204F:

        call	sub_1FA6
        call	sub_1FDA
        jb	short loc_2058
        retn
; ---------------------------------------------------------------------------

loc_2058:				; CODE XREF: _03C8:2055j
        mov	ah, [byte_DDB3]
        and	ah, 18h
        jz	short loc_2062
        retn
; ---------------------------------------------------------------------------

loc_2062:				; CODE XREF: _03C8:205Fj
        call	sub_1E91
        jb	short loc_2068
        retn
; ---------------------------------------------------------------------------

loc_2068:				; CODE XREF: _03C8:2065j
        test	[byte ptr FRAME_NUM], 1
        jnz	short loc_206F
        retn
; ---------------------------------------------------------------------------

loc_206F:				; CODE XREF: _03C8:206Cj
        mov	ah, [FRAME_PAUSE]
        cmp	ah, 2
        jnb	short loc_204A
        jmp	short loc_20CD
; ---------------------------------------------------------------------------
; jmp

loc_2079:
        call	sub_1FA6
        call	sub_F19
        cmp	ah, 4
        jnb	short loc_2085
        retn
; ---------------------------------------------------------------------------

loc_2085:				; CODE XREF: _03C8:2082j

        jmp	short loc_201A
; ---------------------------------------------------------------------------
; jmp

loc_2087:

        call	sub_1FA6
        jmp	short loc_201A
; ---------------------------------------------------------------------------
; jmp

loc_208C:
        call	sub_1FA6
        call	sub_1FF1
        jb	short loc_2095
        retn
; ---------------------------------------------------------------------------

loc_2095:
        jmp	short loc_2020
; ---------------------------------------------------------------------------
; jmp

loc_2097:

        call	sub_1FA6
        call	sub_1FF1
        jb	short loc_20A0
        retn
; ---------------------------------------------------------------------------

loc_20A0:
        mov	ah, [byte_DDB3]
        and	ah, 18h
        jz	short loc_20AA
        retn
; ---------------------------------------------------------------------------

loc_20AA:
        call	sub_1E91
        jb	short loc_20B0
        retn
; ---------------------------------------------------------------------------

loc_20B0:
        call	getRandom
        cmp	ah, 0C8h
        jnb	short loc_20B9
        retn
; ---------------------------------------------------------------------------

loc_20B9:
        mov	ah, [si+2]
        cmp	ah, 2
        jb	short loc_20C2
        retn
; ---------------------------------------------------------------------------

loc_20C2:				; CODE XREF: _03C8:20BFj
        jmp	short loc_20CD
; ---------------------------------------------------------------------------
; jmp

loc_20C4:

        call	sub_2000
        jb	short loc_20CA
        retn
; ---------------------------------------------------------------------------

loc_20CA:				; CODE XREF: _03C8:20C7j
        jmp	loc_2020
; ---------------------------------------------------------------------------

loc_20CD:				; CODE XREF: _03C8:2047j _03C8:2077j
                    ; _03C8:loc_20C2j
        call	sub_1F18
        mov	[word_DDD6], di
        call	getObjCoord
        mov	cx, 0A0h
        add	bx, cx
        inc	dh
        mov	[word_DDD2], bx
        mov	[word_DDD4], dx
        mov	[word_DDD8], si
        call	sub_E31
        jnb	short loc_20F0
        retn
; ---------------------------------------------------------------------------

loc_20F0:
        mov	bx, offset muteSound
        call	playSound

        mov	cl, 0
        mov	di, [word_DDD6]
        mov	ch, [di+4]
        mov	dx, [word_DDD4]
        mov	bx, [word_DDD2]
        call	sub_DFA
        mov	di, [word_DDD8]
        mov	ah, [di+12h]
        mov	[si+2],	ah
        mov	ah, [di+13h]
        mov	[si+13h], ah
        mov	ah, [di+14h]
        mov	[si+14h], ah
        inc	[byte ptr di+2]
        mov	di, [word_DDD6]
loc_2127:
        mov	ah, [di+2]
        mov	[si+22h], ah
        add	ah, 7
        mov	[si+20h], ah
        mov	ah, [di+3]
        mov	[si+23h], ah
        adc	ah, 0
        mov	[si+21h], ah
        retn
; ---------------------------------------------------------------------------
; jmp
loc_2140:

        call	sub_1F12
        jnb	short loc_214A
        call	sub_10E0
        jmp	short loc_2168
; ---------------------------------------------------------------------------

loc_214A:
        call	sub_1E91
        jb	short loc_2150
        retn
; ---------------------------------------------------------------------------

loc_2150:
        call	sub_1E0F
        call	sub_1E29
        call	checkGround
        mov	ah, [si+24h]
        and	ah, 0F0h
        jnz	short loc_2168
        test	[byte ptr OBJ_STATUS], 40h
        jnz	short loc_2168
        retn

; ---------------------------------------------------------------------------

loc_2168:
        call	copy8bytesDown
        or	[byte ptr si], 10h
        mov	ah, [si+2]
        call	sub_1095
        jnb	short loc_2177
        retn
; ---------------------------------------------------------------------------

loc_2177:
        mov	ah, [di+2]
        or	ah, ah
        jnz	short loc_217F
        retn
; ---------------------------------------------------------------------------

loc_217F:
        dec	[byte ptr di+2]
        retn
; ---------------------------------------------------------------------------
; jmp

loc_2183:

        call	sub_1F12
        jnb	short loc_218E
        pop	bx
        call	stanleyDied
        jmp	short loc_2168
; ---------------------------------------------------------------------------

loc_218E:				; CODE XREF: _03C8:2186j
        call	sub_1E91
        jb	short loc_2194
        retn
; ---------------------------------------------------------------------------

loc_2194:				; CODE XREF: _03C8:2191j
        call	sub_1E29
        call	checkGround
        mov	ah, [si+24h]
        and	ah, 0F0h
        jnz	short loc_2168
        retn
; ---------------------------------------------------------------------------
; jmp

loc_21A3:

        call	sub_1F12
        jnb	short loc_21AE
        pop	bx
        call	stanleyDied
        jmp	short loc_2168
; ---------------------------------------------------------------------------

loc_21AE:
        jmp	short loc_214A
; ---------------------------------------------------------------------------
; jmp
loc_21B0:

        call	sub_2295
        jz	short locret_21B7
        jmp	short loc_2168
; ---------------------------------------------------------------------------

locret_21B7:
        retn
; ---------------------------------------------------------------------------
; jmp
loc_21B8:

        call	sub_1F12
        jnb	short loc_21C3
        pop	bx
        call	stanleyDied
        jmp	short loc_2168
; ---------------------------------------------------------------------------

loc_21C3:
        call	sub_1E91
        jb	short loc_21C9
        retn
; ---------------------------------------------------------------------------

loc_21C9:
        call	sub_1E1C
        call	sub_1E29
        call	checkGround
        mov	ah, [si+24h]
        and	ah, 0B0h
        jz	short locret_21DC
        jmp	short loc_2168
; ---------------------------------------------------------------------------

locret_21DC:
        retn
; ---------------------------------------------------------------------------
; jmp
loc_21DD:

        call	sub_1F12
        jb	short loc_21E4
        jmp	short loc_21C3
; ---------------------------------------------------------------------------

loc_21E4:
        pop	bx
        call	sub_10E0
        jmp	loc_2168
; ---------------------------------------------------------------------------
; jmp

loc_21EB:

        call	sub_1F3D
        jnb	short loc_21F7
        mov	cl, 0
        mov	ch, 0
        jmp	loc_148B
; ---------------------------------------------------------------------------

loc_21F7:
        call	sub_1F12
        jnb	short sub_2200
        pop	bx
        jmp	stanleyDied

; =============== S U B	R O U T	I N E =======================================


proc		sub_2200 near

        mov	ah, [si+2]
        or	ah, ah
        jnz	short loc_222F
        call	sub_1F26
        mov	ah, [di]
        cmp	ah, 0FFh
        jnz	short loc_2217
        xor	ah, ah
        mov	[si+24h], ah
        retn
; ---------------------------------------------------------------------------

loc_2217:
        mov	[si+2],	ah
        mov	ah, [di+1]
        mov	[si+13h], ah
        mov	ah, [di+2]
        mov	[si+14h], ah
        mov	ah, [si+24h]
        add	ah, 3
        mov	[si+24h], ah

loc_222F:
        call	sub_1E91
        jb	short loc_2235
        retn
; ---------------------------------------------------------------------------
loc_2235:
        dec	[byte ptr si+2]
        jmp	sub_1E64
endp		sub_2200

; ---------------------------------------------------------------------------
; jmp
loc_223B:
        call	sub_1F12
        jb	short foodUp
        retn
; ---------------------------------------------------------------------------
foodUp:
        mov	ah, 3Ch
        mov	[byte ptr pFOOD], ah
        call	markUsedProvision
        mov	bx, offset positiveSound
        jmp	playSound
; ---------------------------------------------------------------------------
; jmp
loc_2250:
        call	sub_1F12
        jb	short waterUp
        retn
; ---------------------------------------------------------------------------
waterUp:
        mov	ah, 3Ch
        mov	[byte ptr pFOOD+1], ah
        call	markUsedProvision
        mov	bx, offset positiveSound
        jmp	playSound

; ---------------------------------------------------------------------------
; jmp

loc_2265:

        call	sub_2200
        call	sub_1F12
        jb	short foundStone
        retn
; ---------------------------------------------------------------------------
foundStone:
        mov	bx, offset stonesFound
        inc	[byte ptr bx]
        call	markUsedProvision
        call	addLive__
        mov	bx, offset positiveSound
        jmp	playSound

; =============== S U B	R O U T	I N E =======================================


proc		markUsedProvision near

        or	[byte ptr si], 10h
        mov	dh, 0
        mov	di, offset provisionStatePtrs
        mov	dl, [si+12h]
        add	di, dx
        mov	bl, [di]
        mov	bh, [di+1]
        or	[byte ptr bx], 80h
        retn
endp		markUsedProvision


; =============== S U B	R O U T	I N E =======================================


proc		sub_2295 near

        call	sub_1F12
        jnb	short loc_22A3
        mov	[byte ptr si+2], 1
        pop	bx
        pop	bx
        jmp	stanleyDied
; ---------------------------------------------------------------------------

loc_22A3:
        call	sub_1E91
        jnb	short loc_22B9
        call	sub_1E41
        test	[byte ptr si+14h], 80h
        jnz	short loc_22B6
        call	sub_1E0F
        jmp	short loc_22B9
; ---------------------------------------------------------------------------

loc_22B6:
        call	sub_1E1C

loc_22B9:
        call	checkGround
        mov	ah, [si+24h]
        and	ah, 0F0h
        retn
endp		sub_2295

; ---------------------------------------------------------------------------
; jmp

loc_22C3:

        call	sub_1F3D
        jnb	short loc_22CF
        mov	ch, 1
        mov	cl, 1
        jmp	loc_148B
; ---------------------------------------------------------------------------

loc_22CF:
        mov	ah, [si+2]
        or	ah, ah
        jnz	short loc_22E9
        mov	ah, [byte_DDB3]
        and	ah, 18h
        jnz	short loc_22F2
        call	sub_1FB4
        call	sub_1FC8
        mov	[byte ptr si+2], 64h

loc_22E9:
        call	sub_2295
        jnz	short loc_22F2
        dec	[byte ptr si+2]
        retn
; ---------------------------------------------------------------------------

loc_22F2:
        mov	ah, [si+13h]
        neg	ah
        mov	[si+13h], ah
        mov	ah, [si+14h]
        neg	ah
        mov	[si+14h], ah
        mov	[byte ptr si+2], 32h
        jmp	copy8bytesDown
; ---------------------------------------------------------------------------
loc_2309:
        mov	bx, offset byte_DDB3
        test	[byte ptr bx], 4
        jz	short loc_2312
        retn
; ---------------------------------------------------------------------------

loc_2312:
        mov	ah, 2Dh
        call	sub_1072
        jb	short loc_231A
        retn
; ---------------------------------------------------------------------------

loc_231A:
        call	getRandom
        and	ah, 7Fh
        cmp	ah, 0Ch
        jz	short loc_2326
        retn
; ---------------------------------------------------------------------------

loc_2326:
        mov	di, [locDscAddr]
        mov	dx, 6
        add	di, dx
        mov	bx, offset byte_DE54
        mov	ah, [di+5]
        sub	ah, [bx]
        jnb	short loc_233B
        neg	ah

loc_233B:
        cmp	ah, 4
        jb	short loc_2341
        retn
; ---------------------------------------------------------------------------

loc_2341:
        mov	ah, [di+3]
        mov	bx, offset byte_DE52
        sub	ah, [bx]
        jnb	short loc_234D
        neg	ah

loc_234D:
        cmp	ah, 6
        jnb	short loc_2353
        retn
; ---------------------------------------------------------------------------

loc_2353:
        call	sub_E31
        jnb	short loc_2359
        retn
; ---------------------------------------------------------------------------

loc_2359:
        jmp	sub_DAF
; ===========================================================================
; jmp

hunterProc:

        call	sub_1F3D
        jnb	short loc_236E
        mov	ch, 2
        mov	cl, 2
        mov	bx, offset byte_DDB3
        or	[byte ptr bx], 4
        jmp	loc_148B
; ---------------------------------------------------------------------------

loc_236E:
        test	[byte ptr si+12h], 80h
        jnz	short loc_2378
        dec	[byte ptr si+12h]
        retn
; ---------------------------------------------------------------------------

loc_2378:
        call	sub_2200
        mov	ah, [si+2]
        or	ah, ah
        jz	short loc_2383
        retn
; ---------------------------------------------------------------------------

loc_2383:
        mov	ah, [si+24h]
        or	ah, ah
        jnz	short loc_238E
        or	[byte ptr si], 10h
        retn
; ---------------------------------------------------------------------------

loc_238E:
        cmp	ah, 3
        jz	short loc_2394
        retn
; ---------------------------------------------------------------------------

loc_2394:
        mov	[byte ptr si+12h], 0Fh
        push	si
        call	sub_E31
        mov	[word_DDD8], si
        pop	si
        jnb	short loc_23A4
        retn
; ---------------------------------------------------------------------------

loc_23A4:
        call	getObjCoord
        mov	cl, 7Fh
        mov	ah, 3
        jz	short loc_23B1
        mov	ah, 0FFh
        mov	cl, 81h

loc_23B1:
        inc	bh
        add	ah, dh
        mov	dh, ah
        mov	ah, cl
        mov	ch, 2Eh
        mov	cl, 0
        mov	si, [word_DDD8]
        call	sub_DFA
        mov	bx, offset bombSound
        jmp	playSound

; =============== S U B	R O U T	I N E =======================================
; Get symbols of scores

proc		getScoreSymbols near
        or	ah, ah
        mov	dh, 0FFh
        mov	cx, 2710h ; 10,000

loc_23D1:
        inc	dh
        sbb	bx, cx
        jnb	short loc_23D1
        add	bx, cx
        or	ah, ah
        mov	cx, 3E8h ; 1000
        mov	dl, 0FFh

loc_23E0:
        inc	dl
        sbb	bx, cx
        jnb	short loc_23E0
        add	bx, cx
        push	dx
        or	ah, ah
        mov	dx, 64h ; 100
        mov	ch, 0FFh

loc_23F0:
        inc	ch
        sbb	bx, dx
        jnb	short loc_23F0
        add	bx, dx
        or	ah, ah
        mov	dx, 0Ah ; 10
        mov	cl, 0FFh

loc_23FF:
        inc	cl
        sbb	bx, dx
        jnb	short loc_23FF
        add	bx, dx
        pop	dx
        mov	si, offset scoreSymbolsBuf
        mov	[si], dh
        mov	[si+1],	dl
        mov	[si+2],	ch
        mov	[si+3],	cl
        mov	[si+4],	bl
        mov	[byte ptr si+5], 0FFh
        retn
endp		getScoreSymbols

; ---------------------------------------------------------------------------

paintScore__:
        push	si
        push	dx
        push	cx
        push	ax
        call	getScoreSymbols
        pop	ax
        mov	dl, ah
        mov	ah, 5
        sub	ah, dl
        mov	dl, ah
        mov	dh, 0
        add	si, dx
        pop	cx

loc_2433:
        mov	ah, [si]
        test	ah, 80h
        jnz	short loc_2449
        mov	al, ah
        mov	ah, 0
        add	ax, 10h
        call	writeSpriteBuf2__
        inc	cl
        inc	si
        jmp	short loc_2433
; ---------------------------------------------------------------------------

loc_2449:
        pop	dx
        pop	si
        retn

; =============== S U B	R O U T	I N E =======================================


proc		hat__ near
        mov	ah, 0
        mov	[byte ptr word_DDD8], ah
        mov	[byte ptr word_DDD8+1],	ah
        mov	ah, [pLIVE_COUNT]
        or	ah, ah
        jnz	short paintHat__
        retn
; ---------------------------------------------------------------------------

paintHat__:
        add	ah, ah
        add	ah, 14h
        mov	cl, ah
        mov	ch, 15h
        mov	al, [byte ptr word_DDD8]
        mov	ah, 0
        call	writeSpriteBuf2__
        inc	cl
        mov	al, [byte ptr word_DDD8+1]
        mov	ah, 0
        jmp	writeSpriteBuf2__
endp		hat__


; =============== S U B	R O U T	I N E =======================================


proc		addLive__ near
        mov	ah, [pLIVE_COUNT]
        cmp	ah, 7
        jnz	short loc_2484
        retn
; ---------------------------------------------------------------------------

loc_2484:
        inc	ah
        mov	[pLIVE_COUNT], ah
        mov	cl, 2Fh
        mov	ch, 30h
        mov	[word_DDD8], cx
        jmp	short paintHat__
endp		addLive__


; =============== S U B	R O U T	I N E =======================================


proc		clearStrenght__	near
        xor	ah, ah
        mov	[byte ptr pSTRENGHT], ah
        jmp	paintStrenght__
endp		clearStrenght__


; =============== S U B	R O U T	I N E =======================================

proc		setFood__ near
        mov	ah, 3Ch
        mov	[byte ptr pFOOD], ah
        jmp	paintFood__
endp		setFood__

; ---------------------------------------------------------------------------

setWater__:
        mov	ah, 3Ch
        mov	[byte ptr pFOOD+1], ah
        jmp	paintWater__

; =============== S U B	R O U T	I N E =======================================


proc		paintScreen2__ near

        mov	bx, offset BOTTOM_SPRITES	; set BX = BOTTOM PANEL	SPRITE BUFFER ADDRESS
        call	paintBottomPanel__
        call	clearStrenght__
        call	setFood__
        jmp	short setWater__
endp		paintScreen2__

; ---------------------------------------------------------------------------

scoreProc:
        mov	bx, [SCORE_COUNT]
        mov	cx, 1715h
        mov	ah, 5
        jmp	paintScore__

; =============== S U B	R O U T	I N E =======================================


proc		prepareDemoPar near
        mov	ah, [byte ptr cs:demo1Counter+1]
        or	ah, ah
        jz	short loc_24F2
        mov	ax, offset DEMO_COMMANDS
        mov	[cs:word_2637],	ax

loc_24D9:
        mov	[cs:byte_2634],	0
        mov	[cs:byte_2635],	0FFh
        mov	[cs:byte_2636],	0FFh
        mov	[tmpRandom], 0
        retn
; ---------------------------------------------------------------------------

loc_24F2:
        mov	ax, offset byte_2636
        mov	[cs:word_2637],	ax
        jmp	short loc_24D9
endp		prepareDemoPar

; ---------------------------------------------------------------------------
        inc	cx
        push	cx
        push	bp
        dec	cx
        and	[bx+si+41h], cl
        pop	cx
        and	[bx+di+55h], dl
        inc	bp
        and	[bx+si+4Fh], dl
        dec	bx
        inc	bp
        inc	cx
        push	dx


; START	OF FUNCTION CHUNK FOR demoProc

loc_250E:
        mov	ah, [byte ptr cs:demo1Counter+1]
        or	ah, ah
        nop
        nop
        jz	short locret_254C
        test	[BREAK_BUTTON], 80h ; IS EXIT KEY PRESSED?
        jz	short loc_252A
        xor	ah, ah
        or	ah, 20h
        mov	[CONTROL_STAT], ah
        retn
; ---------------------------------------------------------------------------

loc_252A:
        mov	ah, [cs:byte_2634]
        or	ah, ah
        jz	short loc_254D
        dec	ah
        mov	[cs:byte_2634],	ah
        mov	ah, [cs:byte_2635]
        mov	[CONTROL_STAT], ah
        mov	ah, [cs:byte_2636]
        mov	[pSelectedWeapon], ah

locret_254C:
        retn
; ---------------------------------------------------------------------------

loc_254D:
        mov	bx, [cs:word_2637]
        mov	ah, [bx]
        dec	ah
        mov	[cs:byte_2634],	ah
        inc	bx
        mov	ah, [bx]
        mov	[cs:byte_2635],	ah
        mov	[CONTROL_STAT], ah
        inc	bx
        mov	ah, [bx]
        mov	[cs:byte_2636],	ah
        mov	[pSelectedWeapon], ah
        inc	bx
        mov	[cs:word_2637],	bx
        retn
; END OF FUNCTION CHUNK	FOR demoProc
; ---------------------------------------------------------------------------
        test	[CONTROL_STAT], 80h
        jnz	short loc_25B5
        mov	ah, [CONTROL_STAT]
        mov	bx, offset byte_2635
        cmp	ah, [bx]
        jnz	short loc_259A
        mov	ah, [pSelectedWeapon]
        mov	bx, offset byte_2636
        cmp	ah, [bx]
        jnz	short loc_259A
        jmp	short loc_260F
        nop
; ---------------------------------------------------------------------------

loc_259A:
        mov	bx, [cs:word_2637]
        inc	bx
        inc	bx
        inc	bx
        mov	[cs:word_2637],	bx
        mov	dx, offset DEMO_COMMANDS
        or	ah, ah
        sbb	bx, dx
        mov	ah, bh
        cmp	ah, 0Ch
        jnz	short loc_25ED

loc_25B5:
        xor	ah, ah
        or	ah, 20h
        mov	bx, [cs:word_2637]
        mov	[byte ptr bx], 1
        inc	bx
        mov	[bx], ah
        mov	[CONTROL_STAT], ah
        mov	ax, cs
        mov	es, ax
        mov	bx, 100h
        mov	dl, 10h
        mov	ch, 0Eh
        mov	cl, 1

loc_25D6:				; CODE XREF: _03C8:25E8j
        push	dx
        mov	ax, 308h
        mov	dx, 0
        int	13h		; DISK - WRITE SECTORS FROM MEMORY
                    ; AL = number of sectors to write, CH =	track, CL = sector
                    ; DH = head, DL	= drive, ES:BX -> buffer
                    ; Return: CF set on error, AH =	status,	AL = number of sectors written
        inc	ch
        add	bx, 1000h
        pop	dx
        dec	dl
        jnz	short loc_25D6
        jmp	start
; ---------------------------------------------------------------------------

loc_25ED:
        mov	ah, 1
        mov	bx, [cs:word_2637]
        mov	[bx], ah
        mov	ah, [CONTROL_STAT]
        mov	[cs:byte_2635],	ah
        inc	bx
        mov	[bx], ah
        mov	ah, [pSelectedWeapon]
        mov	[cs:byte_2636],	ah
        inc	bx
        mov	[bx], ah
        retn
; ---------------------------------------------------------------------------

loc_260F:
        mov	bx, [cs:word_2637]
        mov	ah, [bx]
        inc	ah
        or	ah, ah
        jnz	short loc_261F
        jmp	loc_259A
; ---------------------------------------------------------------------------

loc_261F:
        mov	[bx], ah
        inc	bx
        mov	ah, [cs:byte_2635]
        mov	[bx], ah
        inc	bx
        mov	ah, [cs:byte_2636]
        mov	[bx], ah
        retn
; ---------------------------------------------------------------------------
demo1Counter	dw 0
byte_2634	db 0
byte_2635	db 14h
byte_2636	db 1
word_2637	dw 3239h

;============================================================================

include "DEMOCMD.INC"

; =============== S U B	R O U T	I N E =======================================


proc		paintScreen__ near
        call	paintScreen2__
        retn
endp		paintScreen__

; ---------------------------------------------------------------------------
; START	OF FUNCTION CHUNK FOR checkStrenght__

paintStrenght__:
        push	cx
        push	dx
        mov	cx, [pSTRENGHT]
        mov	bx, 1B86h
        mov	dx, 3B86h
        mov	ah, 55h
        call	prepareLifeLine__
        pop	dx
        pop	cx
        retn
; END OF FUNCTION CHUNK	FOR checkStrenght__

; =============== S U B	R O U T	I N E =======================================

proc		paintFood__ near

        mov	cx, [pFOOD]
        mov	bx, 3BD6h	; screen buffer	address	for line
        mov	dx, 1C26h
        mov	ah, 0AAh
        jmp	short prepareLifeLine__
endp		paintFood__

; =============== S U B	R O U T	I N E =======================================


proc		paintWater__ near	;
        mov	cx, [pFOOD+1]
        mov	bx, 1C76h
        mov	dx, 3C76h
        mov	ah, 0FFh
endp		paintWater__


; =============== S U B	R O U T	I N E =======================================

proc		prepareLifeLine__ near
        sar	cl, 1
        push	ds
        push	dx
        mov	dx, 0B800h
        mov	ds, dx
        assume es:nothing, ds:nothing
        pop	dx
        mov	ch, 1Eh
        sub	ch, cl
        call	paintLifeLine__
        mov	bx, dx
        call	paintLifeLine__
        pop	ds
        assume ds:_03C8
        retn
endp		prepareLifeLine__


; =============== S U B	R O U T	I N E =======================================


proc		paintLifeLine__	near
        push	cx
        push	bx
        mov	al, cl
        or	al, al
        jz	short loc_329A

loc_328D:
        mov	[bx], ah
        inc	bx
        dec	cl
        jnz	short loc_328D
        mov	al, ch
        or	al, al
        jz	short loc_32A2

loc_329A:
        mov	[byte ptr bx], 0
        inc	bx
        dec	ch
        jnz	short loc_329A

loc_32A2:
        pop	bx
        pop	cx
        retn
endp		paintLifeLine__

; ============================================================================
; 1D-location monster proc

loc_32A5:
        mov	ah, [byte_DDAE]
        inc	ah
        mov	[byte_DDAE], ah
        cmp	ah, 0Ah
        jz	short loc_32B5
        retn
; ---------------------------------------------------------------------------

loc_32B5:
        xor	ah, ah
        mov	[byte_DDAE], ah
        mov	si, offset WORK_BUF
        mov	ch, 12h
        test	[byte ptr si+13h], 80h
        jnz	short loc_32CD
        mov	bx, offset loc_E31C
        mov	cl, 27h
        jmp	short loc_32F0
; ---------------------------------------------------------------------------

loc_32CD:
        mov	bx, offset loc_E343
        mov	cl, 0
        mov	ah, [bx]
        mov	bx, offset loc_E342
        mov	dx, offset loc_E343
        mov	cx, 27h
        xchg	si, bx
        xchg	di, dx
        std
        rep movsb
        xchg	si, bx
        xchg	di, dx
        xchg	dx, bx
        mov	[bx], ah
        xchg	dx, bx
        jmp	short loc_330C
; ---------------------------------------------------------------------------

loc_32F0:
        mov	ah, [bx]
        mov	bx, offset loc_E31C + 1
        mov	dx, offset loc_E31C
        mov	cx, 27h
        xchg	si, bx
        xchg	di, dx
        cld
        rep movsb
        xchg	si, bx
        xchg	di, dx
        xchg	dx, bx
        mov	[bx], ah
        xchg	dx, bx

loc_330C:
        mov	ch, 12h
        mov	cl, 0
        mov	ah, 28h
        mov	si, offset loc_E31C

loc_3315:
        push	ax
        mov	ah, [si]
        call	writeSprite2Buf2__
        inc	si
        inc	cl
        pop	ax
        dec	ah
        jnz	short loc_3315
        retn
; ---------------------------------------------------------------------------
; START	OF FUNCTION CHUNK FOR weaponProc

weaponSubProc:
        mov	ah, [byte ptr paintedWeapon]
        and	ah, 0Fh
        mov	dl, ah
        mov	ah, [byte ptr paintedWeapon+1]
        and	ah, 0Fh
        cmp	ah, dl
        jnz	short loc_3339
        retn
; -------------------
loc_3339:
        or	ah, ah
        jz	short loc_3343
        call	getWeapBacklightX
        call	paintXorSprite__

loc_3343:
        mov	ah, [byte ptr paintedWeapon]
        and	ah, 0Fh
        jz	short loc_3352
        call	getWeapBacklightX
        call	paintXorSprite__

loc_3352:
        mov	ah, [byte ptr paintedWeapon]
        mov	[byte ptr paintedWeapon+1], ah

        retn
; END OF FUNCTION CHUNK	FOR weaponProc

; =============== S U B	R O U T	I N E =======================================

proc		getWeapBacklightX near
        mov	dh, 0
        mov	bx, offset weaponBacklightX
        dec	ah
        mov	dl, ah
        add	bx, dx
        mov	cl, [bx]
        mov	ch, 16h
        retn
endp		getWeapBacklightX


; =============== S U B	R O U T	I N E =======================================


proc		paintXorSprite__ near	; CODE XREF: weaponProc+2A32p
                    ; weaponProc+2A41p
        mov	ax, 0FFFFh
        jmp	short $+2
        push	ds
        mov	dx, 0B800h
        mov	ds, dx
        assume ds:nothing
        mov	bx, cx
        mov	dl, bh
        mov	dh, 0
        push	ax
        mov	ax, 140h
        mul	dx
        mov	bh, 0
        add	ax, bx
        add	ax, bx
        mov	bx, ax
        mov	cx, 8
        pop	ax

loc_338E:				; CODE XREF: paintXorSprite__+37j
        xor	[bx], ax
        inc	bx
        inc	bx
        xor	[bx], ax
        add	bx, 1FFEh
        xor	[bx], ax
        inc	bx
        inc	bx
        xor	[bx], ax
        sub	bx, 1FB2h
        loop	loc_338E
        pop	ds
        assume ds:_03C8
        retn
endp		paintXorSprite__


; =============== S U B	R O U T	I N E =======================================


proc		setVideoMode near	;
        mov	ax, 4
        int	10h		; - VIDEO - SET	VIDEO MODE
                    ; AL = mode
        call	setPal0100__
        retn
endp		setVideoMode

; =============== S U B	R O U T	I N E =======================================

proc		setPal0100__ near	;
        mov	bx, 100h
        mov	[cs:CURR_PALETTE],	bl
        mov	ax, 0B00h
        int	10h		; - VIDEO - SET	COLOR PALETTE
                    ; BH = 00h, BL = border	color
                    ; BH = 01h, BL = palette (0-3)
        retn
endp		setPal0100__

; ---------------------------------------------------------------------------
; START	OF FUNCTION CHUNK FOR checkLocationPalette

setPal_0101__:				;
        mov	bx, 101h
        mov	[cs:CURR_PALETTE],	bl
        mov	ax, 0B00h
        int	10h		; - VIDEO - SET	COLOR PALETTE
                    ; BH = 00h, BL = border	color
                    ; BH = 01h, BL = palette (0-3)
        retn

; =============== S U B	R O U T	I N E =======================================

proc		checkControls__	near

        mov	[CONTROL_STAT], 0
        mov	al, [byte_7D0D]
        or	al, [byte_7D1C]
        test	al, 80h
        jz	short loc_33E0
        or	[CONTROL_STAT], 1 ; KEY 'UP' PRESSED

loc_33E0:
        mov	al, [byte_7D0E]
        or	al, [byte_7D1D]
        test	al, 80h
        jz	short loc_33F0
        or	[CONTROL_STAT], 2 ; KEY 'DOWN' PRESSED

loc_33F0:				;
        mov	al, [byte_7D0B]
        or	al, [byte_7D1A]
        test	al, 80h
        jz	short loc_3400
        or	[CONTROL_STAT], 4 ; KEY 'LEFT' PRESSED

loc_3400:				;
        mov	al, [byte_7D0C]
        or	al, [byte_7D1B]
        test	al, 80h
        jz	short loc_3410
        or	[CONTROL_STAT], 8 ; KEY 'RIGHT' PRESSED

loc_3410:				;
        mov	al, [FIRE_BUTTON]
        or	al, [byte_7D1E]
        or	al, [byte_7D1F]
        test	al, 80h
        jz	short loc_3424
        or	[CONTROL_STAT], 10h ; KEY 'FIRE' PRESSED

loc_3424:				;
        mov	al, [BREAK_BUTTON]
        test	al, 80h
        jz	short loc_3430
        or	[CONTROL_STAT], 20h ; KEY 'ABORT' PRESSED

loc_3430:				;
        test	[byte_7D19], 80h ; KEY 'HELP' PRESSED (F1)
        jz	short loc_343C
        or	[CONTROL_STAT], 80h ;

loc_343C:				;
        mov	al, [demoLockStat]
        or	al, al
        jz	short loc_3444
        retn
; ---------------------------------------------------------------------------
loc_3444:
        test	[WEAP1_BUTTON], 80h
        jz	short loc_3451
        mov	[pSelectedWeapon], 1
        retn
; ---------------------------------------------------------------------------

loc_3451:
        test	[WEAP2_BUTTON], 80h
        jz	short loc_345E
        mov	[pSelectedWeapon], 2
        retn
; ---------------------------------------------------------------------------

loc_345E:
        test	[WEAP3_BUTTON], 80h
        jz	short loc_346B
        mov	[pSelectedWeapon], 3
        retn
; ---------------------------------------------------------------------------

loc_346B:
        test	[WEAP4_BUTTON], 80h
        jz	short locret_3477
        mov	[pSelectedWeapon], 4

locret_3477:
        retn
endp		checkControls__

        retn
; ---------------------------------------------------------------------------
        retn
; ---------------------------------------------------------------------------
        test	[CONTROL_STAT], 20h
        jnz	short loc_3482
        retn
; ---------------------------------------------------------------------------

loc_3482:
        test	[CONTROL_STAT], 20h
        jnz	short loc_3482
        mov	al, 1
        or	al, al
        retn
; ---------------------------------------------------------------------------
        db 0

; =============== S U B	R O U T	I N E =======================================

proc		test7D11__ near
        test	[byte_7D11], 80h
        retn
endp		test7D11__

; =============== S U B	R O U T	I N E =======================================


proc		isFirePressed near
        test	[FIRE_BUTTON], 80h ; IS SPACE PRESSED ?
        retn
endp		isFirePressed


; =============== S U B	R O U T	I N E =======================================
; input:
; AH = sprite number

proc		writeSprite1Buf1__ near	;
        push	si
        push	di
        push	ax
        push	cx
        push	dx
        push	bx
        push	es
        mov	cl, 4
        shl	ax, cl
        add	ax, offset GRBANK1 ; BUF1 sprites address
        mov	si, ax
        jmp	short paintSprite
endp		writeSprite1Buf1__


; =============== S U B	R O U T	I N E =======================================
; input:
; AH = sprite number

proc		writeSpriteBuf2__ near
        push	si
        push	di
        push	ax
        push	cx
        push	dx
        mov	bx, cx
        push	bx
        push	es
        mov	cl, 4
        shl	ax, cl
        add	ax, offset GRBANK2	; BUF2 sprites address
        mov	si, ax

paintSprite:
        mov	dx, 0B800h
        mov	es, dx
        assume es:nothing
        mov	dl, bh
        mov	dh, 0
        mov	ax, 140h
        mul	dx
        mov	bh, 0
        add	ax, bx
        add	ax, bx
        mov	di, ax
        cld
        mov	cx, 4

loc_34D9:
        movsw
        add	di, 1FFEh
        movsw
        sub	di, 1FB2h
        loop	loc_34D9
        pop	es
        assume es:nothing
        pop	bx
        pop	dx
        pop	cx
        pop	ax
        pop	di
        pop	si
        retn
endp		writeSpriteBuf2__

; =============== S U B	R O U T	I N E =======================================
; input:
; AH = sprite number
; res:
; SI = sprite address
; paint sprite

proc		writeSprite2Buf2__ near

        push	si
        push	di
        push	ax
        push	cx
        push	dx
        mov	bx, cx
        push	bx
        push	es
        mov	cl, 4
        mov	al, ah
        mov	ah, 0
        shl	ax, cl
        add	ax, offset GRBANK1 ; BUF1 sprite address
        mov	si, ax
        jmp	short paintSprite
endp		writeSprite2Buf2__


; =============== S U B	R O U T	I N E =======================================


proc		PrepareLocation__ near

        ; COPY CURRENT LOCATION TO UPPER
        mov	si, offset LOCAT_BUF
        mov	di, offset LOCAT_BUF + 320H
        mov	cx, 190h
        cld
        rep movsw

        ; CLEAR CURRENT LOCATION
        mov	si, offset LOCAT_BUF
        mov	di, offset LOCAT_BUF + 2
        mov	cx, 18Eh
        mov	bx, 0
        mov	[si], bx
        rep movsw

        ;get new location address
        ; addr = location number * 2 + LOCATIONS_OFFSET
        mov	al, [locationNum]
        mov	ah, 0
        add	ax, ax
        add	ax, offset LOCATIONS_OFFSET
        mov	bx, ax
        mov	dx, [bx]

        ; map of location include objects with coord, not sprites;
        mov	si, offset LOCATIONS_MAP
        add	si, dx

        ; Looks as:  (OBJ.COUNT) ; (OBJ1.X); (OBJ1.Y); (OBJ1.OFFSET); (OBJ2.X); (OBJ2.Y); (OBJ2.OFFSET) ... etc.
        ; get objects count
        mov	ch, [si]

        inc	si

loc_3537:

        ; SI = X on loc
        ; SI + 1 = Y on loc
        ; SI + 2 = obj offset

        ; get XY coordinate on location
        push	cx
        mov	bl, [si+1]
        mov	ax, 28h
        mul	bl  ; y
        mov	dl, [si] ; x
        mov	dh, 0
        add	ax, dx;
        add	ax, offset LOCAT_BUF
        mov	di, ax

        ; set object offset in BX
        mov	bx, [si+2]
        add	bx, offset LOCATION_OBJECTS

        ; get object size
        ; XY size in CX = [BX]
        ; Looks as:  X, Y, SPRITE1, SPRITE2.. etc
        mov	cx, [bx]
        inc	bx
        inc	bx

loc_3556:
        push	cx
        push	di

loc_3558:
        mov	al, [bx] ; get sprite number
        or	al, al	; check for zero
        jz	short loc_3560 ; we not type 'zero sprite'
        mov	[di], al ; set sprite on location

loc_3560:
        inc	bx ; next sprite on object
        inc	di ; next sprite on location
        dec	cl ; dec X
        jnz	short loc_3558 ; if X > 0 set next sprite (loc_3558)

        pop	di
        pop	cx

        mov	ax, 28h
        add	di, ax ; increment Y coord on location (40 symbols)
        dec	ch ; dec Y
        jnz	short loc_3556 ; if Y > 0 set next sprite line (loc_3556)

        mov	dx, 4
        add	si, dx
        pop	cx

        dec	ch
        jnz	short loc_3537
        jmp	checkLocation__
endp		PrepareLocation__


; =============== S U B	R O U T	I N E =======================================

proc		paintLocation__	near
        mov	di, offset LOCAT_BUF
        mov	si, offset LOCAT_BUF + 320H	;� 320H
        mov	bx, 0

loc_3587:
        mov	al, [di]
        cmpsb
        jz	short loc_3595
        mov	ah, 0
        push	si
        push	di
        call	writeSprite1Buf1__
        pop	di
        pop	si

loc_3595:
        inc	bl
        cmp	bl, 28h
        jnz	short loc_3587
        mov	bl, 0
        inc	bh
        cmp	bh, 14h
        jnz	short loc_3587
        mov	[LOCK_STATUS1], 1
        call	checkLocationPalette
        retn
endp		paintLocation__

; =============== S U B	R O U T	I N E =======================================

proc		checkLocationPalette near

        cmp	[locationNum], 3Ah
        jz	short loc_35C3
        cmp	[locationNum], 2Ch
        jb	short setPaletteNumber
        cmp	[locationNum], 38h
        jnb	short setPaletteNumber

loc_35C3:
        cmp	[cs:CURR_PALETTE],	0
        jnz	short locret_35CE
        jmp	setPal_0101__
; ---------------------------------------------------------------------------

locret_35CE:
        retn
; ---------------------------------------------------------------------------

setPaletteNumber:
        cmp	[cs:CURR_PALETTE],	1
        jnz	short locret_35DA
        jmp	setPal0100__
; ---------------------------------------------------------------------------

locret_35DA:
        retn
endp		checkLocationPalette

; ---------------------------------------------------------------------------

CURR_PALETTE	db 1

; =============== S U B	R O U T	I N E =======================================

proc		updateObjShadowTiles near

        mov	si, offset WORK_BUF

testAgain:
        test	[byte ptr si], 80h
        jz	short nextReadyObj
        call	updateShadowTiles

nextReadyObj:
        mov	dx, 28h
        add	si, dx
        cmp	[byte ptr si], 0FFh
        jnz	short testAgain
        retn
endp		updateObjShadowTiles


; =============== S U B	R O U T	I N E =======================================


proc		calcBX28 near
        mov	ax, 28h
        mul	ch
        mov	ch, 0
        add	ax, cx ; CX * 028H (40)
        mov	bx, offset LOCAT_BUF
        add	bx, ax
        retn
endp		calcBX28


; =============== S U B	R O U T	I N E =======================================

proc		updateShadowTiles near

        mov	cx, [si+1Ah]
        shr	cl, 1 ; CL / 2
        shr	ch, 1 ;
        shr	ch, 1 ; CH / 4
        call	calcBX28
        mov	cx, [FRAME_SIZE]
        shr	cl, 1 ; CL / 2
        shr	ch, 1
        shr	ch, 1
        shr	ch, 1 ; CH / 6
        inc	ch ;
        inc	ch ; CH + 2
        inc	cl ;
        inc	cl ; CL + 2
        mov	dx, 28h
        mov	ah, 0FFh

loop11:
        push	cx
        push	bx

loop22:
        mov	[bx], ah
        inc	bx
        dec	cl
        jnz	short loop22
        mov	cx, offset loc_E344
        sub	bx, cx
        jnb	short endproc1
        pop	bx
        add	bx, dx  ; + 40 symb (1 row)
        pop	cx
        dec	ch
        jnz	short loop11
        retn
; ---------------------------------------------------------------------------

endproc1:
        pop	bx
        pop	cx
        retn
endp		updateShadowTiles


; =============== S U B	R O U T	I N E =======================================


proc		sub_3641 near

        push	si
        mov	di, offset workBufAddr

loc_3645:
        call	sub_3686
        jz	short loop1
        test	[byte ptr si], 4
        jz	short loc_365E
        test	[byte ptr si], 10h
        jz	short loc_3645
        call	deleteObject
        dec	di
        dec	di
        mov	[byte ptr si], 0
        jmp	short loc_3645
; ---------------------------------------------------------------------------

loc_365E:
        call	sub_3696
        jmp	short loc_3645
; ---------------------------------------------------------------------------

loop1:
        call	sub_3686
        jz	short loc_367F
        test	[byte ptr si], 4
        jnz	short loop1
        test	[byte ptr si+1], 1
        jnz	short loc_3676
        call	sub_383A

loc_3676:
        and	[byte ptr si+1], 0FEh
        and	[byte ptr si], 0BFh
        jmp	short loop1
; ---------------------------------------------------------------------------

loc_367F:
        pop	si
        mov	[LOCK_STATUS1], 1
        retn
endp		sub_3641


; =============== S U B	R O U T	I N E =======================================


proc		sub_3686 near

        mov	al, [di]
        or	al, [di+1]
        jnz	short loc_3691
        mov	di, offset workBufAddr
        retn
; ---------------------------------------------------------------------------

loc_3691:
        mov	si, [di]
        inc	di
        inc	di
        retn
endp		sub_3686


; =============== S U B	R O U T	I N E =======================================

proc		sub_3696 near
        test	[byte ptr si], 40h
        jz	short loc_36A0
        call	copy8bytes2
        jmp	short loc_36C2
; ---------------------------------------------------------------------------
loc_36A0:
        mov	cx, [FRAME_SIZE]
        mov	[tmpFrameSize], cx
        mov	cx, [si+1Ah]
        mov	[word_DE2F], cx
        mov	ah, [si+1]
        mov	[byte_DE45], ah
        and	[byte ptr si+1], 0FDh
        and	[byte ptr si+1], 0FBh
        test	[byte ptr si], 20h
        jnz	short loc_3713

loc_36C2:
        call	getObjAddr
        mov	dx, [si+0Bh]
        test	dh, 80h
        jz	short loc_36FA
        mov	[byte ptr si+1Ah], 0
        mov	bx, 0
        sub	bx, dx
        call	sub_3822
        jnb	short loc_36DE
        jmp	loc_37F0
; ---------------------------------------------------------------------------
loc_36DE:
        mov	ah, [FRAME_SIZE]
        sub	ah, cl
        jnb	short loc_36E8
        jmp	loc_37F0
; ---------------------------------------------------------------------------
loc_36E8:
        jnz	short loc_36ED
        jmp	loc_37F0
; ---------------------------------------------------------------------------

loc_36ED:
        mov	[FRAME_SIZE], ah
        mov	ah, [FRAME_DISP]
        add	ah, cl
        mov	[FRAME_DISP], ah
        jmp	short loc_3713
; ---------------------------------------------------------------------------
loc_36FA:
        xchg	dx, bx
        call	sub_3822
        jnb	short loc_3704
        jmp	loc_37F0
; ---------------------------------------------------------------------------
loc_3704:
        mov	[si+1Ah], cl
        mov	ah, 50h
        sub	ah, cl
        cmp	ah, [FRAME_SIZE]
        jnb	short loc_3713
        mov	[FRAME_SIZE], ah

loc_3713:
        mov	dx, [si+0Dh]
        test	dh, 80h
        jz	short loc_3748
        mov	[byte ptr si+1Bh], 0
        mov	bx, 0
        sub	bx, dx
        call	sub_382D
        jnb	short loc_372C
        jmp	loc_37F0
; ---------------------------------------------------------------------------
loc_372C:
        mov	ah, [si+1Fh]
        sub	ah, cl
        jnb	short loc_3736
        jmp	loc_37F0
; ---------------------------------------------------------------------------
loc_3736:
        jnz	short loc_373B
        jmp	loc_37F0
; ---------------------------------------------------------------------------
loc_373B:
        mov	[si+1Fh], ah
        mov	ah, [si+1Dh]
        add	ah, cl
        mov	[si+1Dh], ah
        jmp	short loc_3761
; ---------------------------------------------------------------------------

loc_3748:
        xchg	dx, bx
        call	sub_382D
        jnb	short loc_3752
        jmp	loc_37F0
; ---------------------------------------------------------------------------

loc_3752:
        mov	[si+1Bh], cl
        mov	ah, 0A0h
        sub	ah, cl
        cmp	ah, [si+1Fh]
        jnb	short loc_3761
        mov	[si+1Fh], ah

loc_3761:
        test	[byte ptr si], 40h
        jnz	short loc_3777
        mov	ah, [byte_DE45]
        test	ah, 4
        jz	short loc_3796
        test	[byte ptr si], 20h
        jz	short loc_3777
        jmp	short loc_37F0
        nop
; ---------------------------------------------------------------------------
loc_3777:
        mov	ah, [si+1Ah]
        mov	[si+16h], ah
        add	ah, [FRAME_SIZE]
        mov	[si+17h], ah
        mov	ah, [si+1Bh]
        mov	[si+18h], ah
        mov	al, [si+1Fh]
        shr	al, 1
        inc	al
        add	ah, al
        mov	[si+19h], ah
        retn
; ---------------------------------------------------------------------------

loc_3796:
        mov	cx, [word_DE2F]
        mov	ah, [si+1Ah]
        cmp	ah, cl
        jb	short loc_37A6
        mov	[si+16h], cl
        jmp	short loc_37A9
; ---------------------------------------------------------------------------

loc_37A6:
        mov	[si+16h], ah

loc_37A9:
        mov	ah, [si+1Bh]
        cmp	ah, ch
        jb	short loc_37B5
        mov	[si+18h], ch
        jmp	short loc_37B8
; ---------------------------------------------------------------------------

loc_37B5:
        mov	[si+18h], ah

loc_37B8:
        add	cl, [byte ptr tmpFrameSize]
        mov	ah, [byte ptr tmpFrameSize+1]
        shr	ah, 1
        inc	ah
        add	ch, ah
        mov	ah, [si+1Ah]
        add	ah, [FRAME_SIZE]
        cmp	ah, cl
        jb	short loc_37D5
        mov	[si+17h], ah
        jmp	short loc_37D8
; ---------------------------------------------------------------------------

loc_37D5:
        mov	[si+17h], cl

loc_37D8:
        mov	ah, [si+1Bh]
        mov	al, [si+1Fh]
        shr	al, 1
        inc	al
        add	ah, al
        cmp	ah, ch
        jb	short loc_37EC
        mov	[si+19h], ah
        retn
; ---------------------------------------------------------------------------

loc_37EC:
        mov	[si+19h], ch
        retn
; ---------------------------------------------------------------------------

loc_37F0:
        or	[byte ptr si+1], 2
        or	[byte ptr si+1], 4
        retn
endp		sub_3696


; =============== S U B	R O U T	I N E =======================================
;; INPUT:
;; OBJ_NUM    = SI+0Fh - OBJECT NUMBER
;; FRAME_NUM  = SI+10h - OBJECT FRAME NUMBER

;; OUTPUT:
;; FRAME_DISP = SI+1Ch - frame displacement
;; FRAME_SIZE = SI+1Eh - frame size
;; FRAME_ADDR = SI+26h - address to frame address

;[ptr_to_addr1] obj1
;[ptr_to_addr2] obj2
;..
;
;addr1:
; frame1_addr:
; frame2_addr:
;
;addr2:
; frame1_addr:
; frame2_addr:
; ...
;

proc		getObjAddr near		; CODE XREF: sub_DFA:loc_E12p
                    ; sub_3696:loc_36C2p
        mov	bx, offset objFramePtrs
        mov	ch, 0
        mov	cl, [OBJ_NUM]; get obj num
        add	cl, cl ; * 2
        add	bx, cx ;
        mov	dx, [bx] ; get pointer
        xchg	dx, bx ; set ADDR to BX
        mov	cl, [FRAME_NUM] ; get FRAME
        add	cx, cx; FRAME = FRAME * 2 (2 bytes for 1 addr)
        add	bx, cx ; ADDR = ADDR + FRAME
        mov	dx, [bx]
        xchg	dx, bx ; BX = get address from [ADDR]
        mov	[FRAME_ADDR], bx ; save object addr to SI+26
        mov	dx, [bx] ; get a object size at first 2 bytes
        mov	[FRAME_SIZE], dx ; save object size
        mov	[word ptr FRAME_DISP], 0 ; displacement
        retn
endp		getObjAddr

; =============== S U B	R O U T	I N E =======================================

proc		sub_3822 near		; CODE XREF: sub_3696+40p sub_3696+66p
        mov	ah, 27h
        cmp	ah, bh
        jb	short locret_382C
        rcl	bx, 1
        mov	cl, bh

locret_382C:				; CODE XREF: sub_3822+4j sub_382D+4j
        retn
endp		sub_3822


; =============== S U B	R O U T	I N E =======================================


proc		sub_382D near		; CODE XREF: sub_3696+8Ep sub_3696+B4p
        mov	ah, 13h
        cmp	ah, bh
        jb	short locret_382C
        rcl	bx, 1
        rcl	bx, 1
        mov	cl, bh
        retn
endp		sub_382D


; =============== S U B	R O U T	I N E =======================================


proc		sub_383A near
        call	sub_38A8
        mov	[byte_DE33], 1
        mov	ah, [si+16h]
        mov	[byte ptr word_DE34], ah
        mov	ah, [si+17h]
        mov	[byte ptr word_DE34+1],	ah
        mov	ah, [si+18h]
        mov	[byte ptr word_DE36], ah
        mov	ah, [si+19h]
        mov	[byte ptr word_DE36+1],	ah
        or	[byte ptr si], 8
        call	sub_388E

loc_3864:
        push	si
        push	di
        mov	[byte_DE38], 0

loc_386B:
        call	sub_3686
        jz	short loc_387B
        test	[byte ptr si+1], 1
        jnz	short loc_386B
        call	sub_38B1
        jmp	short loc_386B
; ---------------------------------------------------------------------------

loc_387B:
        pop	di
        mov	ah, [byte_DE38]
        or	ah, ah
        jz	short loc_3887
        pop	si
        jmp	short loc_3864
; ---------------------------------------------------------------------------

loc_3887:
        pop	si
        push	si
        call	sub_394E
        pop	si
        retn
endp		sub_383A


; =============== S U B	R O U T	I N E =======================================


proc		sub_388E near
        mov	bx, [word_DE15]
        mov	[bx], si
        inc	bx
        inc	bx
        mov	[word_DE15], bx
        retn
endp		sub_388E


; =============== S U B	R O U T	I N E =======================================


proc		sub_389B near
        mov	bx, [word_DE15]
        mov	si, [bx]
        inc	bx
        inc	bx
        mov	[word_DE15], bx
        retn
endp		sub_389B


; =============== S U B	R O U T	I N E =======================================


proc		sub_38A8 near
        mov	bx, [word_DE17]
        mov	[word_DE15], bx
        retn
endp		sub_38A8


; =============== S U B	R O U T	I N E =======================================


proc		sub_38B1 near		; CODE XREF: sub_383A+3Cp
        mov	bh, [si+16h]
        mov	bl, [si+17h]
        mov	dh, [byte ptr word_DE34]
        mov	dl, [byte ptr word_DE34+1]
        call	sub_3942
        jb	short loc_38C7
        jmp	short endproc2
        nop
; ---------------------------------------------------------------------------

loc_38C7:				; CODE XREF: sub_38B1+11j
        mov	bh, [si+18h]
        mov	bl, [si+19h]
        mov	dh, [byte ptr word_DE36]
        mov	dl, [byte ptr word_DE36+1]
        call	sub_3942
        jnb	short endproc2
        mov	ch, [si+16h]
        mov	ah, [byte ptr word_DE34]
        call	ifAHbCH_AHeqCH
        mov	dl, ah
        mov	ch, [si+17h]
        mov	ah, [byte ptr word_DE34+1]
        call	ifAHnbCH_AHeqCH
        mov	dh, ah
        sub	ah, dl
        cmp	ah, 3Eh
        jnb	short endproc2
        mov	ch, [si+18h]
        mov	ah, [byte ptr word_DE36]
        call	ifAHbCH_AHeqCH
        mov	bl, ah
        mov	ch, [si+19h]
        mov	ah, [byte ptr word_DE36+1]
        call	ifAHnbCH_AHeqCH
        mov	bh, ah
        sub	ah, bl
        cmp	ah, 80h
        jnb	short endproc2
        mov	[word_DE34], dx
        mov	[word_DE36], bx
        call	sub_388E
        mov	[byte_DE38], 1
        or	[byte ptr si+1], 1
        or	[byte ptr si], 8
        inc	[byte_DE33]

endproc2:

        retn
endp		sub_38B1


; =============== S U B	R O U T	I N E =======================================


proc		ifAHnbCH_AHeqCH	near
        cmp	ah, ch
        jnb	short locret_393A
        mov	ah, ch

locret_393A:
        retn
endp		ifAHnbCH_AHeqCH


; =============== S U B	R O U T	I N E =======================================


proc		ifAHbCH_AHeqCH near
        cmp	ah, ch
        jb	short locret_393A
        mov	ah, ch
        retn
endp		ifAHbCH_AHeqCH


; =============== S U B	R O U T	I N E =======================================


proc		sub_3942 near

        mov	ah, dl
        cmp	ah, bh
        jb	short loc_394C
        mov	ah, bl
        cmp	ah, dh

loc_394C:
        cmc
        retn
endp		sub_3942


; =============== S U B	R O U T	I N E =======================================
; OBJECT ANIMATION & COLLISION CHECK

proc		sub_394E near

        mov	ah, [LOCK_STATUS1]
        or	ah, ah
        jnz	short loc_3974

        mov	ah, [byte_DE33]
        cmp	ah, 1
        jnz	short loc_3974
        mov	bx, offset word_DE17
        mov	dx, [bx]
        xchg	dx, bx
        inc	bx
        test	[byte ptr bx], 4
        jz	short loc_3974
        test	[byte ptr bx], 2
        jz	short loc_3974
        jmp	copy8bytes2

; ---------------------------------------------------------------------------

loc_3974:
        mov	cl, [byte ptr word_DE34]
        shr	cl, 1
        mov	ch, [byte ptr word_DE36]
        shr	ch, 1
        shr	ch, 1
        mov	[word_DE3F], cx
        mov	dl, [byte ptr word_DE34+1]
        test	dl, 1
        jz	short loc_3992
        add	dl, 2

loc_3992:
        shr	dl, 1
        sub	dl, cl
        mov	dh, [byte ptr word_DE36+1]
        test	dh, 3
        jz	short loc_39A2
        add	dh, 4

loc_39A2:
        shr	dh, 1
        shr	dh, 1
        sub	dh, ch
        mov	[word_DE41], dx
        mov	ch, [byte ptr word_DE3F+1]
        add	ch, dh
        cmp	ch, 14h
        jb	short loc_39C0
        sub	ch, 14h
        sub	dh, ch
        mov	[byte ptr word_DE41+1],	dh

loc_39C0:
        mov	cx, [word_DE3F]
        add	cl, cl
        add	ch, ch
        add	ch, ch
        mov	[tmpScrObjAddr], cx
        mov	cx, [word_DE41]
        add	cl, cl
        add	ch, ch
        add	ch, ch
        mov	[frameOffset], cx
        mov	dx, [word_DE41]
        mov	al, dl
        mov	ah, 0
        mul	dh
        mov	cl, 8
        mul	cl
        mov	cx, ax
        push	si
        push	di

        ; 	clear buffer
        mov	si, offset objGraphBuf
        mov	di, offset objGraphBuf + 2
        mov	[word ptr si], 0
        cld
        rep movsw

        mov	ax, [frameOffset]
        mov	ah, 0
        mov	cl, 3
        shl	ax, cl	; * 6
        mov	[word_DE0D], ax

        mov	dx, [word_DE3F]
        mov	ax, 28h
        mul	dh
        mov	dh, 0
        add	ax, dx
        add	ax, offset LOCAT_BUF
        mov	bx, ax
        mov	dx, [word_DE41]
        mov	di, offset objGraphBuf  ; set address to frame buffer

loc_3A20:
        push	dx
        push	bx
        push	di
loc_3A23:
        push	bx
        push	dx

        mov	al, [bx] ; AL = sprite number
        or	al, al
        jz	short loc_3A30 ; zero sprite?
        mov	ah, 0 ;
        call	copySprite2Buf ; copy sprite to buffer (background)

loc_3A30:
        inc	di
        inc	di
        pop	dx
        pop	bx
        inc	bx

        dec	dl
        jnz	short loc_3A23

        pop	di
        mov	dx, [word_DE0D]
        add	di, dx
        pop	bx
        mov	dx, 28h
        add	bx, dx
        pop	dx
        dec	dh
        jnz	short loc_3A20
        pop	di
        pop	si
        call	sub_38A8
        mov	[word_DE13], di
        mov	ah, [byte_DE33]
        push	si

loc_3A59:
        push	ax
        call	sub_389B
        test	[byte ptr si], 10h
        jz	short loc_3A67
        call	sub_3BA0
        jmp	short loc_3A7D
; ---------------------------------------------------------------------------

loc_3A67:
        test	[byte ptr si+1], 2
        jnz	short loc_3A72
        test	[byte ptr si], 20h
        jz	short loc_3A77

loc_3A72:
        call	copy8bytes2
        jmp	short loc_3A7D
; ---------------------------------------------------------------------------

loc_3A77:
        call	sub_3AE6 ; get paint addr?
        call	copy8bytes2 ; collision?

loc_3A7D:
        pop	ax
        dec	ah
        jnz	short loc_3A59

        pop	si
        mov	di, [word_DE13] ; screen address

; paint object on screen
        push	si
        push	di
        push	es
        mov	dx, 0B800h
        mov	es, dx
        assume es:nothing
        mov	dx, [tmpScrObjAddr] ; get addr on screen
        mov	ax, 50h
        mul	dh
        mov	dh, 0
        add	ax, dx
        mov	di, ax
        mov	si, offset objGraphBuf
        mov	cx, [word_DE41] ; get size
        shl	ch, 1
        shl	ch, 1

objPaintLoop:
        push	cx
        mov	ch, 0
        push	di
        rep movsw
        pop	di
        add	di, 2000h
        pop	cx
        push	cx
        mov	ch, 0
        push	di
        rep movsw
        pop	di
        sub	di, 1FB0h
        pop	cx
        dec	ch
        jnz	short objPaintLoop
        pop	es
        assume es:nothing
        pop	di
        pop	si
        retn
endp		sub_394E


; =============== S U B	R O U T	I N E =======================================
; INPUT :
; AX = SPRITE NUMBER
; SI = OFFSET TO LOCATIONS SPRITE GRAPHIC BANK
;
proc		copySprite2Buf near
        push	di
        mov	cl, 4
        shl	ax, cl ; AX = SPRITE ADDRESS = AX * 8
        add	ax, offset GRBANK1
        mov	si, ax

        mov	dx, [frameOffset] ; get frame offset
        mov	dh, 0
        dec	dx
        dec	dx
        cld
        mov	cx, 8

loc_3ADF:
        movsw	; copy word
        add	di, dx  ; add offset

        loop	loc_3ADF
        pop	di
        retn
endp		copySprite2Buf


; =============== S U B	R O U T	I N E =======================================

proc		sub_3AE6 near
        push	si
        push	di
        mov	bx, [FRAME_ADDR] ; get frame address
        mov	dl, [bx] ; get X-size
        mov	[tmpX], dl ; save X
        inc	bx
        inc	bx
        mov	al, [FRAME_DISP]
        mov	ah, 0
        add	bx, ax
        mov	al, [si+1Dh]
        mul	dl
        add	bx, ax
        mov	[tmpAddrDE0F], bx
        mov	ah, 0
        mov	di, offset objGraphBuf
        mov	cx, [tmpScrObjAddr]
        mov	dx, [si+1Ah]
        mov	al, dl
        sub	al, cl
        add	di, ax
        mov	al, dh
        sub	al, ch
        mov	cl, [byte ptr frameOffset]
        mul	cl
        add	ax, ax
        add	di, ax
        mov	cx, [FRAME_SIZE]
        mov	si, [tmpAddrDE0F]
        mov	bl, [byte ptr frameOffset]
        mov	bh, 0
        mov	dl, [tmpX]
        mov	dh, 0
        cld

loc_3B39:
        push	cx
        push	si
        push	di
        mov	ch, 0
        call	graphOverlay
        pop	di
        add	di, bx
        pop	si
        add	si, dx
        pop	cx
        dec	ch
        jnz	short loc_3B39
        pop	di
        pop	si
        retn
endp		sub_3AE6


; =============== superimpose graphic =======================================
; addr: 0x3b4f
; superimpose graphic
; make bit 'mask': test each 2 bits (one pixel) in byte
; if pixel exists, remove background pixel and put our pixel instead it
; SI: addr of overlay graph buffer
; DI: addr of background graph buffer

proc		graphOverlay near
        mov	al, [si]
        or	al, al
        jz	short loc_3B75
        test	al, 3 ; first 2 bit
        jz	short loc_3B5B
        or	al, 3

loc_3B5B:
        test	al, 0Ch ; next 2 bit and etc
        jz	short loc_3B61
        or	al, 0Ch

loc_3B61:
        test	al, 30h
        jz	short loc_3B67
        or	al, 30h

loc_3B67:
        test	al, 0C0h
        jz	short loc_3B6D
        or	al, 0C0h

loc_3B6D:
        xor	al, 0FFh
        and	al, [di]
        or	al, [si]
        mov	[di], al

loc_3B75:
        inc	di
        inc	si
        loop	graphOverlay
        retn
endp		graphOverlay

; ---------------------------------------------------------------------------
        push	si
        push	di
        add	si, 3
        mov	si, di
        mov	cx, 8
        add	di, cx
        cld
        rep movsb
        pop	di
        pop	si
        retn

; =============== S U B	R O U T	I N E =======================================

proc		copy8bytes2 near
        push	si
        push	di
        mov	di, si
        add	di, 3
        mov	si, di
        mov	cx, 8
        add	si, cx
        cld
        rep movsb
        pop	di
        pop	si
        retn
endp		copy8bytes2


; =============== S U B	R O U T	I N E =======================================


proc		sub_3BA0 near
        mov	[byte ptr si], 0
        call	deleteObject
        mov	cx, [word_DE13]
        sub	bx, cx
        jnb	short locret_3BB4
        dec	cx
        dec	cx
        mov	[word_DE13], cx

locret_3BB4:
        retn
endp		sub_3BA0


; =============== S U B	R O U T	I N E =======================================

proc		deleteObject near

        mov	dx, si
        mov	ch, [objectsCount]
        mov	bx, offset workBufAddr

loc_3BBE:
        mov	ax, [bx]
        cmp	ax, dx
        jz	short loc_3BCB
        inc	bx
        inc	bx
        dec	ch
        jnz	short loc_3BBE
        retn
; ---------------------------------------------------------------------------
loc_3BCB:
        dec	ch
        mov	ah, ch
        jz	short loc_3BEC
        push	bx
        mov	dx, bx
        inc	dx
        inc	dx
        mov	cl, ah
        mov	ch, 0
        inc	cx
        xchg	si, dx
        xchg	di, bx
        cld
        rep movsw
        xchg	si, dx
        xchg	di, bx

loc_3BE6:
        dec	[objectsCount]

        pop	bx
        retn
; ---------------------------------------------------------------------------

loc_3BEC:
        push	bx
        mov	[word ptr bx], 0
        jmp	short loc_3BE6
endp		deleteObject


; =============== S U B	R O U T	I N E =======================================

proc		addObject near

        push	si
        or	ah, ah
        jnz	short loc_3BFA
        inc	ah

loc_3BFA:
        mov	[si+25h], ah
        mov	cl, ah
        mov	ch, [objectsCount]
        mov	di, offset workBufAddr

loc_3C06:
        mov	ax, [di]
        or	ax, ax
        jz	short loc_3C44
        mov	bx, [di]
        push	bx
        pop	si
        mov	al, [si+25h]
        cmp	al, cl
        jnb	short loc_3C1D
        inc	di
        inc	di
        dec	ch
        jmp	short loc_3C06
; ---------------------------------------------------------------------------
loc_3C1D:
        push	bx
        mov	cl, ch
        add	cl, cl
        mov	ch, 0
        push	di
        pop	bx
        inc	cx
        add	bx, cx
        push	bx
        pop	dx
        inc	dx
        inc	dx
        inc	cx
        xchg	si, bx
        xchg	di, dx
        std
        rep movsb
        xchg	si, bx
        xchg	di, dx
        pop	cx

loc_3C3A:
        pop	si
        push	si
        pop	bx
        mov	[di], bx
        inc	[objectsCount]
        retn
; ---------------------------------------------------------------------------

loc_3C44:
        mov	[word ptr di+2], 0
        jmp	short loc_3C3A
endp		addObject


; =============== S U B	R O U T	I N E =======================================


proc		sub_3C4B near
        push	di
        push	ax
        call	sub_3C63
        jb	short loc_3C5F
        pop	ax
        call	addObject
        or	[byte ptr si], 80h
        or	[byte ptr si], 40h
        pop	di
        clc
        retn
; ---------------------------------------------------------------------------

loc_3C5F:
        pop	ax
        pop	di
        stc
        retn
endp		sub_3C4B


; =============== S U B	R O U T	I N E =======================================


proc		sub_3C63 near
        mov	ch, 0Ch
        mov	dx, 28h
        mov	si, offset WORK_BUF

loc_3C6B:
        test	[byte ptr si], 80h
        jz	short loc_3C78
        add	si, dx
        dec	ch
        jnz	short loc_3C6B
        stc
        retn
; ---------------------------------------------------------------------------

loc_3C78:
        push	si
        push	di
        mov	di, si
        inc	di
        mov	cx, 27h
        mov	[byte ptr si], 0
        cld
        rep movsb
        pop	di
        pop	si
        clc
        retn
endp		sub_3C63

; ---------------------------------------------------------------------------
        mov	si, offset WORK_BUF
        mov	di, offset WORK_BUF + 1
        mov	cx, 1DFh
        mov	[byte ptr si], 0
        cld
        rep movsb
        inc	si
        mov	[byte ptr si], 0FFh
        xor	ax, ax
        mov	[objectsCount], al
        mov	si, offset WORK_BUF
        mov	di, offset workBufAddr
        mov	[di], ax
        retn
; ---------------------------------------------------------------------------
        push	dx
        push	bx
        call	sub_3C4B
        pop	bx
        jb	short loc_3CD3
        pop	dx
        push	dx
        push	si
        mov	di, bx
        mov	ah, 0

loc_3CBA:				; CODE XREF: _03C8:3CCAj
        mov	bx, dx
        mov	al, [bx]
        or	al, al
        jz	short loc_3CCC
        inc	dx
        mov	bx, ax
        mov	al, [di]
        mov	[bx+si], al
        inc	di
        jmp	short loc_3CBA
; ---------------------------------------------------------------------------

loc_3CCC:				; CODE XREF: _03C8:3CC0j
        pop	si
        call	copy8bytes2
        clc
        mov	bx, di

loc_3CD3:				; CODE XREF: _03C8:3CB1j
        pop	dx
        retn
; ---------------------------------------------------------------------------
        push	ax
        call	deleteObject
        pop	ax
        call	addObject
        retn

; =============== S U B	R O U T	I N E =======================================


proc		setInterrupts__	near
        cli
        push	ds
        mov	ax, 0
        mov	ds, ax
        mov	bx, 24h ; int 9
        mov	ax, [bx]
        mov	[cs:keybIntVectorOffset],	ax
        mov	[word ptr bx], offset keyboardInterrupt
        inc	bx
        inc	bx
        mov	ax, [bx]
        mov	[cs:keybIntVectorSegment],	ax
        mov	ax, cs
        mov	[bx], ax
        mov	bx, 70h ; int 1Ch
        mov	ax, [bx]
        mov	[cs:timerIntVectorOffset],	ax
        mov	[word ptr bx], offset timerInterrupt
        inc	bx
        inc	bx
        mov	ax, [bx]
        mov	[cs:timerIntVectorSegment],	ax
        mov	ax, cs
        mov	[bx], ax
        mov	cx, 2E9Eh
        mov	al, cl
        out	40h, al		; Timer	8253-5 (AT: 8254.2).
        mov	al, ch
        out	40h, al		; Timer	8253-5 (AT: 8254.2).
        pop	ds
        sti
        retn
endp		setInterrupts__

; ---------------------------------------------------------------------------
;3D25
keybIntVectorOffset	dw offset keyboardInterrupt
;3D27
keybIntVectorSegment	dw 1000h
;3D29
timerIntVectorOffset	dw offset timerInterrupt
;3D2B
timerIntVectorSegment	dw 1000h

; ---------------------------------------------------------------------------
; SYSTEM TIMER INTERRUPT

timerInterrupt:
        cli
        push	ds
        push	es
        push	ax
        push	bx
        push	cx
        push	dx
        push	si
        push	di
        mov	ax, cs
        add	ax, 0
        mov	ds, ax
        inc	[INT_TICK]
        cmp	[INT_TICK], 0C8h
        jnz	short TI_INC ; = 200?
        mov	[INT_TICK], 0 ; set 0
        or	[timerVar64], 40h ; +64

TI_INC:
        inc	[SMALL_TICK]
        inc	[BIG_TICK]
        test	[BIG_TICK], 1
        jnz	short TI_EXIT

        call	processSound ; sound

TI_EXIT:
        pop	di
        pop	si
        pop	dx
        pop	cx
        pop	bx
        pop	ax
        pop	es
        pop	ds
        sti
        iret
; ---------------------------------------------------------------------------

keyboardInterrupt:
        cli
        push	ds
        push	ax
        push	bx
        push	cx
        mov	ax, cs
        add	ax, 0
        mov	ds, ax
        in	al, 60h		; 8042 keyboard	controller data	register
        xchg	ax, bx
        in	al, 61h		; PC/XT	PPI port B bits:
                    ; 0: Tmr 2 gate	��� OR	03H=spkr ON
                    ; 1: Tmr 2 data	ͼ  AND	0fcH=spkr OFF
                    ; 3: 1=read high switches
                    ; 4: 0=enable RAM parity checking
                    ; 5: 0=enable I/O channel check
                    ; 6: 0=hold keyboard clock low
                    ; 7: 0=enable kbrd
        mov	ah, al
        or	al, 80h
        out	61h, al		; PC/XT	PPI port B bits:
                    ; 0: Tmr 2 gate	��� OR	03H=spkr ON
                    ; 1: Tmr 2 data	ͼ  AND	0fcH=spkr OFF
                    ; 3: 1=read high switches
                    ; 4: 0=enable RAM parity checking
                    ; 5: 0=enable I/O channel check
                    ; 6: 0=hold keyboard clock low
                    ; 7: 0=enable kbrd
        xchg	al, ah
        out	61h, al		; PC/XT	PPI port B bits:
                    ; 0: Tmr 2 gate	��� OR	03H=spkr ON
                    ; 1: Tmr 2 data	ͼ  AND	0fcH=spkr OFF
                    ; 3: 1=read high switches
                    ; 4: 0=enable RAM parity checking
                    ; 5: 0=enable I/O channel check
                    ; 6: 0=hold keyboard clock low
                    ; 7: 0=enable kbrd
        xchg	ax, bx
        mov	bx, offset KEYBOARD_TABLE

loc_3D8E:				; CODE XREF: _03C8:3D98j
        cmp	[byte ptr bx], 0
        jz	short loc_3D9D
        cmp	al, [bx]
        jz	short loc_3D9A
        inc	bx
        jmp	short loc_3D8E
; ---------------------------------------------------------------------------

loc_3D9A:
        xor	[byte ptr bx], 80h

loc_3D9D:
        in	al, 20h		; Interrupt controller,	8259A.
        or	al, 20h
        out	20h, al		; Interrupt controller,	8259A.

        ; CHECK CTRL + ALT + DEL
        test	[byte_7D16], 80h
        jz	short checkOPERA
        test	[byte_7D16+1], 80h
        jz	short checkOPERA
        test	[byte_7D16+2], 80h
        jz	short checkOPERA

        ; RESET SYSTEM
        jmp	far ptr	0FFFFh:0
; ---------------------------------------------------------------------------

checkOPERA:
        ; INFINITY CHEAT
        ; CHECK 'opera' on keyboard

        test	[byte_7D0B], 80h 	; O
        jz	short checkS
        test	[byte_7D0C], 80h 	; P
        jz	short checkS
        test	[byte_7D12], 80h 	; E
        jz	short checkS
        test	[byte_7D12+1], 80h 	; R
        jz	short checkS
        test	[byte_7D0E], 80h 	; A
        jz	short checkS

        ; set infinity lives
        mov	[byte ptr cs:loc_644], 90h
        mov	[byte ptr cs:loc_644+1], 90h

checkS:
        test	[byte_7D12+2], 80h ; S
        jz	short loc_3DFF

        ; set code to decrement lives
        mov	[byte ptr cs:loc_644], 0FEh
        mov	[byte ptr cs:loc_644+1], 0CCh

loc_3DFF:
        pop	cx
        pop	bx
        pop	ax
        pop	ds
        sti
        iret

;---------------------------------------------------
INCLUDE "SOUND.ASM"
;---------------------------------------------------
INCLUDE "LOCMAP.inc"
;---------------------------------------------------
INCLUDE	"GRBANK1.inc"
;---------------------------------------------------
INCLUDE	"GRBANK2.inc"
;---------------------------------------------------
INCLUDE "LOCOBJ.inc"
;---------------------------------------------------
INCLUDE "OBJFRDAT.INC"
;---------------------------------------------------

LOCATIONS_OFFSET:
        db 1, 0, 4Eh, 0, 0AFh, 0, 10h, 1, 0A1h,	1, 1Ah,	2, 97h
        db 2, 24h, 3, 0B1h, 3, 46h, 4, 0DBh, 4,	6Ch, 5,	0F9h, 5
        db 82h,	6, 0EBh, 6, 5Ch, 7, 0A9h, 7, 32h, 8, 0AFh, 8, 0FCh
        db 8, 31h, 9, 8Eh, 9, 0DFh, 9, 20h, 0Ah, 75h, 0Ah, 0BAh
        db 0Ah,	0FBh, 0Ah, 34h,	0Bh, 85h, 0Bh, 0CAh, 0Bh, 3Bh
        db 0Ch,	0A8h, 0Ch, 15h,	0Dh, 8Ah, 0Dh, 0F7h, 0Dh, 54h
        db 0Eh,	0DDh, 0Eh, 36h,	0Fh, 0C7h, 0Fh,	50h, 10h, 0E5h
        db 10h,	62h, 11h, 0EFh,	11h, 3Ch, 12h, 95h, 12h, 0DEh
        db 12h,	23h, 13h, 64h, 13h, 0B5h, 13h, 16h, 14h, 6Fh, 14h
        db 0D4h, 14h, 4Dh, 15h,	0BAh, 15h, 77h,	16h, 0D4h, 16h
        db 55h,	17h, 9Eh, 17h, 4Fh, 18h, 0C8h, 18h, 5, 19h, 96h
        db 19h,	0EBh, 19h

;=======================
INCLUDE "KEYBOARD.INC" ;
;=======================
INCLUDE "SOUNDDAT.INC" ;
;=======================
SMALL_TICK	db 7Ch	   ;
BIG_TICK	dw 97E2h   ;

soundStatus	db 0

weaponBacklightX: db 1Bh, 1Eh, 21h, 24h
animObjSizes: db 17h, 10h, 8, 6, 4, 9, 7,	6, 1, 24h
        db 8, 10h, 16h,	3 dup(10h), 15h, 5, 16h, 2 dup(0Fh), 0Dh
        db 6, 0Ch, 16h,	0Fh, 16h, 0Eh, 16h, 10h, 16h, 10h, 16h
        db 10h,	16h, 10h, 7, 4,	0Ch, 9,	3, 5, 3, 10h, 2	dup(0Ah)
        db 0Ch,	0Eh, 10h, 2 dup(12h), 10h, 0Fh,	10h, 7,	2 dup(10h)
        db 0Eh,	16h, 10h, 1Ah, 11h, 0Ch, 9, 2 dup(7), 14h, 0Ch
        db 10h,	6, 27h,	12h, 27h, 12h, 9, 13h, 16h, 10h, 0Ch, 2	dup(9)
        db 0Ch,	10h, 0Bh, 0Eh, 0Ch, 8, 10h, 0Fh, 0Bh, 16h, 10h
        db 4, 5, 11h, 10h, 0Eh,	10h, 0Bh, 20h, 16h, 11h, 19h, 2
        db 0Bh,	6

;=======================
include "OBJSTAT.INC"
;=======================

scoreHelperData:
        db 64h, 0, 0FAh, 0, 0F4h, 1, 10h, 8
        db 4, 2, 10h, 40h, 4, 10h, 0, 40h, 3, 0, 10h, 2, 40h, 1
        db 88h,	22h, 0,	40h

START_SCR_CMD:
        db 0Ah, 8, 84h, 0Fh, 10h, 3Fh, 0, 0Ah
        db 4, 84h, 0Fh,	10h, 3Fh, 0, 0Fh, 8, 81h, 0Ah, 10h, 7Eh
        db 0, 0Fh, 4, 5, 8, 82h, 0Fh, 10h, 3Fh,	0, 83h,	0Fh, 10h
        db 3Fh,	0, 5, 4, 0FFh

FINAL_SCR_CMD:
        db 7Eh, 0, 22h, 8, 3Fh, 0, 0FFh

RAFT_SPR:
        db 0DEh, 8 dup(0D9h),	84h

loc_80A4:
        db 0, 0Bh, 0Fh, 13h, 17h, 1Bh, 23h
loc_80AB:
        db 0FFh, 4, 8, 0Ch, 10h, 14h, 18h
loc_80B2:
        db 0FFh, 0Fh, 13h, 17h, 1Bh, 1Fh, 23h
loc_80B9:
        db 0FFh, 8, 0Ch, 10h,	14h, 18h, 1Ch, 20h, 24h, 0FFh

loc_80C3:
        db 1
rightThrowTiles:
        db 0, 3, 1, 0
loc_80C8:
        db 0
loc_80C9:
        db 5
rightJumpTiles:
        db 6, 7Fh, 81h
loc_80CD:
        db 1, 4
loc_80CF:
        db 4, 1, 0
rightStartThrowTile:
        db 1
rightFireTiles:
        db 7, 8, 0, 0
startJumpRightTiles:
        db 0, 2 dup(6), 0, 7Fh
leftDieTiles:
        db 14h, 9, 0Ah
        db 2 dup(0)
leftStunnedTiles:
        db 4, 0Bh, 0Ch, 2 dup(0)
stanleyEatLeftTiles:
        db 4, 0Dh, 0Eh, 2 dup(0)

swampDieTiles:
        db 4, 0Fh, 10h,	2 dup(0)

loc_80F0:
        db 1
leftThrowTiles:
        db 11h, 14h, 0FFh, 0
loc_80F5:
        db 0
leftFallTiles:
        db 16h
leftJumpTiles:
        db 17h, 2 dup(81h)
loc_80FA:
        db 1, 2 dup(15h),	0FFh
        db 0
leftStartThrowTile:
        db 1

leftFireTiles:
        db 18h
        db 19h,	0, 0
startJumpLeftTiles:
        db 0, 2 dup(17h), 0, 7Fh

rightDieTiles:
        db 14h, 1Ah,	1Bh, 2 dup(0)
rightStunnedTiles:
        db 4, 1Ch, 1Dh,	2 dup(0)
stanleyEatRightTiles:
        db 4, 1Eh, 1Fh, 2 dup(0)

        db 4, 20h, 21h,	0

blockTypes:
        db 0, 0, 28h, 50h, 0FFh, 3, 2Bh, 53h, 2 dup(0FFh)
        db 0, 1
        db 2, 0FFh
loc_812A:
        db 5 dup(0FFh)
loc_812F:
        db 5 dup(1)

;-------------------------
; objects data
;
INCLUDE	"ROOMOBJ.inc"
;-------------------------
; Bottom panel sprites
;
INCLUDE	"BOTPNL.inc"
;--------------------------
; Animated objects graphics
;
INCLUDE "OBJGRAPH.INC"
;--------------------------
; Game variables

INCLUDE "VARDAT.INC"
;--------------------------

ends		_03C8
        end start
