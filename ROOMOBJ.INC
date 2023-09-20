;==========================
; ROOM OBJECTS DESCRIPTIONS
;==========================
		
objProcPtrs:  
		dw loc_return ; stanley 
		dw bumerangProc ; bumerang
		dw rifleProc ; rifle
		dw bombProc ; bomb
		dw loc_return ; chest
		dw score100Proc ; 100$
		dw explosionProc ; explosion
		dw score250Proc ; 250$
		dw booblesProc ; bubbles
		dw loc_166D ; flower
		dw switchProc ; switch
		dw loc_1E85 ;
		dw loc_1E85 ; monkey C
		dw loc_1E85 ; axe man D
		dw loc_1E85 ; tube E
		dw loc_1E85 ; spear F
		dw loc_1E85 ; arhcher 10
		dw loc_1E85 ; shaman 11
		dw loc_1E85 ; tornado 12
		dw loc_1E85 ; axe 13
		dw loc_1E85 ; boom 14
		dw loc_1E85 ; arch 15
		dw loc_1E85 ; arch2 16
		dw loc_1E85 ; smoke 17
		dw trolleyProc ; trolley 18
		dw loc_174B ; smoke2 19
		dw loc_1E85 ; 1a
		dw loc_1E85 ; 1b
		dw loc_1E85 ; 1c
		dw loc_1E85 ; 1d
		dw loc_1E85 ; 1e
		dw loc_1E85 ; 1f
		dw loc_1E85 ; 20
		dw loc_174B ; 21
		dw downArchProc ; 22
		dw loc_1783 ; 23
		dw loc_return ; 24
		dw loc_1E85 ; 25
		dw loc_1E85 ; 26
		dw loc_178C ; 27
		dw loc_1E85
		dw loc_1E85
		dw loc_1E85
		dw loc_1E85
		dw loc_1E85
		dw loc_1E85
		dw loc_17DC
		dw loc_1E85
		dw loc_1E85
		dw loc_1E85
		dw loc_1E85
		dw loc_181A
		dw loc_return
		dw loc_return
		dw loc_return
		dw loc_return

locPointers:
		dw loc_0set ; 0
		dw loc_1set ; 1
		dw loc_2set ; 2
		dw loc_3set ; 3
		dw loc_4set ; 4
		dw loc_5set ; 5
		dw loc_6set ; 6
		dw loc_7set ; 7
		dw loc_8set ; 8
		dw loc_9set ; 9
		dw loc_Aset ; A
		dw loc_Bset ; B
		dw loc_Cset ; C
		dw loc_Dset ; D
		dw loc_Eset ; E
		dw loc_Fset ; F
		dw loc_10set ; 10
		dw loc_11set ; 11
		dw loc_12set ; 12
		dw loc_13set ; 13
		dw loc_14set ; 14
		dw loc_15set ; 15
		dw loc_16set ; 16
		dw loc_17set ;17
		dw loc_18set; 18
		dw loc_19set ; 19
		dw loc_1Aset ; 1A
		dw loc_1Bset ; 1B
		dw loc_1Cset ; 1C
		dw loc_1Dset ; 1D
		dw loc_1Eset ; 1E
		dw loc_1Fset ; 1F
		dw loc_20set ; 20
		dw loc_21set ; 21
		dw loc_22set ; 22
		dw loc_23set ; 23
		dw loc_24set ; 24
		dw loc_25set ; 25
		dw loc_26set ; 26
		dw loc_27set ; 27
		dw loc_28set ; 28
		dw loc_29set ; 29
		dw loc_2Aset ; 2A
		dw loc_2Bset ; 2B
		dw loc_2Cset ; 2C
		dw loc_2Dset ; 2D
		dw loc_2Eset ; 2E
		dw loc_2Fset ; 2F
		dw loc_30set ; 30
		dw loc_31set ; 31
		dw loc_32set ; 32
		dw loc_33set ; 33
		dw loc_34set ; 34
		dw loc_35set ; 35
		dw loc_36set ; 36
		dw loc_37set ; 37
		dw loc_38set ; 38
		dw loc_39set ; 39
		dw loc_3Aset ; 3A
		dw loc_3Bset ; 3B
		dw loc_3Cset ; 3C
		dw loc_3Dset ; 3D
		
; location descriptions
loc_0set:
		db 0FFh, 11h, 81h, 81h
		db 3
		db 80h, 07, 004, 00, 24h, 0, 03, 00
		db 00
		
		db 01
		db 0Ch	; monkey here ( 0Ch)
		db 00, 00, 03, 0A0h, 01 
		dw monkeyDef
		
		db 0
		db 2Fh  ; fish (02Fh)
		db 0, 0, 7, 0, 11h
		dw jumpPiranhaDef
		
		db 3
		dw setLoc0Raft
		dw loc_08DA
		dw loc_A26
		
loc_1set:
		db 7, 0FFh,	18h, 82h
		db 3
		
		db 0
		db 1Ah
		db 2 dup(0), 1Dh, 60h, 5
		dw offset someCrawlingDef
		
		db 0, 30h
		db 2, 0, 20h, 0, 10h
		dw piranhaDef
		
		db 1
		db 0Ch
		db 2 dup(0), 22h
		db 40h,	1
		dw monkeyDef
		
		db 2
		dw loc_08C2
		dw loc_08DA

loc_2set:
		db 2 dup(0FFh), 39h, 83h
		db 1
		
		db 0
		db 2Fh  ; fish
		db 2, 0, 20h, 0, 10h
		dw piranhaDef
		
		db 2
		dw loc_08C2
		dw loc_08DA
		
loc_3set:
		db 2 dup(0FFh), 6, 0FFh
		db 2
		
		db 1
		db 0Ch ; monkey
		db 2, 0, 23h, 0A0h, 1
		dw offset monkeyDef
		
		db 0
		db 30h ; piranha
		db 0, 0, 5, 0, 0Eh
		dw offset fishDef
		
		db 2
		dw loc_08C2
		dw loc_08DA
		
loc_4set: 
		db 2 dup(5), 2 dup(11h)
		db 3
		
		db 80h
		db 2Dh ; hunter
		db 3 dup(0), 40h, 0Fh
		dw offset hunterDef
		
		db 0
		db 9 ; flower
		db 2 dup(0), 0Eh, 40h, 0Fh
		db 0, 0
		
		db 0
		db 2Bh ; snake
		db 2, 0, 10h, 0, 11h
		dw offset loc_8B85
		
		db 1
		dw loc_2309
		
loc_5set:
		db 2 dup(6), 2 dup(4)
		db 4
		
		db 80h
		db 2Dh ; hunter
		db 4, 0, 24h, 40h, 0Fh
		dw offset walkHunterDef
		
loc_82CC:
		db 80h
		db 2Ah ; pot
		db 2 dup(0), 12h, 0A0h, 10h
		dw offset potDef
		
loc_82D5:
		db 82h
		db 29h ; bread
		db 2 dup(0), 21h, 80h, 10h
		dw offset breadDef
		
		db	0
		db 2Bh ; snake (02Bh)
		db	2 dup(0), 1Fh, 0, 6
		dw someCrawlingDef
		
		db 2
		dw checkPit
		dw loc_2309
		
; START LOCATION
loc_6set: 
		db 0FFh, 3, 5 ,5
		db 3
		
		db 0
                db 0 ; stanley
                db 0, 0, 3, 40h, 0Fh
		db 0, 0
		
		db 0
		db 9 ; flower (9)
                db 0, 0, 1Fh, 40h, 0Fh
		db 0, 0
		
		db 0
                db 2Bh ; snake (02Bh)
                db 0, 0, 1Dh, 0, 6 ; 6=y ; 1D = x
		dw leftRightEnemyDef1
		
		db 1
		dw checkPit
		
loc_7set:
		db 2 dup(8)
		db 2 dup(1)
		db 4
		
		db 0
		db 1Bh ; varan
		db 2, 40h,	7, 40h,	7
		dw leftRightEnemyDef2
		
		db 0
		db 1Ah ; scorpion
		db	2 dup(0), 14h, 60h, 10h
		dw leftRightEnemyDef1
		
		db 0, 1Ch ; bat
		db 2 dup(0), 0Ch, 0, 4
		dw batDef

loc_832F:
		db 4
		db 29h ; bread
		db 1, 0, 0, 0, 7
		
		dw breadDef
		db 0
		
loc_8set:
		db 2 dup(9), 2 dup(7)
		db 3
		db 0, 1Bh ; varan
		db 2 dup(0), 1Dh, 20h, 11h
		dw leftRightEnemyDef1
		
		db 0, 30h ; 
		db 2 dup(0), 0Eh, 0, 11h
		dw loc_8C2A
		
loc_8350:
		db 94h,	28h ; stone
		db 2 dup(0), 2, 0, 2
		dw stoneDef
		
		db 0
		
loc_9set:
		db 2 dup(0Ah)
		db 2 dup(8)
		db 3
		
		db 80h, 2Dh ; 
		db 4, 0, 24h, 20h, 0Dh
		dw walkHunterDef
		
		db 0, 1Ah ;
		db 2 dup(0), 8,	60h, 10h
		dw loc_8B75
		
		db 0, 1Ch ;
		db 2 dup(0)
		db 0Dh,	0, 7
		dw batDef
		
		db 1
	    dw loc_2309
		
loc_Aset:
		db 2 dup(0Bh),	2 dup(9)
		db 4
		
		db 0, 1Bh ;
		db 2 dup(0), 1Bh, 20h, 11h
		dw leftRightEnemyDef1
		
		db 0, 1Ah ;
		db 2, 0, 0Ch
		db 60h, 7
		dw leftRightEnemyDef1
		
		db	0, 1Ah ;
		db	2 dup(0), 6, 60h
		db 10h
		dw loc_8B75
		
loc_839D:
		db 6
		db 2Ah ; pot
		db 1, 0, 5, 20h,	10h
		dw potDef
		
		db 0
		
loc_Bset:
		db 2 dup(0Ch), 2 dup(0Ah)
		db 4
		
		db 0, 1Ch ; 
		db 2 dup(0), 0Ah
		db 0, 6
		dw batDef
		
		db 0, 1Ch ;
		db 2 dup(0), 18h, 0, 3
		dw batDef
		
		db	0, 1Bh;
		db 2 dup(0), 5, 20h, 11h
		dw someCrawlingDef
		
		db 0, 1Ah
		db 2 dup(0), 14h, 60h, 10h
		dw leftRightEnemyDef1
		
		db 0
		
loc_Cset:
		db 2 dup(0Dh), 2 dup(0Bh)
		db 3
		
		db 80h, 2Dh
		db	3 dup(0), 20h, 0Fh
		dw hunterDef
		
		db 0, 1Ch
		db 2 dup(0), 10h, 0, 9
		dw batDef
		
loc_83E8:		
		db 88h,	2Ah ; pot
		db 2 dup(0)
		db 6, 40h, 8
		dw potDef
		
		db 2
		dw loc_19A2
		dw loc_2309
		
loc_Dset:		
		db 2 dup(0Eh)
		db 25h,	0Ch
		db 3
		
		db 80h, 2Dh ;
		db 3 dup(0), 40h, 6
		dw hunterDef
		
		db 1, 0Dh;
		db 2, 0, 20h, 40h, 5
		dw axeManDef
		
loc_840D:
		db 8Ah, 29h ; bread
		db 2 dup(0)
		db 10h,	0, 3
		dw breadDef
		
		db	3
		dw trolleyRunProc
		dw loc_19A2
		dw loc_2309
		
loc_Eset:
		db 2 dup(0Fh), 2 dup(0Dh)
		db 2
		
		db 80h, 2Dh ;
		db	4, 0, 24h, 20h
		db 6
		dw walkHunterDef
		
		db 1
		db 0Dh ;
		db	2 dup(0), 0Eh, 40h, 6
		dw axeManDef
		
		db 3
		dw trolleyRunProc
		dw loc_19A2
		dw loc_2309
		
loc_Fset:
		db 2 dup(10h), 2 dup(0Eh)
		db 3
		
		db 80h,	2Dh ;
		db 4
		db 0, 24h, 40h,	6
		dw walkHunterDef
		
		db 1, 0Dh ;
		db 2, 0, 1Ah, 40h, 6
		dw axeManDef
		
		db 2, 0Dh ;
		db 2 dup(0), 5, 40h, 6
		dw axeManDef
		
		db 3
		dw trolleyRunProc
		dw loc_19A2
		dw loc_2309
		
loc_10set:
		db 12h, 18h, 2 dup(0Fh)
		db 3
		
		db 1, 0Dh ; axeman
		db 2 dup(0), 1Ch, 40h, 6
		dw axeManDef
		
		db 2, 0Dh ; axeman
		db 0, 0, 9
		db 40h, 6 ;
		dw axeManDef
		
loc_8479:
		db 96h, 28h ; stone
		db 2 dup(0), 6, 0, 6
		dw stoneDef
		
		db 2
		dw trolleyRunProc ; trolley
		dw loc_19A2 ; dust smoke
		
loc_11set:
		db 2 dup(4), 2 dup(0)
		db 3
		
		db 80h,	7 ;
		db 2 dup(0), 2,	0, 7
		db 0, 0
		
		db 1, 0Ch ;
		db 2, 0, 23h, 0A0h, 1
		dw monkeyDef
		
		db 2, 0Ch
		db 2	dup(0),	14h, 0A0h, 8
		dw monkeyDef
		
		db 2
		dw loc_A26
		dw checkPit

loc_12set:
		db 2 dup(13h), 0FFh, 10h
		db 3
		
		db 80h,	7 ;
		db 2 dup(0), 1,	0, 3
		db 2 dup(0)
		
		db 1, 0Ch ;
		db 2, 0, 17h, 0A0h, 8
		dw monkeyDef
		
		db 0, 31h ;
		db 2 dup(0),	5, 0, 11h
		dw loc_8B95
		
		db 1
		dw loc_A26
		
loc_13set:
		db 2 dup(14h), 2 dup(12h)
		db 3
		
		db 1, 0Fh ; spear-thrower
		db 2, 0, 1Ah, 40h, 5
		dw spearThrowerDef
		
		db	2, 0Fh ; spear-thrower
		db	0, 0, 0Dh
		db 40h,	8
		dw spearThrowerDef
		
		db 3,	10h ; archer
		db 2 dup(0), 15h, 0A0h, 0Fh
		dw archerDef
		db 0
		
loc_14set:
		db 2 dup(15h), 2 dup(13h)
		db 5
		db 80h, 2Dh ;
		db 0, 0, 0, 40h, 0Fh
		dw hunterDef 
		
		db 1, 0Eh ;
		db 2 dup(0), 6, 80h, 0Fh
		dw tubeWarriorDef
		
		db 2, 0Fh ;
		db 0, 80h, 12h, 40h, 9
		dw spearThrowerDef
		
		db 3
		db 11h,	2 ;
		db 0, 0Fh, 80h,	0Ch
		dw loc_8AAF
		
		db 4, 10h ;
		db	2 dup(0)
		db 20h,	0A0h, 0Fh
		dw archerDef
		db 1
		dw loc_2309
		
loc_15set:
		db 2 dup(16h), 2 dup(14h)
		db 5
		
		db 80h, 2Dh ;
		db	3 dup(0), 40h, 0Fh
		dw hunterDef
		
		db 1, 0Fh ;
		db 2 dup(0), 20h, 40h, 5
		dw spearThrowerDef
		
		db 2, 0Eh ;
		db 2 dup(0), 7
		db 60h,	8
		dw tubeWarriorDef
		
		db 3, 10h ;
		db 2 dup(0), 15h, 0A0h, 0Fh
		dw archerDef
		
loc_854E:
		db 0Ch, 29h ; bread
		db 1, 0, 0Ah, 0, 0Eh
		dw breadDef
		
		db 2
		dw loc_2309
		dw loc_2309
		
loc_16set:
		db 2 dup(17h), 2 dup(15h)
		db 5
		
		db 1, 0Fh ;
		db 2 dup(0), 14h, 40h, 3
		dw spearThrowerDef
		
		db 2, 0Eh ;
		db 0, 0, 0Bh, 60h, 0Bh
		dw tubeWarriorDef
		
		db	3, 11h ;
		db	2, 0, 1Ah, 80h,	0Ch
		dw loc_8AAF
		
		db	4, 10h
		db	2, 0, 13h, 0A0h, 0Fh
		dw archerDef
		
loc_8585:
		db 0Eh, 2Ah ; pot
		db 1, 0, 4, 60h, 10h
		dw potDef
		
		db 0
		
loc_17set:
		db 2 dup(18h),	2 dup(16h)
		db 5
		
		db 1, 0Eh, 2	dup(0),	6, 60h,	8
		dw tubeWarriorDef
		
		db 2, 0Eh, 2	dup(0)
		db 20h,	60h, 8
		dw tubeWarriorDef
		
		db 3, 0Fh
		db 2 dup(0), 10h, 40h
		db 3
		dw spearThrowerDef
		
		db	5, 11h
		db	2, 0, 9, 60h, 0Ch
		dw loc_8AAF
		
loc_85B8:
		db 98h
		db 28h ; stone
		db 0, 0, 15h, 0, 5
		dw stoneDef
		
		db 1
		dw checkPit
		
loc_18set:
		db 0FFh, 1, 2 dup(17h)
		db 2
		
		db 1, 0Eh, 0, 0, 06, 80h, 0Fh
		dw tubeWarriorDef
		
		;db 1, 0Eh, 0, 0, 06, 80h, 0Fh
		;dw tubeWarriorDef
		
		db 2, 10h, 2, 0, 1Ah, 0A0h, 0Fh
		dw archerDef
		
		db 0
		
loc_19set:
		db 2 dup(2Ah)
		db 2 dup(1Ah)
		db 3
		
		db 0, 9
		db 0, 0, 21h, 60h, 0Fh
		db 0, 0
		
		db 1, 10h
		db 2, 0, 16h, 0A0h, 0Fh
		dw archerDef
		
		db 2, 0Eh, 2 dup(0)
		db 6, 80h, 0Fh
		dw tubeWarriorDef
		db 0
		
loc_1Aset:
		db 2 dup(19h), 2 dup(1Bh)
		db 4
		
		db 80h,	7 ;
		db 0, 0, 2,	0, 3
		db 0, 0
		
		db 0, 31h ;
		db 0, 0, 5, 0E0h, 10h
		dw loc_8B95
		
		db 0, 9 ;
		db 0, 0, 22h,	60h, 0Fh
		db 0, 0
		
loc_861D:
		db 1Eh, 2Ah ; pot
		db 1, 0, 1Dh, 40h, 10h
		dw potDef
		
		db 1
		dw loc_A26
		
loc_1Bset:
		db 2 dup(1Ah), 2 dup(1Ch)
		db 2
		
		db 1, 0Eh
		db 0, 0
		db 0Fh,	80h, 0Fh
		dw tubeWarriorDef
		
		db 2, 0Eh ;
		db 2, 0, 1Fh, 60h, 0Dh
		dw tubeWarriorDef
		
		db 0
		
loc_1Cset:
		db 2 dup(1Bh), 2 dup(1Dh)
		db 2
		
		db 0, 0 ; stanley
		db 0, 0, 0, 40h, 0Dh
		db 0, 0
		
		db 0, 23h ; godness
		db 0, 20h, 11h, 20h, 6
		db 0, 0
		
		db 1
		dw godnessRoomProc
		
loc_1Dset:
		db 2 dup(0FFh), 2 dup(1Eh)
		db 3
		
		db 1, 0Ah ;
		db 2, 0, 7, 0, 2
		dw loc_1F67
		
		db 2, 0Ah ;
		db 2, 0, 1Eh, 0, 2
		dw loc_1F6F
		
		db 0, 26h ;
		db 0, 0, 1Fh, 40h,	0Fh
		dw flyManDef
		
		db 2
		dw loc_32A5
		dw loc_18CE
		
loc_1Eset:
		db 2 dup(1Dh), 2 dup(1Fh)
		db 2
		
		db 1, 0Fh ;
		db 2, 0, 22h, 40h, 5
		dw spearThrowerDef
		
		db 2, 10h ;
		db 2, 0, 1Eh, 80h, 0Ch
		dw archerDef
		
		db 1
		dw loc_18D3
		
loc_1Fset:
		db 2 dup(1Eh), 2 dup(20h)
		db 2
		
		db 1, 0Fh
		db 0, 0, 3, 40h, 5
		dw spearThrowerDef
		
		db	2, 10h,	2, 0, 1Ah, 80h,	0Eh
		dw archerDef
		
		db 1
		dw loc_18D8
		
loc_20set:
		db 2 dup(1Fh), 2 dup(21h)
		db 2
		db 1, 0Fh 
		db 2, 0, 20h, 40h, 9
		dw spearThrowerDef
		
		db 2, 0Eh ; tube-warrior
		db 2, 0, 17h, 60h, 0Ch
		dw tubeWarriorDef
		
		db 1
		dw loc_18DD
		
loc_21set:
		db 2 dup(20h), 2 dup(22h)
		db 3
		
		db 1, 10h ;
		db 0, 0, 0Ah, 80h, 0Dh
		dw archerManDef
		
		db 2, 10h ;
		db 2 dup(0), 1Ah, 80h, 0Dh
		dw archerManDef
		
		db 3, 26h ;
		db 0, 0
		db 1Fh,	40h, 9
		dw flyManDef
		
		db 0
		
loc_22set:
		db 2 dup(21h), 2 dup(23h)
		db 4
		
		db 80h,	2Dh, 4,	0, 24h,	20h, 9
		dw walkHunterDef
		
		db 0, 31h ; crocodile
		db 0, 0, 8, 0C0h, 10h
		dw crocodileDef1
		
		db 0, 31h
		db 2, 0, 1Ch, 0C0h, 10h
		dw crocodileDef2
		
loc_870F:
		db 20h, 29h ; bread
		db 0, 0, 8, 40h, 10h
		dw breadDef
		
		db 1
		dw loc_2309
		
loc_23set:
		db 2 dup(22h), 2 dup(24h)
		db 1
		
		db 80h, 2Dh ;
		db 4, 0
		db 24h,	20h, 9
		dw walkHunterDef
		
		db 3
		dw loc_1A28
		dw checkFire
		dw loc_2309
		
loc_24set:
		db 2 dup(23h)
		db 2 dup(2Bh)
		db 3
		
		db 80h, 7
		db 0, 0, 23h, 0, 2
		db 0, 0
		
		db 0, 2Bh
		db 0, 0, 16h, 0, 11h
		dw loc_8B75
		
		db 0, 9
		db 0, 0, 1Ah, 40h, 0Fh
		db 0, 0
		
		db 1
		dw loc_A26
		
loc_25set:
		db 0FFh, 0Dh, 26h, 0FFh
		db 3
		
		db 1, 1Eh
		db 0, 0, 0Bh, 40h,	10h
		dw mermaidDef
		
		db 2, 1Eh, 2, 0, 1Ch, 40h, 10h
		dw mermaidDef
		
		db 3, 1Dh, 2, 0
		db 18h,	40h, 4
		dw batonManDef
		
		db 3
		dw loc_08D4
		dw loc_08DA
		dw loc_19C9
		
loc_26set:
		db 0FFh, 25h, 27h, 0FFh
		db 4
		
		db 1, 1Eh ;
		db 2 dup(0), 16h, 40h
		db 10h
		dw mermaidDef
		
		db 2, 1Dh ;
		db 2, 0, 5, 40h, 4
		dw batonManDef
		
		db 3, 1Dh ;
		db 0, 0, 1Ch, 40h, 4
		dw batonManDef
		
loc_879A:
		db 9Ah, 28h ; stone
		db 0, 0, 16h, 0, 0Ah
		dw stoneDef
		
		db 3
		dw loc_08CE
		dw loc_08DA
		dw loc_19C9
		
loc_27set:
		db 0FFh, 26h, 28h, 0FFh
		db 3
		
		db 1, 1Eh ;
		db 0, 0
		db 10h,	40h, 10h
		dw mermaidDef
		
		db 2,	1Dh, 2,	0, 19h,	40h, 4
		dw batonManDef
		
loc_87C1:
		db 92h, 29h ; bread
		db 1, 0, 3, 0, 2
		dw breadDef
		
		db 1
		dw loc_19C9
		
loc_28set:
		db 0FFh, 27h, 29h, 0FFh
		db 2
		
		db 1, 1Eh, 0, 0, 12h
		db 40h,	10h
		dw mermaidDef
		
		db	2, 1Dh,	0, 0, 11h, 40h, 4
		dw batonManDef
		db 1
		dw loc_19C9
		
loc_29set:
		db 0FFh, 28h, 2Ah, 0FFh
		db 3
		
		db 1
		db 1Eh,	2 dup(0), 12h, 40h, 10h
		dw mermaidDef
		
		db 2, 1Dh, 2
		db 0, 20h, 40h,	6
		dw batonManDef
		
loc_87FE:
		db 90h, 2Ah ; pot
		db	2 dup(0), 25h
		db 40h,	7
		dw potDef
		
		db 3
		dw loc_08CE
		dw loc_08DA
		dw loc_19C9
		
loc_2Aset:
		db 0FFh, 29h, 19h, 81h
		db 2
		
		db 0, 9
		db 0, 0, 21h, 40h, 7
		db 0, 0
		
		db 0, 2Fh
		db 2, 0, 1Fh, 0, 11h
		dw piranhaDef
		
		db 2
		dw loc_08C8
		dw loc_08DA
		
loc_2Bset:
		db 2 dup(24h), 2 dup(0FFh)
		db 5
		
		db 80h, 7 ; bird
		db 0, 0, 1Eh
		db 0, 2, 0, 0
		
		db 1, 0Ch ; monkey
		db 2, 0, 1Ch, 0A0h, 6
		dw monkeyDef
		
		db 0, 9 ; flower
		db 0, 0, 11h, 60h, 0Fh
		db 0, 0
		
		db 0, 9 ; flower
		db 0, 0, 1Ch, 40h, 0Fh
		db 0, 0
		
loc_8853:
		db 22h, 2Ah ; pot
		db 0, 0, 21h, 40h, 8
		dw potDef
		
		db 2
		dw checkWell1
		dw loc_A26

loc_2Cset:
		db 3 dup(0FFh), 6Dh
		db 3	
		
		db 0, 0
		db 0, 0, 19h, 0, 0
		db 0, 0
		
		db 0, 1Ch
		db 0, 0, 10h, 0, 0Eh
		dw batDef
		
		db 0, 2Ch
		db 0, 0, 8, 0, 0Dh
		dw staticEnemyDef
		
		db 0
		
loc_2Dset:
		db 2 dup(0FFh),	31h, 6Eh
		db 3
		db 0, 1Ch ;
		db 0, 0, 17h, 0, 5
		dw batDef
		
		db 0, 2Bh
		db 0, 0, 1Fh, 0C0h, 0Ah
		dw leftRightEnemyDef2
		
		db 0, 2Ch
		db 0, 0, 1Eh, 0, 1
		dw staticEnemyDef
		
		db 1
		dw checkPaling
		
loc_2Eset:
		db 3 dup(0FFh), 6Fh
		db 4
		
		db 0, 1Ch
		db 0, 0, 12h, 0, 0Ah
		dw batDef
		
		db 0, 2Ch
		db 0, 0, 7,	0, 2
		dw staticEnemyDef
		
		db 0, 2Ch
		db 2 dup(0), 1Fh,	0, 4
		dw staticEnemyDef
		
		db 0, 2Ch
		db 2 dup(0), 1Eh, 0, 11h
		dw staticEnemyDef
		
		db 0
		
loc_2Fset:
		db 0FFh, 32h
		db 0FFh, 70h
		db 2
		
		db 0, 1Ch, 2 dup(0), 0Ah,	0, 0Ah
		dw batDef
		
		db 0, 2Ch, 2 dup(0), 17h, 0, 9
		dw staticEnemyDef
		
		db 1
		dw checkPaling
		
loc_30set:
		db 2 dup(0FFh),	2 dup(33h)
		db 2
		
		db 0, 1Ch ;
		db 0, 0, 19h, 0, 7
		dw batDef
		
		db 0, 1Ah ;
		db 0, 0, 3, 60h, 8
		dw leftRightEnemyDef1
		
		db 0
		
loc_31set:
		db 2 dup(2Dh), 2 dup(0FFh)
		db 3
		
		db 0, 0Ah ;
		db 2, 0, 12h, 0, 2
		dw loc_1CA1
		
		db 0, 0Bh ;
		db 0, 0, 1Ah, 0, 6
		dw eyesThingDef

loc_8918:
		db 24h,	29h
		db 1,	0, 21h,	0, 5
		dw breadDef
		
		db 2 
		dw loc_1A5B
		dw checkPaling
		
loc_32set:
		db 2 dup(0FFh), 2 dup(2Fh)
		db 2
		
		db 0, 0Ah ;
		db 2, 0, 9, 0, 2
		dw loc_1CB8
		
		db 0, 0Bh ;
		db 0, 0, 13h, 0, 0Ah
		dw eyesThingDef
		
		db 2
		dw loc_1A6F
		dw checkPaling
		
loc_33set:
		db 2 dup(30h), 2 dup(34h)
		db 2 dup(0)
		
loc_34set:
		db 2 dup(33h), 2 dup(36h)
		db 0
		
		db 1
		dw checkWell2
		
loc_35set:
		db 4 dup(0FFh)
		db 2
		
		db 0, 0
		db 0, 0, 14h, 0, 0
		db 0, 0
		
		db 0, 30h ;
		db 0, 0, 7, 0, 0Dh
		dw fishDef
		
		db 0
		
loc_36set:
		db 2 dup(34h), 2 dup(38h)
		db 2
		
		db 0, 1Ch ;
		db 0, 0, 22h, 0, 0Ah
		dw batDef
		
		db 0, 1Ch
		db 0, 0, 14h, 0, 5
		dw batDef
		db 0
		
loc_37set:
		db 0FFh, 0FEh, 2 dup(0FFh)
		db 3
		
		db 0, 0
		db 0, 0, 13h, 0, 0
		db 0, 0
		
		db 1, 0Ah
		db 2, 0, 20h, 0,	4
		dw loc_1F77
		
		db 2, 0Bh
		db 0, 0, 0Ch, 0, 0Ch
		dw eyesThingDef
		
		db 0
		
loc_38set:
		db 2 dup(36h)
		db 2 dup(3Bh)
		db 2
		
		db 80h, 2Dh
		db 4, 0, 24h, 40h, 0Fh
		dw walkHunterDef
		
		db	0, 31h
		db	0, 0, 8, 0A0h, 10h
		dw loc_8B95
		
		db 1
		dw loc_2309
		
loc_39set:
		db 0FFh, 2, 2 dup(0FFh)
		db 4
		
		db 2 dup(0), 5, 0, 2, 0, 4
		db 0, 0
		
		db 0, 7
		db 0, 0, 2,	0, 2
		db 0, 0
		
		db 0, 30h
		db 0, 0
		db 6, 0, 10h
		dw fishDef
		
loc_89DB:
		db 9Ch, 28h ; stone
		db	2 dup(0), 1Dh, 0, 6
		dw stoneDef
		
		db 0
		
loc_3Aset:
		db 2 dup(0FFh),	2 dup(0FEh)
		db 3
		
		db 4 dup(0), 13h
		db 4 dup(0)
		
		db 1, 0Ah ;
		db 2, 0, 1Dh,	0, 3
		dw loc_1F7D
		
		db 2, 0Bh ;
		db 2 dup(0), 0Ch, 0, 0Ch
		dw eyesThingDef
		
		db 0
		
loc_3Bset:
		db 2 dup(38h), 2 dup(3Ch)
		db 3
		
		db 80h, 7
		db 2 dup(0), 1, 0, 6
		db 2 dup(0)
		
		db 1, 0Fh
		db 2, 0, 23h, 40h, 0Dh
		dw spearThrowerDef
		
		db 2, 0Eh, 2, 0, 1Eh, 60h, 0Eh
		dw tubeWarriorDef
		
		db 1
		dw loc_A26
		
; FINAL ROOM
loc_3Cset:
		db 2 dup(3Bh), 2 dup(0FFh)
		db 2
		
		db 0, 0 ; stanley
		db 0, 0, 1, 40h, 0Dh
		db 0, 0
		
		db 0, 25h ; david
		db 0, 60h, 21h, 20h, 9
		dw stoneDef
		
		db 1
		dw loc_1B41
		
; SPLASH SCREEN
loc_3Dset:
		db 4 dup(0FFh)
		db 5
		
		db 0, 0 ; stanley
		db 0, 0, 5, 20h, 0Fh
		db 0, 0
		 
		db 0, 34h ;
		db 0, 0, 9, 0, 5
		db 0, 0
		
		db 0
		db 32h ; tambourine man
		db 0, 0
		db 1Dh ; x
		db 40h ;
		db 8 ; y
		dw offset staticEnemyDef
		
		db 0
		db 32h ; tambourine man
		db 1, 0
		db 22h ; x
		db 40h
		db 8 ; y
		dw offset staticEnemyDef
		
		db 0, 35h ;
		db 0, 0, 1Eh, 0, 5
		db 0, 0
		
		db 0
; =================================================
; OBJECTS ACTIONS DEFINES

eyesThingDef:
		db 6,	0, 7, 0, 7
		dw offset loc_1EA5
		
		db 6, 0Ch
		
monkeyDef:
		db 0Ah, 0
		db 1, 2, 3
		
		dw offset loc_2017
		
		db 0Fh, 16h
		dw offset coconutDef
		db 12h
		
axeManDef:		
		db 0Ah, 0
		db 1, 2, 3
		dw offset loc_204F
		
		db 10h, 16h
		dw offset axeDef
		db 13h
		
spearThrowerDef:
		db 0Ah, 0
		db 1, 2, 3
		dw offset loc_2079
		
		db 10h, 16h
		dw offset spearDef
		db 15h
		
tubeWarriorDef:		
		db 7, 0, 1
		db 2, 3
		dw offset loc_204F
		
		db 10h,	16h
		dw offset dartDef
		db 14h
		
loc_8AAF:		
		db 0Fh, 0, 1, 2, 3
		dw offset loc_2087
		
		db 10h,	16h
		dw offset loc_8B3C
		db 17h
		
batonManDef:
		db 0Ah, 0, 1
		db 2, 3
		dw offset loc_204F
		
		db 10h,	16h
		dw offset axeDef
		db	1Fh
		
archerDef:
		db 0Ah, 0, 1
		db 2, 3
		dw offset loc_208C
		
		db 10h,	16h
		dw offset archDef
		db 16h
		
archerManDef:		
		db 5, 0, 1, 2
		db 3
		dw offset loc_20C4
		
		db 10h, 16h
		dw offset archDef
		db 16h
		
mermaidDef:
		db 0Fh,	0, 1, 2
		db 3
		dw offset loc_2097
		
		db	10h, 16h
		dw offset heartDef
		db 20h
		
batDef:
		db 2, 0, 3,	0, 3
		dw offset loc_22C3
		
		db	0Eh, 0Fh
		
axeDef:		
		db 0, 0, 3, 4, 7
		dw offset loc_2183
		
		db 6, 7
		
archDef:
		db 3 dup(0)
		db 2 dup(1)
		dw offset loc_21B8
		db	2 dup(0Ah)
		
heartDef:
		db 5 dup(0)
		dw offset loc_21DD
		db 2 dup(7)
		
coconutDef:
		db 5 dup(0)
		dw offset loc_2140
		
		db 4, 7

spearDef:	
		db 3 dup(0), 2 dup(1)
		dw offset loc_21A3
		db 10h, 3
		
dartDef:		
		db 3 dup(0), 1, 1
		dw offset loc_2183
		
		db 5, 3
		
loc_8B2A:
		db 2, 0, 3
loc_8B2D:
		db 0, 3
		dw loc_8B2A
		db 10h, 0Ah
		
loc_8B33:		
		db 2, 0, 1
loc_8B36:
		db 0, 1
		dw loc_8B33
		db 0Ch, 14h
	
loc_8B3C:	
		db 2, 0, 3, 0, 3
		dw offset loc_21B0
		
		db	0Ah, 0Ch
		
someCrawlingDef:		
		db 2, 0, 1, 2, 3
		dw offset loc_21EB
		
		db 10h, 0Fh, 18h
		db 40h,	0, 18h,	0C0h, 0, 0FFh
		
leftRightEnemyDef2:		
		db 2, 0, 1,	2, 3
		dw offset loc_21EB
		db 10h,	0Fh, 1Ch, 0C0h,	0, 1Ch,	40h, 0,	0FFh
		
		
leftRightEnemyDef1:
		db 2, 0, 1, 2, 3
		dw offset loc_21EB

		db 10h, 0Fh, 1Ch, 40h,	0, 1Ch,	0C0h, 0, 0FFh
		
loc_8B75:		
		db 2, 0, 1, 2, 3
		dw offset loc_21EB
		
		db 10h,	0Fh, 28h, 40h
		db 0, 28h, 0C0h, 0, 0FFh
		
loc_8B85:
		db 2, 0, 1, 2, 3
		dw offset loc_21EB
		
		db 10h
		db 0Fh,	28h, 0C0h, 0, 28h, 40h,	0, 0FFh
		
loc_8B95:
		db 2, 0, 1, 2, 3
		dw offset loc_21F7
		
		db 20h, 0Bh,	50h, 40h, 0, 50h, 0C0h,	0, 0FFh
	
staticEnemyDef:	
		db 2, 0, 1, 0, 1
		dw offset loc_21EB
		db 0Bh, 0Fh, 64h, 2 dup(0), 0FFh
		
jumpPiranhaDef:		
		db 2, 0, 1, 2, 3
		dw offset loc_21EB
		
		db 2 dup(10h), 0Ch, 40h, 0, 10h
		db 20h,	0C0h, 20h, 40h,	0, 10h,	20h, 40h, 0Ch, 40h, 0
		db 0Ch,	0C0h, 0, 10h, 0E0h, 0C0h, 20h, 0C0h, 0,	10h, 0E0h
		db 40h,	0Ch, 0C0h, 0, 0FFh
		
piranhaDef:
		db 2, 0, 1, 2, 3
		dw offset loc_21EB
		
		db 2	dup(10h)
		db 20h,	0C0h, 0, 0Ch, 0E0h, 0C0h, 14h, 0C0h, 0,	0Ch, 0E0h
		db 40h,	10h, 0C0h, 0, 10h, 40h,	0, 0Ch,	20h, 0C0h, 14h
		db 40h,	0, 0Ch,	20h, 40h, 20h, 40h, 0, 0FFh
		
fishDef:
		db 2, 0, 1, 2
		db 3
		
		dw offset loc_21EB
		
		db 3 dup(10h), 40h, 0, 0Ch, 20h, 0C0h, 10h
		db 40h,	0, 0Ch,	20h, 40h, 10h, 40h, 0, 10h, 0C0h, 0, 0Ch
		db 0E0h, 0C0h, 10h, 0C0h, 0, 0Ch, 0E0h,	40h, 10h, 0C0h
		db 0, 0FFh
		
loc_8C2A:		
		db 2, 0, 1, 2,	3
		dw offset loc_21EB
		
		db 2	dup(10h), 4, 40h
		db 0, 0Ch, 20h,	0C0h, 0Ch, 40h,	0, 0Ch,	20h, 40h, 0Ch
		db 40h,	0, 0Ch,	0C0h, 0, 0Ch, 0E0h, 0C0h, 0Ch, 0C0h, 0
		db 0Ch,	0E0h, 40h, 4, 0C0h, 0, 0FFh
		
crocodileDef1:
		db 2, 0, 1, 2, 3
		dw offset loc_21F7
		
		db	20h, 0Bh, 48h, 40h, 0, 48h, 0C0h, 0, 0FFh

crocodileDef2:		
		db 2, 0
		db 1, 2, 3
		dw offset loc_21F7
		
		db 20h, 0Bh, 48h, 0C0h, 0, 48h, 40h
		db 0, 0FFh
		
flyManDef:
		db 1, 0, 1, 2,	3
		dw offset loc_21EB
		
		db 10h, 16h, 0Ch, 81h
		db 0C0h, 0Ch, 81h, 40h,	0Ch, 81h, 0C0h,	0Ch, 81h, 40h
		db 0Ch,	7Fh, 0C0h, 0Ch,	7Fh, 40h, 0Ch, 7Fh, 0C0h, 0Ch
		db 7Fh,	40h, 0FFh

breadDef:
		db 0FFh, 4 dup(0)
		dw offset loc_223B
		
		db 0Eh, 0Dh
		db 64h,	2 dup(0), 0FFh
		
potDef:		
		db 0FFh , 4 dup(0)
		dw offset loc_2250
		
		db 0Eh
		db 0Dh,	64h, 0, 0, 0FFh
		
stoneDef:
		db 5, 0, 3, 0, 3
		dw offset loc_2265
		
		db 0Ch
		db 0Ah,	64h, 0, 0, 0FFh

walkHunterDef:
		db 2, 0, 3, 4, 7
		dw offset hunterProc
		db 10h
		db 16h,	10h
		db 0C0h, 0, 10h, 40h, 0, 0FFh

hunterDef:		
		db 2, 0, 3, 4, 7
		dw offset hunterProc
		db 10h, 16h
		
;=============================
		
loc_8CD4:
		db 10h, 40h, 0, 10h, 0C0h, 0, 0FFh
		db 39h,	4 dup(0), 40h, 4, 26h, 4 dup(0), 40h, 5, 17h, 0
		db 11h,	0, 23h,	40h, 0Fh, 10h, 4 dup(0), 40h, 0Fh, 8, 0
		db 11h,	0, 23h,	40h, 5,	0
		
room_1D_defs:
		db 0, 0, 0, 0, 40h, 0Fh
		
;==================================
