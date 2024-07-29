.define PPUCTRL $2000
.define PPUMASK $2001
.define PPUSTATUS $2002
.define OAMADDR $2003
.define OAMDATA $2004
.define PPUSCROLL $2005
.define PPUADDR $2006
.define PPUDATA $2007

.define PALETTE_BG_0 $3F00
.define PALETTE_SPRITE_0 $3F10

.define COLOR_PINK $11
.define COLOR_SIMIL_RED $10
.define COLOR_ORANGE $00
.define COLOR_GREEN $3D

.define sprite_x $203
.define sprite_y $200
.define DMA $4014
.define JOY $4016


.db "NES", $1A, 2, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0

;INIZIO con il registro 8000
.org $8000

reset:
    SEI          ; disable IRQs
    CLD          ; disable decimal mode
    LDX #$40
    STX $4017    ; disable APU frame IRQ
    LDX #$FF
    TXS          ; Set up stack
    INX          ; now X = 0
    STX $2000    ; disable NMI
    STX $2001    ; disable rendering
    STX $4010    ; disable DMC IRQs

;vblankwait1:       ; First wait for vblank to make sure PPU is ready
    ;BIT $2002
    ;BPL vblankwait1

start:
    
    ;LDX #$FF
    ;TXS
    ;SPENGO NMI
    ;LDX #0
    ;STX PPUCTRL

    
    ;STX PPUMASK           ;SETTO 0 NELLA PPU COSI NON DISEGNA NULLA PER EVITARE GLITCH GRAFICI AD INIZIO GIOCO



    init_palette:

        ;INIZIALIZZO PALETTE PER BACKGROUND
        LDA #>PALETTE_BG_0
        STA PPUADDR
        LDA #<PALETTE_BG_0
        STA PPUADDR

        ;CARICO I COLORI NELLA PALETTE DEL BACGKORUND
        LDA #COLOR_PINK
        STA PPUDATA
        LDA #COLOR_SIMIL_RED
        STA PPUDATA
        LDA #COLOR_ORANGE
        STA PPUDATA
        LDA #COLOR_GREEN
        STA PPUDATA

        ;INIZIALIZZO PALETTE PER SPRITE
        LDA #>PALETTE_SPRITE_0
        STA PPUADDR
        LDA #<PALETTE_SPRITE_0
        STA PPUADDR

        ;CARICO I COLORI NELLA PALETTE DEGLI SPRITE
        LDA #COLOR_PINK
        STA PPUDATA
        LDA #COLOR_SIMIL_RED
        STA PPUDATA
        LDA #COLOR_ORANGE
        STA PPUDATA
        LDA #COLOR_GREEN
        STA PPUDATA

    ;LDX #%00010000
    ;STX PPUMASK 

    ;LDA #$00
    ;STA OAMADDR

    ;LDA #$40
    ;STA OAMDATA
    ;LDA #$00
    ;STA OAMDATA
    ;LDA #$00
    ;STA OAMDATA
    ;LDA #$40
    ;STA OAMDATA
    sprites:

        .db $80, $32, $00, $80
        .db $80, $33, $00, $88  
        .db $88, $34, $00, $80 
        .db $88, $35, $00, $88 

    LoadSprites:

        LDX #$00        

    LoadSpritesLoop:

        LDA sprites, x     

        STA $0200, x     

        INX              

        CPX #$10     

        BNE LoadSpritesLoop

    LDA #%00010000   ; no intensify (black background), enable sprites
    STA PPUMASK
   
    game_loop:  
        LDX #$00
        LDA #$01
        STA $4016
        LDA #$00
        STA $4016

        LDA #$00
        STA DMA
        LDA #$02
        STA DMA  

        wait_for_vblank_sprite:
            LDA PPUSTATUS
            AND #%10000000
            BEQ wait_for_vblank_sprite

        LDA JOY
        AND #%00000001
        LDA JOY
        AND #%00000001
        LDA JOY
        AND #%00000001
        LDA JOY
        AND #%00000001
        LDA JOY
        AND #%00000001
        BEQ move_down

    up_loop:
        LDA sprite_y, x
        SEC
        SBC #$01
        STA sprite_y, x
        INX
        INX
        INX
        INX
        CPX #$10 
        BNE up_loop
        JMP game_loop

    move_down:
        LDA JOY
        AND #%00000001
        BEQ move_left
        down_loop:
            LDA sprite_y, x
            CLC
            ADC #$01
            STA sprite_y, x
            INX
            INX
            INX
            INX
            CPX #$10
            BNE down_loop
            JMP game_loop

    move_left:
        LDA JOY
        AND #%000000001
        BEQ move_right
        left_loop:
            LDA sprite_x, x
            SEC
            SBC #$01
            STA sprite_x, x
            INX
            INX
            INX
            INX
            CPX #$10
            BNE left_loop
            JMP game_loop

    move_right:
        LDA JOY
        AND #%00000001
        BEQ end_move
        right_loop:
            LDA sprite_x, x
            CLC
            ADC #$01
            STA sprite_x, x
            INX
            INX
            INX
            INX
            CPX #$10
            BNE right_loop
        JMP game_loop

    end_move:
        JMP game_loop

    nmi:
        RTI

    irq:    
        RTI

.goto $FFFA
.dw nmi ;NMI
.dw reset ;RESET
.dw irq ;IRQ/BRQ

.incbin "mario0.chr"