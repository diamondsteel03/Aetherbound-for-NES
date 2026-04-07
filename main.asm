; =========================
; AETHERBOUND NES BASE
; ca65 assembly
; =========================

.segment "ZEROPAGE"
game_state: .res 1

.segment "CODE"

; -------------------------
; RESET ENTRY
; -------------------------
Reset:
    SEI
    CLD
    LDX #$FF
    TXS

    INX
    STX game_state     ; 0 = menu

    ; Disable PPU
    LDA #$00
    STA $2000
    STA $2001

    JSR WaitVBlank

    JSR InitAPU

MainLoop:
    JSR WaitVBlank

    LDA game_state
    CMP #$00
    BEQ MenuState
    JMP GameState

    JMP MainLoop

; -------------------------
; MENU STATE
; -------------------------
MenuState:
    JSR DrawMenu
    JSR ReadInput

    ; If START pressed -> go game
    LDA #$01
    STA game_state

    JSR PlayBeep

    JMP MainLoop

; -------------------------
; GAME STATE
; -------------------------
GameState:
    JSR DrawGame
    JSR ReadInput

    JMP MainLoop

; -------------------------
; INPUT (simplified)
; -------------------------
ReadInput:
    LDA $4016
    RTS

; -------------------------
; MENU DRAW
; -------------------------
DrawMenu:
    LDA #$20
    STA $2006
    LDA #$00
    STA $2006

    LDX #$00
MenuLoop:
    LDA MenuText, X
    BEQ DoneMenu
    STA $2007
    INX
    JMP MenuLoop

DoneMenu:
    RTS

MenuText:
    .byte "AETHERBOUND NES",0

; -------------------------
; GAME DRAW
; -------------------------
DrawGame:
    LDA #$20
    STA $2006
    LDA #$00
    STA $2006

    LDX #$00
GameLoop:
    LDA GameText, X
    BEQ DoneGame
    STA $2007
    INX
    JMP GameLoop

DoneGame:
    RTS

GameText:
    .byte "GAME WORLD",0

; -------------------------
; WAIT VBLANK
; -------------------------
WaitVBlank:
    BIT $2002
VBlankLoop:
    BIT $2002
    BPL VBlankLoop
    RTS

; -------------------------
; APU INIT
; -------------------------
InitAPU:
    LDA #$0F
    STA $4015     ; enable channels
    RTS

; -------------------------
; SOUND: simple beep
; -------------------------
PlayBeep:
    LDA #$30
    STA $4000     ; volume

    LDA #$AA
    STA $4002     ; low freq

    LDA #$00
    STA $4003     ; high + restart

    RTS

; -------------------------
; PPU INIT (basic)
; -------------------------
InitPPU:
    LDA #$00
    STA $2000
    STA $2001
    RTS

; -------------------------
; VECTORS
; -------------------------
.segment "VECTORS"
.word Reset
.word 0
.word 0
.word 0

; =========================
; CHR GRAPHICS DATA
; =========================

.segment "CHARS"
.incbin "chr.chr"