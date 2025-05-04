; ************************************************************************
;
;	General equates and macros
;
; ************************************************************************

	; define segments
        seg     CODE_SEG, 4:$0000,$8000				; flat address
        seg     DATA_SEG, 0:$0000,$C000				; Data
        seg     IRQ_SEG,  1:$1cfc,$fcfc				; IRQ vector/routine
        seg	FILE_SEG, 20:$0000,$0000			; Start of files (after screens/layer2 etc)

; Hardware
Kempston_Mouse_Buttons		equ	$fadf
Kempston_Mouse_X		equ	$fbdf
Kempston_Mouse_Y		equ	$ffdf
Mouse_LB			equ	1			; 0 = pressed
Mouse_RB			equ	2
Mouse_MB			equ	4
Mouse_Wheel			equ	$f0

SpriteReg			equ	$57
SpriteShape			equ	$5b

ULAScreen			equ	$4000
AttrScreen			equ	((ULAScreen)+(32*192))
ULAScreenPysical		equ	(10*8192)
AttrScreenPysical		equ	((ULAScreenPysical)+(32*192))




; ************************************************************************
;	Keyboard values
; ************************************************************************
; half row 1
VK_CAPS		equ	0
VK_Z		equ	1
VK_X		equ	2
VK_C		equ	3
VK_V		equ	4
; half row 2
VK_A		equ	5
VK_S		equ	6
VK_D		equ	7
VK_F		equ	8
VK_G		equ	9
; half row 3
VK_Q		equ	10
VK_W		equ	11
VK_E		equ	12
VK_R		equ	13
VK_T		equ	14
; half row 4
VK_1		equ	15
VK_2		equ	16
VK_3		equ	17
VK_4		equ	18
VK_5		equ	19

; half row 5
VK_0		equ	20
VK_9		equ	21
VK_8		equ	22
VK_7		equ	23
VK_6		equ	24
; half row 6
VK_P		equ	25
VK_O		equ	26
VK_I		equ	27
VK_U		equ	28
VK_Y		equ	29

; half row 7
VK_ENTER	equ	30
VK_J		equ	31
VK_L		equ	32
VK_K		equ	33
VK_H		equ	34
; half row 8
VK_SPACE	equ	35
VK_SYM		equ	36
VK_M		equ	37
VK_N		equ	38
VK_B		equ	39


; ***********************************************************************************************************************************************
; File system
; ***********************************************************************************************************************************************
SRC_BANK		equ	0		; bank to use for loading data (src data)
DEST_BANK		equ	1		; bank to use for loading data (dest data)
SRC_FILE_ADD		equ	((SRC_BANK&7)*8192)
DEST_FILE_ADD		equ	((DEST_BANK&7)*8192)
SRC_FILE_OVERFLOW	equ	((((SRC_BANK&7)*8192)+8192)>>8)
DEST_FILE_OVERFLOW	equ	((((DEST_BANK&7)*8192)+8192)>>8)
SRC_FILE_MASK		equ	(((((SRC_BANK&7)*8192)+8192)-1)>>8)
DEST_FILE_MASK		equ	(((((DEST_BANK&7)*8192)+8192)-1)>>8)

;	LOAD <file_id>,<physical_dest_address>
LOAD	macro
		ld		hl,\0
		ld		de,0+\1&$1fff
		ld		a,0+\1>>13
		call	LoadFile
		endm

; *******************************************************************************************************
;
;	Rom Disk filing system
;
;	dw	Bank Offset
;	db	8K Bank start
;	dw	File size
;
; *******************************************************************************************************

;		File	<def_label>,<filename>,<incbin_address>
file_id		def	0		
File	macro
\0:		equ	file_id
		dw	BANKOFF(\2)
		db	BANK(\2)
		dw	Filesize(\1)
file_id		def	file_id+1
		endm

;		File	<def_label>,<size in bytes>,<incbin_address>
File2	macro
\0:		equ	file_id
		dw	BANKOFF(\2)
		db	BANK(\2)
		dw	\1
file_id		def	file_id+1
	endm




; ***********************************************************************************************************************************************
;	General macros
; ***********************************************************************************************************************************************
CLC		macro		
		or	a
		endm
SEC		macro		
		scf
		endm

; Simple MMU instructions
MMU0		macro		
		NextReg	$50,a
		endm
MMU1		macro		
		NextReg	$51,a
		endm
MMU2		macro		
		NextReg	$52,a
		endm
MMU3		macro		
		NextReg	$53,a
		endm
MMU4		macro		
		NextReg	$54,a
		endm
MMU5		macro		
		NextReg	$55,a
		endm
MMU6		macro		
		NextReg	$56,a
		endm
MMU7		macro		
		NextReg	$57,a
		endm


		; copper WAIT  VPOS,HPOS
WAIT		macro
		db	HI($8000+(\0&$1ff)+(( (\1/8) &$3f)<<9))
		db	LO($8000+(\0&$1ff)+(( ((\1/8) >>3) &$3f)<<9))
		endm

		; copper MOVE reg,val
MOVE		macro
		db	HI($0000+((\0&$ff)<<8)+(\1&$ff))
		db	LO($0000+((\0&$ff)<<8)+(\1&$ff))
		endm

		; NOP
CNOP		macro
		db	0,0
		endm

		; CSpect Software break
BREAK		macro
		db $fd,$00
		endm

