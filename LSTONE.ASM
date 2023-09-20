; REMAKE
; LIVINGSTONE I PRESUME
; OPERA SOFT S.A. 1986
;
;
; !!! = changed

        Ideal
        model tiny

        include	"LSTONE.INC"
        include "LSTONE.DEF"

segment		_03C8 byte public 'CODE'
        assume cs:_03C8
        org 100h
        assume es:nothing, ss:nothing, ds:_03C8

        public start
proc		start near		;
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
                ;call	paintScreen__

startScreen:
        mov	sp, [cs:dwSTACK]
                ;call	clearGameData
        ;call	updateObjShadowTiles
        call	setInterrupts__
        ;call	playMusic
        ;call	clearProvisionStates

        mov	ah, 020h 			; SET START SCREEN
        mov	[locationNum], ah
                ;call	resetLives
        ;call	setDemoParam__
                ;call	paintScreen2__ ; paintBottomPanel
                ;call	checkRaft
        call	PrepareLocation__
                ;call	locationRoutine
                ;call	paintLocation__

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
; ---------------
setDemoMode__:
        mov	ah, 1		; DEMO_MODE
loc_18F:
        mov	[byte ptr cs:demo1Counter+1], ah
        ;call	prepareDemoPar ;TODO
        call	paintScreen__
        mov	ah, 06 ; SET START LOCATION
        mov	[locationNum], ah
        mov	ah, 1
        mov	[CONTROL_MODE], ah

        xor	ah, ah
        mov	[demoLockStat], ah

        mov	[byte ptr paintedWeapon], ah
        mov	[byte ptr paintedWeapon+1], ah
        ;call	updateObjShadowTiles ; TODO
        ;call	goToLoc ; TODO
        jmp	startScreen

endp		start

;=======================================
; STANLEY PROC
; 0x284
proc		stanleyProc	near

        mov	bx, offset byte_DDB3
        test	[byte ptr bx], 2
        jz	short loc_28D
        retn

loc_28D:
        test	[byte ptr bx], 80h
        jz	short loc_29F
endp		stanleyProc
; -----------------
loc_29F:
        mov	si, offset WORK_BUF
        test	[byte ptr bx], 20h
        jz	short loc_2AA
        jmp	setStanleyEat

loc_2AA:
        test	[byte ptr BLOCK_STATUS], 4
        jz	short loc_2B3
        jmp	stanleyDrown ; bit 4 is set

loc_2B3:
        test	[byte ptr BLOCK_STATUS], 1
        jz	short loc_2BC
        jmp	swampProc

loc_2BC:
        call	checkGround
        mov	[footIndex], ah

        cmp	ah, 8Ah ; check for water
        jnz	short checkSwamp
        jmp	stanleyDrown

checkSwamp:
        cmp	ah, 89h ; check for swamp
        jnz	short loc_2D3
        jmp	swampProc

loc_2D3:
        call	checkBlockCollision ; check collision on right-left ?

        test	[byte ptr BLOCK_STATUS], 2
        jz	short loc_2DF
        jmp	loc_683

loc_2DF:
        mov	bx, offset byte_DDB3
        test	[byte ptr bx], 10h
        jz	short loc_2EA
        jmp	stunnedStanley

loc_2EA:
        call	stanleyFire

        test	[byte ptr OBJ_STATUS], 2
        jz	short loc_2F6
        jmp	weaponUsed

loc_2F6:
        test	[byte ptr OBJ_STATUS], 4
        jz	short loc_2FF
        jmp	stanleyThrow

loc_2FF:
        call	stanleyUp
        test	[byte ptr OBJ_STATUS], 8
        jz	short loc_30B
        jmp	loc_4E1

loc_30B:
        test	[byte ptr OBJ_STATUS], 40h
        jz	short loc_32C
        and	[byte ptr OBJ_STATUS], 0FEh
        mov	ah, [CONTROL_STAT] ; check for RIGHT key
        test	ah, 8 ; check for right status
        jz	short testStanleyLeft

        jmp	stanleyRight

testStanleyLeft:
        test	ah, 4 ; check for left status
        jz	short loc_329

        jmp	stanleyLeft
loc_329:
        jmp	loc_5F9
loc_32C:
        test	[byte ptr OBJ_STATUS], 1
        jnz	short loc_371
        test	[byte ptr BLOCK_STATUS], 40h ; check up status - jump if not blocked
        jz	short loc_339
        retn
; ===========
loc_5F9:
        mov	ah, [CONTROL_STAT]
        and	ah, 0Fh
        jz	short loc_603
        retn

loc_603:
        mov	ah, 40h
        mov	[Y_COORD2], ah
        xor	ah, ah
        mov	[FRAME_PAUSE],	ah
        test	[byte ptr DIRECTION], 80h
        mov	bx, offset rightThrowTiles
        jz	short loc_619
        mov	bx, offset leftThrowTiles

loc_619:
        mov	ah, [bx]
        mov	[FRAME_NUM], ah
        retn

; ----------

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
; -----------

loc_34E:
        mov	ah, [OBJ_STATUS]
        or	ah, [BLOCK_STATUS]
        test	[byte ptr DIRECTION], 80h
        jnz	short loc_365
        test	ah, 20h
        jz	short loc_36E
        mov	[byte ptr DIRECTION], 1
        jmp	short loc_36E
; -----------------------

loc_365:
        test	ah, 10h
        jz	short loc_36E
        mov	[byte ptr DIRECTION], 0FFh

loc_36E:
        jmp	sub_1E64

; -------------------------------------
loc_371:
        call	checkJumpTiles
        test	[byte ptr BLOCK_STATUS], 80h
        jz	short loc_37E
        mov	[byte ptr si+14h], 7Fh

loc_37E:
        test	[byte ptr DIRECTION], 80h
        jnz	short loc_393
        test	[byte ptr OBJ_STATUS], 20h
        jnz	short loc_3B7
        test	[byte ptr BLOCK_STATUS], 20h
        jz	short loc_391
        retn
; ----------
loc_391:
        jmp	short loc_3A0
; -----------------------

loc_393:
        test	[byte ptr OBJ_STATUS], 10h
        jnz	short loc_3B7
        test	[byte ptr BLOCK_STATUS], 10h
        jz	short loc_3A0
        retn
; ----------

loc_3A0:
        call	sub_1E29
        mov	ah, [si+14h]
        test	ah, 80h
        jz	short loc_3B2
        add	ah, 3
        mov	[si+14h], ah
        retn
; ----------
loc_3B2:
        mov	[byte ptr si+14h], 7Fh
        retn
; -----------

loc_3B7:
        and	[byte ptr OBJ_STATUS], 0FEh
        retn

; =======================================================

stanleyRight:
        mov	ah, 40h
        mov	[Y_COORD2], ah
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

loc_4A1:
        mov	ah, [BLOCK_STATUS]
        or	ah, [OBJ_STATUS]
        test	ah, 20h
        jz	short loc_4AD
        retn

loc_4AD:
        inc	[byte ptr X_COORD]

        stc
        retn
; =======================================================

stanleyLeft:
        mov	ah, 40h
        mov	[si+0Dh], ah
        mov	ah, [FRAME_PAUSE]
        cmp	ah, 0Ch
        jz	short loc_4C4
        inc	ah
        mov	[FRAME_PAUSE],	ah

loc_4C4:
        mov	bx, offset loc_80F0
        call	getFramesPar
        call	checkFrames
        jb	short loc_4D0
        retn

loc_4D0:
        mov	ah, [BLOCK_STATUS]
        or	ah, [OBJ_STATUS]
        test	ah, 10h
        jz	short loc_4DC
        retn

loc_4DC:
        dec	[byte ptr X_COORD]
        stc
        retn
; =======================================================
loc_4E1:
        test	[byte ptr BLOCK_STATUS], 8
        jnz	short loc_538
        mov	ah, [FRAME_PAUSE]
        or	ah, ah
        jnz	short loc_4F8

loc_4EE:
        xor	ah, ah
        mov	[FRAME_PAUSE],	ah
        and	[byte ptr OBJ_STATUS], 0F7h
        retn

loc_4F8:
        dec	ah
        mov	[FRAME_PAUSE],	ah
        mov	ah, [OBJ_STATUS]
        or	ah, [BLOCK_STATUS]
        test	ah, 80h
        jnz	short loc_4EE
        test	[byte ptr DIRECTION], 80h
        jnz	short loc_51E
        mov	ah, [OBJ_STATUS]
        or	ah, [BLOCK_STATUS]
        test	ah, 20h
        jnz	short loc_4EE
        mov	bx, offset loc_80C8
        jmp	short loc_52C

loc_51E:
        mov	ah, [OBJ_STATUS]
        or	ah, [BLOCK_STATUS]
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
        and	[byte ptr BLOCK_STATUS], 0F7h
        and	[byte ptr OBJ_STATUS], 0F7h
        retn
; ---------------------------------------------------------------------------
; 547
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
loc_55C:
        or	ah, ah
        jnz	short loc_561
        retn

loc_561:
        mov	[FRAME_NUM], ah
        and	[byte ptr OBJ_STATUS], 0FBh
        and	[byte ptr BLOCK_STATUS], 0F7h
        call	sub_939
        xor	ah, ah
        mov	[byte ptr pSTRENGHT], ah
        retn

;==========================================================

proc		stanleyUp	near
        test	[byte ptr OBJ_STATUS], 8
        jz	short loc_57D
        retn
; ----------

loc_57D:
        mov	ah, [CONTROL_STAT] ; check for UP key pressed
        test	ah, 1
        jz	short stanleyDown
        test	[byte ptr OBJ_STATUS], 40h ; check up block
        jnz	short loc_58D
        retn
; ------------

loc_58D:
        mov	bx, offset loc_80C8
        test	[byte ptr DIRECTION], 80h
        jz	short loc_599
        mov	bx, offset loc_80F5

loc_599:
        call	getFramesPar
        or	[byte ptr OBJ_STATUS], 8
        call	checkFrames
        mov	ah, [FRAME_PAUSE]
        or	ah, ah
        jz	short loc_5B0
        mov	bx, offset smallJumpSound
        jmp	playSound

loc_5B0:
        mov	ah, [Y_COORD]
        sub	ah, 2
        jnb	short loc_5B9
        retn

loc_5B9:
        mov	cl, 1
        test	[byte ptr DIRECTION], 80h
        jz	short loc_5C3
        mov	cl, 0FFh

loc_5C3:
        mov	[DIRECTION], cl
        or	[byte ptr BLOCK_STATUS], 8
        mov	[byte ptr si+12h], 8
        dec	[byte ptr Y_COORD] ; jump on stay
        dec	[byte ptr Y_COORD] ; -'-'-'-
        mov	bx, offset jumpSound
        jmp	playSound
; ==============================================

stanleyDown:
        test	ah, 2
        jnz	short loc_5E0
        retn

loc_5E0:
        test	[byte ptr OBJ_STATUS], GROUND_BIT
        jnz	short loc_5E7
        retn

loc_5E7:
        mov	bx, offset loc_80CD
        test	[byte ptr DIRECTION], 80h
        jz	short loc_5F3
        mov	bx, offset loc_80FA

loc_5F3:
        call	getFramesPar
        jmp	checkFrames
endp		stanleyUp

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
        jmp	respawnStanley
; ---------------------------------------------------------------------------

locret_6AB:
        retn
;============================================================================

stunnedStanley:
        test	[byte ptr OBJ_STATUS], 40h
        jnz	short loc_6B9
        mov	[byte ptr si+14h], 7Fh
        jmp	sub_1E64
; ---------------------------------------------------------------------------

loc_6B9:
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
        dec	[byte ptr FRAME_PAUSE]
        jz	short endStun
        retn
; ---------------------------------------------------------------------------

endStun:
        mov	bx, offset byte_DDB3
        and	[byte ptr bx], 0EFh
        retn

; END OF FUNCTION CHUNK	FOR stanleyProc

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
loc_90A:

db 80
db 40
db 20
db 10

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
; ---------------------
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
; something with weapon

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
; C32

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
        mov	dx, [X_COORD2]
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
        mov	dx, [Y_COORD2]
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

proc		sub_3822 near
        mov	ah, 27h ; check x
        cmp	ah, bh
        jb	short locret_382C
        rcl	bx, 1
        mov	cl, bh

locret_382C:
        retn
endp		sub_3822


; =============== S U B	R O U T	I N E =======================================


proc		sub_382D near
        mov	ah, 13h ; check y
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
        call	getSIworkbuf
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

proc		sub_38B1 near
        mov	bh, [si+16h]
        mov	bl, [si+17h]
        mov	dh, [byte ptr word_DE34]
        mov	dl, [byte ptr word_DE34+1]
        call	sub_3942
        jb	short loc_38C7
        jmp	short endproc2
        nop
; ---------------------------------------------------------------------------

loc_38C7:
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

proc		ifAHbCH_AHeqCH near	;
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
; e29
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
;
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
; something with background
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
        mov	cx, [word_DE41]
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
        test	al, 3 ; 00000011 first 2 bit
        jz	short loc_3B5B
        or	al, 3

loc_3B5B:
        test	al, 0Ch ; 00001100 next 2 bit and etc
        jz	short loc_3B61
        or	al, 0Ch

loc_3B61:
        test	al, 30h ; 00110000
        jz	short loc_3B67
        or	al, 30h

loc_3B67:
        test	al, 0C0h ; 11000000
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
; 3B8C - not used ?
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
; // sub_DAF

;push	di
;mov	di, [locDscAddr]
;mov	dx, 6
;add	di, dx

; load objects from location desription

;DI = data from location
;SI = object params

; DI-1 = SI+0Ah
; DI   = SI+07
; DI+1 = SI+08
; DI+2 = SI+03
; DI+3 = SI+04
; DI+4 = SI+05
; DI+5 = SI+06
; DI+6 = SI+022h ; +7 -> SI+020h
; DI+7 = SI+023h ;  0 -> SI+021h

proc		sub_DAF	near

        call	clear26Bytes
        mov	ah, [di-1]
        mov	[si+0Ah], ah
        mov	ah, [di]
        mov	[si+7],	ah ; obj number
        mov	cl, ah
        mov	ah, [di+1]
        mov	[si+8],	ah
        mov	ah, [di+2]
        mov	[X_RESERVE], ah
        mov	ah, [di+3]
        mov	[X_RESERVE2], ah
        mov	ah, [di+4]
        mov	[Y_RESERVE], ah
        mov	ah, [di+5]
        mov	[Y_RESERVE2], ah
        mov	ah, [di+6]
        mov	[si+22h], ah ; proc address
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
; sub_DFA    something with weapon coord ( pole )
; DX = X coords
; BX = Y coords
proc		sub_DFA	near

        call	clear26Bytes
        mov	[si+7],	ch
        mov	[si+8],	cl
        mov	[X_RESERVE],	dl
        mov	[X_RESERVE2],	dh
        mov	[Y_RESERVE],	bl
        mov	[Y_RESERVE2],	bh
        mov	[DIRECTION], ah

loc_E12:
        call	getObjAddr

        jmp	copy8bytesDown

endp		sub_DFA

; =============== S U B	R O U T	I N E =======================================
; DX - X coord
; BX - Y coord

proc		saveXY near

        mov	[X_COORD2], dl
        mov	[X_COORD], dh
        mov	[Y_COORD2], bl
        mov	[Y_COORD], bh
        retn

endp		saveXY

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


; =============== S U B	R O U T	I N E =======================================

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
        test	ah, 10h ; check for FIRE key
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

; =============================================================

loc_129E:
        call	checkGround
        call	getObjCoord
        mov	di, [word_DDE8]
        jnz	short loc_12B8
        mov	ah, [BLOCK_STATUS]
        and	ah, 0B0h
        jnz	short loc_12B8
        mov	ah, [di]
        add	ah, dh
        mov	dh, ah

loc_12B8:
        dec	bh
        call	saveXY
        mov	si, offset WORK_BUF
        test	[byte ptr DIRECTION], 80h
        jnz	short loc_12D6
        mov	ah, [BLOCK_STATUS]
        or	ah, [OBJ_STATUS]
        and	ah, 0A0h
        jz	short loc_12D4
        jmp	loc_136E
; ---------------------------------------------------------------------------

loc_12D4:
        jmp	short loc_12E4
; ---------------------------------------------------------------------------

loc_12D6:
        mov	ah, [BLOCK_STATUS]
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
        call	saveXY
        inc	di
        mov	[word_DDE8], di
        retn

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
        cmp	ah, MAX_X_SPR-1
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
        mov	ah, [DIRECTION]
        cmp	ah, 7Fh
        jnz	short loc_1DFE
        retn
; ---------------------------------------------------------------------------

loc_1DFE:
        inc	[byte ptr DIRECTION]
        retn
; ---------------------------------------------------------------------------
        mov	ah, [DIRECTION]
        cmp	ah, 81h
        jnz	short loc_1E0B
        retn
; ---------------------------------------------------------------------------

loc_1E0B:
        dec	[byte ptr DIRECTION]
        retn

; =============== S U B	R O U T	I N E =======================================


proc		sub_1E29 near

        call	sub_1E64
        mov	cl, [DIRECTION]
        mov	bl, [X_COORD2]
        mov	bh, [X_COORD]

        call	cbwProcCX
        add	bx, cx

        mov	[X_COORD2], bl
        mov	[X_COORD], bh
        retn
endp		sub_1E29

; =============== S U B	R O U T	I N E =======================================
; ?  collision detect on down ?
; fall
proc		sub_1E64 near

        mov	cl, [DIRECTION]
        mov	bx, [X_RESERVE]
        call	cbwProcCX
        add	bx, cx
        mov	[X_COORD2], bx
        mov	cl, [si+14h]
        call	cbwProcCX
        mov	bx, [Y_RESERVE]
        add	bx, cx
        mov	[Y_COORD2], bx
        retn
endp		sub_1E64


; =============== S U B	R O U T	I N E =======================================

proc		cbwProcCX near
        xchg	ax, cx
        cbw
        xchg	ax, cx
        retn
endp		cbwProcCX

; =============== S U B	R O U T	I N E =======================================
;		objects queue
proc		sub_3641 near
; si = DE46 by default
        push	si
        mov	di, offset workBufAddr

loc_3645:
        call	getSIworkbuf
        jz	short loop1
        test	[byte ptr si], 4
        jz	short loc_365E

; this code portion not work at all
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
        call	getSIworkbuf
        jz	short loc_367F
        test	[byte ptr si], 4
        jnz	short loop1
        test	[byte ptr si+1], 1
        jnz	short loc_3676
        call	sub_383A

loc_3676:
        and	[byte ptr si+1], 0FEh ; remove bit 1
        and	[byte ptr si], 0BFh   ; remove bit 7
        jmp	short loop1
; ---------------------------------------------------------------------------

loc_367F:
        pop	si
        mov	[LOCK_STATUS1], 1
        retn
endp		sub_3641

; =============== S U B	R O U T	I N E =======================================
; // sub_3686;
; // DI is pointer to object workbuf
; if [di] == [di+1] // (0?)
;    ( di = workbuf ; return 0; )
;   else ( si = [di]; di+=2; return 1; )

proc		getSIworkbuf near

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
endp		getSIworkbuf

; =============== S U B	R O U T	I N E =======================================
; KEYBOARD?
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

proc		test7D11__ near
        test	[byte_7D11], 80h
        retn
endp		test7D11__

; =============== S U B	R O U T	I N E =======================================
INCLUDE	"LSTONREC.ASM" ; encoded procedures
; =============== S U B	R O U T	I N E =======================================


ends		_03C8
end start
