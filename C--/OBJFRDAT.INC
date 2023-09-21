//======================
// OBJECTS FRAMES DATA
// addr = 7A45
//======================

// SI+0Fh - object type

//0 - stanley
//1 - bumerang
//2 - rifle
//3 - bomb
//4 - chest
//5 - score
//6 - explosion
//7 - bird
//8 - bubbles
//9 - hungry flower
//A - switch
//B - eyes
//C - monkey
//D - man with axe
//E - tube-warrior
//F - spear-thrower
//10h - archer
//11h - shaman
//12h - tornado
//13h - axe
//14h - boom from tube
//15h - arch
//16h - arch2 / spear
//17h - smoke
//18h - trolley
//19h - smoke2
//1Ah - scorpion
//1Bh - varan
//1Ch - bat
//1Dh - man with baton
//1Eh - mermaid
//1Fh - baton
//20h - heart
//21h - ???
//22h - down arch
//23h - godness
//24h - godness
//25h - david
//26h - flying man
//27h - fire to down
//28h - diamond
//29h - bread
//2Ah - kettle (pot)
//2Bh - snake
//2Ch - spider
//2Dh - hunter
//2Eh - bullet
//2Fh - fish
//30h - fish2
//31h - crocodile
//32h - tambourine man
//33h - fliying diamond
//34h - OPERASOFT
//35h - SUPONGO
//36h - stanley word 'livignstone supongo'
//37h - 'no'

stanleyFramePtrs:
		// left side
		dw loc_8E69 // walk
		dw loc_8EF5
		dw loc_8E69
		
		dw loc_8F81
		dw loc_900D // sit
		
		dw loc_9125 // start fly
		dw loc_9099 // fly down
		
		dw loc_91B1 // throw
		dw loc_923D // throw2 
		
		dw loc_92C9 // die frame1
		dw loc_9355 // die frame2
		
		dw loc_93E1 // head boom
		dw loc_946D // head boom frame2
		
		dw loc_94F9 // flower eated
		dw loc_9585 // flower eated2
		
		dw loc_9611 // swamp die1
		dw loc_969D // swamp die2
		
		// right side
		dw loc_C831 
		dw loc_C8BD
		dw loc_C831
		
		dw loc_C949
		dw loc_C9D5
		
		dw loc_CA61
		dw loc_CAED
		
		dw loc_CB79
		dw loc_CC05
		
		dw loc_CC91
		dw loc_CD1D
		
		dw loc_CEC1
		dw loc_CF4D
		
		dw loc_CDA9
		dw loc_CE35
		
		dw loc_9611
		dw loc_969D
		
		// zero sprite
		dw loc_8DDD
		
bumerangPtrs:
		dw loc_9729
		dw loc_9739
		dw loc_9749
		dw loc_9759
		
riflePtrs:
		dw loc_9769 // right
		dw loc_C281 // left
		
bombPtrs:
		dw loc_9777
		
//stanley's chest
chestPtrs:
		dw loc_9787
		dw loc_9795
		dw loc_97F7
		dw loc_9899
		dw loc_9963
		dw loc_9A25
		dw loc_9ACB
		dw loc_9787
		
		dw loc_D607
		dw loc_D669
		dw loc_D70B
		dw loc_D7D5
		dw loc_D897
		dw loc_9ACB
		
scoreFramePtr:
		dw loc_9AFD // 100
		dw loc_9B23 // 250
		dw loc_9B49 // 500
		
explosionFramePtr:
		dw loc_9B6F
		dw loc_9BEF
		dw loc_9C6F
		dw loc_9BEF
		
birdFramePtr:
		dw loc_C15B
		dw loc_C1BD
		dw loc_C15B
		
		dw loc_C21F
		
		dw loc_9CEF
		dw loc_9D51
		dw loc_9CEF
		
		dw loc_9DB3
		
bubblesFramePtr:
		dw loc_9E15
		dw loc_9E41
		dw loc_9E6D
		dw loc_9E41
		
flowerFramePtr:
		dw loc_DA95 // right
		dw loc_DB21
		
		dw loc_9FB1 // front
		
		dw loc_9E99 // left
		dw loc_9F25
		
		dw loc_9FB1 // front
		
switchFramePtr:
		dw loc_A03D
		dw loc_A077
		dw loc_A03D
		dw loc_A077
		
eyesFramePtr:
		dw loc_A0B1
		dw loc_A0D1
		dw loc_A0F1
		dw loc_A111
		dw loc_A0F1
		dw loc_A0D1
		dw loc_A0B1
		
		dw loc_8DDD // dark
		
monkeyFramePtr:		
		dw loc_D213
		dw loc_D28D
		
		dw loc_A131
		dw loc_A1AB
		
axemanFramePtr:
		dw loc_D107
		dw loc_D18D
		
		dw loc_A225
		dw loc_A2AB
		
tubeFramePtr:
		dw loc_D3FB
		dw loc_D47B
		dw loc_A331
		dw loc_A3B1
		
spearmanFramePtr:
		dw loc_D4FB
		dw loc_D581
		
		dw loc_A431
		dw loc_A4B7
		
archerFramePtr:
		dw loc_D307
		dw loc_D381
		
		dw loc_A53D
		dw loc_A5B7

shamanFramePtr:
		dw loc_D007
		dw loc_D087
		
		dw loc_A631
		dw loc_A6B1
		
coconutFramePtr:
		dw loc_A731
		
axeFramePtr:		
		dw loc_A741		
		dw loc_A753
		dw loc_A765
		dw loc_A777

		dw loc_A741	
		dw loc_A753
		dw loc_A765
		dw loc_A777
		
dartFramePtr:
		dw loc_C543
		dw loc_A789
		
spearFramePtr:
		dw loc_CFF3
		dw loc_A795
		
archFramePtr:
		dw loc_CFD9
		dw loc_A7A9
		
smokeFramePtr:
		dw loc_A7C3
		dw loc_A7F5
		dw loc_A827
		dw loc_A7F5
		
trolleyFramePtr:		
		dw loc_A859
		dw loc_A8AF
		
smoke2FramePtr:
		dw loc_A905
		dw loc_A95B
		dw loc_A9B1
		dw loc_A95B

scorpFramePtr:
		dw loc_C785
		dw loc_C7DB
		
		dw loc_AA07
		dw loc_AA5D
		
varanFramePtr:
		dw loc_DCB9
		dw loc_DCE5
		
		dw loc_AAB3
		dw loc_AADF
		
breadFramePtr:
		dw loc_AB0B // bread
		dw loc_AB45 // hamburger
		
kettleFramePtr:
		dw loc_ABBD // teapot
		dw loc_AB7B // pitcher
		
stoneFramePtr:		
		dw loc_ABF7 // stone
		dw loc_ABF7 // 
		dw loc_ABF7 //
		dw loc_AC15 // stone blink
		
batFramePtr:
		dw loc_AC33
		dw loc_AC89
		dw loc_ACDF
		dw loc_AC89
		
piranhaFramePtr:
		dw loc_D9D1
		dw loc_DA33
		dw loc_AD35
		dw loc_AD97
		
fishFramePtr:
		dw loc_D93D
		dw loc_D987
		
		dw loc_ADF9
		dw loc_AE43
		
tambmanFramePtr:
		dw loc_AE8D
		dw loc_AF13
		
tornadoFramePtr:
		dw loc_AF99
		dw loc_B019
		
mermaidFramePtr:
		dw loc_B099
		dw loc_B0F3
		dw loc_B099
		dw loc_B0F3
		
batnmanFramePtr:
		dw loc_DBAD
		dw loc_DC33
		
		dw loc_B14D
		dw loc_B1D3
		
heartFramePtr:
		dw loc_B259
		
batonFramePtr:
		dw loc_B26D
		dw loc_B27F
		dw loc_B291
		dw loc_B2A3
		dw loc_B26D
		dw loc_B27F
		dw loc_B291
		dw loc_B2A3
		
darchFramePtr:
		dw loc_B2B5
		dw loc_B2B5
		
godnessFramePtr:
		dw loc_B8DF
		dw loc_C54F
		
davidFramePtr:
		dw loc_B2D7
		dw loc_B2D7
		
		dw loc_B34B
		dw loc_B34B
		
snakeFramePtr:
		dw loc_DD11
		dw loc_DD55
		
		dw loc_B3BF
		dw loc_B403
		
flmanFramePtr:		
		dw loc_B447
		dw loc_B4C7
		dw loc_B447
		dw loc_B4C7
		
dwnfireFramePtr:
		dw loc_B547
		dw loc_B56D
		
spiderFramePtr:
		dw loc_B593
		dw loc_B5D5
		
hunterFramePtr:
		dw loc_C293
		dw loc_C31F
		dw loc_C3AB
		dw loc_C31F
		
		dw loc_B617
		dw loc_B6A3
		dw loc_B72F
		dw loc_B6A3
		
bulletFramePtr:		
		dw loc_B8C7
		dw loc_B8CF
		dw loc_B8C7
		dw loc_B8D7
		
crocodileFramePtr:
		dw loc_C437
		dw loc_C4BD
		
		dw loc_B7BB
		dw loc_B841
		
fldiamFramePtr:
		dw loc_ABF7
		
operasoftFramePtr:
		dw loc_BB15
		
supongoFramePtr:
		dw loc_C003
		
lsFramePtr:		
		dw loc_BF1D // livingstone supongo
		dw loc_BBEF // continuara
		
noFramePtr:			
		dw loc_BDBB // no
		dw loc_BDF9 // ok



objFramePtrs:
		dw stanleyFramePtrs //0 - stanley
		dw bumerangPtrs //1 - bumerang
		dw riflePtrs // 2 - rifle
		dw bombPtrs // 3 - bomb
		dw chestPtrs // 4 - chest
		dw scoreFramePtr // 5 - 100$
		dw explosionFramePtr // 6 - explosion
		dw birdFramePtr // 7 - 250
		dw bubblesFramePtr// 8 - bubbles
		dw flowerFramePtr // 9 - flower
		dw switchFramePtr // A - switch
		dw eyesFramePtr // B - eyes
		dw monkeyFramePtr // C - monkey
		dw axemanFramePtr // D - axe man
		dw tubeFramePtr // E - tube
		dw spearmanFramePtr // F - spear
		dw archerFramePtr // 10 - archer
		dw shamanFramePtr // 11 - shaman
		dw coconutFramePtr // 12 - tornado
		dw axeFramePtr // 13 - axe
		dw dartFramePtr // 14 - boom
		dw spearFramePtr // 15 - arch
		dw archFramePtr // 16 - arch2
		dw smokeFramePtr // 17 - smoke
		dw trolleyFramePtr // 18 - trolley
		dw smoke2FramePtr // 19 - smoke2
		dw scorpFramePtr // 1A - scorp
		dw varanFramePtr //1Bh - varan
		dw batFramePtr //1Ch - bat
		dw batnmanFramePtr	//1Dh - man with baton
		dw mermaidFramePtr	//1Eh - mermaid
		dw batonFramePtr //1Fh - baton
		dw heartFramePtr //20h - heart
		dw tornadoFramePtr // 21h - tornado
		dw darchFramePtr // 22h - down arch
		dw godnessFramePtr	// 23h - godness
		dw godnessFramePtr // -/-
		dw davidFramePtr // david
		dw flmanFramePtr // flying man
		dw dwnfireFramePtr // fire to down
		dw stoneFramePtr // diamond
		dw breadFramePtr // bread
		dw kettleFramePtr // kettle
		dw snakeFramePtr  // snake
		dw spiderFramePtr // spider
		dw hunterFramePtr  // hunter
		dw bulletFramePtr // bullet
		dw piranhaFramePtr // fish
		dw fishFramePtr // fish2
		dw crocodileFramePtr // crocodile
		dw tambmanFramePtr // tambourine man
		dw fldiamFramePtr //  fliying diamond
		dw operasoftFramePtr // OPERASOFT
		dw supongoFramePtr // SUPONGO
		dw lsFramePtr // 'livignstone supongo'
		dw noFramePtr // 'no'

//=========================
