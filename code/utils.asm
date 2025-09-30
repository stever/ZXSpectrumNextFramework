; ************************************************************************
;
; 	Utils file - keep all utils variables in this file
;
; port $123b
; 	bit 0 = WRITE paging on. $0000-$3fff write access goes to selected Layer 2 page
; 	bit 1 = Layer 2 ON (visible)
; 	bit 3 = Page in back buffer (reg 19)
; 	bit 6/7= VRAM Banking selection (layer 2 uses 3 banks) (0,$40 and $c0 only)
;
; ************************************************************************


; ************************************************************************
;
;	Function:	Enable the 256 colour Layer 2 bitmap
;
; ************************************************************************
Layer2on:
                ld      bc, $123b
		ld	a,(Port123b)
		or	2
		ld	(Port123b),a
                out	(c),a
                ret


; ************************************************************************
;
;	Function:	Disable the 256 colour Layer 2 bitmap
;
; ************************************************************************
Layer2off:
		ld      bc, $123b
		ld	a,(Port123b)
		and	$fd
		ld	(Port123b),a
                out	(c),a
                ret



; ************************************************************************
;
;	Function:	Clear the spectrum attribute screen
;	In:		A = attribute
;
;	Format:		F_B_PPP_III
;
;			F = Flash
;			B = Bright
;			P = Paper
;			I = Ink
;
; ************************************************************************
ClsATTR:
                ld      hl,AttrScreen
                ld      (hl),a
                ld      de,AttrScreen+1
                ld      bc,1000
                ldir
                ret


; ************************************************************************
;
;	Function:	clear the normal spectrum screen
;
; ************************************************************************
Cls:
		xor	a
                ld      hl,ULAScreen
                ld      (hl),a
                ld      de,ULAScreen+1
                ld      bc,6143
                ldir
                ret




; ******************************************************************************
;
; Function:	ReadMouse
;
; Used:		uses bc,a
; ******************************************************************************
ReadMouse:
		ld	bc,Kempston_Mouse_Buttons
		in	a,(c)
		ld	(MouseButtons),a

		ld	bc,Kempston_Mouse_X
		in	a,(c)
		ld	(MouseX),a

		ld	bc,Kempston_Mouse_Y
		in	a,(c)
		neg
		ld	(MouseY),a

		ret

MouseButtons	db	0
MouseX		db	0
MouseY		db	0



; ******************************************************************************
;
;	A  = hex value tp print
;	DE= address to print to (normal specturm screen)
;
; ******************************************************************************
PrintHex:
		push	hl
		push	af

		srl	a
		srl	a
		srl	a
		srl	a
		call	DrawHexCharacter
		inc	e

		pop	af
		and	$f
		call	DrawHexCharacter
		pop	hl
		ret


;
; A = NIBBLE hex value to print (0 to 15 only)
; DE= address to print to (normal specturm screen)
; uses:	hl,de
;
DrawHexCharacter:
		ld	hl,HexCharset
		add	a,a
		add	a,a		; *8
		add	a,a
		add	hl,a

		; data is aligned to 256 bytes
		ld	a,(hl)
		ld	(de),a
		inc	l
		inc	d
		ld	a,(hl)
		ld	(de),a
		inc	l
		inc	d
		ld	a,(hl)
		ld	(de),a
		inc	l
		inc	d
		ld	a,(hl)
		ld	(de),a
		inc	l
		inc	d
		ld	a,(hl)
		ld	(de),a
		inc	l
		inc	d
		ld	a,(hl)
		ld	(de),a
		inc	l
		inc	d
		ld	a,(hl)
		ld	(de),a
		inc	l
		inc	d
		ld	a,(hl)
		ld	(de),a
		ld	a,d
		sub	7
		ld	d,a
		ret



; ******************************************************************************
;
; Function:	Upload a set of sprites
; In:	E = sprite shape to start at
;		D = number of sprites
;		HL = shape data
;
; ******************************************************************************
UploadSprites
		; Upload sprite graphics
                ld      a,e			; get start shape
                ld	e,0			; each pattern is 256 bytes
.AllSprites:
                ; select pattern 2
                ld      bc, $303B
                out     (c),a

                ; upload ALL sprite sprite image data
                ld      bc, SpriteShape
.UpLoadSprite:
                outinb				; port=(hl), hl++

                dec     de
                ld      a,d
                or      e
                jr      nz, .UpLoadSprite
                ret


; ******************************************************************************
;
; Function:	Upload a set of sprites
; In:		E = sprite shape to start at
;		D = number of sprites
;		HL = shape data
;
; ******************************************************************************
UploadSpritesDMA
		; Upload sprite graphics
                ld      a,e			; get start shape
                ld	e,0			; each pattern is 256 bytes
.AllSprites:
                ; select pattern 2
                ld      bc, $303B
                out     (c),a

                ; upload ALL sprite sprite image data
                ld      bc, SpriteShape
.UpLoadSprite:
                outinb				; port=(hl), hl++

                dec     de
                ld      a,d
                or      e
                jr      nz, .UpLoadSprite
                ret


; ******************************************************************************
; Function:	Scan the whole keyboard
; ******************************************************************************
ReadKeyboard:
		; clear all keys first
		ld	b,39
		ld	hl,Keys
		xor	a
.lp1:		ld	(hl),a
		inc	hl
		djnz	.lp1

		ld	ix,Keys
		ld	bc,$fefe	;Caps,Z,X,C,V
		ld	hl,RawKeys
.ReadAllKeys:	in	a,(c)
		ld	(hl),a
		inc	hl

		ld	d,5
		ld	e,$ff
.DoAll:		srl	a
		jr	c,.notset
		ld	(ix+0),e
.notset:	inc	ix
		dec	d
		jr	nz,.DoAll

		ld	a,b
		sla	a
		jr	nc,ExitKeyRead
		or	1
		ld	b,a
		jp	.ReadAllKeys
ExitKeyRead:
		ret


; ******************************************************************************
; Function:	Upload copper
; In:		hl = address
;		de = size
; ******************************************************************************
UploadCopper:
		NEXTREG	$61,0
		NEXTREG	$62,0


.lp1:		ld	a,(hl)
		NEXTREG	$60,a

		inc	hl
		dec	de
		ld	a,d
		or	e
		cp	0
		jr	nz,.lp1
		ret


; ******************************************************************************
; Function:	DMACopy
; In:		hl = Src
; 			de = Dest
;			bc = size
; ******************************************************************************
Z80DMAPORT	equ 107
DMACopy:
		ld	(DMASrc),hl			; 16
		ld	(DMADest),de			; 20
		ld	(DMALen),bc			; store size
		ld	hl,DMACopyProg 			; 10
		ld	bc,DMASIZE*256 + Z80DMAPORT	; 10
		otir					; 21*20  + 240*4
		ret





; =============================================================
; Jun 2012, May 2015 Patrik Rak
; =============================================================
; modified by aralbrec
; * removed self-modifying code
; * seed passed in as parameter
; =============================================================
; Generates an 8-bit random number from an 75-bit seed
; CMWC generator passes all diehard tests.
; http://www.worldofspectrum.org/forums/discussion/39632/cmwc-random-number-generator-for-z80
; =============================================================


; enter : hl = seed * (75-bits, 10 bytes)
;
; exit  : a = random number [0,255]
;         seed updated
;
; uses  : af, bc, de, hl

;random:
	ld	hl,(Seed)

	ld	a,(hl)                 ; i = ( i & 7 ) + 1
	and	7
	inc	a
	ld	(hl),a

	inc	hl                     ; hl = &cy

	ld	b,h                    ; bc = &q[i]
	add	a,l
	ld	c,a
	jr	nc,.Skip1
	inc	b
.Skip1:
	ld	a,(bc)                 ; y = q[i]
	ld	d,a
	ld	e,a
	ld 	a,(hl)                 ; da = 256 * y + cy

	sub	e                      ; da = 255 * y + cy
	jr	nc,.Skip2
	dec	d
.Skip2
	sub	e                      ; da = 254 * y + cy
	jr	nc,.Skip3
	dec	d
.Skip3:
	sub	e                      ; da = 253 * y + cy
	jr	nc,.Skip4
	dec	d
.Skip4:
	ld	(hl),d                 ; cy = da >> 8, x = da & 255
	cpl                         	; x = (b-1) - x = -x - 1 = ~x + 1 - 1 = ~x
	ld	(bc),a                 ; q[i] = x

	ld	(Seed),hl
	ret

Random:
	ld	de,0     		; c,i

	ld	b,0
	ld	c,e
	ld	hl,RandomTable
	add	hl,bc

	ld	c,(hl)   		; y = q[i]

	push	hl

	ld	a,e      		; i = ( i + 1 ) & 7
	inc	a
	and	7
	ld	e,a

	ld	h,c      		; t = 256 * y
	ld	l,b

	sbc	hl,bc    		; t = 255 * y
	sbc	hl,bc    		; t = 254 * y
	sbc	hl,bc    		; t = 253 * y

	ld	c,d
	add	hl,bc    		; t = 253 * y + c

	ld	d,h      		; c = t / 256

	ld	(Random+1),de

	ld	a,l      		; x = t % 256
	cpl           			; x = (b-1) - x = -x - 1 = ~x + 1 - 1 = ~x

	pop	hl

	ld	(hl),a   		; q[i] = x
	ret


; This shake comes from "Super Crate Box", a GameMaker: Studio game by Vlambeer
; We'll use 0 to 15, not 0 to 10
;
;if shake > 10 {
;    shake = 10
;}
;__view_set( e__VW.XView, 0, 10+random(shake)-shake/2 )
;__view_set( e__VW.YView, 0, 10+random(shake)-shake/2 )
;
; if shake > 0
;      shake -= 0.5
; else
;      shake = 0
;
; if( shake > 5) {
;    shake -= 1
; }
;


DoScreenShake:
	ld	a,(Shake)
	cp	$f
	jr	c,.carryon
	ld	a,$f
.carryon:
	ld	(Shake),a

	ld	hl,shake0	; get shake table
	add	a,a
	add	a,a
	add	a,a
	add	a,a
	add	hl,a

	ld	a,(Shake)
	srl	a
	ld	b,a		; remember shake/2

	push	hl
	call	Random		; use a 0 to 7 number (but *2 for fraction)
	pop	hl
	push	hl
	and	$f
	add	hl,a
	ld	a,(hl)
	sub	b
	srl	a		; ditch fraction
	ld	(ShakeX),a

	call	Random		; use a 0 to 7 number (but *2 for fraction)
	pop	hl
	and	$f
	add	hl,a
	ld	a,(hl)
	sub	b
	srl	a		; ditch fraction
	ld	(ShakeY),a

;
; 	if shake > 0
;      	    shake -= 0.5
; 	else
;      	    shake = 0
;
;       if( shake > 5) {
;           shake -= 1
;       }
;
	ld	a,(Shake)
	and	a
	ret	z
	dec	a		; sub 0.5
	ld	(Shake),a

	cp	$7		; over 3.5?
	ret	c
	sub	2		; then sub 2
	test	$80
	jr	nz,.StoreIt
	ld	a,0		; gone neg?
.StoreIt:
	ld	(Shake),a

	ret



