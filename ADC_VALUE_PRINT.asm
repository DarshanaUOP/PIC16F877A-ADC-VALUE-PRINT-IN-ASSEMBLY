;Author: DarshanaAriyarathna || darshana.uop@gmail.com || +94774901245
processor	16f877a			;Initialize the processor
#include	<p16f877a.inc>		;Include library


org	0x00;
    TIMER1  EQU	0x20
    TIMER2  EQU	0x21
    DISP    EQU	0x22
    
    K3	    EQU	0x23
    K2	    EQU	0x24
    K1	    EQU	0x25
    K0	    EQU	0x26

    HIGH_BIT_COPPY	EQU 0x27
    LOW_BIT_COPPY	EQU 0x28
    NEWS    EQU	0x29
    
    NORTH_H EQU	0x2A
    NORTH_L EQU	0x2B
    EAST_H  EQU	0x2C
    EAST_L  EQU	0x2D
    SOUTH_H EQU	0x2E
    SOUTH_L EQU	0x2F
    WEST_H  EQU	0x30
    WEST_L  EQU	0x31
  
    NORTH_H_ZERO EQU	0x32
    NORTH_L_ZERO EQU	0x33
    EAST_H_ZERO  EQU	0x34
    EAST_L_ZERO  EQU	0x35
    SOUTH_H_ZERO EQU	0x36
    SOUTH_L_ZERO EQU	0x37
    WEST_H_ZERO  EQU	0x38
    WEST_L_ZERO  EQU	0x39
    
    
GOTO	Main
org	0x04			    ;origin vector of interrupt
GOTO	SET_ZERO

Main:
    CALL    INITIALIZE_IC
    CALL    INITIALIZE_ADC
    
   T
    CALL    INITIALIZE_LCD
    GOTO    GET_DATA
    CALL    WAIT
    
    GOTO    T
    
    ;______________________________________
    SET_ZERO
    	BCF	    INTCON,7
	CALL	    PRINT_SET_ZERO
	BCF	    INTCON,1
	BSF	    INTCON,7
    RETFIE
    
    PRINT_SET_ZERO
	CALL	set_DDRAM_address_to_line2
	MOVLW	'S'
	CALL	PRINT_CHAR
	MOVLW	'E'
	CALL	PRINT_CHAR
	MOVLW	'T'
	CALL	PRINT_CHAR
	MOVLW	' '
	CALL	PRINT_CHAR
	MOVLW	'Z'
	CALL	PRINT_CHAR
	MOVLW	'E'
	CALL	PRINT_CHAR
	MOVLW	'R'
	CALL	PRINT_CHAR
	MOVLW	'O'
	CALL	PRINT_CHAR
      	
	CALL	GET_ZERO
	CALL	WAIT
	RETURN
    
    GET_ZERO
	CALL	SET_ANALOG_CH0
	CALL	START_CONVERSON
	LOOP_N
	BTFSC	ADCON0,2
	    GOTO    LOOP_N
		MOVF	ADRESH,0
		MOVWF	NORTH_H_ZERO
	    CALL	GO_BANK_1
		MOVF	ADRESL,0
	    CALL	GO_BANK_0
		MOVWF	NORTH_L_ZERO
	MOVLW	'.'
	CALL	PRINT_CHAR
	;-----------------------------
	CALL	SET_ANALOG_CH1
	CALL	START_CONVERSON
	LOOP_E
	BTFSC	ADCON0,2
	    GOTO    LOOP_E
		MOVF	ADRESH,0
		MOVWF	EAST_H_ZERO
	    CALL	GO_BANK_1
		MOVF	ADRESL,0
	    CALL	GO_BANK_0
		MOVWF	EAST_L_ZERO
	MOVLW	'.'
	CALL	PRINT_CHAR
	;-----------------------------
	CALL	SET_ANALOG_CH2
	CALL	START_CONVERSON
	LOOP_S
	BTFSC	ADCON0,2
	    GOTO    LOOP_S
		MOVF	ADRESH,0
		MOVWF	SOUTH_H_ZERO
	    CALL	GO_BANK_1
		MOVF	ADRESL,0
	    CALL	GO_BANK_0
		MOVWF	SOUTH_L_ZERO
	MOVLW	'.'
	CALL	PRINT_CHAR
	;-----------------------------
	CALL	SET_ANALOG_CH4
	CALL	START_CONVERSON
	LOOP_W
	BTFSC	ADCON0,2
	    GOTO    LOOP_W
		MOVF	ADRESH,0
		MOVWF	WEST_H_ZERO
	    CALL	GO_BANK_1
		MOVF	ADRESL,0
	    CALL	GO_BANK_0
		MOVWF	WEST_L_ZERO
	MOVLW	'.'
	CALL	PRINT_CHAR
	;-----------------------------
RETURN

    ;______________________________________
    
    GET_DATA
    	CALL	K_VALUES_TO_ZERO
	MOVLW	b'00000001'
	SUBWF	NEWS,0
	
	BTFSC	STATUS,2
		GOTO	GET_SOUTH
		MOVLW	b'00000010'
		SUBWF	NEWS,0
		BTFSC	STATUS,2
			GOTO	GET_EAST
		
			MOVLW	b'00000011'
			SUBWF	NEWS,0
			BTFSC	STATUS,2
				GOTO	GET_NORTH
				GOTO	GET_WEST
	UP
	CALL	PRINT_VALUE
	CALL	END_CONVERSON
	CALL	WAIT
	GOTO	T
    RETURN
    
    NEWS_MIN_ONE
        MOVLW	b'00000001'    
	SUBWF	NEWS,1
    RETURN	
    
    GET_NORTH
	CALL	NEWS_MIN_ONE
	CALL	SET_ANALOG_CH0
	CALL	WAIT
	CALL	START_CONVERSON
	
	CALL	PRINT_NORTH
	
	    CALL	COPPY_VALUES_FROM_ADC
	    GOTO	PROCESS_HIGH_VALUE
    ;RETURN
    
    GET_EAST
	CALL	NEWS_MIN_ONE
	CALL	SET_ANALOG_CH1
	CALL	WAIT
	
	CALL	START_CONVERSON
	CALL	PRINT_EAST
	    CALL	COPPY_VALUES_FROM_ADC
	    GOTO	PROCESS_HIGH_VALUE
	
    ;RETURN
    
    GET_SOUTH
	CALL	NEWS_MIN_ONE
	CALL	SET_ANALOG_CH2
	CALL	WAIT
	
	CALL	START_CONVERSON
	CALL	PRINT_SOUTH
	    CALL	COPPY_VALUES_FROM_ADC
	    GOTO	PROCESS_HIGH_VALUE
    ;RETURN
    
    GET_WEST
	CALL	SET_ANALOG_CH4
	CALL	WAIT
	CALL	START_CONVERSON
	
	CALL	PRINT_WEST
	    CALL	COPPY_VALUES_FROM_ADC
	    MOVLW	d'3'
	    MOVWF	NEWS
	    GOTO	PROCESS_HIGH_VALUE
    ;RETURN
    
    COPPY_VALUES_FROM_ADC
	MOVF	ADRESH,0
	MOVWF	HIGH_BIT_COPPY
	
	CALL	GO_BANK_1
	    MOVF	ADRESL,0
	CALL	GO_BANK_0
	MOVWF	LOW_BIT_COPPY
	
    RETURN
    
    ;______________________________________
    PROCESS_HIGH_VALUE
	
	MOVLW	b'00000001'
	SUBWF	HIGH_BIT_COPPY,0
	BTFSC	STATUS,2
		GOTO	LIBRARY_ONE
		MOVLW	b'00000010'
		SUBWF	HIGH_BIT_COPPY,0
		
		BTFSC	STATUS,2
			GOTO	LIBRARY_TWO
			MOVLW	b'00000011'
			SUBWF	HIGH_BIT_COPPY,0
		
			BTFSC	STATUS,2
				GOTO	LIBRARY_THREE
				GOTO	BEFORE_END
	BEFORE_END
	
	GOTO    PROCESS_LOWER_VALUE
;______________________________________
	    
    LIBRARY_ONE
	;256
	MOVLW	d'6'
	MOVWF	K0
	
	MOVLW	d'5'
	MOVWF	K1
	
	MOVLW	d'2'
	MOVWF	K2
	
    GOTO    BEFORE_END
    ;______________________________
    
    LIBRARY_TWO
	;512
	MOVLW	d'2'
	MOVWF	K0
	
	MOVLW	d'1'
	MOVWF	K1
	
	MOVLW	d'5'
	MOVWF	K2
	
    GOTO    BEFORE_END
    ;______________________________
    
    LIBRARY_THREE
	;768
	MOVLW	d'8'
	MOVWF	K0
	
	MOVLW	d'6'
	MOVWF	K1
	
	MOVLW	d'7'
	MOVWF	K2
	
    GOTO    BEFORE_END
    
    ;______________________________
    PROCESS_LOWER_VALUE
    
    GOTO    FIND_K2
    FIND_K2
	MOVLW   d'100'
	SUBWF   LOW_BIT_COPPY,0
	BTFSC   STATUS,0
	    GOTO	CHECK_POIT_2	;+ve
    	    GOTO	FIND_K1		;-ve
	    
    FIND_K1
	MOVLW   d'10'
	SUBWF   LOW_BIT_COPPY,0
	BTFSC   STATUS,0
	    GOTO	CHECK_POIT_1    
	    GOTO	FIND_K0
	    
    FIND_K0
	MOVLW   d'1'
	SUBWF   LOW_BIT_COPPY,0
	BTFSC   STATUS,0
	    GOTO	CHECK_POIT_0
	    GOTO	END_3
	    
    END_3
    GOTO    UP
    ;______________________________    
    CHECK_POIT_2
	MOVWF	LOW_BIT_COPPY
	CALL	K2_PLUS_ONE
    GOTO    FIND_K2
    ;______________________________ 
    CHECK_POIT_1
	MOVWF	LOW_BIT_COPPY
	CALL	K1_PLUS_ONE
    GOTO    FIND_K1
    ;______________________________ 
    CHECK_POIT_0
	MOVWF	LOW_BIT_COPPY
	CALL	K0_PLUS_ONE
    GOTO    FIND_K0
    
    ;______________________________
    K0_PLUS_ONE
	MOVLW	d'1'
	ADDWF	K0,1
	MOVLW	d'10'
	SUBWF	K0,0
	BTFSC	STATUS,1
	    GOTO    K0_MIN_TEN
	    GOTO    END_2
	    K0_MIN_TEN
		MOVLW   b'00001010'
		SUBWF   K0,1
		GOTO	K1_PLUS_ONE
		GOTO    END_2
    K1_PLUS_ONE
        MOVLW	d'1'
	ADDWF	K1,1
	MOVLW	d'10'
	SUBWF	K1,0
	BTFSC	STATUS,1
	   GOTO    K1_MIN_TEN
	   GOTO    END_2
	    
	    K1_MIN_TEN
		MOVLW   b'00001010'
		SUBWF   K1,1
		GOTO	K2_PLUS_ONE
		GOTO    END_2
    K2_PLUS_ONE
	MOVLW	d'1'
	ADDWF	K2,1
	MOVLW	d'10'
	SUBWF	K2,0
	BTFSC	STATUS,1
	   GOTO    K2_MIN_TEN
	   GOTO    END_2
	    K2_MIN_TEN
		MOVLW   b'00001010'
		SUBWF   K2,1
		GOTO	K3_PLUS_ONE
		GOTO    END_2
    K3_PLUS_ONE
	MOVLW	d'1'
	ADDWF	K3,1
	MOVLW	D'10'
	SUBWF	K3,0
	BTFSC	STATUS,1
	    GOTO    K3_MIN_TEN
	    GOTO    END_2	    
	    K3_MIN_TEN
		MOVLW   b'00001010'
		SUBWF   K3,1
		GOTO    END_2
    END_2
    RETURN
    ;______________________________
    K_VALUES_TO_ZERO
	MOVLW	b'00000000'
	MOVWF	K3
	
	MOVLW	b'00000000'
	MOVWF	K2
	
	MOVLW	b'00000000'
	MOVWF	K1
	
	MOVLW	b'00000000'
	MOVWF	K0
    RETURN
    
    ;+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

    ;subroutings_for_INITIALIZE_ADC
    
    INITIALIZE_ADC
    CALL    CONFIG_ADC_MODULE
    CALL    CONFIG_ADC_INTERUPT
    CALL    DELAY_50_MS		    ;WAIT THE REQURED ACQUISITION TIME
    CALL    START_CONVERSON
    RETURN
    ;______________________________________
    CONFIG_ADC_MODULE
	CALL	INITIALIZE_ADC_SETTING
	CALL	ADC_ON
    RETURN
    ;______________________________________
    INITIALIZE_ADC_SETTING
	CALL	GO_BANK_0
	    BCF	ADCON0,7    ;CLOCK
	    BCF	ADCON0,6    ;CLOCK
	CALL	GO_BANK_1
	    BCF	ADCON1,6    ;CLOCK
	    BSF	ADCON1,7    ;RESULT_FORMAT
			    ;ADFM: A/D Result Format Select bit
			    ;1 = Right justified. Six (6) Most Significant bits of ADRESH are read as ?0?.
			    ;0 = Left justified. Six (6) Least Significant bits of ADRESL are read as ?0?.
	    BCF	ADCON1,3    
	    BCF	ADCON1,2
	    BSF	ADCON1,1
	    BSF	ADCON1,0
	    
	CALL	GO_BANK_0
    RETURN
    
    SET_ANALOG_CH0
	    BCF	 ADCON0,3
	    BCF	 ADCON0,4
	    BCF	 ADCON0,5  
    RETURN
    
    SET_ANALOG_CH1
	    BSF	 ADCON0,3
	    BCF	 ADCON0,4
	    BCF	 ADCON0,5 
    RETURN
    
    SET_ANALOG_CH2
	    BCF	 ADCON0,3
	    BSF	 ADCON0,4
	    BCF	 ADCON0,5 
    RETURN
    
    SET_ANALOG_CH4
	    BCF	 ADCON0,3
	    BCF	 ADCON0,4
	    BSF	 ADCON0,5 
    RETURN
    
    ;______________________________________
    ADC_ON
    	CALL	GO_BANK_0
	BSF	ADCON0,0	
    RETURN
    
    ADC_OFF
    	CALL	GO_BANK_0
	BCF	ADCON0,0
    RETURN
    ;______________________________________
    CONFIG_ADC_INTERUPT
	BCF	PIR1,6	    ;ADIF(1=CONV CMPLTED,0=NOT COMPLETE)
	BSF	PIE1,6	    ;1 = Enables the A/D converter interrupt/0 = Disables the A/D converter interrupt
	BSF	INTCON,6    ;1 = Enables all unmasked peripheral interrupts/0 = Disables all peripheral interrupts
	BSF	INTCON,7    ;1 = Enables all unmasked interrupts/0 = Disables all interrupts
	
    RETURN
    ;______________________________________
    START_CONVERSON
	CALL	GO_BANK_0
	BSF	ADCON0,2
    RETURN
    
    END_CONVERSON
	BCF	ADCON0,2
    RETURN
    ;+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    ;subroutings_for_INITIALIZE_LCD
    INITIALIZE_LCD
	CALL    instructionMode
	CALL    setFunctions
	CALL    setDisplayOnOff
	CALL    displayClear
	CALL    setEntryModule
	CALL	set_CGRAM_address
	CALL	set_DDRAM_address_to_line1
    RETURN
    ;______________________________________
    
    instructionMode
	    MOVLW   b'000'
            MOVWF   PORTC
	    CALL    ENABLE_PULSE
    RETURN
    ;______________________________________
    dataSendMode
	    ;MOVLW   b'11111111'
	    ;MOVWF   PORTD

            ;MOVLW   b'00001'
            ;MOVWF   PORTC
	    BSF	    PORTC,0
	    ;CALL    ENABLE_PULSE
    RETURN
    ;______________________________________
    
    setFunctions
    	CALL    instructionMode
	MOVWF   PORTC
	MOVLW   b'00111000'
	;+----------+-----------+-----------+-----------+-----------+-----------+-----------+-----------+
	;| bit7	    | bit6	| bit5	    | bit4	| bit3	    | bit2	| bit1	    | bit0	|
	;+----------+-----------+-----------+-----------+-----------+-----------+-----------+-----------+
	;|	0   |	0   	|	1   |   1	|0=1 Line   |0=5x8 Dots |	x   |	x   	|
	;|	    |	    	|	    |	    	|1=2 Line   |1=5x11 Dots|	x   |	x   	|
	;+----------+-----------+-----------+-----------+-----------+-----------+-----------+-----------+  
	MOVWF   PORTD
	CALL    ENABLE_PULSE
    RETURN
    ;______________________________________
    setDisplayOnOff
	CALL    instructionMode
	MOVLW   b'00001111'
	;+----------+-----------+-----------+-----------+-----------+-----------+-----------+-----------+
	;| bit7	    | bit6      | bit5	    | bit4	| bit3	    | bit2	| bit1	    | bit0      |
	;+----------+-----------+-----------+-----------+-----------+-----------+-----------+-----------+
	;|	0   |	0   	|	0   |	0   	|	1   |0=DispOff  |0=CurserOff|0=BlinkOff |
	;|	    |	    	|	    |	    	|	    |1=DispOn   |1=CurserOn |1=BlinkOn  |
	;+----------+-----------+-----------+-----------+-----------+-----------+-----------+-----------+
	MOVWF   PORTD
	CALL    ENABLE_PULSE
    RETURN
    ;______________________________________
    displayClear
    	CALL    instructionMode
	MOVLW   b'00000001'
	;+----------+-----------+-----------+-----------+-----------+-----------+-----------+-----------+
	;| bit7	    | bit6	| bit5	    | bit4      | bit3	    | bit2      | bit1	    | bit0	|
	;+----------+-----------+-----------+-----------+-----------+-----------+-----------+-----------+
	;|	0   |	0	|	0   |	0	|	0   |   0	|	0   |   1	|
	;|	    |		|	    |		|	    |		|	    |		|
	;+----------+-----------+-----------+-----------+-----------+-----------+-----------+-----------+
	MOVWF   PORTD
	CALL    ENABLE_PULSE
	CALL	set_DDRAM_address_to_line1
    RETURN
    ;______________________________________
    setEntryModule
       	CALL	instructionMode
	MOVLW   b'00000110'
	;+----------+-----------+-----------+-----------+-----------+-----------+-----------+---------------+
	;| bit7	    | bit6	| bit5	    | bit4      | bit3	    | bit2      | bit1	    | bit0	    |
	;+----------+-----------+-----------+-----------+-----------+-----------+-----------+---------------+
	;|	0   |   0	|	0   |   0	|	0   |   1	|0=Decrement|0=EntireShift  |
	;|	    |		|	    |		|	    |		|   Mode    |   off	    |
	;|	    |		|	    |		|	    |	        |1=Increment|1=EntireShif   |
	;|	    |		|	    |		|	    |		|   Mode    |   on	    |
	;+----------+-----------+-----------+-----------+-----------+-----------+-----------+---------------+
	MOVWF   PORTD
	CALL    ENABLE_PULSE
    RETURN
    
    ;______________________________________
    set_CGRAM_address
    	CALL	instructionMode
	MOVLW   b'01000000'	
	;SET CGRAM ADDRESS
	;+----------+-----------+-----------+-----------+-----------+-----------+-----------+-----------+
	;| bit7	    | bit6	| bit5	    |bit4	| bit3	    | bit2	| bit1	    | bit0	|
	;+----------+-----------+-----------+-----------+-----------+-----------+-----------+-----------+
	;|	0   |	1	|	AC5 |	AC4	|	AC3 |	AC2	|	AC1 |	AC0	|
	;+----------+-----------+-----------+-----------+-----------+-----------+-----------+-----------+
	
	MOVWF   PORTD
	CALL    ENABLE_PULSE
    RETURN
    
    ;______________________________________
    set_DDRAM_address_to_line1
    	CALL	instructionMode
	MOVLW   b'10000000'	;SET DDRAM ADDRESS
    
	;+----------+-----------+-----------+-----------+-----------+-----------+-----------+-----------+
	;| bit7	    | bit6	| bit5	    | bit4	| bit3	    | bit2	| bit1	    | bit0	|
	;+----------+-----------+-----------+-----------+-----------+-----------+-----------+-----------+
	;|	1   |	AC6	|	AC5 |	AC4	|	AC3 |	AC2	|	AC1 |	AC0	|
	;+----------+-----------+-----------+-----------+-----------+-----------+-----------+-----------+
	    ;DDRAM ADDRESS 1ST Line:00H to 27H
	    ;DDRAM ADDRESS 2ND Line:40H to 67H

	MOVWF   PORTD
	CALL    ENABLE_PULSE
	CALL	dataSendMode
    RETURN
    ;______________________________________
    set_DDRAM_address_to_line2
    	CALL	instructionMode
	MOVLW   b'11000000'
	MOVWF   PORTD
	CALL    ENABLE_PULSE
	CALL	dataSendMode

    RETURN
    ;+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    ;subroutings_for_INITIALIZE_IC
    INITIALIZE_IC
	CALL	GO_BANK_1
	    MOVLW   b'000'
	    MOVWF   TRISC
	    MOVLW   b'00000000'
	    MOVWF   TRISD
	    BSF	    PORTB,0
	CALL	GO_BANK_0
	    MOVLW   b'000'
	    MOVWF   PORTC

	    MOVLW   b'00000000'
	    MOVWF   PORTD
	    
	CALL    IC_INTERRUPT_CONFIG
	;MOVLW	d'3'
	;MOVWF	NEWS

    RETURN
    
    IC_INTERRUPT_CONFIG
	CALL	GO_BANK_1	    ;SWITCH TO BANK 1
	   
	    bsf	    OPTION_REG,6    ;Interrupt on rising edge of RB0/INT pin
	    bsf	    INTCON,7	    ;Enable all unmasked interrupts
	    bsf	    INTCON,4	    ;Enables the RB0/INT external interrupt
	CALL	GO_BANK_0
    RETURN
    
    ;_______________________________________
    
    GO_BANK_0
	BCF	    STATUS,5
        BCF	    STATUS,6
    RETURN
    
    GO_BANK_1
	BSF	    STATUS,5
        BCF	    STATUS,6
    RETURN
    
    GO_BANK_2
	BCF	    STATUS,5
        BSF	    STATUS,6
    RETURN
    
    GO_BANK_3
	BSF	    STATUS,5
        BSF	    STATUS,6
    RETURN
    
    ;+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
   
    ENABLE_PULSE
	BSF	    PORTC,2
	CALL    DELAY_50_MS
	BCF	    PORTC,2
	;CALL    DELAY_50_MS
    RETURN
    ;_______________________________________
    DELAY_50_MS
	DECFSZ	TIMER1,1
	GOTO	DELAY_50_MS
	;DECFSZ	TIMER2,1
	;GOTO	DELAY_50_MS
	;MOVLW   b'11111111'
	;movwf   TIMER1
    RETURN
    
    ;+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    ;subroutings_for_PRINT_IN_LCD
    writeOnDisp
	MOVLW	'R'
	CALL    PRINT_CHAR
	MOVLW	'U'
	CALL    PRINT_CHAR
	MOVLW	'N'
	CALL    PRINT_CHAR
	
    RETURN
    
    PRINT_NORTH
    	CALL	set_DDRAM_address_to_line1
	MOVLW	'N'
	CALL    PRINT_CHAR
	MOVLW	'O'
	CALL    PRINT_CHAR
	MOVLW	'R'
	CALL    PRINT_CHAR
	MOVLW	'T'
	CALL    PRINT_CHAR
	MOVLW	'H'
	CALL    PRINT_CHAR
	MOVLW	':'
	CALL    PRINT_CHAR
	
    RETURN
    
    
    PRINT_EAST
    	CALL	set_DDRAM_address_to_line1
	MOVLW	'E'
	CALL    PRINT_CHAR
	MOVLW	'A'
	CALL    PRINT_CHAR
	MOVLW	'S'
	CALL    PRINT_CHAR
	MOVLW	'T'
	CALL    PRINT_CHAR
	MOVLW	' '
	CALL    PRINT_CHAR
	MOVLW	':'
	CALL    PRINT_CHAR
	
    RETURN
    
    PRINT_SOUTH
    	CALL	set_DDRAM_address_to_line1
	MOVLW	'S'
	CALL    PRINT_CHAR
	MOVLW	'O'
	CALL    PRINT_CHAR
	MOVLW	'U'
	CALL    PRINT_CHAR
	MOVLW	'T'
	CALL    PRINT_CHAR
	MOVLW	'H'
	CALL    PRINT_CHAR
	MOVLW	':'
	CALL    PRINT_CHAR
	
    RETURN
    
    PRINT_WEST
    	CALL	set_DDRAM_address_to_line1
	MOVLW	'W'
	CALL    PRINT_CHAR
	MOVLW	'E'
	CALL    PRINT_CHAR
	MOVLW	'S'
	CALL    PRINT_CHAR
	MOVLW	'T'
	CALL    PRINT_CHAR
	MOVLW	' '
	CALL    PRINT_CHAR
	MOVLW	':'
	CALL    PRINT_CHAR
	
    RETURN
    
    
    PRINT_VALUE
	;CALL	displayClear
	MOVF	K3,0
	CALL	MAKE_LCD_NUMBER
	CALL    PRINT_CHAR
	
	MOVF	K2,0
	CALL	MAKE_LCD_NUMBER
	CALL    PRINT_CHAR
	
	MOVF	K1,0
	CALL	MAKE_LCD_NUMBER
	CALL    PRINT_CHAR
	
	MOVF	K0,0
	CALL	MAKE_LCD_NUMBER
	CALL    PRINT_CHAR
	
    RETURN
    
    MAKE_LCD_NUMBER
	ADDLW	b'00110000'
    RETURN
    
    PRINT_CHAR
	MOVWF  PORTD
	CALL    ENABLE_PULSE
    RETURN
    ;+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    WAIT
	DECFSZ	TIMER1,1
	GOTO	WAIT
	DECFSZ	TIMER2,1
	GOTO	WAIT
    RETURN 
END