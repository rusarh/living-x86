#pragma option ia     //"$" and "asm" keywords not required.
#pragma option lst             // assembler listing
#pragma option w               // warnings on
#pragma option wf=warning.err
#pragma option s=16384          // stack
#pragma option x               // disable SPHINX C-- logo
#pragma option 3
#use8086

//#include "c--/OPEN_LIB/MEM.H"
#include "LSTONE.DEF"

dword memCpy(char* dst, char* src, dword count)
{
    char* rt = dst;
    while( count-- )
     {
            *dst = *src;
             dst++; src++;
     }
    return rt;
}

////////////////////////////

main ()
{
        push	cs
        sub	ax, ax
        push	ax
        mov CSWORD[#dwSTACK], sp   //CSWORD[#dwSTACK] = SP//
        mov	ax, cs
        add	ax, 0
        mov	es, ax
        //assume es:_03C8
        mov	ds, ax
        mov	ss, ax
        //assume ss:_03C8
        mov	si, #GAME_DATA_BUF	// clear	temp buffer
        mov	DSWORD[si], 0
        mov	di, #GAME_DATA_BUF + 1
        mov	cx, 8F3h
        cld
        rep movsb

        setVideoMode();
        resetLives();
        //call	isFirePressed

startScreen:

        mov	sp, CSWORD[#dwSTACK]

        //call	clearGameData
        //call	updateObjShadowTiles

        setInterrupts__();

        //call	playMusic
        //call	clearProvisionStates

        mov	ah, 06 			// SET START SCREEN
        mov	DSBYTE[#locationNum], ah

        resetLives();

        //call	setDemoParam__

        paintScreen2__(); //

       //call paintBottomPanel
       //call	checkRaft

        PrepareLocation__();

        //call	locationRoutine

        paintLocation__();

        mov	ah, 0
        //mov	CSBYTE[#demo1Counter], ah // reset Stanley dance count :)

playStartDance:

//        call	mainCycle

        mainCycle();
}

PrepareLocation2()
{

}

PrepareLocation__()
{
    // COPY CURRENT LOCATION TO UPPER
    //PrepareLocation2();

        DI = #LOCAT_BUF+0x320;
        SI = #LOCAT_BUF;
        CX = 0x190;
        CLD;
        REP MOVSW;

        // CLEAR CURRENT LOCATION
        SI = #LOCAT_BUF;
        DI = #LOCAT_BUF + 2;
        CX = 18Eh;
        BX = 0;
        DSWORD[SI] = BX;
        rep movsw


        // get new location address
        // addr = location number * 2 + LOCATIONS_OFFSET
        AL = DSBYTE[#locationNum];
        AH = 0;
        AX += AX;
        AX += #LOCATIONS_OFFSET;
        BX = AX;
        DX = DSWORD[BX];

        // map of location include objects with coord, not sprites//
        SI = #LOCATIONS_MAP;
        SI += DX;

// Looks as:  (OBJ.COUNT) // (OBJ1.X)// (OBJ1.Y)// (OBJ1.OFFSET)// (OBJ2.X)// (OBJ2.Y)// (OBJ2.OFFSET) ... etc.
        // get objects count
        CH = DSBYTE[SI];

        SI++;

loc_3537:

        // SI = X on loc
        // SI + 1 = Y on loc
        // SI + 2 = obj offset

        // get XY coordinate on location
        PUSH CX;

        BL = DSBYTE[SI+1];
        AX = MAX_X_SPR;
        MUL BL; // AX *= BL;
        DL = DSBYTE[SI];
        DH = 0;
        AX += DX;
        AX += #LOCAT_BUF;
        DI = AX;

        // set object offset in BX
        BX = DSWORD[SI+2];

        //// load to bx - compiler walkaround..
        PUSH AX;
        AX = BX;
        AX += #LOCATION_OBJECTS;
        BX = AX;
        POP AX;

        //////////
        // get object size
        // XY size in CX = [BX]
        // Looks as:  X, Y, SPRITE1, SPRITE2.. etc

        CX = DSWORD[BX];
        BX++;
        BX++;

loc_3556:
        PUSH CX;
        PUSH DI;

loc_3558:

        do {

            AL = DSBYTE[BX]; // get sprite number
            IF (AL != 0)
            {
                DSBYTE[DI] = AL;  // set sprite on location
            }

    //loc_3560:
            BX++; // next sprite on object
            DI++; // next sprite on location
            CL--;

        } while (CL != 0);

        //IF (CL != 0) // dec X
        //    GOTO loc_3558; // if X > 0 set next sprite (loc_3558)

        pop	di
        pop	cx

        mov	ax, MAX_X_SPR
        add	di, ax  // increment Y coord on location (40 symbols)
        dec	ch      // dec Y
        jnz	short loc_3556 // if Y > 0 set next sprite line (loc_3556)

        mov	dx, 4
        add	si, dx
        pop	cx

        dec	ch
        jnz	short loc_3537

        //jmp	checkLocation__
        ////////////////////////
        ret

        // endp		PrepareLocation__
}

//////////////////////

mainCycle()
{
    // =============== S U B	R O U T	I N E =======================================
    // MAIN GAME CYCLE
    // sub_254

    //mainCycle:

    do {

        mov	DSBYTE[#SMALL_TICK], 0 // reset timer

                checkControls__(); // demoProc // Stanley move -- not working without it

        //call	foodWaterProc // food water
        //call	weaponProc // weapon
        //call	locationObjProc // raft ?

        stanleyProc(); // Stanley proc

        //call	execObjectsProc // enemies proc !
        //call	sub_A6E // check point to next room

        call	sub_3641 // paint animation objects

                //call	sub_CBC // keyb check ?

                loc_274:
            cmp	DSBYTE[#SMALL_TICK], 3 // WAIT FOR NEXT TICK
            jb	short loc_274

            //        mov	ah, DSBYTE[#demoLockStat]
            //        or	ah, ah
    }   while (1);

        RETURN;
} //endp		mainCycle

    //=======================================
    // STANLEY PROC
    // 0x284

void stanleyProc()
{
        BX = #byte_DDB3;
        IF (DSBYTE[BX] & 2)
            RETURN;

loc_28D:
        IF (DSBYTE[BX] & 0x80)
            RETURN;

//endp		stanleyProc

// -----------------
//                ; 292
//                proc		setWeaponStat	near
//                        mov	si, offset weaponBuf
//                        test	[byte ptr si], 80h
//                        jnz	short loc_29B
//                        retn


loc_29F:
        SI = #WORK_BUF;
        IF (DSBYTE[BX] & 0x20)
        {
            setStanleyEat();
            RETURN;
        }

loc_2AA:
        IF (DSBYTE[BLOCK_STATUS] & 4)  //  BLOCK_STATUS
        {
            stanleyDrown(); // bit 4 is set
            RETURN;
        }

loc_2B3:
        IF (DSBYTE[BLOCK_STATUS] & 1) //  BLOCK_STATUS
        {
            swampProc();
            RETURN;
        }

loc_2BC:
        checkGround();

        mov	DSBYTE[#footIndex], ah

        IF (AH == 0x8A) // check for water
        {
            stanleyDrown();
            RETURN;
        }

checkSwamp:
        IF (AH == 0x89) // check for swamp
        {
            swampProc();
            RETURN;
        }
        ELSE
        {
            GOTO loc_2D3;
        }

loc_2D3:
        checkBlockCollision(); // check collision on right-left ?

        IF (DSBYTE[BLOCK_STATUS] & 2)
        {
            loc_683();
            RETURN;
        }

loc_2DF:
        BX = #byte_DDB3;
        IF (DSBYTE[BX] & 0x10)
        {
            stunnedStanley();
            RETURN;
        }

loc_2EA:
        //call	stanleyFire

        IF (DSBYTE[OBJ_STATUS] & 2)
        {
            //jmp	weaponUsed;
        }
//        jz	short loc_2F6

loc_2F6:
        IF (DSBYTE[OBJ_STATUS] & 4)
        {
            stanleyThrow();
            RETURN;
        }

loc_2FF:
        stanleyUp();

        IF (DSBYTE[OBJ_STATUS] & 8)
        {
            loc_4E1();
            RETURN;
        }

loc_30B:
        IF (DSBYTE[OBJ_STATUS] & 0x40)
        {
            AND	DSBYTE[OBJ_STATUS], 0xFE;

            //       CHECK KEYS
            AH = DSBYTE[#CONTROL_STAT]; // check for RIGHT key
            IF (AH & 8)
            {
                stanleyRight();
                RETURN;
            }

            // testStanleyLeft:
            IF (AH & 4)
            {
                stanleyLeft(); // check for left status
                RETURN;
            }

loc_329:
            jmp	loc_5F9
        }

loc_32C:
        IF (DSBYTE[OBJ_STATUS] & 1)
        {
            GOTO loc_371;
        }

        IF (DSBYTE[BLOCK_STATUS] & 0x40) // check up status - jump if not blocked
        {
            RETURN;
        }

// ----------

loc_339:
        BX =  #startJumpRightTiles;

        IF (DSBYTE[DIRECTION] & 0x80)
        {
            BX = #startJumpLeftTiles;
        }

loc_345:
        getFramesPar();
        checkFrames();
        JB loc_34E;
        RETURN;
// -----------

loc_34E:
        AH = DSBYTE[OBJ_STATUS];
        AH |= DSBYTE[BLOCK_STATUS]; //  OR ah,[si+24h]

        IF (!DSBYTE[DIRECTION] & 0x80)
        {
            IF (AH & 0x20)
            {
                DSBYTE[DIRECTION] = 1;
            }
        }
        ELSE
        {
//loc_365:
            IF (AH & 0x10)
            {
                DSBYTE[DIRECTION] = 0xFF;
            }
        }

loc_36E:
        sub_1E64();
        RETURN;

// -------------------------------------
loc_371:
        checkJumpTiles();

        IF (DSBYTE[BLOCK_STATUS] & 0x80)
        {
            DSBYTE[STRENGHT_CNT] = 0x7F;
        }

loc_37E:
        IF (DSBYTE[DIRECTION] & 0x80)
        {
            IF (!DSBYTE[OBJ_STATUS] & 0x20)
                    GOTO loc_3B7;
            IF (!DSBYTE[BLOCK_STATUS]& 0x20)
                    RETURN;

//                jmp	short loc_3A0
loc_391:

        }
        ELSE {
loc_393:
            IF (!DSBYTE[OBJ_STATUS] & 0x10)
                    GOTO loc_3B7;
            IF (!DSBYTE[BLOCK_STATUS] & 0x10)
                    RETURN;
        }
// ----------

loc_3A0:
        sub_1E29(); ////////////

        mov	ah, DSBYTE[STRENGHT_CNT]
        test	ah, 80h
        jz	short loc_3B2
        add	ah, 3
        mov	DSBYTE[STRENGHT_CNT], ah
        ret
// ----------
loc_3B2:
        DSBYTE[STRENGHT_CNT] = 0x7F;
        RETURN;
// -----------

loc_3B7:
        DSBYTE[OBJ_STATUS] = 0x0FE;
        RETURN;

// =======================================================

stanleyRight:
        mov	ah, 40h
        mov	DSBYTE[Y_COORD2], ah
        mov	ah, DSBYTE[FRAME_PAUSE]
        cmp	ah, 0Ch
        jz	short loc_495
        inc	ah
        mov	DSBYTE[FRAME_PAUSE],	ah

loc_495:
        BX = #loc_80C3;
        getFramesPar();
        checkFrames();
        jb	short loc_4A1
        ret

loc_4A1:
        mov	ah, DSBYTE[BLOCK_STATUS]
        or	ah, DSBYTE[OBJ_STATUS]
        test	ah, 20h
        jz	short loc_4AD
        ret

loc_4AD:
        INC DSBYTE[X_COORD];
        stc
        ret

// =======================================================

stanleyLeft:
        mov	ah, 40h
        mov	DSBYTE[Y_COORD2], ah
        mov	ah, DSBYTE[FRAME_PAUSE]
        cmp	ah, 0Ch
        jz	short loc_4C4
        inc	ah
        mov	DSBYTE[FRAME_PAUSE],	ah

loc_4C4:
        BX = #loc_80F0;
        getFramesPar();
        checkFrames();
        jb	short loc_4D0
        ret

loc_4D0:
        mov	ah, DSBYTE[BLOCK_STATUS]
        or	ah, DSBYTE[OBJ_STATUS]
        test	ah, 10h
        jz	short loc_4DC
        ret

loc_4DC:
        dec	DSBYTE[X_COORD]
        stc
        ret
// =======================================================
loc_4E1:
        test	DSBYTE[BLOCK_STATUS], 8
        jnz	short loc_538
        mov	ah, DSBYTE[FRAME_PAUSE]
        or	ah, ah
        jnz	short loc_4F8

loc_4EE:
        xor	ah, ah
        mov	DSBYTE[FRAME_PAUSE],	ah
        and	DSBYTE[OBJ_STATUS], 0F7h
        ret

loc_4F8:
        dec	ah
        mov	DSBYTE[FRAME_PAUSE],	ah
        mov	ah, DSBYTE[OBJ_STATUS]
        or	ah, DSBYTE[BLOCK_STATUS]
        test	ah, 80h
        jnz	short loc_4EE
        test	DSBYTE[DIRECTION], 80h
        jnz	short loc_51E
        mov	ah, DSBYTE[OBJ_STATUS]
        or	ah, DSBYTE[BLOCK_STATUS]
        test	ah, 20h
        jnz	short loc_4EE

        BX = #loc_80C8;
        jmp	short loc_52C

loc_51E:
        mov	ah, DSBYTE[OBJ_STATUS]
        or	ah, DSBYTE[BLOCK_STATUS]
        test	ah, 10h
        jnz	short loc_4EE
        BX = #loc_80F5;

loc_52C:
        getFramesPar();
        MOV DSBYTE[FRAME_NUM], CL;
        call	sub_1E64
        jmp	checkJumpTiles
// ---------------------------------------------------------------------------
loc_538:
        dec	DSBYTE[JUMP_CNT]
        jz	short loc_53E
        ret
// ---------------------------------------------------------------------------

loc_53E:
        and	DSBYTE[BLOCK_STATUS], 0F7h
        and	DSBYTE[OBJ_STATUS], 0F7h
        ret
// ---------------------------------------------------------------------------
// 547
stanleyThrow:
        BX = #rightStartThrowTile;

        test	DSBYTE[DIRECTION], 80h
        jz	short loc_553

        BX = #leftStartThrowTile;

loc_553:
        getFramesPar();
        checkFrames();
        jb	short loc_55C
        ret
loc_55C:
        or	ah, ah
        jnz	short loc_561
        ret

loc_561:
        mov	DSBYTE[FRAME_NUM], ah
        and	DSBYTE[OBJ_STATUS], 0FBh
        and	DSBYTE[BLOCK_STATUS], 0F7h
        //call	sub_939
        xor	ah, ah
        mov	DSBYTE[#pSTRENGHT], ah
        ret

//==========================================================
// CHECK UP

stanleyUp:
        test	DSBYTE[OBJ_STATUS], 8
        jz	short loc_57D
        ret
// ----------

loc_57D:
        mov	ah, DSBYTE[#CONTROL_STAT] // check for UP key pressed
        test	ah, 1
        jz      stanleyDown
        test	DSBYTE[OBJ_STATUS], 40h // check up block
        jnz	short loc_58D
        ret
// ------------

loc_58D:
        mov	bx, #loc_80C8
        test	DSBYTE[DIRECTION], 80h
        jz	short loc_599
        mov	bx, #loc_80F5

loc_599:
        getFramesPar();

        or	DSBYTE[OBJ_STATUS], 8
        call	checkFrames
        mov	ah, DSBYTE[FRAME_PAUSE]
        or	ah, ah
        jz	short loc_5B0
        mov	bx, #smallJumpSound
        ret // jmp	playSound // TODO

loc_5B0:
        mov	ah, DSBYTE[Y_COORD]
        sub	ah, 2
        jnb	short loc_5B9
        ret

loc_5B9:
        mov	cl, 1
        test	DSBYTE[DIRECTION], 80h
        jz	short loc_5C3
        mov	cl, 0FFh

loc_5C3:
        mov	DSBYTE[DIRECTION], cl
        or	DSBYTE[BLOCK_STATUS], 8
        mov	DSBYTE[JUMP_CNT], 8
        dec	DSBYTE[Y_COORD] // jump on stay
        dec	DSBYTE[Y_COORD] // -'-'-'-
        //mov	bx, #jumpSound
        jmp	playSound
// ==============================================
// END OF FUNCTION CHUNK	FOR stanleyProc


// =============== S U B	R O U T	I N E =======================================
// moved from 5ХХ

stanleyDown:
        test	ah, 2
        jnz	short loc_5E0
        ret

loc_5E0:
        test	DSBYTE[OBJ_STATUS], GROUND_BIT
        jnz	short loc_5E7
        ret

loc_5E7:
        mov	bx, #loc_80CD
        test	DSBYTE[DIRECTION], 80h
        jz	short loc_5F3
        mov	bx, #loc_80FA

loc_5F3:
        getFramesPar();
        jmp	checkFrames
//endp		stanleyUp

// ===========
loc_5F9:
        mov	ah, DSBYTE[#CONTROL_STAT]
        and	ah, 0Fh
        jz	short loc_603
        ret

loc_603:
        mov	ah, 40h
        mov	DSBYTE[Y_COORD2], ah
        xor	ah, ah
        mov	DSBYTE[FRAME_PAUSE], ah

        test	DSBYTE[DIRECTION], 80h
        mov bx, #rightThrowTiles
        jz	short loc_619

        mov bx, #leftThrowTiles

loc_619:
        mov	ah, DSBYTE[bx]
        mov	DSBYTE[FRAME_NUM], ah
        ret

// ---------------------------------------------------------------------------

loc_683:
        test	DSBYTE[OBJ_STATUS], 40h
        jnz	short loc_690
        mov	DSBYTE[STRENGHT_CNT], 7Fh
        jmp	sub_1E64
// ---------------------------------------------------------------------------

loc_690:
        BX = #leftDieTiles;
        test	DSBYTE[DIRECTION], 80h
        jz	short loc_69C

        BX = #rightDieTiles;

loc_69C:
        getFramesPar();
        checkFrames();
        jb	short loc_6A5
        ret
// ---------------------------------------------------------------------------

loc_6A5:
        or	ah, ah
        jz	short locret_6AB
        jmp	respawnStanley
// ---------------------------------------------------------------------------

locret_6AB:
        ret
//============================================================================

stunnedStanley:
        test	DSBYTE[OBJ_STATUS], 40h
        jnz	short loc_6B9
        mov	DSBYTE[STRENGHT_CNT], 7Fh
        jmp	sub_1E64
// ---------------------------------------------------------------------------

loc_6B9:
        mov	bx, #leftStunnedTiles
        test	DSBYTE[DIRECTION], 80h
        jz	short loc_6C5
        mov	bx, #rightStunnedTiles

loc_6C5:
        getFramesPar();
        checkFrames();
        jb	short loc_6CE
        ret
// ---------------------------------------------------------------------------

loc_6CE:
        dec	DSBYTE[FRAME_PAUSE]
        jz	short endStun
        ret
// ---------------------------------------------------------------------------

endStun:
        mov	bx, #byte_DDB3
        and	DSBYTE[bx], 0EFh
        ret

//////////////////////////////////////////////////////
        ////////////////////////////
        dbg:
        {
                push ax
                push dx
                mov ah,09
                mov dx,#teststr
                int 21h
                jmp more
                teststr:
                db " ! $"
                more:
                pop dx
                pop ax
                ret
        }
        ////////////////////////////

        ////============================================================================
        //// START	OF FUNCTION CHUNK FOR stanleyProc

respawnStanley:
        //      //call	hat__
        mov	ah, DSBYTE[#pLIVE_COUNT]

loc_644:
                dec	ah
                mov	DSBYTE[#pLIVE_COUNT], ah
                cmp	ah, 0FFh
                jnz	short resurrectStanley

                jmp	startScreen

                //// -----------------------

                resurrectStanley:
                mov	ah, 3Ch
                mov	DSBYTE[#pFOOD], ah
                mov	DSBYTE[#pFOOD+1], ah

                mov	si, #WORK_BUF

                mov	DSBYTE[OBJ_STATUS], 0
                mov	DSBYTE[BLOCK_STATUS], 0
                or	DSBYTE[si], 20h //// set bit 6

                call	sub_3641

                mov	si, #WORK_BUF
                and	DSBYTE[si], 0DFh //// reset bit 6

                call	getRespawnCoord
                xor	ah, ah
                mov	DSBYTE[#byte_DDB3], ah
                mov	DSBYTE[#footIndex], ah

                ret // // // jmp	checkRaft // was TODO

                //////////////////////////////////////////////////////

                ////////////////////
} // END MAIN // !!!

        // ERASED CODE...
        // ....
// TODO // STUB
swampProc()
{
    RETURN;
}

stanleyDrown()
{
    RETURN;
}

stanleyEat()
{
    RETURN;
}

setStanleyEat()
{
    RETURN;
}


// =============== S U B	R O U T	I N E =======================================
//		objects queue

sub_3641()
{

// si = DE46 by default

        push	si
        mov	di, #workBufAddr

loc_3645:
        call	sub_3686
        jz	short loop1

        test	DSBYTE[si], 4
        jz	short loc_365E

        test	DSBYTE[si], 10h
        jz	short loc_3645
        call	deleteObject
        dec	di
        dec	di
        mov	DSBYTE[si], 0
        jmp	short loc_3645
// ---------------------------------------------------------------------------

loc_365E:
        call	sub_3696
        jmp	short loc_3645
// ---------------------------------------------------------------------------

loop1:

        call	sub_3686
        jz	short loc_367F

        test	DSBYTE[si], 4
        jnz	short loop1
        test	DSBYTE[si+1], 1
        jnz	short loc_3676


        call	sub_383A

loc_3676:

        and	DSBYTE[si+1], 0FEh
        and	DSBYTE[si  ], 0BFh
        jmp	short loop1

// ---------------------------------------------------------------------------

loc_367F:

        pop	si
        mov	DSBYTE[#LOCK_STATUS1], 1
        ret
}   //endp		sub_3641


// =============== S U B	R O U T	I N E =======================================

sub_3686()
{
        mov	al, DSBYTE[di]
        or	al, DSBYTE[di+1]
        jnz	short loc_3691
        mov	di, #workBufAddr
        ret
// ---------------------------------------------------------------------------

loc_3691:
        mov	si, DSWORD[di]

        inc	di
        inc	di

        ret
}//endp		sub_3686

//////////////////////////////////////////////////////

sub_3696()
{
        test	DSBYTE[si], 40h
        jz	short loc_36A0
        call	copy8bytes2
        jmp	short loc_36C2

// ---------------------------------------------------------------------------

loc_36A0:
        mov	cx, DSWORD[FRAME_SIZE]
        mov	DSWORD[#tmpFrameSize], cx
        mov	cx, DSWORD[si+1Ah]
        mov	DSWORD[#word_DE2F], cx
        mov	ah, DSBYTE[si+1]
        mov	DSBYTE[#byte_DE45], ah
        and	DSBYTE[si+1], 0FDh
        and	DSBYTE[si+1], 0FBh
        test	DSBYTE[si], 20h
        jnz	short loc_3713

loc_36C2:
        call	getObjAddr
        mov	dx, DSWORD[X_COORD2]
        test	dh, 80h
        jz	short loc_36FA
        mov	DSBYTE[si+1Ah], 0
        mov	bx, 0
        sub	bx, dx
        call	sub_3822
        jnb	short loc_36DE
        jmp	loc_37F0
// ---------------------------------------------------------------------------
loc_36DE:
        mov	ah, DSBYTE[FRAME_SIZE]
        sub	ah, cl
        jnb	short loc_36E8
        jmp	loc_37F0
// ---------------------------------------------------------------------------
loc_36E8:
        jnz	short loc_36ED
        jmp	loc_37F0
// ---------------------------------------------------------------------------

loc_36ED:
        mov	DSBYTE[FRAME_SIZE], ah
        mov	ah, DSBYTE[FRAME_DISP]
        add	ah, cl
        mov	DSBYTE[FRAME_DISP], ah
        jmp	short loc_3713
// ---------------------------------------------------------------------------
loc_36FA:
        xchg	dx, bx
        call	sub_3822
        jnb	short loc_3704
        jmp	loc_37F0
// ---------------------------------------------------------------------------
loc_3704:
        mov	DSBYTE[si+1Ah], cl
        mov	ah, 50h
        sub	ah, cl
        cmp	ah, DSBYTE[FRAME_SIZE]
        jnb	short loc_3713
        mov	DSBYTE[FRAME_SIZE], ah

loc_3713:
        mov	dx, DSWORD[Y_COORD2]
        test	dh, 80h
        jz	short loc_3748
        mov	DSBYTE[si+1Bh], 0
        mov	bx, 0
        sub	bx, dx
        call	sub_382D
        jnb	short loc_372C
        jmp	loc_37F0
// ---------------------------------------------------------------------------
loc_372C:
        mov	ah, DSBYTE[si+1Fh]
        sub	ah, cl
        jnb	short loc_3736
        jmp	loc_37F0
// ---------------------------------------------------------------------------
loc_3736:
        jnz	short loc_373B
        jmp	loc_37F0
// ---------------------------------------------------------------------------
loc_373B:
        mov	DSBYTE[si+1Fh], ah
        mov	ah, DSBYTE[si+1Dh]
        add	ah, cl
        mov	DSBYTE[si+1Dh], ah
        jmp	short loc_3761
// ---------------------------------------------------------------------------

loc_3748:
        xchg	dx, bx
        call	sub_382D
        jnb	short loc_3752
        jmp	loc_37F0
// ---------------------------------------------------------------------------

loc_3752:
        mov	DSBYTE[si+1Bh], cl
        mov	ah, 0A0h
        sub	ah, cl
        cmp	ah, DSBYTE[si+1Fh]
        jnb	short loc_3761
        mov	DSBYTE[si+1Fh], ah

loc_3761:
        test	DSBYTE[si], 40h
        jnz	short loc_3777
        mov	ah, DSBYTE[#byte_DE45]
        test	ah, 4
        jz	short loc_3796
        test	DSBYTE[si], 20h
        jz	short loc_3777
        jmp	short loc_37F0
        nop
// ---------------------------------------------------------------------------
loc_3777:
        mov	ah, DSBYTE[si+1Ah]
        mov	DSBYTE[si+16h], ah
        add	ah, DSBYTE[FRAME_SIZE]
        mov	DSBYTE[si+17h], ah
        mov	ah, DSBYTE[si+1Bh]
        mov	DSBYTE[si+18h], ah
        mov	al, DSBYTE[si+1Fh]
        shr	al, 1
        inc	al
        add	ah, al
        mov	DSBYTE[si+19h], ah
        ret
// ---------------------------------------------------------------------------

loc_3796:
        mov	cx, DSWORD[#word_DE2F]
        mov	ah, DSBYTE[si+1Ah]
        cmp	ah, cl
        jb	short loc_37A6
        mov	DSBYTE[si+16h], cl
        jmp	short loc_37A9
// ---------------------------------------------------------------------------

loc_37A6:
        mov	DSBYTE[si+16h], ah

loc_37A9:
        mov	ah, DSBYTE[si+1Bh]
        cmp	ah, ch
        jb	short loc_37B5
        mov	DSBYTE[si+18h], ch
        jmp	short loc_37B8
// ---------------------------------------------------------------------------

loc_37B5:
        mov	DSBYTE[si+18h], ah

loc_37B8:
        add	cl, DSBYTE[#tmpFrameSize]
        mov	ah, DSBYTE[#tmpFrameSize+1]
        shr	ah, 1
        inc	ah
        add	ch, ah
        mov	ah, DSBYTE[si+1Ah]
        add	ah, DSBYTE[FRAME_SIZE]
        cmp	ah, cl
        jb	short loc_37D5
        mov	DSBYTE[si+17h], ah
        jmp	short loc_37D8
// ---------------------------------------------------------------------------

loc_37D5:
        mov	DSBYTE[si+17h], cl

loc_37D8:
        mov	ah, DSBYTE[si+1Bh]
        mov	al, DSBYTE[si+1Fh]
        shr	al, 1
        inc	al
        add	ah, al
        cmp	ah, ch
        jb	short loc_37EC
        mov	DSBYTE[si+19h], ah
        ret
// ---------------------------------------------------------------------------

loc_37EC:
        mov	DSBYTE[si+19h], ch
        ret
// ---------------------------------------------------------------------------

loc_37F0:
        or	DSBYTE[si+1], 2
        or	DSBYTE[si+1], 4
        ret

}   //endp		sub_3696

//////////////////////////////////////////////////////

sub_3822()
        {
        mov	ah, MAX_X_SPR-1 //// check x
        cmp	ah, bh
        jb	short locret_382C
        rcl	bx, 1
        mov	cl, bh

//        if (BH+1 > MAX_X_SPR)
//        {
//            BX = BX/2;
//            CL = BH;
//        }

locret_382C:
        ret
}   //endp		sub_3822

//////////////////////////////////////////////////////

sub_382D()
{
        mov	ah, MAX_Y_SPR-1 //// check y
        cmp	ah, bh
        jb	short locret_382C
        rcl	bx, 1
        rcl	bx, 1
        mov	cl, bh

//        if (BH+1 > MAX_Y_SPR)
//        {
//            BX = BX/4;
//            CL = BH;
//        }

        RETURN;

}   //endp		sub_382D

//////////////////////////////////////////////////////

sub_383A()
{
        call	sub_38A8
        mov	DSBYTE[#byte_DE33], 1
        mov	ah, DSBYTE[si+16h]
        mov	DSBYTE[#word_DE34], ah
        mov	ah, DSBYTE[si+17h]
        mov	DSBYTE[#word_DE34+1], ah
        mov	ah, DSBYTE[si+18h]
        mov	DSBYTE[#word_DE36], ah
        mov	ah, DSBYTE[si+19h]
        mov	DSBYTE[#word_DE36+1], ah
        or	DSBYTE[si], 8
        call	sub_388E

loc_3864:
        push	si
        push	di
        mov	DSBYTE[#byte_DE38], 0

loc_386B:
        call	sub_3686
        jz	short loc_387B
        test	DSBYTE[si+1], 1
        jnz	short loc_386B
        call	sub_38B1
        jmp	short loc_386B

////////////////////////////////

loc_387B:
        pop	di
        mov	ah, DSBYTE[#byte_DE38]
        or	ah, ah
        jz	short loc_3887
        pop	si
        jmp	short loc_3864
//// ---------------------------------------------------------------------------

loc_3887:
        pop	si
        push	si
        call	sub_394E
        pop	si
        ret
}   //endp		sub_383A

//// =============== S U B	R O U T	I N E =======================================


sub_388E()
{
        mov	bx, DSWORD[#word_DE15]
        mov	DSWORD[bx], si
        inc	bx
        inc	bx
        mov	DSWORD[#word_DE15], bx
        ret
}   //endp		sub_388E

//// =============== S U B	R O U T	I N E =======================================

sub_389B()
{
        mov	bx, DSWORD[#word_DE15]
        mov	si, DSWORD[bx]
        inc	bx
        inc	bx
        mov	DSWORD[#word_DE15], bx
        ret
}   //endp		sub_389B


//// =============== S U B	R O U T	I N E =======================================

sub_38A8()
{
//        mov	bx, DSWORD[#word_DE17]
//        mov	DSWORD[#word_DE15], bx

        DSWORD[#word_DE15] = DSWORD[#word_DE17];

        ret
} //endp		sub_38A8

//// =============== S U B	R O U T	I N E =======================================

sub_38B1()
{
//        mov	bh, DSBYTE[si+16h]
//        mov	bl, DSBYTE[si+17h]

        BX = DSWORD[SI+16h];

        DX = DSWORD[#word_DE34];
//        mov	dh, DSBYTE[#word_DE34]
//        mov	dl, DSBYTE[#word_DE34+1]

        call	sub_3942
        jb	short loc_38C7

        jmp	short endproc2
        nop
//// ---------------------------------------------------------------------------

loc_38C7:
        mov	BX, DSWORD[si+18h]
        mov	DX, DSWORD[#word_DE36]

        call	sub_3942
        jnb	short endproc2

        mov	ch, DSBYTE[si+16h]
        mov	ah, DSBYTE[#word_DE34]
        call	ifAHbCH_AHeqCH
        mov	dl, ah
        mov	ch, DSBYTE[si+17h]
        mov	ah, DSBYTE[#word_DE34+1]
        call	ifAHnbCH_AHeqCH
        mov	dh, ah
        sub	ah, dl
        cmp	ah, 3Eh
        jnb	short endproc2
        mov	ch, DSBYTE[si+18h]
        mov	ah, DSBYTE[#word_DE36]
        call	ifAHbCH_AHeqCH
        mov	bl, ah
        mov	ch, DSBYTE[si+19h]
        mov	ah, DSBYTE[#word_DE36+1]
        call	ifAHnbCH_AHeqCH
        mov	bh, ah
        sub	ah, bl
        cmp	ah, 80h
        jnb	short endproc2
        mov	DSWORD[#word_DE34], dx
        mov	DSWORD[#word_DE36], bx
        call	sub_388E
        mov	DSBYTE[#byte_DE38], 1
        or	DSBYTE[si+1], 1
        or	DSBYTE[si], 8
        inc	DSBYTE[#byte_DE33]

endproc2:

        RETURN;
}   //endp		sub_38B1


//// =============== S U B	R O U T	I N E =======================================

ifAHnbCH_AHeqCH()
{
        //;cmp	ah, ch
        //;jnb	short locret_393A
        //;mov	ah, ch

        if (AH>CH)
            AH = CH;

locret_393A:
        ret
}//endp		ifAHnbCH_AHeqCH


// =============== S U B	R O U T	I N E =======================================

ifAHbCH_AHeqCH()
{
        //;cmp	ah, ch
        //;jb	short locret_393A
        //;mov	ah, ch

        if (AH<CH)
          AH = CH;

        RETURN;
}//endp		ifAHbCH_AHeqCH

//// =============== S U B	R O U T	I N E =======================================

sub_3942()
{
        mov	ah, dl
        cmp	ah, bh
        jb	short loc_394C
        mov	ah, bl
        cmp	ah, dh

loc_394C:
        cmc

        RETURN;
}//endp		sub_3942


//////////////////////////////////////////////////////
//// OBJECT ANIMATION & COLLISION CHECK (sub_394E)
//// from 0XE29

sub_394E()
{
        mov	ah, DSBYTE[#LOCK_STATUS1]
        or	ah, ah
        jnz	short loc_3974

        mov	ah, DSBYTE[#byte_DE33]
        cmp	ah, 1
        jnz	short loc_3974
        mov	bx, #word_DE17
        mov	dx, DSWORD[bx]
        xchg	dx, bx
        inc	bx
        test	DSBYTE[bx], 4
        jz	short loc_3974
        test	DSBYTE[bx], 2
        jz	short loc_3974
        jmp	copy8bytes2

//// ---------------------------------------------------------------------------
////
loc_3974:
//        CL = DSBYTE[#word_DE34] / 2;
        mov	cl, DSBYTE[#word_DE34]
        shr	cl, 1

        mov	ch, DSBYTE[#word_DE36]
        shr	ch, 1
        shr	ch, 1
        mov	DSWORD[#word_DE3F], cx
        mov	dl, DSBYTE[#word_DE34+1]
        test	dl, 1
        jz	short loc_3992
        add	dl, 2

loc_3992:
        shr	dl, 1
        sub	dl, cl
        mov	dh, DSBYTE[#word_DE36+1]
        test	dh, 3
        jz	short loc_39A2
        add	dh, 4

loc_39A2:
        shr	dh, 1
        shr	dh, 1
        sub	dh, ch
        mov	DSWORD[#word_DE41], dx
        mov	ch, DSBYTE[#word_DE3F+1] //// DE40
        add	ch, dh
        cmp	ch, 14h
        jb	short loc_39C0
        sub	ch, 14h
        sub	dh, ch
        mov	DSBYTE[#word_DE41+1],	dh

//// something with background

loc_39C0:
        CX = DSWORD[#word_DE3F];
        CL += CL;
        CH += CH; // ch = ch * 4;
        CH += CH; //
        DSWORD[#tmpScrObjAddr] = CX;

        CX = DSWORD[#word_DE41];
        CL += CL;
        CH += CH; // ch = ch * 4;
        CH += CH; //
        DSWORD[#frameOffset] = CX;

        DX = DSWORD[#word_DE41];
        CX = DL * DH * 8;

        push	si
        push	di

        //// 	clear buffer
        SI = #objGraphBuf;
        DI = #objGraphBuf + 2;
        DSWORD[SI] = 0;
        cld
        rep movsw

        AX = DSWORD[#frameOffset];
        DSWORD[#word_DE0D] = AL * 8;

        DX = DSWORD[#word_DE3F];
        BX = DH*MAX_X_SPR + DL + #LOCAT_BUF;
        DX = DSWORD[#word_DE41];
        DI = #objGraphBuf;  ////; set address to frame buffer

loc_3A20:
        do
        {
            push	dx
            push	bx
            push	di

//;loc_3A23:
            do {
                push	bx
                push	dx

                    AL = DSBYTE[BX]; //// AL = sprite number
                    IF (AL != 0)
                    {
                        AH = 0;
                        call	copySprite2Buf //// copy sprite to buffer (background)
                    }

//;loc_3A30:
                DI++;
                DI++;

                pop	dx
                pop	bx
                BX++;

                DL--;
            } while (DL);

            pop	di
            DI += DSWORD[#word_DE0D];

            pop	bx
            BX += MAX_X_SPR;

            pop	dx
            DH--;

        } while (DH);

        pop	di
        pop	si
        call	sub_38A8

        mov	DSWORD[#word_DE13], di
        mov	ah, DSBYTE[#byte_DE33]
        push	si

loc_3A59:
        push	ax
        call	sub_389B
        test	DSBYTE[si], 10h
        jz	short loc_3A67
        call	sub_3BA0
        jmp	short loc_3A7D
//// ---------------------------------------------------------------------------

loc_3A67:
        test	DSBYTE[si+1], 2
        jnz	short loc_3A72
        test	DSBYTE[si], 20h
        jz	short loc_3A77

loc_3A72:
        call	copy8bytes2
        jmp	short loc_3A7D
//// ---------------------------------------------------------------------------

loc_3A77:
        call	sub_3AE6 //// get paint addr?
        call	copy8bytes2 //// collision?

loc_3A7D:
        pop	ax
        dec	ah
        jnz	short loc_3A59

        pop	si
        mov	di, DSWORD[#word_DE13] //// screen address

//// paint object on screen
        push	si
        push	di
        push	es
        mov	dx, 0B800h
        mov	es, dx
        //assume es:nothing
        mov	dx, DSWORD[#tmpScrObjAddr] //// get addr on screen
        mov	ax, 50h
        mul	dh
        mov	dh, 0
        add	ax, dx
        mov	di, ax
        mov	si, #objGraphBuf
        mov	cx, DSWORD[#word_DE41] // buffer size

        shl	ch, 1 // cx = cx * 4
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
        //assume es:nothing
        pop	di
        pop	si
        ret
//endp		sub_394E
}


//// =============== S U B	R O U T	I N E =======================================

sub_3AE6()
{

        push	si
        push	di
        mov	bx, DSWORD[FRAME_ADDR] //// get frame address
        mov	dl, DSBYTE[bx] //// get X-size
        mov	DSBYTE[#tmpX], dl //// save X
        inc	bx
        inc	bx
        mov	al, DSBYTE[FRAME_DISP]
        mov	ah, 0
        add	bx, ax
        mov	al, DSBYTE[si+1Dh]
        mul	dl
        add	bx, ax
        mov	DSWORD[#tmpAddrDE0F], bx
        mov	ah, 0
        mov	di, #objGraphBuf
        mov	cx, DSWORD[#tmpScrObjAddr]
        mov	dx, DSWORD[si+1Ah]
        mov	al, dl
        sub	al, cl
        add	di, ax
        mov	al, dh
        sub	al, ch
        mov	cl, DSBYTE[#frameOffset]
        mul	cl
        add	ax, ax
        add	di, ax
        mov	cx, DSWORD[FRAME_SIZE]
        mov	si, DSWORD[#tmpAddrDE0F]
        mov	bl, DSBYTE[#frameOffset]
        mov	bh, 0
        mov	dl, DSBYTE[#tmpX]
        mov	dh, 0
        cld

loc_3B39:
        do {
            push	cx
            push	si
            push	di

            mov	ch, 0
            graphOverlay();

            pop	di
            add	di, bx
            pop	si
            add	si, dx
            pop	cx
            dec	ch
        } while (CH);

        pop	di
        pop	si

        ret
}   //endp		sub_3AE6

//// =============== superimpose graphic =======================================
//// addr: 0x3b4f
//// superimpose graphic
//// make bit 'mask': test each 2 bits (one pixel) in byte
//// if pixel exists, remove background pixel and put our pixel instead it
//// SI: addr of overlay graph buffer
//// DI: addr of background graph buffer
graphOverlay()
{
    do {
        mov	al, DSBYTE[si]
                or	al, al
                jz	short loc_3B75
                test	al, 3 //// 00000011 first 2 bit
                jz	short loc_3B5B
                or	al, 3

                loc_3B5B:
            test	al, 0Ch //// 00001100 next 2 bit and etc
            jz	short loc_3B61
            or	al, 0Ch

            loc_3B61:
            test	al, 30h //// 00110000
            jz	short loc_3B67
            or	al, 30h

            loc_3B67:
            test	al, 0C0h //// 11000000
            jz	short loc_3B6D
            or	al, 0C0h

            loc_3B6D:
            xor	al, 0FFh
            and	al, DSBYTE[di]
            or	al, DSBYTE[si]
            mov	DSBYTE[di], al

            loc_3B75:
            DI++;
        SI++;
        CX--;
    } while (CX);   // loop graphOverlay

    RETURN;
}

//endp		graphOverlay
//// ---------------------------------------------------------------------------

//{
////// ---------------------------------------------------------------------------
////// 3B8C - not used ?
//push	si
//push	di
//add	si, 3
//mov	si, di
//mov	cx, 8
//add	di, cx
//cld
//rep movsb
//pop	di
//pop	si
//ret
//}

//// =============== S U B	R O U T	I N E =======================================

sub_3BA0()
{
        mov	DSBYTE[si], 0
        call	deleteObject
        mov	cx, DSWORD[#word_DE13]
        sub	bx, cx
        jnb	short locret_3BB4
        dec	cx
        dec	cx
        mov	DSWORD[#word_DE13], cx

locret_3BB4:
        ret
} //endp		sub_3BA0

//////////////////////////////////////////////////////

checkControls__()
{
        mov	DSBYTE[#CONTROL_STAT], 0
        mov	al, DSBYTE[#byte_7D0D]
        or	al, DSBYTE[#byte_7D1C]
        test	al, 80h
        jz	short loc_33E0
        or	DSBYTE[#CONTROL_STAT], 1 //// KEY 'UP' PRESSED

loc_33E0:
        mov	al, DSBYTE[#byte_7D0E]
        or	al, DSBYTE[#byte_7D1D]
        test	al, 80h
        jz	short loc_33F0
        or	DSBYTE[#CONTROL_STAT], 2 //// KEY 'DOWN' PRESSED

loc_33F0:				////
        mov	al, DSBYTE[#byte_7D0B]
        or	al, DSBYTE[#byte_7D1A]
        test	al, 80h
        jz	short loc_3400
        or	DSBYTE[#CONTROL_STAT], 4 //// KEY 'LEFT' PRESSED

loc_3400:				////
        mov	al, DSBYTE[#byte_7D0C]
        or	al, DSBYTE[#byte_7D1B]
        test	al, 80h
        jz	short loc_3410
        or	DSBYTE[#CONTROL_STAT], 8 //// KEY 'RIGHT' PRESSED

loc_3410:				////
        mov	al, DSBYTE[#FIRE_BUTTON]
        or	al, DSBYTE[#byte_7D1E]
        or	al, DSBYTE[#byte_7D1F]
        test	al, 80h
        jz	short loc_3424
        or	DSBYTE[#CONTROL_STAT], 10h //// KEY 'FIRE' PRESSED

loc_3424:				//
        mov	al, DSBYTE[#BREAK_BUTTON]
        test	al, 80h
        jz	short loc_3430
        or	DSBYTE[#CONTROL_STAT], 20h //// KEY 'ABORT' PRESSED

loc_3430:				////
        test	DSBYTE[#byte_7D19], 80h // // KEY 'HELP' PRESSED (F1)
        jz	short loc_343C
        or	DSBYTE[#CONTROL_STAT], 80h ////

loc_343C:				////
        mov	al, DSBYTE[#demoLockStat]
        or	al, al
        jz	short loc_3444
        ret
//// ---------------------------------------------------------------------------
loc_3444:
        test	DSBYTE[#WEAP1_BUTTON], 80h
        jz	short loc_3451
        mov	DSBYTE[#pSelectedWeapon], 1
        ret
//// ---------------------------------------------------------------------------

loc_3451:
        test	DSBYTE[#WEAP2_BUTTON], 80h
        jz	short loc_345E
        mov	DSBYTE[#pSelectedWeapon], 2
        ret
//// ---------------------------------------------------------------------------

loc_345E:
        test	DSBYTE[#WEAP3_BUTTON], 80h
        jz	short loc_346B
        mov	DSBYTE[#pSelectedWeapon], 3
        ret
//// ---------------------------------------------------------------------------

loc_346B:
        test	DSBYTE[#WEAP4_BUTTON], 80h
        jz	short locret_3477
        mov	DSBYTE[#pSelectedWeapon], 4

locret_3477:
        RETURN;
} //endp		checkControls__

//////////////////////////////////////////////////////

getObjAddr()
{
        mov	bx, #objFramePtrs
        mov	ch, 0
        mov	cl, DSBYTE[OBJ_NUM] //// get obj num
        add	cl, cl //// * 2
        add	bx, cx ////
        mov	dx, DSWORD[bx] //// get pointer
        xchg	dx, bx //// set ADDR to BX
        mov	cl, DSBYTE[FRAME_NUM] //// get FRAME
        add	cx, cx //// FRAME = FRAME * 2 (2 bytes for 1 addr)
        add	bx, cx //// ADDR = ADDR + FRAME
        mov	dx, DSWORD[bx]
        xchg	dx, bx //// BX = get address from [ADDR]
        mov	DSWORD[FRAME_ADDR], bx //// save object addr to SI+26
        mov	dx, DSWORD[bx] //// get a object size at first 2 bytes
        mov	DSWORD[FRAME_SIZE], dx //// save object size
        mov	DSWORD[FRAME_DISP], 0 //// displacement
        ret
}  //endp		getObjAddr

//////////////////////////////////////////////////////

deleteObject()
{
        mov	dx, si
        mov	ch, DSBYTE[#objectsCount]
        mov	bx, #workBufAddr

loc_3BBE:
        mov	ax, DSWORD[bx]
        cmp	ax, dx
        jz	short loc_3BCB
        inc	bx
        inc	bx
        dec	ch
        jnz	short loc_3BBE
        ret
//// -----------
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
        dec	DSBYTE[#objectsCount]

        pop	bx
        ret
//// -----------

loc_3BEC:
        push	bx
        mov	DSWORD[bx], 0
        jmp	short loc_3BE6

} //endp		deleteObject

//////////////////////////////////////////////////////

resetLives()
{
        mov	ah, 7
        mov	DSBYTE[#pLIVE_COUNT], ah
        mov	bx, 0
        mov	DSWORD[#paintedWeapon], bx

//        proc		clearBuf	near
//                call	clearWorkbuf
//                mov	bx, 0
//                mov	[SCORE_COUNT], bx
//        endp		clearBuf	;

setParam:
        mov	ah, 1
        mov	DSBYTE[#objectsCount], ah
        mov	bx, #WORK_BUF
        mov	DSWORD[#workBufAddr], bx
        mov	bx, 0

        mov	DSWORD[#word_E02A], bx // -- ?
        mov	DSBYTE[#byte_DE6B], ah // -- ?

        RETURN;
} //endp		setParam

//////////////////////////////////////////////////////

// AX = SPRITE NUMBER
// SI = OFFSET TO LOCATIONS SPRITE GRAPHIC BANK
//

copySprite2Buf()
{
        push	di
        mov	cl, 4
        shl	ax, cl //// AX = SPRITE ADDRESS = AX * 8
        add	ax, #GRBANK1
        mov	si, ax

        mov	dx, DSWORD[#frameOffset] //// get frame offset
        mov	dh, 0
        dec	dx
        dec	dx
        cld
        mov	cx, 8

loc_3ADF:
        movsw	//// copy word
        add	di, dx  //// add offset

        loop	loc_3ADF
        pop	di
        ret
}

//////////////////////////////////////////////////////

// 858

checkBlockCollision()
{
        mov	ch, DSBYTE[Y_COORD]
        mov	cl, DSBYTE[X_COORD]
        call	getAddrByCoord
        mov	ah, 10h
        mov	DSBYTE[#word_DDD8], ah
        mov	di, #blockTypes
        mov	dh, 0

loc_86C:
        push	bx
        inc	di
        mov	ah, 0FFh
        mov	dl, DSBYTE[di]
        cmp	ah, dl
        jz	short loc_88C
        add	bx, dx
        mov	ah, DSBYTE[bx]
        cmp	ah, 0B9h
        pop	bx
        jb	short loc_86C
        mov	ah, DSBYTE[#word_DDD8]
        or	ah, DSBYTE[OBJ_STATUS]
        mov	DSBYTE[OBJ_STATUS], ah
        jmp	loc_86C
//// ---------------------------------------------------------------------------

loc_88C:
        pop	bx
        mov	ah, DSBYTE[#word_DDD8]
        shl	ah, 1
        mov	DSBYTE[#word_DDD8], ah
        jnb	loc_86C
        ret
} //endp		checkBlockCollision

/////////////////////////////////////////////////////////////
// C32

checkFrames()
{
        inc	ch
        mov	ah, DSBYTE[FRAME_NUM]
        cmp	ah, cl
        jb	 loc_C3F
        cmp	ah, ch
        jb	 loc_C71

loc_C3F:
        mov	DSBYTE[FRAME_NUM], cl
        xor	ah, ah
        mov	DSBYTE[si+15h], ah
        ret
//endp		checkFrames

loc_C71:
        mov	ah, DSBYTE[si+15h]
        cmp	ah, dl
        jnb	short loc_C7E
        inc	DSBYTE[si+15h]
        xor	ah, ah
        ret
// ---------------------------------------------------------------------------
loc_C7E:
        mov	ah, DSBYTE[FRAME_NUM]
        inc	ah
        cmp	ah, ch
        jnb	short loc_C91
        mov	DSBYTE[FRAME_NUM], ah
        xor	ah, ah
        mov	DSBYTE[si+15h], ah
        stc
        ret
// ---------------------------------------------------------------------------

loc_C91:
        dec	ch
        mov	ah, ch
        mov	DSBYTE[FRAME_NUM], cl
        mov	DSBYTE[si+15h], 0
        stc
        ret
}//endp		setFrameNum



//// =============== S U B	R O U T	I N E =======================================

getRespawnCoord()
{
        mov	si, #WORK_BUF
        mov	bx, #loc_DDFA
        mov	ch, 4

loc_EF3:
        do {
            mov	ah, DSBYTE[bx]
            mov	DSBYTE[X_COORD2], ah

            BX++;
            SI++;

            CH--;
        } while (CH); //jnz	short loc_EF3

        SI = #WORK_BUF;
        AH = DSBYTE[BX];
        DSBYTE[SI+0x13] = AH; // direction ?
        DSBYTE[SI] |= 0x40;
        jmp	copy8bytesUp

} //endp		getRespawnCoord

////////////////////////////////////////////////
// 61F

getFramesPar()
{
        mov	dl, DSBYTE[bx]
        inc	bx
        mov	cl, DSBYTE[bx]
        inc	bx
        mov	ch, DSBYTE[bx]
        inc	bx
        mov	ah, DSBYTE[bx]
        or	ah, ah
        jz	short loc_631
        mov	DSBYTE[DIRECTION], ah
loc_631:
        inc	bx
        mov	ah, DSBYTE[bx]
        or	ah, ah
        jnz	short loc_639
        ret

loc_639:
        mov	DSBYTE[STRENGHT_CNT], ah
        ret
} ///endp		getFramesPar

//===================================
// 3BC

checkJumpTiles()
{
        mov	bx, #rightJumpTiles
        test	DSBYTE[DIRECTION], 80h
        jz	short loc_3C8
        mov	bx, #leftJumpTiles

loc_3C8:
        test	DSBYTE[STRENGHT_CNT], 80h
        jz	short loc_3CF
        dec	bx // set falling tile

loc_3CF:
        mov	ah, DSBYTE[bx]
        mov	DSBYTE[FRAME_NUM], ah

                RETURN;
} //endp		checkJumpTiles

////===========================================

// =============== S U B	R O U T	I N E =======================================
// 1DEA
//
// input:
// SI = object addr
//
// output:
// DX = X coord
// BX = Y coord

getObjCoord()
{
        mov	dx, DSWORD[X_COORD2]
        mov	bx, DSWORD[Y_COORD2]
        test	DSBYTE[DIRECTION], 80h

        RETURN;
}//endp		getObjCoord

// =============== S U B	R O U T	I N E =======================================

getObjSize()
{
        BX = #animObjSizes;
        mov dl, DSBYTE[ OBJ_NUM ]
        shl	dl, 1
        mov	dh, 0
        add	bx, dx
        mov	dh, DSBYTE[bx]
        BX++;
        mov	dl, DSBYTE[bx]
        BX = DH * 32;
        mov	DSWORD[#objYsize], bx
        BX = DL * 32;
        mov	DSWORD[#objXsize], bx

        RETURN;
} //endp		getObjSize

//// =============== S U B	R O U T	I N E =======================================

getAddrByCoord()
{
        mov	bl, ch
        mov	bh, 0		//// BX=CH*4+CH*3+CL
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
        mov	dx, #LOCAT_BUF
        add	bx, dx

        RETURN;
} //endp		getAddrByCoord

////////////////////////////////////////////////

copy8bytesUp()
{
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
        ret
}//endp		copy8bytesUp


//// =============== S U B	R O U T	I N E =======================================
//// D95

copy8bytesDown()
{
//// dx = si + 3
//// bx = si + 11 (dec)
//// cx = 8
////
//// si = dx  = (si + 3)
//// di = bx  = (si + 11)
//// copy (si+1Bh, si+3, 8)
//// si = si + 11
//// di = si + 3
////
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
        ret
}//endp		copy8bytesDown

//// =============== S U B	R O U T	I N E =======================================

clear26Bytes()
{
        push	si
        push	di
        push	cx
        push	si
        mov	DSBYTE[si], 0
        pop	di
        inc	di
        mov	cx, 26h
        cld
        rep movsb
        pop	cx
        pop	di
        pop	si
        or	DSBYTE[si], 80h // set work flag
        or	DSBYTE[si], 40h
        ret
} //endp		clear26Bytes

//// =============== S U B	R O U T	I N E =======================================

copy8bytes2()
{
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
        ret
} //endp		copy8bytes2

////////////////////////////////////////////////

//// 800
checkRoomBorder()
{
        mov	ah, DSBYTE[BLOCK_STATUS]
        and	ah, 0Fh
        mov	DSBYTE[BLOCK_STATUS], ah // clear block status

        mov	ah, DSBYTE[Y_COORD]
        IF (AH < 1) //// checking ceiling
            stanleyBlockDown(); // block up !

loc_814:
        mov	dx, DSWORD[#objYsize]
        mov	bh, DSBYTE[Y_COORD]
        mov	bl, DSBYTE[Y_COORD2]
        add	bx, dx
        mov	dx, 1300h
        IF (BX > DX)
            stanleyBlockUp(); // block down!

loc_82A:
        mov	bx, DSWORD[X_COORD2]
        mov	ah, bh
        IF (AH < 1)
            stanleyBlockLeft();

loc_837:
        mov	dx, DSWORD[#objXsize]
        add	bx, dx
        mov	ah, 26h
        IF (BH > AH)
            stanleyBlockRight();

        RETURN;
}

//// ------------------------------

stanleyBlockRight()
{
        or	DSBYTE[BLOCK_STATUS], 20h
        ret
}
//endp		checkRoomBorder

//// ===============
stanleyBlockDown()
{
        or	DSBYTE[BLOCK_STATUS], 80h

        ret
}
//endp		stanleyBlockDown
//// ===============
stanleyBlockLeft()
{
        or	DSBYTE[BLOCK_STATUS], 10h
        ret
}
//endp		stanleyBlockLeft
//// ===============
stanleyBlockUp()
{
        or	DSBYTE[BLOCK_STATUS], 40h
        ret
}
//endp		stanleyBlockUp


////////////////////////////////////////////////
////===========================================
// check ground
//
// output:
// AH = sprite under object
// set GROUND_BIT status if sprite = 0A2h

checkGround()
{
        mov	ah, DSBYTE[OBJ_STATUS]
        and	ah, 0Fh
        mov	DSBYTE[OBJ_STATUS], ah

        call	getObjSize
        call	checkRoomBorder
        call	getObjCoord

        mov	cx, 20h
        add	bx, cx //add 32 bytes

        mov	cx, DSWORD[#objYsize]
        add	bx, cx

        xchg	dx, bx
        mov	cx, DSWORD[#objXsize]
        shr	cx, 1
        add	bx, cx

        xchg	dx, bx
        mov	ch, bh
        mov	cl, dh
        call	getAddrByCoord
        mov	ah, DSBYTE[bx]
        cmp	ah, 0A2h
        jnb	short loc_7C5

        RETURN;
//// -----------
loc_7C5:
        or	DSBYTE[OBJ_STATUS], GROUND_BIT
        RETURN;
} //endp		checkGround

          ///////////////////////

//////////////////////////////////////////////////////
sub_1E29()
{
        sub_1E64();

        mov	cl, DSBYTE[DIRECTION]
        mov	bl, DSBYTE[X_COORD2]
        mov	bh, DSBYTE[X_COORD]

        cbwProcCX();

        add	bx, cx

        mov	DSBYTE[X_COORD2], bl
        mov	DSBYTE[X_COORD], bh
        ret
}
//////////////////////////////////////////////////////
// ?  collision detect on down ?
// fall

sub_1E64()
{
        mov	cl, DSBYTE[DIRECTION]
        mov	bx, DSWORD[X_RESERVE]

        cbwProcCX(); //

        add	bx, cx
        mov	DSWORD[X_COORD2], bx
        mov	cl, DSBYTE[STRENGHT_CNT]
        call	cbwProcCX
        mov	bx, DSWORD[Y_RESERVE]
        add	bx, cx
        mov	DSWORD[Y_COORD2], bx

        RETURN;
} //endp		sub_1E64

///////////////////

cbwProcCX()
{
        xchg	ax, cx
        cbw
        xchg	ax, cx
        ret
}

//---------------------------------------------------

paintScreen2__()
{
        mov	bx, #BOTTOM_SPRITES	// set BX = BOTTOM PANEL	SPRITE BUFFER ADDRESS
        call	paintBottomPanel__
        //call	clearStrenght__
        //call	setFood__
        //jmp	short setWater__
        ret
}

//---------------------------------------------------
paintBottomPanel__()
{
        mov	ah, DSBYTE[bx]	// // get	sprite number from [bx]
        cmp	ah, 0FFh	// // check the end of sprite buffer
        jnz	short loc_D35
        ret

setSpritePos:
        inc	bx  // byte code array = 0,x,y  where 0 is code for position indication
                 // read sprite position
        mov	ah, DSBYTE[bx]
        inc	bx
        mov	DSBYTE[#pSPR_XY+1], ah
        mov	ah, DSBYTE[bx]
        mov	DSBYTE[#pSPR_XY], ah
        inc	bx
        jmp	paintBottomPanel__

// ---------------------------------------------------------------------------
loc_D35:
        or	ah, ah // if (AH == 0) set sprite pos command
        jz	setSpritePos // if AH=0 goto D45H
        push	bx
        mov	al, ah
        mov	ah, 0
        call	typeBuf2Sprite__
        pop	bx
        inc	bx
        jmp	paintBottomPanel__

// --------------------------------------------------
typeBuf2Sprite__:
        mov	cx, DSWORD[#pSPR_XY]	 // CL = x // CH	 = y

                    // CX = *DDDC//
                    // AL = sprite number//
                    //
                    // paint_sprite(cx)//
                    //
                    // x++//
                    // if (x	> 40) goto end
                    // x = 0//
                    // y++//
                    // if (y	> 24) goto end

        call	writeSpriteBuf2__
        mov	cx, DSWORD[#pSPR_XY]
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
        mov	DSWORD[#pSPR_XY], cx

        RETURN;
}

////////////////////////

paintLocation__	()
{
    mov	di, #LOCAT_BUF
            mov	si, #LOCAT_BUF + 320H	//  320H
            mov	bx, 0

            loc_3587:
        mov	al, DSBYTE[di]
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
        cmp	bl, MAX_X_SPR // 40  MAX X SPRITES COUNT
        jnz	short loc_3587
        mov	bl, 0
        inc	bh
        cmp	bh, MAX_Y_SPR	// 20  MAX Y SPRITES COUNT
        jnz	short loc_3587
        mov	DSBYTE[#LOCK_STATUS1], 1
        //call	checkLocationPalette
        ret
}

//endp		paintLocation__
                 //////////////////

writeSprite1Buf1__()
{
        push	si
        push	di
        push	ax
        push	cx
        push	dx
        push	bx
        push	es

        mov	cl, 4
        shl	ax, cl

//        AX = AX * 16 + #GRBANK1;
//        SI = AX;

        add	ax, #GRBANK1 //; BUF1 sprites address
        mov	si, ax

        jmp	paintSprite

}// endp		writeSprite1Buf1__

///////////////////////
// input:
// AH = sprite number
// res:
// SI = sprite address
// paint sprite

writeSprite2Buf2__()
{
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
        add	ax, #GRBANK1 // BUF1 sprite address
        mov	si, ax
        jmp	short paintSprite
        ret 	//endp		writeSprite2Buf2__
}
///////////////////////

writeSpriteBuf2__ ()
{
        push	si		// ax = sprite number//
                    // ch, cl  = sprite position
        push	di
        push	ax
        push	cx
        push	dx
        mov	bx, cx
        push	bx
        push	es
        mov	cl, 4
        shl	ax, cl
        add	ax, #GRBANK2	// BUF2 sprites address
        mov	si, ax

paintSprite:
        mov	dx, 0B800h
        mov	es, dx
       // assume es:nothing
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
        //assume es:nothing
        pop	bx
        pop	dx
        pop	cx
        pop	ax
        pop	di
        pop	si
        ret
 }   //endp		writeSpriteBuf2__

////////////////////////////


setVideoMode()
{

//// AL = mode
    AX = 0x4;
    int	10h

    setPal0100__();

    RETURN;
}

setPal0100__()
{
        BX = 0x100;
        CSBYTE[#CURR_PALETTE] = BL;
        AX = 0x0B00;
        int	10h		// - VIDEO - SET	COLOR PALETTE
                    // BH = 00h, BL = border	color
                    // BH = 01h, BL = palette (0-3)
        RETURN;
}

// not used here
setPal_0101__()
{
        BX = 0x101;
        CSBYTE[#CURR_PALETTE] = BL;
        AX = 0x0B00;
        int	10h     // - VIDEO - SET COLOR PALETTE
                        // BH = 00h, BL = border color
                        // BH = 01h, BL = palette (0-3)
        RETURN;
}
////////////////////////////
//////////////////////////////////////////////////////////////

//===========================================

setInterrupts__()
{
        cli
        push	ds
        mov	ax, 0
        mov	ds, ax
        mov	bx, 24h // int 9
        mov	ax, DSWORD[bx]
        mov	CSWORD[#keybIntVectorOffset],	ax
        mov	DSWORD[bx], #keyboardInterrupt
        inc	bx
        inc	bx
        mov	ax, DSWORD[bx]
        mov	CSWORD[#keybIntVectorSegment],	ax
        mov	ax, cs
        mov	DSWORD[bx], ax
        mov	bx, 70h // int 1Ch
        mov	ax, DSWORD[bx]
        mov	CSWORD[#timerIntVectorOffset],	ax
        mov	DSWORD[bx], #timerInterrupt
        inc	bx
        inc	bx
        mov	ax, DSWORD[bx]
        mov	CSWORD[#timerIntVectorSegment],	ax
        mov	ax, cs
        mov	DSWORD[bx], ax
        mov	cx, 2E9Eh
        mov	al, cl
        out	40h, al		// Timer	8253-5 (AT: 8254.2).
        mov	al, ch
        out	40h, al		// Timer	8253-5 (AT: 8254.2).
        pop	ds
        sti

        RETURN;
} //endp		setInterrupts__

// ---------------------------------------------------------------------------
// SYSTEM TIMER INTERRUPT

timerInterrupt()
{
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
        inc	DSBYTE[#INT_TICK]
        cmp	DSBYTE[#INT_TICK], 0C8h
        jnz	short TI_INC // = 200?
        mov	DSBYTE[#INT_TICK], 0 // set 0
        or	DSBYTE[#timerVar64], 40h // +64

TI_INC:
        inc	DSBYTE[#SMALL_TICK]
        inc	DSBYTE[#BIG_TICK]
        test	DSBYTE[#BIG_TICK], 1
        jnz	short TI_EXIT

        //call	processSound // sound

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
}
// ---------------------------------------------------------------------------

keyboardInterrupt()
{
        cli
        push	ds
        push	ax
        push	bx
        push	cx
        mov	ax, cs
        add	ax, 0
        mov	ds, ax
        in	al, 60h		// 8042 keyboard	controller data	register
        xchg	ax, bx
        in	al, 61h		// PC/XT	PPI port B bits:
                    // 0: Tmr 2 gate	?? OR	03H=spkr ON
                    // 1: Tmr 2 data	?  AND	0fcH=spkr OFF
                    // 3: 1=read high switches
                    // 4: 0=enable RAM parity checking
                    // 5: 0=enable I/O channel check
                    // 6: 0=hold keyboard clock low
                    // 7: 0=enable kbrd
        mov	ah, al
        or	al, 80h
        out	61h, al		// PC/XT	PPI port B bits:
                    // 0: Tmr 2 gate	?? OR	03H=spkr ON
                    // 1: Tmr 2 data	?  AND	0fcH=spkr OFF
                    // 3: 1=read high switches
                    // 4: 0=enable RAM parity checking
                    // 5: 0=enable I/O channel check
                    // 6: 0=hold keyboard clock low
                    // 7: 0=enable kbrd
        xchg	al, ah
        out	61h, al		// PC/XT	PPI port B bits:
                    // 0: Tmr 2 gate	?? OR	03H=spkr ON
                    // 1: Tmr 2 data	?  AND	0fcH=spkr OFF
                    // 3: 1=read high switches
                    // 4: 0=enable RAM parity checking
                    // 5: 0=enable I/O channel check
                    // 6: 0=hold keyboard clock low
                    // 7: 0=enable kbrd
        xchg	ax, bx
        mov	bx, #KEYBOARD_TABLE

loc_3D8E:				// CODE XREF: _03C8:3D98j
        cmp	DSBYTE[bx], 0
        jz	short loc_3D9D
        cmp	al, DSBYTE[bx]
        jz	short loc_3D9A
        inc	bx
        jmp	short loc_3D8E
// ---------------------------------------------------------------------------

loc_3D9A:
        xor	DSBYTE[bx], 80h

loc_3D9D:
        in	al, 20h		// Interrupt controller,	8259A.
        or	al, 20h
        out	20h, al		// Interrupt controller,	8259A.

// ---------------------------------------------------------------------------

checkOPERA:
        // INFINITY CHEAT
        // CHECK 'opera' on keyboard
        // ...

loc_3DFF:
        pop	cx
        pop	bx
        pop	ax
        pop	ds
        sti

        iret

        playSound:
                ret // STUB
}

// ---------------------------------------------------------------------------
//3D25
keybIntVectorOffset:	dw  #keyboardInterrupt
//3D27
keybIntVectorSegment:	dw 1000h
//3D29
timerIntVectorOffset:	dw #timerInterrupt
//3D2B
timerIntVectorSegment:	dw 1000h

/////////////////////////////////////////////////////////////

// ---------------------------------------------------------------------------
//CURR_PALETTE	db 1
//-----------------------------------------------
//-----------------------------------------------------------
SMALL_TICK:	db 7Ch	   //
BIG_TICK:	dw 97E2h   //
//-----------------------------------------------------------
soundStatus:	db 0

//================


jumpSound:
smallJumpSound:
sound1:
loc_7F3B:
    db 0
// ======================================================

demo1Counter:	dw 0
byte_2634:	db 0
byte_2635:	db 14h
byte_2636:	db 1
word_2637:	dw 3239h
// ---------------------------------------------------------------------------
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
        db 0, 2 dup 6 , 0, 7Fh
loc_80CD:
        db 1, 4
rightFireTiles:
        db 7, 8, 0, 0
leftDieTiles:
        db 14h, 9, 0Ah
        db 2 dup 0
leftStunnedTiles:
        db 4, 0Bh, 0Ch, 2 dup 0
stanleyEatLeftTiles:
        db 4, 0Dh, 0Eh, 2 dup 0
swampDieTiles:
        db 4, 0Fh, 10h,	2 dup 0

loc_80F0:
        db 1
leftThrowTiles:
        db 11h, 14h, 0FFh, 0
loc_80F5:
        db 0
leftFallTiles:
        db 16h
leftJumpTiles:
        db 17h, 2 dup 81h
loc_80FA:
        db 1, 2 dup 15h ,	0FFh
        db 0
leftStartThrowTile:
        db 1
leftFireTiles:
        db 18h
        db 19h,	0, 0
startJumpLeftTiles:
        db 0, 2 dup 17h , 0, 7Fh
rightDieTiles:
        db 14h, 1Ah, 1Bh, 2 dup 0
rightStunnedTiles:
        db 4, 1Ch, 1Dh,	2 dup 0
stanleyEatRightTiles:
        db 4, 1Eh, 1Fh, 2 dup 0
        db 4, 20h
        db 21h,	0
blockTypes:
        db 0, 0, 28h, 50h, 0FFh, 3, 2Bh, 53h, 2 dup 0FFh
        db 0, 1
        db 2, 0FFh
loc_812A:
        db 5 dup 0FFh
loc_812F:
        db 5 dup 1

// ======================================================
animObjSizes: db 17h, 10h, 8, 6, 4, 9, 7,	6, 1, 24h
        db 8, 10h, 16h,	3 dup 10h , 15h, 5, 16h, 2 dup 0Fh , 0Dh
        db 6, 0Ch, 16h,	0Fh, 16h, 0Eh, 16h, 10h, 16h, 10h, 16h
        db 10h,	16h, 10h, 7, 4,	0Ch, 9,	3, 5, 3, 10h, 2	dup 0Ah
        db 0Ch,	0Eh, 10h, 2 dup 12h , 10h, 0Fh,	10h, 7,	2 dup 10h
        db 0Eh,	16h, 10h, 1Ah, 11h, 0Ch, 9, 2 dup 7 , 14h, 0Ch
        db 10h,	6, 27h,	12h, 27h, 12h, 9, 13h, 16h, 10h, 0Ch, 2	dup 9
        db 0Ch,	10h, 0Bh, 0Eh, 0Ch, 8, 10h, 0Fh, 0Bh, 16h, 10h
        db 4, 5, 11h, 10h, 0Eh,	10h, 0Bh, 20h, 16h, 11h, 19h, 2
        db 0Bh,	6

// ======================================================
CURR_PALETTE:	db 1
// ======================================================
weaponBacklightX: db 1Bh, 1Eh, 21h, 24h
//=======================================
KEYBOARD_TABLE:

WEAP1_BUTTON:	db 2			// '1'
WEAP2_BUTTON:	db 3			// '2'
WEAP3_BUTTON:	db 4			// '3'
WEAP4_BUTTON:	db 5			// '4'
byte_7D0B:	db 18h			// 'O'
byte_7D0C:	db 19h			// //P'
byte_7D0D:	db 10h			// 'Q'
byte_7D0E:	db 1Eh			// //A'
FIRE_BUTTON:	db 39h			// SPACE
BREAK_BUTTON:	db 46h		        // SCROLL LOCK
byte_7D11:	db 1Ch			// Up Arrow
byte_7D12:	db 12h,	13h, 1Fh        // E R S
DEMO_BUTTON:	db 20h			// 'D'
byte_7D16:	db 38h,	1Dh, 53h	// ALT CTRL DEL
byte_7D19:	db 3Bh			// 'F1'
byte_7D1A:	db 7Ah			// 'O'
byte_7D1B:	db 79h			// 'P'
byte_7D1C:	db 7Ch			// 'Q'
byte_7D1D:	db 7Bh			// 'A'
byte_7D1E:	db 77h			// SPACE
byte_7D1F:	db 78h			// SPACE
// ======================================================

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
//// ======================================================
#include "GRBANK1.INC"
#include "GRBANK2.INC"
#include "BOTPNL.INC"
#include "OBJGRAPH.INC"
#include "OBJFRDAT.INC"
#include "LOCOBJ.INC"
#include "LOCMAP.INC"
#include "VARDAT.INC"
//// ======================================================
dwSTACK:	dw 0F6h

