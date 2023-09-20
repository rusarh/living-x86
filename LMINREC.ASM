
; =============== S U B	R O U T	I N E =======================================
; MAIN GAME CYCLE
; sub_254

proc		mainCycle	near

        mov	[SMALL_TICK], 0 ; reset timer
        call	checkControls__ ; demoProc ; Stanley move -- not working without it
        ;call	foodWaterProc ; food water
        ;call	weaponProc ; weapon
        ;call	locationObjProc ; raft ?

        call	stanleyProc ; Stanley proc

        ;call	execObjectsProc ; enemies proc !
        ;call	sub_A6E ; check point to next room

        call	sub_3641 ; paint animation objects

        ;call	sub_CBC ; keyb check ?

loc_274:
        cmp	[SMALL_TICK], 3 ; WAIT FOR NEXT TICK
        jb	short loc_274

        mov	ah, [demoLockStat]
        or	ah, ah
        jz	short mainCycle
        retn
endp		mainCycle

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
        ;call	stanleyFire

        test	[byte ptr OBJ_STATUS], 2
        jz	short loc_2F6
        ;jmp	weaponUsed

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

;       CHECK KEYS

        mov	ah, [CONTROL_STAT] ; check for RIGHT key

        ;or ah,4  ; for auto test right

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
        mov	[byte ptr STRENGHT_CNT], 7Fh

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
        mov	ah, [STRENGHT_CNT]
        test	ah, 80h
        jz	short loc_3B2
        add	ah, 3
        mov	[STRENGHT_CNT], ah
        retn
; ----------
loc_3B2:
        mov	[byte ptr STRENGHT_CNT], 7Fh
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
        mov	[Y_COORD2], ah
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
        dec	[byte ptr JUMP_CNT]
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
        ;call	sub_939
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
        jz      stanleyDown
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
        retn ; jmp	playSound ; TODO

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
        mov	[byte ptr JUMP_CNT], 8
        dec	[byte ptr Y_COORD] ; jump on stay
        dec	[byte ptr Y_COORD] ; -'-'-'-
        mov	bx, offset jumpSound
        jmp	playSound
; ==============================================

; END OF FUNCTION CHUNK	FOR stanleyProc

; =============== S U B	R O U T	I N E =======================================
; moved from 5ХХ

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

; ---------------------------------------------------------------------------

loc_683:
        test	[byte ptr OBJ_STATUS], 40h
        jnz	short loc_690
        mov	[byte ptr STRENGHT_CNT], 7Fh
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
        mov	[byte ptr STRENGHT_CNT], 7Fh
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
        mov	dx, MAX_X_SPR
        mov	di, offset WORK_BUF

loc_107C:
        test	[byte ptr di], 80h
        jz	short loc_1086
        cmp	ah, [OBJ_NUM] ; OBJ_NUM
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


;============================================================================
proc		resetLives near	;
        mov	ah, 7
        mov	[pLIVE_COUNT], ah
        mov	bx, 0
        mov	[paintedWeapon], bx
endp		resetLives

; =======================================================
;  it's one procedure ^^^
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
;============================================================================


proc		isFirePressed near
        test	[FIRE_BUTTON], 80h ; IS SPACE PRESSED ?
        retn
endp		isFirePressed

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
        jmp	paintSprite
endp		writeSprite1Buf1__

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
        mov	bl, [Y_COORD2]
        add	bx, dx
        mov	dx, 1300h
        sbb	bx, dx
        jb	short loc_82A
        call	stanleyBlockUp

loc_82A:
        mov	bx, [X_COORD2]
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
loc_D35:
        or	ah, ah ; if (AH == 0) set sprite pos command
        jz	short setSpritePos ; if	AH=0 goto D45H
        push	bx
        mov	al, ah
        mov	ah, 0
        call	typeBuf2Sprite__
        pop	bx
        inc	bx
        jmp	paintBottomPanel__

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
        jmp	loc_86C
; ---------------------------------------------------------------------------

loc_88C:
        pop	bx
        mov	ah, [byte ptr word_DDD8]
        shl	ah, 1
        mov	[byte ptr word_DDD8], ah
        jnb	loc_86C
        retn
endp		checkBlockCollision

; ---------------------------------------------------------------------------

setSpritePos:
        inc	bx  ; byte code array = 0,x,y  where 0 is code for position indication
                    ; read sprite position
        mov	ah, [bx]
        inc	bx
        mov	[byte ptr pSPR_XY+1], ah
        mov	ah, [bx]
        mov	[byte ptr pSPR_XY], ah
        inc	bx
        jmp	paintBottomPanel__
endp		paintBottomPanel__

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

proc		getStanleyCoord near

        push	si
        mov	si, offset WORK_BUF
        call	getObjCoord
        pop	si
        retn
endp		getStanleyCoord

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
        mov	[STRENGHT_CNT], ah
        retn
endp		getFramesPar

;===================================
; 3BC

proc		checkJumpTiles	near

        mov	bx, offset rightJumpTiles
        test	[byte ptr DIRECTION], 80h
        jz	short loc_3C8
        mov	bx, offset leftJumpTiles

loc_3C8:
        test	[byte ptr STRENGHT_CNT], 80h
        jz	short loc_3CF
        dec	bx ; set falling tile

loc_3CF:
        mov	ah, [bx]
        mov	[FRAME_NUM], ah
        retn
endp		checkJumpTiles

; =============== S U B	R O U T	I N E =======================================

proc		setswampPar near
        push	si
        mov	si, offset WORK_BUF
        or	[byte ptr BLOCK_STATUS], 1
        mov	[byte ptr OBJ_STATUS], 0
        ;call	setWeaponStat
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
        mov	[byte ptr X_COORD2], 0
        mov	[byte ptr FRAME_PAUSE], 14h

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

; =======================================================
setStanleyEat:
        mov	bx, offset stanleyEatLeftTiles
        test	[byte ptr DIRECTION], 80h
        jz	short loc_47D
        mov	bx, offset stanleyEatRightTiles

loc_47D:
        call	getFramesPar
        jmp	checkFrames

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

;============================================================================
; START	OF FUNCTION CHUNK FOR stanleyProc

respawnStanley:
        ;call	hat__
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
;===========================================

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

        ;call	processSound ; sound

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
;CURR_PALETTE	db 1
;-----------------------------------------------
;-----------------------------------------------------------
SMALL_TICK	db 7Ch	   ;
BIG_TICK	dw 97E2h   ;
;-----------------------------------------------------------
soundStatus	db 0

;================
playSound:
        retn ; STUB

jumpSound:
smallJumpSound:
sound1:
loc_7F3B:
    db 0
; ======================================================

demo1Counter	dw 0
byte_2634	db 0
byte_2635	db 14h
byte_2636	db 1
word_2637	dw 3239h
; ---------------------------------------------------------------------------
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

; ======================================================
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

; ======================================================
CURR_PALETTE	db 1
; ======================================================
weaponBacklightX: db 1Bh, 1Eh, 21h, 24h
;=======================================
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
BREAK_BUTTON	db 46h		        ; SCROLL LOCK
byte_7D11	db 1Ch			; Up Arrow
byte_7D12	db 12h,	13h, 1Fh        ; E R S
DEMO_BUTTON	db 20h			; 'D'
byte_7D16	db 38h,	1Dh, 53h	; ALT CTRL DEL
byte_7D19	db 3Bh			; 'F1'
byte_7D1A	db 7Ah			; 'O'
byte_7D1B	db 79h			; 'P'
byte_7D1C	db 7Ch			; 'Q'
byte_7D1D	db 7Bh			; 'A'
byte_7D1E	db 77h			; SPACE
byte_7D1F	db 78h			; SPACE
; ======================================================

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
; ======================================================
include	"GRBANK1.inc"
include	"GRBANK2.inc"
include	"BOTPNL.inc"
INCLUDE "OBJGRAPH.INC"
INCLUDE "OBJFRDAT.INC"
INCLUDE "LOCOBJ.INC"
INCLUDE "LOCMAP.INC"
INCLUDE	"VARDAT.INC"
; ===========================================+===========
dwSTACK	dw 0F6h			;


