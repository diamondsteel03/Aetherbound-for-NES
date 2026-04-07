.segment "ZEROPAGE"
buttons:  .res 1
playerX:  .res 1
playerY:  .res 1

.segment "CODE"

RESET:
    SEI
    CLD

    LDX #$FF
    TXS

    INX
    STX $2000
    STX $2001

; wait vblank
@vblank1:
    BIT $2002
    BPL @vblank1

; clear RAM
    LDA #$00
    TAX
@clear:
    STA $0000, X
    STA $0100, X
    STA $0200, X
    STA $0300, X
    INX
    BNE @clear

; init player
    LDA #$70
    STA playerX

    LDA #$60
    STA playerY

; enable PPU later
    LDA #%10000000
    STA $2000

    LDA #%00011110
    STA $2001

MainLoop:
    JSR ReadController
    JSR UpdatePlayer
    JSR DrawPlayer

    LDA #$02
    STA $4014

    JMP MainLoop

; -------------------------
; CONTROLLER
; -------------------------
ReadController:
    LDA #$01
    STA $4016
    LDA #$00
    STA $4016

    LDX #$08
@loop:
    LDA $4016
    LSR A
    ROL buttons
    DEX
    BNE @loop
    RTS

; -------------------------
; PLAYER LOGIC
; -------------------------
UpdatePlayer:

    LDA buttons
    AND #%00010000
    BEQ @down
    DEC playerY
@down:

    LDA buttons
    AND #%00100000
    BEQ @left
    INC playerY
@left:

    LDA buttons
    AND #%01000000
    BEQ @right
    DEC playerX
@right:

    LDA buttons
    AND #%10000000
    BEQ @done
    INC playerX

@done:
    RTS

; -------------------------
; DRAW SPRITE
; -------------------------
DrawPlayer:

    LDA playerY
    STA $0200

    LDA #$01        ; tile index (CHR tile 1)
    STA $0201

    LDA #$00
    STA $0202

    LDA playerX
    STA $0203

    RTS

; -------------------------
; BACKGROUND (fill screen)
; -------------------------
.segment "CODE"
DrawBackground:

    LDA $2002
    LDA #$20
    STA $2006
    LDA #$00
    STA $2006

    LDX #$00
@fill:
    LDA #$00
    STA $2007
    INX
    BNE @fill

    RTS

; -------------------------
; VECTORS
; -------------------------
.segment "VECTORS"

.word 0
.word RESET
.word 0