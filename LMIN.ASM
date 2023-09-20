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
        ;mov	si, offset GAME_DATA_BUF	; clear	temp buffer
        ;mov	[word ptr si], 0
        ;mov	di, offset GAME_DATA_BUF + 1
        ;mov	cx, 8F3h
        ;cld
        ;rep movsb

        call	setVideoMode
;        call	resetLives
        ;call	isFirePressed

startScreen:
        mov	sp, [cs:dwSTACK]
        ;call	clearGameData
        ;call	updateObjShadowTiles

        call	setInterrupts__

        ;call	playMusic
        ;call	clearProvisionStates

        mov	ah, 20h 			; SET START SCREEN
        mov	[locationNum], ah

        call	resetLives

        ;call	setDemoParam__

;        call	paintScreen2__ ;

       ;call paintBottomPanel
       ;call	checkRaft

        call	PrepareLocation__

        ;call	locationRoutine

        call	paintLocation__

        mov	ah, 0
        ;mov	[byte ptr cs:demo1Counter], ah ; reset Stanley dance count :)

playStartDance:

        call	mainCycle

        retn

endp		start

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
;
;push	di
;mov	di, [locDscAddr]
;mov	dx, 6
;add	di, dx

; load hero data from location routine?

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
; sub_DFA    something with weapon coord ( pole )
; DX = X coords
; BX = Y coords
proc		sub_DFA	near

        call	clear26Bytes
        mov	[si+7],	ch
        mov	[si+8],	cl
        mov	[X_RESERVE],	dl
        mov	[X_RESERVE+1],	dh
        mov	[Y_RESERVE],	bl
        mov	[Y_RESERVE+1],	bh
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
        mov	[X_COORD],  dh
        mov	[Y_COORD2], bl
        mov	[Y_COORD],  bh
        retn

endp		saveXY

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
        mov	cl, [STRENGHT_CNT]
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

; ==========================================
; DEBUG
; debug test proc
testproc:
push ax
push dx
mov ah,09
mov dx,offset teststr
int 21h
jmp more
teststr:
db "TEST $"
more:
pop dx
pop ax
ret

; =============== S U B	R O U T	I N E =======================================
;		objects queue
proc		sub_3641 near
; si = DE46 by default
        push	si
        mov	di, offset workBufAddr

loc_3645:
        call	sub_3686
        jz	short loop1
        test	[byte ptr si], 4

        jmp	short loc_365E
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

db 90,90,1

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

nop
nop
nop

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
        mov	ch, [byte ptr word_DE3F+1] ; DE40
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

nop
nop

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
    INCLUDE "LMINREC.ASM"
    ;INCLUDE "LSTONREC.ASM"
; =============== S U B	R O U T	I N E =======================================
        ends		_03C8
        end start

