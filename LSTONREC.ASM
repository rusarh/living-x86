; encoded procedures


; =============== S U B	R O U T	I N E =======================================
; MAIN GAME CYCLE
; sub_254

proc		mainCycle	near

        mov	[SMALL_TICK], 0 ; reset timer
        call	demoProc ; Stanley move
        ;call	foodWaterProc ; food water
        call	weaponProc ; weapon
        ;call	locationObjProc ; raft ?
        call	stanleyProc ; Stanley proc
        ;call	execObjectsProc ; enemies proc !
        ;call	sub_A6E ; check point to next room
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

; =======================================================

proc		resetLives near	;
        mov	ah, 7
        mov	[pLIVE_COUNT], ah
        mov	bx, 0
        mov	[paintedWeapon], bx
endp		resetLives

; =======================================================
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

; =======================================================
setStanleyEat:
        mov	bx, offset stanleyEatLeftTiles
        test	[byte ptr DIRECTION], 80h
        jz	short loc_47D
        mov	bx, offset stanleyEatRightTiles

loc_47D:
        call	getFramesPar
        jmp	checkFrames

; =============== S U B	R O U T	I N E =======================================

proc		getStanleyCoord near

        push	si
        mov	si, offset WORK_BUF
        call	getObjCoord
        pop	si
        retn
endp		getStanleyCoord

; =============== S U B	R O U T	I N E =======================================
; 1DEA
;
; input:
; SI = object addr
;
; output:
; DX = X coord
; BX = Y coord

proc		getObjCoord near
        mov	dx, [X_COORD2]
        mov	bx, [Y_COORD2]
        test	[byte ptr DIRECTION], 80h
        retn
endp		getObjCoord


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
; -----------
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
; -----------

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
; -------------
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
; ----------

loc_3C44:
        mov	[word ptr di+2], 0
        jmp	short loc_3C3A
endp		addObject

;===================================
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

; =============== S U B	R O U T	I N E =======================================

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
; D95

proc		copy8bytesDown	near

; dx = si + 3
; bx = si + 11 (dec)
; cx = 8
;
; si = dx  = (si + 3)
; di = bx  = (si + 11)
; copy (si+1Bh, si+3, 8)
; si = si + 11
; di = si + 3
;
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
; 61F

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

loc_639:
        mov	[si+14h], ah
        retn
endp		getFramesPar


;============================================================================
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

; -----------------------

resurrectStanley:
        mov	ah, 3Ch
        mov	[byte ptr pFOOD], ah
        mov	[byte ptr pFOOD+1], ah

        mov	si, offset WORK_BUF

        mov	[byte ptr OBJ_STATUS], 0
        mov	[byte ptr BLOCK_STATUS], 0
        or	[byte ptr si], 20h ; set bit 6

        call	sub_3641

        mov	si, offset WORK_BUF
        and	[byte ptr si], 0DFh ; reset bit 6

        call	getRespawnCoord
        xor	ah, ah
        mov	[byte_DDB3], ah
        mov	[footIndex], ah

        retn ; // jmp	checkRaft ; was TODO


;===================================

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

; =============== S U B	R O U T	I N E =======================================

proc		stanleyFire	near

        test	[byte ptr OBJ_STATUS], 2
        jz	short loc_6E2
        retn
; ----------
loc_6E2:
        test	[byte ptr OBJ_STATUS], FIRE_BIT
        jz	short loc_6E9
        retn
; ----------

loc_6E9:
        mov	ah, [CONTROL_STAT]
        test	ah, 10h		; check for FIRE key
        jz	short setStanleyFire

        mov	ah, [byte ptr paintedWeapon]
        test	ah, 4
        jz	short checkStrenght__

        or	[byte ptr OBJ_STATUS], 2
        jmp	loc_748

endp		stanleyFire

;===================================

setStanleyFire:
        mov	ah, [byte ptr pSTRENGHT]
        or	ah, ah
        jnz	short strenghtNotZero
        retn

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
; -----------

addCount:
        inc	ah
        inc	ah
        mov	[byte ptr pSTRENGHT], ah
        jmp	paintStrenght__
endp		checkStrenght__

; ===============

proc		clearStrenght__	near
        xor	ah, ah
        mov	[byte ptr pSTRENGHT], ah
        jmp	paintStrenght__
endp		clearStrenght__

; ===============

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

; ===============

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

; ===============

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

; =============== S U B	R O U T	I N E =======================================
; 800

proc		checkRoomBorder	near
        mov	ah, [BLOCK_STATUS]
        and	ah, 0Fh
        mov	[BLOCK_STATUS], ah ; clear block status

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
; ------------------------------
stanleyBlockRight:
        or	[byte ptr BLOCK_STATUS], 20h
        retn
endp		checkRoomBorder

; ===============
proc		stanleyBlockDown	near
        or	[byte ptr BLOCK_STATUS], 80h
        retn
endp		stanleyBlockDown
; ===============
proc		stanleyBlockLeft	near
        or	[byte ptr BLOCK_STATUS], 10h
        retn
endp		stanleyBlockLeft
; ===============
proc		stanleyBlockUp	near
        or	[byte ptr BLOCK_STATUS], 40h
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
; -----------

loc_7C5:
        or	[byte ptr OBJ_STATUS], GROUND_BIT
        retn
endp		checkGround

; =============== S U B	R O U T	I N E =======================================

proc		getRespawnCoord	near

        mov	si, offset WORK_BUF
        mov	bx, offset loc_DDFA
        mov	ch, 4

loc_EF3:
        mov	ah, [bx]
        mov	[X_COORD2], ah
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

proc		getObjSize	near
        mov	bx, offset animObjSizes
        mov	dl, [OBJ_NUM]
        shl	dl, 1
        mov	dh, 0
        add	bx, dx
        mov	dh, [bx]
        inc	bx
        mov	dl, [bx]
        mov	bl, dh
        mov	bh, 0
        add	bx, bx
        add	bx, bx
        add	bx, bx
        add	bx, bx
        add	bx, bx
        mov	[objYsize], bx
        mov	bh, 0
        mov	bl, dl
        add	bx, bx
        add	bx, bx
        add	bx, bx
        add	bx, bx
        add	bx, bx
        mov	[objXsize], bx
        retn
endp		getObjSize

; =============== S U B	R O U T	I N E =======================================
; input:
; AH = obj num
;
; output:
; DI = obj buf ptr

proc		getObjPtr near

        push	cx
        push	dx
        mov	ch, 0Ch
        mov	dx, 28h
        mov	di, offset WORK_BUF

loc_107C:
        test	[byte ptr di], 80h
        jz	short loc_1086
        cmp	ah, [di+0Fh] ; OBJ_NUM
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
endp		getObjPtr

; =============== S U B	R O U T	I N E =======================================

proc		setswampPar near
        push	si
        mov	si, offset WORK_BUF
        or	[byte ptr BLOCK_STATUS], 1
        mov	[byte ptr OBJ_STATUS], 0
        call	setWeaponStat
        pop	si
        retn
endp		setswampPar

; =============== S U B	R O U T	I N E =======================================

swampProc:
        test	[byte ptr BLOCK_STATUS], 1
        jnz	short loc_3F8
        call	setswampPar
        mov	dl, 1
        test	[byte ptr DIRECTION], 80h
        jz	short loc_3E8
        mov	dl, 0FFh

loc_3E8:
        mov	ah, [X_COORD]
        add	ah, dl
        mov	[X_COORD], ah
        mov	[byte ptr si+0Bh], 0
        mov	[byte ptr si+2], 14h

loc_3F8:
        mov	bx, offset swampDieTiles
        call	getFramesPar
        call	checkFrames
        jb	short loc_404
        retn
; -------------------------

loc_404:
        dec	[byte ptr FRAME_PAUSE]
        jnz	short locret_40C
        jmp	respawnStanley
; -------------------------

locret_40C:
        retn
; =========================================

stanleyDrown:
        test	[byte ptr BLOCK_STATUS], 4
        jnz	short loc_432
        inc	[byte ptr Y_COORD]
        inc	[byte ptr Y_COORD]
        or	[byte ptr BLOCK_STATUS], 4
        ;call	sub_E31 // add objects ? TODO
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
        cmp	ah, 8Ah
        jz	short loc_456
        retn

loc_456:
        test	[byte ptr si+15h], 1
        jnz	short loc_45D
        retn

loc_45D:
        inc	[byte ptr Y_COORD]

        retn

loc_461:
        mov	ah, 8
        call	getObjPtr
        jnb	short loc_46B
        jmp	respawnStanley

loc_46B:
        or	[byte ptr di], 10h
        jmp	respawnStanley

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
        ;mov	di, offset locPointers // TODO
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
        ;call	sub_E82 ; // TODO
        jmp	short loc_1C42
; ---------------------------------------------------------------------------

loc_1C3A:
        ;call	sub_E31  ; // add objects ? TODO
        jb	short loc_1C42
        call	sub_DAF

loc_1C42:

        mov	dx, 8
        add	di, dx
        pop	cx
        dec	ch
        jnz	short loc_1C1C  ; go to next desc

setLocProcAddr:
        mov	[locProcAddr], di
        retn
endp		locationRoutine

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

;============================================================================
; demo proc
proc		demoProc	near

        mov	ah, [CONTROL_MODE]
        or	ah, ah
        jz	short loc_BC8
        call	checkControls__

        jmp	loc_250E

loc_BC8:
        mov	si, offset WORK_BUF
        mov	ah, [OBJ_STATUS]
        and	ah, 0FDh
        or	ah, [BLOCK_STATUS]
        and	ah, 0Fh
        jz	short loc_BDA
        retn

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
loc_BF5:
        test	ah, 80h
        jz	loc_C0C

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
; -------------------
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
; -------------

loc_C30:
        jmp	short setDemoAddr

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
; -----------

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

proc		getObjAddr near

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

;=======================================

proc		clearWorkbuf near	;
        mov	bx, offset WORK_BUF	; memset (WORK_BUF, 0, 480)
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
;=======================================
dwSTACK	dw 0F6h			;
;=======================================

; - VIDEO - SET	VIDEO MODE
proc	setVideoMode near	;
; AL = mode
        mov	ax, 4
        int	10h

        call	setPal0100__
        retn
endp		setVideoMode
;--------------------------------------------------
; - VIDEO - SET	COLOR PALETTE
proc	setPal0100__ near	;
        mov	bx, 100h
        mov	[cs:CURR_PALETTE],	bl
        mov	ax, 0B00h
        int	10h		; - VIDEO - SET	COLOR PALETTE
                    ; BH = 00h, BL = border	color
                    ; BH = 01h, BL = palette (0-3)
        retn
endp		setPal0100__
;---------------------------------------------------
setPal_0101__:				;
        mov	bx, 101h
        mov	[cs:CURR_PALETTE],	bl
        mov	ax, 0B00h
        int	10h		; - VIDEO - SET	COLOR PALETTE
                    ; BH = 00h, BL = border	color
                    ; BH = 01h, BL = palette (0-3)
        retn
;---------------------------------------------------

proc		paintScreen__ near	;
        call	paintScreen2__
        retn
endp		paintScreen__
;---------------------------------------------------
proc		paintScreen2__ near	;

        mov	bx, offset BOTTOM_SPRITES	; set BX = BOTTOM PANEL	SPRITE BUFFER ADDRESS
        call	paintBottomPanel__
        ;call	clearStrenght__
        ;call	setFood__
        ;jmp	short setWater__
endp		paintScreen2__
;---------------------------------------------------
proc		paintBottomPanel__ near	;
        mov	ah, [bx]	; ; get	sprite number from [bx]
        cmp	ah, 0FFh	; ; check the end of sprite buffer
        jnz	short loc_D35
        retn

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

; ---------------------------------------------------------------------------
loc_D35:
        or	ah, ah ; if (AH == 0) set sprite pos command
        jz	short setSpritePos ; if	AH=0 goto D45H
        push	bx
        mov	al, ah
        mov	ah, 0
        call	typeBuf2Sprite__
        pop	bx
        inc	bx
        jmp	short paintBottomPanel__
; --------------------------------------------------
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
        call	writeSpriteBuf2__
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

proc		isFirePressed near
        test	[FIRE_BUTTON], 80h ; IS SPACE PRESSED ?
        retn
endp		isFirePressed

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

;----------------------------

proc		writeSpriteBuf2__ near
        push	si		; ax = sprite number;
                    ; ch, cl  = sprite position
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


proc		paintXorSprite__ near

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

loc_338E:
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
        mov	ax, MAX_X_SPR
        mul	bl
        mov	dl, [si]
        mov	dh, 0
        add	ax, dx
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

        mov	ax, MAX_X_SPR
        add	di, ax ; increment Y coord on location (40 symbols)
        dec	ch ; dec Y
        jnz	short loc_3556 ; if Y > 0 set next sprite line (loc_3556)

        mov	dx, 4
        add	si, dx
        pop	cx

        dec	ch
        jnz	short loc_3537

        ;jmp	checkLocation__
        ;;;;;;;;;;;;
        ret

endp		PrepareLocation__


; =============== S U B	R O U T	I N E =======================================

proc		paintLocation__	near	;
        mov	di, offset LOCAT_BUF
        mov	si, offset LOCAT_BUF + 320H	;  320H
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
        cmp	bl, MAX_X_SPR ; 40  MAX X SPRITES COUNT
        jnz	short loc_3587
        mov	bl, 0
        inc	bh
        cmp	bh, MAX_Y_SPR	; 20  MAX Y SPRITES COUNT
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

locret_35CE:
        retn

setPaletteNumber:
        cmp	[cs:CURR_PALETTE],	1
        jnz	short locret_35DA
        jmp	setPal0100__

locret_35DA:
        retn
endp		checkLocationPalette
; ---------------------------------------------------------------------------
CURR_PALETTE	db 1
;-----------------------------------------------
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
                    ; 0: Tmr 2 gate	?? OR	03H=spkr ON
                    ; 1: Tmr 2 data	?  AND	0fcH=spkr OFF
                    ; 3: 1=read high switches
                    ; 4: 0=enable RAM parity checking
                    ; 5: 0=enable I/O channel check
                    ; 6: 0=hold keyboard clock low
                    ; 7: 0=enable kbrd
        mov	ah, al
        or	al, 80h
        out	61h, al		; PC/XT	PPI port B bits:
                    ; 0: Tmr 2 gate	?? OR	03H=spkr ON
                    ; 1: Tmr 2 data	?  AND	0fcH=spkr OFF
                    ; 3: 1=read high switches
                    ; 4: 0=enable RAM parity checking
                    ; 5: 0=enable I/O channel check
                    ; 6: 0=hold keyboard clock low
                    ; 7: 0=enable kbrd
        xchg	al, ah
        out	61h, al		; PC/XT	PPI port B bits:
                    ; 0: Tmr 2 gate	?? OR	03H=spkr ON
                    ; 1: Tmr 2 data	?  AND	0fcH=spkr OFF
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
;include "OBJPROC.ASM" ; TODO
;---------------------------------------------------
include "LOCMAP.inc"
;----------------------------------------------------------------------
include	"GRBANK1.inc"
;----------------------------------------------------------------------
include	"GRBANK2.inc"
;------------------------------------------------------------------------------
;include "LOCOBJ.inc"
;------------------------------------------------------------------------------
include	"BOTPNL.inc"
;---------------------------------------------------
;include "OBJSTAT.INC" ; TODO
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
;-----------------------------------------------------------
SMALL_TICK	db 7Ch	   ;
BIG_TICK	dw 97E2h   ;
;-----------------------------------------------------------
soundStatus	db 0
;---------------
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
;----------------
;INCLUDE	"DEMOCMD.INC" ; TODO

INCLUDE	"SOUND.ASM"
INCLUDE	"SOUNDDAT.inc"

INCLUDE "OBJGRAPH.INC"
INCLUDE "OBJFRDAT.INC"
INCLUDE "LOCOBJ.INC"
;INCLUDE "ROOMOBJ.INC" ; TODO
;-----------------------------------------------------------
START_SCR_CMD:
        db 0Ah, 8, 84h, 0Fh, 10h, 3Fh, 0, 0Ah
        db 4, 84h, 0Fh,	10h, 3Fh, 0, 0Fh, 8, 81h, 0Ah, 10h, 7Eh
        db 0, 0Fh, 4, 5, 8, 82h, 0Fh, 10h, 3Fh,	0, 83h,	0Fh, 10h
        db 3Fh,	0, 5, 4, 0FFh
;-----------------------------------------------------------

KEYBOARD_TABLE:

WEAP1_BUTTON	db 2			; '1'
WEAP2_BUTTON	db 3			; '2'
WEAP3_BUTTON	db 4			; '3'
WEAP4_BUTTON	db 5			; '4'
byte_7D0B	db 18h			; 'O'
byte_7D0C	db 19h			; ;P'
byte_7D0D	db 10h			; 'Q'
byte_7D0E	db 1Eh			; ;A'
FIRE_BUTTON	db 39h			; SPACE
BREAK_BUTTON	db 46h		; SCROLL LOCK
byte_7D11	db 1Ch			; Up Arrow
byte_7D12	db 12h,	13h, 1Fh ; E R S
DEMO_BUTTON	db 20h				; 'D'
byte_7D16	db 38h,	1Dh, 53h	; ALT CTRL DEL
byte_7D19	db 3Bh			; 'F1'
byte_7D1A	db 7Ah			; 'O'
byte_7D1B	db 79h			; 'P'
byte_7D1C	db 7Ch			; 'Q'
byte_7D1D	db 7Bh			; 'A'
byte_7D1E	db 77h			; SPACE
byte_7D1F	db 78h			; SPACE

;------------------------------------------------------
;GAME_DATA_BUF:
;
;CONTROL_MODE	db 1
;CONTROL_STAT	db 20h
;demoLockStat	db 0
; ---------------------------------------------------------------------------
demo1Counter	dw 0
byte_2634	db 0
byte_2635	db 14h
byte_2636	db 1
word_2637	dw 3239h
;-----------------------------------------------------------------------------

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
rightStartThrowTile:
        db 1
startJumpRightTiles:
        db 0, 2 dup(6), 0, 7Fh
loc_80CD:
        db 1, 4
rightFireTiles:
        db 7, 8, 0, 0
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
        db 14h, 1Ah, 1Bh, 2 dup(0)
rightStunnedTiles:
        db 4, 1Ch, 1Dh,	2 dup(0)
stanleyEatRightTiles:
        db 4, 1Eh, 1Fh, 2 dup(0)
        db 4, 20h
        db 21h,	0
blockTypes:
        db 0, 0, 28h, 50h, 0FFh, 3, 2Bh, 53h, 2 dup(0FFh)
        db 0, 1
        db 2, 0FFh
loc_812A:
        db 5 dup(0FFh)
loc_812F:
        db 5 dup(1)

;--------------------------------------------------------
INCLUDE	"VARDAT.inc"
;====================================================
