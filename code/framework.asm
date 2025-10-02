;
; Created on Sunday, 3rd of May 2025 at 11:39
; Simple Platform Engine for the ZX Spectrum next
; © Copyright Michael Dailly 2025, All rights reserved.
;
;
                opt --zxnext
                device zxspectrumnext

                lua allpass
                        ROM = dofile("code/filesys.lua")
                        if package.config:sub(1,1) == '\\' then
                                sj.insert_define("WINDOWS", "1")
                        end
                endlua

                include "includes.asm"
                include "irq.asm"

                org     CODE_SEG

; Stack
stack_end:
                ds      256 - 1                                 ; Stack size is 256 bytes
stack_start:
                db      0
stack_top:

StartAddress:
                ld      sp, stack_top                           ; Set stack pointer

                call    SetupIRQs

                call    Cls                                     ; clear the ULA screen
                ld      a,7
                call    ClsATTR                                 ; clear the ULA Attribute screen with INK 7 paper 0   F_B_PPP_III

                NEXTREG $07,3                                   ; select 28Mhz Z80n
                NEXTREG $08,%01001000                           ; Disable RAM contention and enable 8bit DACS
                NEXTREG $14, $e7                                ; Bright PINK
                NEXTREG $15,%00000001                           ; Sprites on, S U L layer order and enable sprites
                NEXTREG $12,16                                  ; Layer 2 base bank 16 (32 for 8k banks)

                ; LOAD    ULAScreenFile,ULAScreenPysical
                ; LOAD    L2ScreenDemo,32*8192

                LOAD_ULA_SCREEN ULAScreenFile                   ; Load the Pyjamarama loading screen in to the ULA screen (test)
                LOAD_LAYER2 L2ScreenDemo                        ; Load the Shadow of the Beast forground screen into Layer 2

                call    Layer2on

                call    InitGlobals
; *****************************************************************************************************************************
;   Main Loop
; *****************************************************************************************************************************
MainLoop:
                xor     a
                ld      (VBlank),a
.Wait:          ld      a,(VBlank)
                and     a
                jr      z,.Wait

                ; Do service routines just after a Vertical Blank (VBlank)
                call    FlipBuffers
                call    ReadKeyboard

                ; press space to shake the screen a little
                ld      a,(Keys+VK_SPACE)
                and     a
                jr      z,.notpressed
                xor     a
                ld      (Keys+VK_SPACE),a

                ld      a,(Shake)
                add     a,4
                ld      (Shake),a
.notpressed:

                ; draw a HEX number to the ULA screen
                ld      a,(HexValue)
                inc     a
                ld      (HexValue),a
                ld      de,$4000
                call    PrintHex

                call    DoScreenShake
                jp      MainLoop                ; infinite loop


; *****************************************************************************************************************************
;   Flip Buffers
; *****************************************************************************************************************************
FlipBuffers:
                ld      a,(ShakeX)
                NEXTREG $26,a
                ld      a,(ShakeY)
                NEXTREG $27,a
                ret


; *****************************************************************************************************************************
;   Init global variables
; *****************************************************************************************************************************
InitGlobals:
                ret


; *****************************************************************************************************************************
;   includes modules
; *****************************************************************************************************************************
                include "filesys.asm"
                include "utils.asm"
CODESEG = $
ENDOFCODE_ADD:
                include "data.asm"
ENDOFDATA_ADD:


                ; wheres our end address?
                lua
                        print(string.format("End of code   = $%X", _c("ENDOFCODE_ADD")))
                        print(string.format("End of data   = $%X", _c("ENDOFDATA_ADD")))
                        print(string.format("End of memory = $%X", _c("ENDOFMEMORY_ADD")))
                endlua

                savenex open "code/framework.nex",StartAddress
                savenex core 3,0,0
                savenex cfg 0
                savenex auto
                savenex close

                if ((_ERRORS = 0) && (_WARNINGS = 0))
                        ifdef WINDOWS
                                shellexec "bin\\CSpect.exe -w3 -zxnext -nextrom -tv -16bit -s28 -remote -mmc=./ code/framework.nex"
                                ; shellexec "bin\\CSpect.exe -w3 -zxnext -nextrom -tv -16bit -s28 -remote -mmc=./"
                        else
                                shellexec "mono bin/CSpect.exe -w3 -zxnext -nextrom -tv -16bit -s28 -remote -mmc=./ code/framework.nex"
                                ; shellexec "mono bin/CSpect.exe -w3 -zxnext -nextrom -tv -16bit -s28 -remote -mmc=./"
                        endif
                endif
