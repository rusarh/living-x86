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

proc		setNextLoc	near
        call	nextLocProc
endp		setNextLoc	;

; =============== S U B	R O U T	I N E =======================================

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


; =============== S U B	R O U T	I N E =======================================

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


proc		addLive__ near
        mov	ah, [pLIVE_COUNT]
        cmp	ah, 7
        jnz	loc_2484
        retn
; ---------------------------------------------------------------------------

loc_2484:
        inc	ah
        mov	[pLIVE_COUNT], ah
        mov	cl, 2Fh
        mov	ch, 30h
        mov	[word_DDD8], cx
        jmp	paintHat__
endp		addLive__

; =============== S U B	R O U T	I N E =======================================

proc		clearBuf	near

        call	clearWorkbuf
        mov	bx, 0
        mov	[SCORE_COUNT], bx ; clear scores

endp		clearBuf	;

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
; ===========================================================================
; ---------------------------------------------------------------------------

loc_A26:
        mov	ah, 7
        call	getObjPtr

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

loc_A66:				; CODE XREF: _03C8:0A62j
        mov	[si+2],	cl
        mov	[byte ptr si+20h], 0Fh
        retn

; =============== S U B	R O U T	I N E =======================================

loc_B38:
        and	[byte ptr OBJ_STATUS], 0FDh
        call	checkRaft
        call	updateObjShadowTiles
        mov	si, offset WORK_BUF
        or	[byte ptr si], 40h
        call	copy8bytesUp
        ;call	sub_E82 ; // TODO
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
        cmp	ah, 3Ch ; DAVID LOCATION (FINAL)
        jnz	short loc_B7F

loc_B79:				; CODE XREF: sub_A6E+104j
        mov	bx, offset WORK_BUF
        mov	[byte ptr bx], 0

loc_B7F:				; CODE XREF: sub_A6E+109j
        jmp	loc_8A3

; =============== S U B	R O U T	I N E =======================================

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

loc_E46:				; CODE XREF: sub_E31+Bj
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
        test	[byte ptr BLOCK_STATUS], 80h
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
        jz	short copy5BytesTo
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

copy5BytesTo:
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
        jmp	getRespawnCoord
endp		sub_E82

; =============== S U B	R O U T	I N E =======================================
proc		copy5BytesFrom	near
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
endp		copy5BytesFrom

; =============== S U B	R O U T	I N E =======================================

proc		sub_F0C	near
        mov	ah, [byte_DE54]
        sub	ah, [Y_COORD]
        jb	short loc_F16
        retn
; ---------------------------------------------------------------------------

loc_F16:				; CODE XREF: sub_F0C+7j
        neg	ah
        retn
endp		sub_F0C

; =============== S U B	R O U T	I N E =======================================


proc		sub_F19	near		; CODE XREF: sub_1FB4p
                    ; sub_1FDA:loc_1FE3p _03C8:207Cp
        mov	ah, [byte_DE52]
        sub	ah, [X_COORD]
        jb	short loc_F23
        retn
; ---------------------------------------------------------------------------

loc_F23:				; CODE XREF: sub_F19+7j
        neg	ah
        retn
endp		sub_F19

; =============== S U B	R O U T	I N E =======================================

loc_F26:

proc		sub_F26	near
        or	ah, ah
        mov	di, offset WORK_BUF
        test	[byte ptr di], 80h
        jnz	short loc_F31
        retn
; ---------------------------------------------------------------------------

loc_F31:
        mov	ah, [di+24h] ;check block status
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

loc_F7C:				; CODE XREF: sub_F3C+3Dj
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

loc_F8D:				; CODE XREF: sub_F3C+4Ej
        mov	[byte ptr di+0Fh], 6
        or	ah, ah
        retn
; ---------------------------------------------------------------------------

loc_F94:				; CODE XREF: sub_F3C+46j
        mov	ch, 14h
        mov	cl, 14h
        jmp	short loc_FAB
; ---------------------------------------------------------------------------

loc_F9A:				; CODE XREF: sub_1F40+16p
        mov	di, offset loc_DE96
        or	ah, ah
        test	[byte ptr di], 80h
        jnz	short loc_FA5
        retn
; ---------------------------------------------------------------------------

loc_FA5:				; CODE XREF: sub_F3C+66j
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
; ---------------------------------------------------------------------------

loc_FD7:				; CODE XREF: sub_F3C+98j
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
; ---------------------------------------------------------------------------
; =============== S U B	R O U T	I N E =======================================

proc		sub_1002 near		; CODE XREF: birdProc+Fp
        call	getRandom
        and	ah, 1Fh
        or	ah, 1
        mov	dh, 8
        test	ah, 10h
        jnz	short loc_1014
        mov	dh, 4

loc_1014:				; CODE XREF: sub_1002+Ej
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

loc_1056:				; CODE XREF: birdProc:loc_1051j
        call	checkGround
        test	[byte ptr OBJ_STATUS], 40h
        jnz	short loc_1060
        retn
; ---------------------------------------------------------------------------

loc_1060:				; CODE XREF: birdProc+42j
        test	[byte ptr si+2], 1
        jz	short loc_1067
        retn
; ---------------------------------------------------------------------------

loc_1067:				; CODE XREF: birdProc+49j
        and	[byte ptr si+2], 0FDh
        or	[byte ptr si+2], 1
        jmp	copy8bytesDown
endp		birdProc

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
        or	[byte ptr BLOCK_STATUS], 2
        mov	[byte ptr OBJ_STATUS], 0
        call	setWeaponStat
        mov	bx, offset byte_DDB3
        or	[byte ptr bx], 8
        pop	si
        retn
endp		stanleyDied

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

bumerangProc:

        call	sub_1D61
        mov	ah, [X_COORD]
        cmp	ah, MAX_X_SPR
        jnb	short loc_1178
        call	checkGround
        mov	ah, [BLOCK_STATUS]
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

; ===========================================================================

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
        or	ah, [BLOCK_STATUS]
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
        mov	ah, [BLOCK_STATUS]
        and	ah, 0F0h
        jnz	short loc_11FF
        test	[byte ptr OBJ_STATUS], 40h
        jnz	short loc_11F5
        retn
; ---------------------------------------------------------------------------
loc_11F5:
        mov	[byte ptr OBJ_NUM], 6
        mov	bx, offset bombSound
        jmp	playSound
; ---------------------------------------------------------------------------

loc_11FF:
        or	[byte ptr si], 10h
        jmp	copy8bytesDown
;==========================================================

explosionProc:

        mov	bl, 10h
        mov	dl, 16h
        call	sub_F26
        jnb	short loc_1212
        pop	bx
        jmp	stanleyDied
; --------------------

loc_1212:
        mov	cx, 300h
        mov	dl, 3
        call	checkFrames
        jb	short loc_121D
        retn
; ----------

loc_121D:
        or	ah, ah
        jnz	short loc_1222
        retn
; -----------

loc_1222:
        or	[byte ptr si], 10h
        retn

;=========================================================

score100Proc:

        mov	cx, [word_DDF0]
        mov	dl, 0Ah
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

scoreHelperData:
        db 64h, 0, 0FAh, 0, 0F4h, 1, 10h, 8
        db 4, 2, 10h, 40h, 4, 10h, 0, 40h, 3, 0, 10h, 2, 40h, 1
        db 88h,	22h, 0,	40h
;=========================================================

score250Proc:

        mov	dl, 3
        mov	cx, 300h
        test	[byte ptr si+2], 8
        jnz	short loc_13BA
        mov	cx, 704h

loc_13BA:
        call	birdProc
        mov	ah, [BLOCK_STATUS]
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
        call	saveXY
        mov	ah, 9
        mov	[si+2],	ah

loc_return:

        retn

;=========================================================

loc_1436:
        and	[byte ptr bx], 0DFh
        call	getObjCoord
        inc	bh
        inc	bh
        push	si
        mov	si, offset WORK_BUF
        call	saveXY
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

loc_1653:
        mov	[byte ptr FRAME_PAUSE], 8
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

loc_1466:				; CODE XREF: _03C8:140Ej
        mov	ch, 1
        mov	cl, 1
        jmp	short loc_148B
; ---------------------------------------------------------------------------

loc_146C:				; CODE XREF: _03C8:13CDj
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

;=========================================================
; START	OF FUNCTION CHUNK FOR sub_1FA6

loc_148B:
        mov	[word_DDF0], cx
        mov	[byte ptr OBJ_NUM], 5
        mov	dl, 0Ah
        call	checkFrames
        mov	bx, offset tilidamSound
        jmp	playSound

; END OF FUNCTION CHUNK	FOR sub_1FA6
;=========================================================

booblesProc:

        mov	cl, 0
        mov	ch, 3
        mov	dl, 4
        call	checkFrames
        call	getStanleyCoord
        inc	dh
        jmp	saveXY
;=========================================================
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
; ---------------------------------------------------------------------------

loc_1527:				; CODE XREF: _03C8:1516j _03C8:151Ej
        mov	ah, [raftTimeCycle]
        inc	ah
        mov	[raftTimeCycle], ah
        cmp	ah, 6
        jz	short loc_1537
        retn
; ---------------------------------------------------------------------------

loc_1537:				; CODE XREF: _03C8:1534j
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
; ---------------------------------------------------------------------------

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
; ---------------------------------------------------------------------------

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
; ---------------------------------------------------------------------------

loc_15CB:
        mov	ah, 3
        mov	[raftStatus], ah
        retn
; =============== S U B	R O U T	I N E =======================================
RAFT_SPR:
        db 0DEh, 8 dup(0D9h),	84h

proc		raftProc2 near

        mov	di, offset RAFT_SPR
        mov	cx, [RAFT_COORD]

loc_15FB:				; CODE XREF: raftProc2+24j
        mov	ah, [di]
        or	ah, ah
        jnz	short loc_1602
        retn
; ---------------------------------------------------------------------------

loc_1602:				; CODE XREF: raftProc2+Bj
        push	cx
        mov	ah, cl
        cmp	ah, 28h
        jnb	short loc_1614
        mov	ah, [di]
        call	setSpriteAtAddr
        mov	ah, [di]
        call	writeSprite2Buf2__

loc_1614:				; CODE XREF: raftProc2+14j
        inc	di
        pop	cx
        inc	cl
        jmp	short loc_15FB
endp		raftProc2
;=============================================================================
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
;============================================================================

loc_166D:

        test	[byte ptr OBJ_STATUS], 80h
        jnz	short loc_16C1

        mov	bl, 0Fh
        mov	dl, 16h
        call	sub_F26
        jnb	short loc_168F

        mov	bx, offset byte_DDB3
        or	[byte ptr bx], 20h
        mov	[byte ptr si+2], 4Bh
        mov	[byte ptr OBJ_STATUS], 0FFh
        push	si
        call	setWeaponStat
        pop	si

loc_168F:
        test	[byte ptr BLOCK_STATUS], 1
        jnz	short loc_16B0
        mov	cx, 100h
        call	sub_F19
        jnb	short loc_16A0
        mov	cx, 403h

loc_16A0:
        or	ah, ah
        jnz	short loc_16AA
        or	[byte ptr BLOCK_STATUS], 1
        jmp	short loc_16B0
; ---------------------------------------------------------------------------

loc_16AA:
        mov	dl, 7
        call	checkFrames
        retn
; ---------------------------------------------------------------------------

loc_16B0:
        mov	ch, 2
        mov	cl, 2
        mov	dl, 28h
        call	checkFrames
        jb	short loc_16BC
        retn
; ---------------------------------------------------------------------------

loc_16BC:
        and	[byte ptr BLOCK_STATUS], 0FEh
        retn

;=========================================================

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
        mov	[si+13h], ah
        call	saveXY
        pop	si
        dec	[byte ptr si+2]
        jz	short loc_16E9
        jmp	short loc_16AA
; ---------------------------------------------------------------------------

loc_16E9:
        mov	[byte ptr OBJ_STATUS], 0
        pop	bx
        jmp	respawnStanley

;=========================================================
switchProc:

        test	[byte ptr BLOCK_STATUS], 80h ; check current switch status
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
        or	[byte ptr BLOCK_STATUS], 80h ; set status
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
        mov	ah, [BLOCK_STATUS]
        and	ah, 0F0h
        jnz	short loc_1745
        retn
; ---------------------------------------------------------------------------

loc_1745:
        or	[byte ptr si], 10h
        jmp	copy8bytesDown

;=========================================================
loc_174B:

        call	sub_2295
        jnz	short loc_1751
        retn

;=========================================================

loc_1751:
        or	[byte ptr si], 10h
        jmp	copy8bytesDown

;=========================================================

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
        test	ah, 40h
        jnz	short loc_1764
        retn
;=========================================================

loc_1783:
        mov	cl, 0
        mov	ch, 1
        mov	dl, 8
        jmp	setFrameNum

;=========================================================

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

;=========================================================

loc_17BC:				; CODE XREF: _03C8:179Dj
        inc	[byte ptr Y_COORD]

loc_17BF:				; CODE XREF: _03C8:17B4j _03C8:17BAj
        mov	cx, 100h
        mov	dl, 0
        call	setFrameNum
        call	checkGround
        mov	ah, [BLOCK_STATUS]
        and	ah, 0F0h
        jnz	short loc_17D3
        retn
;=========================================================

loc_17D3:				; CODE XREF: _03C8:17D0j
        mov	bx, offset byte_DDB4
        dec	[byte ptr bx]
        or	[byte ptr si], 10h
        retn

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

loc_17EE:				; CODE XREF: _03C8:17EBj
        or	ah, ah
        jnz	short loc_17F3
        retn
; ---------------------------------------------------------------------------

loc_17F3:				; CODE XREF: _03C8:17F0j
        mov	[FRAME_NUM], ah
        or	[byte ptr si+2], 80h

loc_17FA:				; CODE XREF: _03C8:17E0j
        mov	bl, 3
        mov	dl, 3
        call	sub_F26
        jnb	short loc_1807
        pop	bx
        jmp	stanleyDied
; ---------------------------------------------------------------------------

loc_1807:				; CODE XREF: _03C8:1801j
        call	sub_1E29
        call	checkGround
        mov	ah, [BLOCK_STATUS]
        and	ah, 0B0h
        jnz	short loc_1816
        retn
; ---------------------------------------------------------------------------

loc_1816:				; CODE XREF: _03C8:1813j
        or	[byte ptr si], 10h
        retn
; ---------------------------------------------------------------------------
loc_181A:
        test	[byte ptr BLOCK_STATUS], 80h
        jz	short loc_1829
        mov	[byte ptr si+0Dh], 0
        mov	[byte ptr si+0Bh], 0
        retn
; ---------------------------------------------------------------------------

loc_1829:				; CODE XREF: _03C8:181Ej
        mov	ah, [si+0Eh]
        or	ah, ah
        mov	cl, 0
        jz	short loc_1834
        mov	cl, 0C0h

loc_1834:				; CODE XREF: _03C8:1830j
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
; ---------------------------------------------------------------------------

loc_184F:
        or	[byte ptr BLOCK_STATUS], 80h
        retn
; ---------------------------------------------------------------------------
checkPit:
        mov	ah, [footIndex]
        cmp	ah, 0CAh
        jnb	short loc_185E
        retn
; ---------------------------------------------------------------------------

loc_185E:
        cmp	ah, 0CDh
        jb	short fellToPit
        retn
; ---------------------------------------------------------------------------

fellToPit:
        call	copy5BytesFrom
        call	getRandom

        mov	dl, 37h ; 		CAVE1
        test	ah, 1
        jz	short goToLoc

        mov	dl, 3Ah	;		CAVE2

goToLoc:

        mov	ah, dl
        mov	[locationNum], ah
        call	nextLocProc
        call	sub_E82
        retn
; ---------------------------------------------------------------------------

checkWell1:
        mov	ah, [footIndex]
        cmp	ah, 0F5h
        jnb	short loc_188A
        retn

; ---------------------------------------------------------------------------

loc_188A:
        cmp	ah, 0F8h
        jb	short loc_1890
        retn
; ---------------------------------------------------------------------------
loc_1890:
        mov	dl, 2Ch
        jmp	short goToLoc
; ---------------------------------------------------------------------------
checkWell2:
        mov	ah, [footIndex]
        cmp	ah, 0F5h
        jnb	short loc_189E
        retn
; ---------------------------------------------------------------------------
loc_189E:
        cmp	ah, 0F8h
        jb	short loc_18A4
        retn
; ---------------------------------------------------------------------------
loc_18A4:
        mov	dl, 35h
        jmp	short goToLoc
; ---------------------------------------------------------------------------
checkPaling:
        mov	ah, [footIndex]
        cmp	ah, 0F9h
        jnb	short loc_18B2
        retn
; ---------------------------------------------------------------------------

loc_18B2:
        cmp	ah, 0FBh
        jnb	short locret_18BA
        jmp	stanleyDied
; ---------------------------------------------------------------------------
locret_18BA:
        retn
; ---------------------------------------------------------------------------
;== ROOM 23 ===============================
checkFire:

        mov	ah, [footIndex]
        cmp	ah, 8Bh
        jnb	short loc_18C5
        retn
; ---------------------------------------------------------------------------

loc_18C5:
        cmp	ah, 8Eh
        jnb	short locret_18CD
        jmp	stanleyDied
; ---------------------------------------------------------------------------

locret_18CD:
        retn
; ---------------------------------------------------------------------------
; == ROOM 1D ========================================

loc_18CE:
        mov	di, offset loc_80A4
        jmp	short loc_18E0
loc_80A4:
        db 0, 0Bh, 0Fh, 13h, 17h, 1Bh, 23h

; == ROOM 1E ========================================
loc_18D3:
        mov	di, offset loc_80AB
        jmp	short loc_18E0
loc_80AB:
        db 0FFh, 4, 8, 0Ch, 10h, 14h, 18h

; == ROOM 1F ========================================
loc_18D8:
        mov	di, offset loc_80B2
        jmp	short loc_18E0
loc_80B2:
        db 0FFh, 0Fh, 13h, 17h, 1Bh, 1Fh, 23h

; == ROOM 20 ========================================
loc_18DD:
        mov	di, offset loc_80B9

loc_18E0:
        mov	ah, [byte_DDAF]
        cmp	ah, 3
        jb	short checkSlab
        retn
loc_80B9:
        db 0FFh, 8, 0Ch, 10h,	14h, 18h, 1Ch, 20h, 24h, 0FFh

;============================================================================
; ---------------------------------------------------------------------------

checkSlab:				; CODE XREF: _03C8:18E7j
        mov	ah, [footIndex]
        cmp	ah, 0C0h
        jnb	short loc_18F4
        retn
; ---------------------------------------------------------------------------

loc_18F4:				; CODE XREF: _03C8:18F1j
        cmp	ah, 0C2h
        jb	short loc_18FA
        retn
; ---------------------------------------------------------------------------

loc_18FA:				; CODE XREF: _03C8:18F7j
        mov	ah, 1
        mov	[byte ptr word_DDD8], ah
        mov	ah, 22h
        mov	[byte ptr word_DDD8+1],	ah
        mov	si, offset WORK_BUF
        mov	ah, [X_COORD]
        sub	ah, 6
        jnb	short loc_1913
        xor	ah, ah

loc_1913:				; CODE XREF: _03C8:190Fj _03C8:191Cj
        inc	di
        test	[byte ptr di], 80h
        jz	short loc_191A
        retn
; ---------------------------------------------------------------------------
loc_191A:
        cmp	ah, [di]
        jnb	short loc_1913

loc_191E:
        test	[byte ptr di], 80h
        jz	short loc_1924
        retn
; ---------------------------------------------------------------------------

loc_1924:
        mov	ah, [byte_DDAF]
        cmp	ah, 3
        jnz	short loc_192E
        retn
; ---------------------------------------------------------------------------

loc_192E:
        call	sub_E31
        jnb	short loc_1934
        retn
; ---------------------------------------------------------------------------

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

;======================================================================

godnessRoomProc:

        mov	bx, offset byte_DDB3
        test	[byte ptr bx], 2
        jnz	loc_1A9D
        or	[byte ptr bx], 2
        mov	ah, [stonesFound]
        mov	[broughtStones ], ah
        or	ah, ah
        jz	loc_1AEB
        jmp	playMusic

; ---------------------------------------------------------------------------

trolleyRunProc:
        mov	ah, 18h ; trolley obj num
        call	getObjPtr
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

; =============== S U B	R O U T	I N E =======================================

loc_19A2:
        mov	ah, 19h ;  dust smoke
        call	getObjPtr
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

; =============== S U B	R O U T	I N E =======================================

loc_19C9:
        mov	ah, 21h
        call	getObjPtr
        jb	short loc_19D1
        retn

; =============== S U B	R O U T	I N E =======================================

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


proc		sub_19F0 near		; CODE XREF: _03C8:19C0p _03C8:19E7p
                    ; _03C8:1A38p _03C8:1A4Ep
        mov	[word_DDD8], cx
        call	sub_E31
        jnb	short loc_19FA
        retn
; ---------------------------------------------------------------------------

loc_19FA:				; CODE XREF: sub_19F0+7j
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

;============================================

loc_1A2E:				; CODE XREF: _03C8:1A2Bj
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

loc_1A4A:				; CODE XREF: _03C8:1A47j
        mov	ch, 1
        mov	cl, 24h
        call	sub_19F0
        mov	[byte ptr si+13h], 81h
        mov	bx, offset byte_DDB4
        inc	[byte ptr bx]
        retn

;============================================

loc_1A5B:
        mov	ah, 0Ah
        call	getObjPtr
        jnb	short loc_1A63
        retn
; --------------------------------------------

loc_1A63:
        mov	ah, [di+10h]
        cmp	ah, 2
        jz	short locret_1A6E
        jmp	loc_1CA1
; --------------------------------------------

locret_1A6E:
        retn

;============================================

loc_1A6F:
        mov	ah, 0Ah
        call	getObjPtr
        jnb	short loc_1A77
        retn

; ---------------------------------------------------------------------------

loc_1A77:				; CODE XREF: _03C8:1A74j
        mov	ah, [di+10h]
        cmp	ah, 2
        jz	short locret_1A82
        jmp	loc_1CB8
; ---------------------------------------------------------------------------

locret_1A82:				; CODE XREF: _03C8:1A7Dj
        retn
;============================================

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


; ====================================================

loc_1AEB:				; CODE XREF: _03C8:1A98j _03C8:1AA3j
        mov	ah, [byte_DDC2]
        inc	ah
        mov	[byte_DDC2], ah
        jz	short loc_1AF8
        retn
; ---------------------------------------------------------------------------

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

; ====================================================

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
; ====================================================

loc_1B41:
        mov	ah, [CONTROL_MODE]
        cmp	ah, 0FFh
        jz	short loc_1B5F
        or	ah, ah
        jnz	short loc_1B4F
        retn
; ====================================================

loc_1B4F:
        xor	ah, ah
        mov	[CONTROL_MODE], ah
        mov	bx, offset FINAL_SCR_CMD
        mov	[demo1CmdAddr], bx
        jmp	playMusic

FINAL_SCR_CMD:
        db 7Eh, 0, 22h, 8, 3Fh, 0, 0FFh
; ====================================================

loc_1B5F:
        call	sub_1BA1
        call	sub_1B89
        call	sub_1BB9
        call	sub_1B89
        call	sub_1BCE
        call	sub_1B89
        call	sub_1B89
        call	paintScreen__
        jmp	startScreen

; =============== S U B	R O U T	I N E =======================================


proc		sub_1B7A near

        mov	bx, offset timerVar64
        test	[byte ptr bx], 40h
        jnz	short loc_1B83
        retn
; ---------------------------------------------------------------------------

loc_1B83:
        pushf
        and	[byte ptr bx], 0BFh
        popf
        retn
endp		sub_1B7A

; ====================================================
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

;=======================================

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
        call	getObjPtr
        mov	[byte ptr di+10h], 1
        mov	ah, 37h
        call	getObjPtr
        mov	[byte ptr di+10h], 1
        jmp	sub_3641
endp		sub_1BCE

;=========================================================
; ---------------------------------------------------------

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

loc_1D8F:				; CODE XREF: sub_1D61+24j
        cmp	ah, 2
        jnz	short loc_1D9C
        dec	[byte ptr si+13h]
        inc	[byte ptr si+14h]
        jmp	short loc_1DAF
; ---------------------------------------------------------------------------

loc_1D9C:				; CODE XREF: sub_1D61+31j
        cmp	ah, 3
        jnz	short loc_1DA9
        inc	[byte ptr si+13h]
        inc	[byte ptr si+14h]
        jmp	short loc_1DAF
; ---------------------------------------------------------------------------

loc_1DA9:				; CODE XREF: sub_1D61+3Ej
        inc	[byte ptr si+13h]
        dec	[byte ptr si+14h]

loc_1DAF:				; CODE XREF: sub_1D61+2Cj sub_1D61+39j
                    ; sub_1D61+46j
        mov	ah, [byte_DDEA]
        dec	ah
        mov	[byte_DDEA], ah
        jz	short loc_1DBE
        jmp	sub_1E41
; ---------------------------------------------------------------------------

loc_1DBE:				; CODE XREF: sub_1D61+58j
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


proc		sub_1E41 near		; CODE XREF: sub_1D61+5Aj sub_2295+13p
        call	sub_1E29
        add	bx, cx
        mov	[si+0Bh], bl
        mov	[X_COORD], bh
        retn
endp		sub_1E41

; ============================================================================
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
        test	[byte ptr si+13h], 80h
        jz	short loc_1E9E
        inc	bx
        inc	bx

loc_1E9E:
        inc	bx
        mov	cx, [bx]
        inc	bx
        jmp	setFrameNum
endp		sub_1E91

; =============== S U B	R O U T	I N E =======================================

; jmp

loc_1EA5:

        test	[byte ptr BLOCK_STATUS], 80h
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
        or	[byte ptr BLOCK_STATUS], 80h
        retn
; ---------------------------------------------------------------------------

loc_1EC7:
        call	sub_1EEE
        or	ah, ah
        jz	short loc_1ECF
        retn
; ---------------------------------------------------------------------------

loc_1ECF:
        and	[byte ptr si], 0DFh
        or	[byte ptr si], 40h
        call	sub_1ED9
        retn

 ;=============== S U B	R O U T	I N E =======================================

proc		sub_1ED9 near
        mov	[si+4],	cl
        mov	[X_COORD], cl
        mov	[si+6],	ch
        mov	[si+0Eh], ch
        and	[byte ptr BLOCK_STATUS], 7Fh
        mov	[byte ptr FRAME_NUM], 0
        retn
endp		sub_1ED9

 ;=============== S U B	R O U T	I N E =======================================

proc		sub_1EEE near
        call	getRandom
        and	ah, 1Fh
        cmp	ah, 14h
        jb	short loc_1EFA
        retn
; ---------------------------------------------------------------------------

loc_1EFA:
        mov	ch, ah
        call	getRandom
        and	ah, 3Fh
        cmp	ah, 25h
        jb	short loc_1F08
        retn
; ---------------------------------------------------------------------------

loc_1F08:
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


proc		sub_1F26 near		; CODE XREF: sub_2200+7p
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
endp		sub_1F3D ;


; =============== S U B	R O U T	I N E =======================================


proc		sub_1F40 near
        mov	[word_DDD4], bx
        mov	[word_DDD6], dx
        call	loc_F60
        jnb	short loc_1F4E
        retn
; ---------------------------------------------------------------------------

loc_1F4E:				; CODE XREF: sub_1F40+Bj
        mov	bx, [word_DDD4]
        mov	dx, [word_DDD6]
        call	loc_F9A
        jnb	short loc_1F5C
        retn
; ---------------------------------------------------------------------------

loc_1F5C:				; CODE XREF: sub_1F40+19j
        mov	bx, [word_DDD4]
        mov	dx, [word_DDD6]
        jmp	loc_F71
endp		sub_1F40
; ============================================================================

; jmp

loc_1F67:
        mov	ch, 4
        mov	cl, 0Ch
        mov	ah, 0Eh
        jmp	short loc_1F83
; ============================================================================
; jmp

loc_1F6F:
        mov	ch, 4
        mov	cl, 19h
        mov	ah, 0Eh
        jmp	short loc_1F83

; ============================================================================

loc_1F77:
        mov	ch, 5
        mov	cl, 0
        jmp	short loc_1F81
; ============================================================================
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

proc		sub_1FA6 near

        call	sub_1F3D
        jb	short loc_1FAC
        retn
; ---------------------------------------------------------------------------

loc_1FAC:
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


proc		sub_200E near		; CODE XREF: sub_1FB4+3p sub_1FC8+3p
        pushf
        mov	dl, ah
        add	dl, dl
        add	dl, ah
        popf
        retn
endp		sub_200E

; ============================================================================
; jmp

loc_2017:
        call	sub_1FA6

loc_201A:				; CODE XREF: _03C8:loc_2085j
                    ; _03C8:208Aj
        call	sub_1FB4
        call	sub_1FC8

loc_2020:				; CODE XREF: _03C8:loc_2095j
                    ; _03C8:loc_20CAj
        mov	ah, [byte_DDB3]
        and	ah, 18h
        jz	short loc_202A
        retn
; ---------------------------------------------------------------------------

loc_202A:				; CODE XREF: _03C8:2027j
        call	sub_1E91
        jb	short loc_2030
        retn
; ---------------------------------------------------------------------------

loc_2030:				; CODE XREF: _03C8:202Dj
        test	[byte ptr FRAME_NUM], 1
        jnz	short loc_2037
        retn
; ---------------------------------------------------------------------------

loc_2037:				; CODE XREF: _03C8:2034j
        call	getRandom
        cmp	ah, 0AAh
        jb	short loc_204A
        mov	ah, [si+2]
        cmp	ah, 2
        jnb	short loc_204A
        jmp	loc_20CD
; ---------------------------------------------------------------------------

loc_204A:

        and	[byte ptr FRAME_NUM], 0FEh
        retn
; ============================================================================
; ---------------------------------------------------------------------------
; jmp

loc_204F:

        call	sub_1FA6
        call	sub_1FDA
        jb	short loc_2058
        retn
; ---------------------------------------------------------------------------

loc_2058:
        mov	ah, [byte_DDB3]
        and	ah, 18h
        jz	short loc_2062
        retn
; ---------------------------------------------------------------------------

loc_2062:
        call	sub_1E91
        jb	short loc_2068
        retn
; ---------------------------------------------------------------------------

loc_2068:
        test	[byte ptr FRAME_NUM], 1
        jnz	short loc_206F
        retn
; ---------------------------------------------------------------------------

loc_206F:
        mov	ah, [si+2]
        cmp	ah, 2
        jnb	short loc_204A
        jmp	short loc_20CD

;==============================================================================
; jmp

loc_2079:
        call	sub_1FA6
        call	sub_F19
        cmp	ah, 4
        jnb	short loc_2085
        retn
; ---------------------------------------------------------------------------

loc_2085:

        jmp	short loc_201A
;==============================================================================
; jmp

loc_2087:

        call	sub_1FA6
        jmp	short loc_201A
;==============================================================================
; jmp
loc_208C:
        call	sub_1FA6
        call	sub_1FF1
        jb	short loc_2095
        retn

;==============================================================================
loc_2095:
        jmp	short loc_2020
;==============================================================================
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

loc_20C2:
        jmp	short loc_20CD
;==============================================================================
; jmp

loc_20C4:

        call	sub_2000
        jb	short loc_20CA
        retn
;=========================================================================

loc_20CA:
        jmp	loc_2020

;=========================================================================

loc_20CD:

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
; ============================================================================
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

        mov	ah, [BLOCK_STATUS]
        and	ah, 0F0h
        jnz	short loc_2168
        test	[byte ptr OBJ_STATUS], GROUND_BIT
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

; ============================================================================
; jmp

loc_2183:

        call	sub_1F12
        jnb	short loc_218E
        pop	bx
        call	stanleyDied
        jmp	short loc_2168
; ---------------------------------------------------------------------------

loc_218E:
        call	sub_1E91
        jb	short loc_2194
        retn
; ---------------------------------------------------------------------------

loc_2194:
        call	sub_1E29
        call	checkGround
        mov	ah, [BLOCK_STATUS]
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
        jmp	loc_214A
; ============================================================================
; jmp
loc_21B0:

        call	sub_2295
        jz	short locret_21B7
        jmp	short loc_2168
; ---------------------------------------------------------------------------

locret_21B7:
        retn

; ============================================================================
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
        mov	ah, [BLOCK_STATUS]
        and	ah, 0B0h
        jz	short locret_21DC
        jmp	short loc_2168
; ---------------------------------------------------------------------------

locret_21DC:
        retn
; ============================================================================
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
; ============================================================================

loc_21EB:

        call	sub_1F3D
        jnb	short loc_21F7
        mov	cl, 0
        mov	ch, 0
        jmp	loc_148B

; ============================================================================

loc_21F7:
        call	sub_1F12
        jnb	short sub_2200
        pop	bx
        jmp	stanleyDied

; =============== S U B	R O U T	I N E =======================================


proc		sub_2200 near		; CODE XREF: _03C8:21FAj _03C8:2265p
                    ; _03C8:loc_2378p
        mov	ah, [si+2]
        or	ah, ah
        jnz	short loc_222F
        call	sub_1F26
        mov	ah, [di]
        cmp	ah, 0FFh
        jnz	short loc_2217
        xor	ah, ah
        mov	[BLOCK_STATUS], ah
        retn
; ---------------------------------------------------------------------------

loc_2217:				; CODE XREF: sub_2200+Fj
        mov	[si+2],	ah
        mov	ah, [di+1]
        mov	[si+13h], ah
        mov	ah, [di+2]
        mov	[si+14h], ah
        mov	ah, [si+24h]
        add	ah, 3
        mov	[si+24h], ah

loc_222F:				; CODE XREF: sub_2200+5j
        call	sub_1E91
        jb	short loc_2235
        retn
; ---------------------------------------------------------------------------
loc_2235:				; CODE XREF: sub_2200+32j
        dec	[byte ptr si+2]
        jmp	sub_1E64
endp		sub_2200
; ============================================================================
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
        mov	ah, [BLOCK_STATUS]
        and	ah, 0F0h
        retn
endp		sub_2295 ;
; =============== S U B	R O U T	I N E =======================================
; jmp
loc_22C3:

        call	sub_1F3D
        jnb	short loc_22CF
        mov	ch, 1
        mov	cl, 1
        jmp	loc_148B
; ---------------------------------------------------------------------------

loc_22CF:				; CODE XREF: _03C8:22C6j
        mov	ah, [si+2]
        or	ah, ah
        jnz	short loc_22E9
        mov	ah, [byte_DDB3]
        and	ah, 18h
        jnz	short loc_22F2
        call	sub_1FB4
        call	sub_1FC8
        mov	[byte ptr si+2], 64h

loc_22E9:				; CODE XREF: _03C8:22D4j
        call	sub_2295
        jnz	short loc_22F2
        dec	[byte ptr si+2]
        retn
; ---------------------------------------------------------------------------

loc_22F2:				; CODE XREF: _03C8:22DDj _03C8:22ECj
        mov	ah, [si+13h]
        neg	ah
        mov	[si+13h], ah
        mov	ah, [si+14h]
        neg	ah
        mov	[si+14h], ah
        mov	[byte ptr si+2], 32h
        jmp	copy8bytesDown
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

loc_2309:
        mov	bx, offset byte_DDB3
        test	[byte ptr bx], 4
        jz	short loc_2312
        retn

; ============================================================================

loc_2312:
        mov	ah, 2Dh
        call	getObjPtr
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

;===========================================================================
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
        mov	ah, [BLOCK_STATUS]
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

;====================================

scoreProc:
        mov	bx, [SCORE_COUNT]
        mov	cx, 1715h
        mov	ah, 5
        jmp	paintScore__

;====================================

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
        test	[byte ptr DIRECTION], 80h
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

; =============== S U B	R O U T	I N E =======================================

proc		updateObjShadowTiles near

        mov	si, offset WORK_BUF

testAgain:
        test	[byte ptr si], 80h
        jz	short loc_35E7
        call	updateShadowTiles

loc_35E7:
        mov	dx, MAX_X_SPR
        add	si, dx
        cmp	[byte ptr si], 0FFh
        jnz	short testAgain
        retn
endp		updateObjShadowTiles

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
        mov	dx, MAX_X_SPR
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


proc		calcBX28 near
        mov	ax, MAX_X_SPR
        mul	ch
        mov	ch, 0
        add	ax, cx ; CX * 028H (40)
        mov	bx, offset LOCAT_BUF
        add	bx, ax
        retn
endp		calcBX28


; =============== S U B	R O U T	I N E =======================================
; demo proc

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

; =============== S U B	R O U T	I N E =======================================
