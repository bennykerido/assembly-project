DATA SEGMENT
    ; FINALS
    N EQU 20
    HEX_LENGTH EQU 5
    BIN_LENGTH EQU 17
    OCT_LENGTH EQU 7
    DEC_LENGTH EQU 6
    
    ; VARIABLES
    ;            MESSAGES
    WELCOME_MSG DB "Welcome to the Base Converter!$"
    ACTION_MSG DB 10,13,"Choose your number base",10,13,"< 'H' - Hexa, 'B' - Binary, 'O' - Octal, 'D' - Decimal >",10,13,"$"
    ERROR_MSG_BASE DB 10,13,"Wrong input!$"   
    LONG_MSG DB 10,13,"Input is too long for that base",10,13,"< BIN - 16 | OCT - 6 | DEC - 5 | HEX - 4 >$"
    END_MSG DB 10,13,"Would you like to start again(Y/N)? ",10,13,"$" 
    HEX_MSG DB 10,13,"Hexadecimal number = $"
    BIN_MSG DB 10,13,"Binary number = $"
    OCT_MSG DB 10,13,"Octal number = $"
    DEC_MSG DB 10,13,"Decimal number = $"
    BADNUM_MSG DB 10,13,"Invalid characters!$" 
    INPUT_MSG DB 10,13,"Enter your number: $"
    BYE_MSG DB 10,13,"Bye Bye :)$" 
    
    ;             FLAGS
    BADNUM DB 0
    ISFIRST DB 0 
    ISNEGATIVE DB 0
    
    ;           USER INPUT
    NUMBER DB N+1, ?, N+1 DUP("$")
     
    ;          VALUES STRINGS 
    HELP_STR DB N DUP("$") 
    HEX_VALUE DB HEX_LENGTH DUP("$")
    BIN_VALUE DB BIN_LENGTH DUP("$")
    OCT_VALUE DB OCT_LENGTH DUP("$")
    DEC_VALUE DB DEC_LENGTH DUP("$")
    
    ;           BASE VALUES
    BASE DW ? 
    ORIGINAL_BASE DB ?       
    
    ;       DECIMAL VALUE OF USER INPUT
    VALUE DW 0 
    
    
ENDS

STACK SEGMENT
    DW   128  DUP(0)
ENDS

CODE SEGMENT
START:

    MOV AX, DATA
    MOV DS, AX
    MOV ES, AX
    
    LEA DX, WELCOME_MSG ; PRINTING WELCOME MESSAGE
    MOV AH, 9
    INT 21H
     
BEGINING:           
    LEA DX, ACTION_MSG ; ASKING FOR BASE
    MOV AH, 9
    INT 21H      
    
  
    MOV AH, 1 ; WAITING FOR INPUT
    INT 21H
    
    CMP AL, 61H  ; CHECKING IF INPUT IS LOWERCASE LOWER THAN 'a'
    JB INPUT
    
    CMP AL, 7AH  ; CHECKING IF INPUT IS LOWERCASE HIGHER THAN 'z'
    JA INPUT
    
    XOR AL, 20H  ; TURNING THE LOWERCASE TO UPPERCASE
    
INPUT:
    CMP AL, 'H'  ; CHECKING IF THE BASE IS HEXADECIMAL
    JZ HEXA
    
    CMP AL, 'B'  ; CHECKING IF THE BASE IS BINARY
    JZ BINARY
    
    CMP AL, 'O'  ; CHECKING IF THE BASE IS OCTAL
    JZ OCTAL
    
    CMP AL, 'D'  ; CHECKING IF THE BASE IS DECIMAL
    JZ DECIMAL 
    
    LEA DX, ERROR_MSG_BASE ; PRINTING WRONG INPUT MESSAGE
    MOV AH, 9
    INT 21H
    JMP BEGINING  ; JUMPS TO CHOOSE BASE AGAIN
    
HEXA:             ; JUMPS HERE IF THE BASE IS HEXA AND SETS THE BASE
    MOV BASE, 16
    MOV ORIGINAL_BASE, 16
    JMP GETNUMBER
    
BINARY:           ; JUMPS HERE IF THE BASE IS BINARY AND SETS THE BASE
    MOV BASE, 2
    MOV ORIGINAL_BASE, 2
    JMP GETNUMBER
    
OCTAL:            ; JUMPS HERE IF THE BASE IS OCTAL AND SETS THE BASE
    MOV BASE, 8
    MOV ORIGINAL_BASE, 8  
    JMP GETNUMBER
    
DECIMAL:          ; JUMPS HERE IF THE BASE IS DECIMAL AND SETS THE BASE
    MOV BASE, 10
    MOV ORIGINAL_BASE, 10      
    
GETNUMBER:        ; JUMP POINT TO GET THE USER'S NUMBER
    MOV BADNUM, 0           ; MAKING SURE
    MOV VALUE, 0            ; ALL FLAGS
    MOV DI, OFFSET NUMBER+2 ; AND STRINGS
    CALL RESETSTRING        ; ARE SETTED
    MOV ISFIRST, 0          ; BACK TO NONE(0 OR '$' FOR STRINGS) 
    LEA DX, INPUT_MSG       ; ASKING FOR A NUMBER
    MOV AH, 9
    INT 21H
    
    MOV DX, OFFSET NUMBER   ; GETTING THE USER'S NUMBER INTO "NUMBER"
    MOV AH, 0AH
    INT 21H   
    
    CALL CALCVALUE          ; CALCULATING THE USER'S NUMBER TO DECIMAL
    CMP BADNUM, 0           ; CHECKING IF BADNUM FLAG IS RAISED
    JNZ GETNUMBER           ; IF YES, GOES BACK TO GET A NEW NUMBER FROM USER
    
    CMP ORIGINAL_BASE, 2    ; CHECKING IF THE BASE IS BINARY
    JNZ TESTOCT             ; IF NOT, JUMPS TO CHECK IF IT IS OCTAL
                            ; IF YES...
                            
    LEA DX, OCT_MSG         ; PRINTS
    MOV AH, 9               ; THE
    INT 21H                 ; OCTAL
    LEA DX, OCT_VALUE       ; VALUE
    MOV AH, 9               ; TO
    INT 21H                 ; SCREEN
  
    LEA DX, DEC_MSG         ; PRINTS
    MOV AH, 9               ; THE
    INT 21H                 ; DECIMAL
    LEA DX, DEC_VALUE       ; VALUE
    MOV AH, 9               ; TO
    INT 21H                 ; SCREEN
      
    LEA DX, HEX_MSG         ; PRINTS
    MOV AH, 9               ; THE
    INT 21H                 ; HEXA
    LEA DX, HEX_VALUE       ; VALUE
    MOV AH, 9               ; TO
    INT 21H                 ; SCREEN
    JMP FINISH              

TESTOCT:
    CMP ORIGINAL_BASE, 8    ; CHECKING IF THE BASE IS OCTAL
    JNZ TESTDEC             ; IF NOT, JUMPS TO CHECK IF IT IS DECIMAL
                            ; IF YES...
    
    LEA DX, BIN_MSG         ; PRINTS
    MOV AH, 9               ; THE 
    INT 21H                 ; BINARY
    LEA DX, BIN_VALUE       ; VALUE
    MOV AH, 9               ; TO
    INT 21H                 ; SCREEN
   
    LEA DX, DEC_MSG         ; PRINTS
    MOV AH, 9               ; THE
    INT 21H                 ; DECIMAL
    LEA DX, DEC_VALUE       ; VALUE
    MOV AH, 9               ; TO
    INT 21H                 ; SCREEN
      
    LEA DX, HEX_MSG         ; PRINTS
    MOV AH, 9               ; THE
    INT 21H                 ; HEXA
    LEA DX, HEX_VALUE       ; VALUE
    MOV AH, 9               ; TO
    INT 21H                 ; SCREEN
    JMP FINISH

TESTDEC:
    CMP ORIGINAL_BASE, 10   ; CHECKING IF THE BASE IS DECIMAL
    JNZ TESTHEX             ; IF NOT, JUMPS TO CHECK IF IT IS HEXA
                            ; IF YES...
    
    LEA DX, BIN_MSG         ; PRINTS
    MOV AH, 9               ; THE 
    INT 21H                 ; BINARY
    LEA DX, BIN_VALUE       ; VALUE
    MOV AH, 9               ; TO
    INT 21H                 ; SCREEN
    
    LEA DX, OCT_MSG         ; PRINTS
    MOV AH, 9               ; THE
    INT 21H                 ; OCTAL
    LEA DX, OCT_VALUE       ; VALUE
    MOV AH, 9               ; TO
    INT 21H                 ; SCREEN
      
    LEA DX, HEX_MSG         ; PRINTS
    MOV AH, 9               ; THE
    INT 21H                 ; HEXA
    LEA DX, HEX_VALUE       ; VALUE
    MOV AH, 9               ; TO
    INT 21H                 ; SCREEN
    JMP FINISH
    
TESTHEX:

    LEA DX, BIN_MSG         ; PRINTS
    MOV AH, 9               ; THE 
    INT 21H                 ; BINARY
    LEA DX, BIN_VALUE       ; VALUE
    MOV AH, 9               ; TO
    INT 21H                 ; SCREEN
    
    LEA DX, OCT_MSG         ; PRINTS
    MOV AH, 9               ; THE
    INT 21H                 ; OCTAL
    LEA DX, OCT_VALUE       ; VALUE
    MOV AH, 9               ; TO
    INT 21H                 ; SCREEN
    
    LEA DX, DEC_MSG         ; PRINTS
    MOV AH, 9               ; THE
    INT 21H                 ; DECIMAL
    LEA DX, DEC_VALUE       ; VALUE
    MOV AH, 9               ; TO
    INT 21H                 ; SCREEN
    
FINISH:
    LEA DX, END_MSG ; PRINTING ENDING MESSAGE, ASKING IF YOU WANT TO ENTER ANOTHER NUMBER
    MOV AH, 9
    INT 21H
    
    MOV AH, 1 ; WAITING FOR INPUT
    INT 21H
    
    CMP AL, 'a' ; CHECKING IF INPUT IS LOWERCASE LOWER THAN 'a'
    JB CONT
    
    CMP AL, 'z' ; CHECKING IF INPUT IS LOWERCASE HIGHER THAN 'z'
    JA CONT
    
    XOR AL, 20H ; TURNING THE LOWERCASE TO UPPERCASE

CONT:
    CMP AL, 'Y'     ; CHECKS IF USER'S CHOISE IS YES
    JNZ NEXTCHECK   ; IF NO, JUMPS TO CHECK NO
    MOV ISFIRST, 0  ; RESETS THE 'ISFIRST' FLAG BACK TO 0
    JMP BEGINING  
    
NEXTCHECK:
    CMP AL, 'N'     ; CHECKS IF USER'S CHOISE IS NO
    JNZ WRONGINPUT  ; IF NO, JUMPS TO WRONG INPUT MESSAGE
    JMP EXIT        ; IF YES, JUMPS TO THE END OF THE PROGRAM
    
WRONGINPUT:
    LEA DX, ERROR_MSG_BASE ; ERROR MESSAGE IF INPUT ISN'T Y OR N
    MOV AH, 9
    INT 21H
    JMP FINISH  ; GOING BACK TO ASKING WHETHER YOU WANT TO TRY AGAIN OR NO
    
EXIT:   
    
    LEA DX, BYE_MSG ; PRINTS THE GOODBYE MESSAGE
    MOV AH, 9
    INT 21H
    
    MOV AX, 4C00H ; EXIT TO OPERATING SYSTEM.
    INT 21H    
ENDS

CALCVALUE PROC
    CALL CHECKLENGTH      ; CHECKS THE USER'S NUMBER'S STRING LENGTH DEPENDING ON BASE
    MOV AX, 0                      
    MOV AL, NUMBER[1]     ; MOVES THE LENGTH OF THE STRING TO AX      
    MOV DI, AX            ; MOVES TO DI THE INDEX OF THE LAST CHARACTER OF "NUMBER"                                         
    INC DI                
CHECKPOINT:  
    SUB NUMBER[DI], 30H   ; SUBTRACTS 30H FROM THE CHARACTER TO GET IT'S DECIMAL VALUE 
    CALL VERIFY           ; VERIFIES THE DIGITS(TO CHECK IF IT'S IN THE RIGHT RANGE, BASED ON BASE)
    CMP BADNUM, 0         ; CHECKS IF BADNUM FLAG IS RAISED
    JNZ FAIL              ; IF YES, JUMP TO THE END OF THE FUNCTION
BEGIN:
    CMP ISFIRST, 0        ; CHECKS IF IT THE FIRST DIGIT FROM THE RIGHT
    JNZ POWER             ; IF NO, JUMPS TO POWER IT 
    MOV AL, NUMBER[DI]    ; IF YES, MOVES THE DECIMAL VALUE OF THE DIGIT TO AL
    ADD VALUE, AX         ; ADDS AX TO THE VALUE
    INC ISFIRST           ; RAISES THE ISFIRST FLAG SO IT WILL KNOW THAT IT PASSED THE FIRST DIGIT TO THE RIGHT
    MOV BX, 1             ; MOVES 1 TO BX FOR THE POWERING
 POWER:                   
    DEC DI
    CMP NUMBER[1], 1      ; CHECKS IF USER'S STRING LENGTH IS 1
    JZ BUILD              ; IF YES, JUMPS TO BUILD IN ALL BASES VALUE(STRINGS)  
    SUB NUMBER[DI], 30H   ; IF NO, MOVES FOR THE NEXT CHARACTER AND SUBTRACTS 30H TO GET DECIMAL VALUE
    CALL VERIFY           ; VERIFIES THE DIGITS(TO CHECK IF IT'S IN THE RIGHT RANGE, BASED ON BASE)
    CMP ISNEGATIVE, 1     ; CHECKS IF NUMBER[DI] == '-' && DI == 2 (STR.LENGTH() == 0)
    JZ NEGATIVE           ; IF YES, JUMPS TO TURN THE VALUE TO NEGATIVE
    CMP BADNUM, 0         ; IF NO, CHECKS IF THE BADNUM FLAG IS RAISED
    JNZ FAIL              ; IF YES, JUMPS TO FAIL THE PROGRAM
    MOV CX, BX            ; MOVES BX(POWER) TO CX, FOR THE LOOP                                       
    MOV AX, 0                                                    
    MOV AL, NUMBER[DI]    
    MOV DX, 0   
  POWERLOOP:
    MUL BASE              ; MULITPLES AX IN THE BASE, CX TIMES
    LOOP POWERLOOP
    ADD VALUE, AX         ; ADDS THE RESULT TO THE VALUE
    ADD VALUE, DX         ; ADDS CARRY, IF THERE'S A CARRY, TO THE VALUE
    INC BX                ; INCREASES THE POWER
    CMP DI, 2             ; CHECKS IF DI REACHED THE END
    JNZ POWER             ; IF NO, GOES BACK TO POWER THE NEXT DIGIT
    JMP BUILD             ; IF YES, JUMPS TO BUILD IN ALL BASES VALUE(STRINGS)
 NEGATIVE:
    NEG VALUE             ; IF THE NEGATIVE FLAG RAISED, IT TURN 'VALUE' TO NEGATIVE AND CONTINUES TO BUILD IT
 BUILD:
    MOV DI, OFFSET BIN_VALUE  ; MOVES THE OFFSET OF THE BINARY VALUE TO DI
    CALL RESETSTRING          ; RESETS THE BIN_VALUE(FOR NEXT RUNS)
    MOV DI, OFFSET OCT_VALUE  ; MOVES THE OFFSET OF THE OCTAL VALUE TO DI
    CALL RESETSTRING          ; RESETS THE OCT_VALUE(FOR NEXT RUNS)
    MOV DI, OFFSET DEC_VALUE  ; MOVES THE OFFSET OF THE DECIMAL VALUE TO DI
    CALL RESETSTRING          ; RESETS THE DEC_VALUE(FOR NEXT RUNS)
    MOV DI, OFFSET HEX_VALUE  ; MOVES THE OFFSET OF THE HEXA VALUE TO DI
    CALL RESETSTRING          ; RESETS THE HEX_VALUE(FOR NEXT RUNS)
    MOV BASE, 8               ; MOVES THE OCTAL BASE TO 'BASE'
    MOV SI, OFFSET OCT_VALUE  ; MOVES THE START OF OCT_VALUE TO SI             
    CALL BUILDBASE            ; BUILDS THE OCTAL VALUE AS A STRING
    MOV BASE, 16              ; MOVES THE HEXA BASE TO 'BASE'
    MOV SI, OFFSET HEX_VALUE  ; MOVES THE START OF HEX_VALUE TO SI             
    CALL BUILDBASE            ; BUILDS THE HEXA VALUE AS A STRING
    MOV BASE, 10              ; MOVES THE DECIMAL BASE TO 'BASE'
    MOV SI, OFFSET DEC_VALUE  ; MOVES THE START OF DEC_VALUE TO SI             
    CALL BUILDBASE            ; BUILDS THE DECIMAL VALUE AS A STRING
    MOV BASE, 2               ; MOVES THE BINARY BASE TO 'BASE'
    MOV SI, OFFSET BIN_VALUE  ; MOVES THE START OF BIN_VALUE TO SI             
    CALL BUILDBASE            ; BUILDS THE BINARY VALUE AS A STRING
FAIL:                 ; JUMP POINT IF THE PROGRAM FAILS(SOME OF THE DIGITS ARE ILLEGAL
    RET
ENDS
 
RESETSTRING PROC      ; FUNCTION
 CLEARLOOP:           ; TO 
    CMP [DI], '$'     ; RESET
    JZ RESETED        ; THE
    MOV [DI], '$'     ; STRING
    INC DI            ; BACK
    JMP CLEARLOOP     ; TO
RESETED:              ; '$'
    RET               
ENDS 

BUILDBASE PROC              
    MOV DI, 0
    MOV AX, VALUE          ; MOVES THE VALUE TO AX, TO DIVIDE IT
BUILDLOOP:
    MOV DX, 0
    DIV BASE               ; DIVIDES AX BY THE BASE
    ADD DL, 30H            ; ADDS 30H TO TURN IT BACK TO CHARACTER
    MOV HELP_STR[DI], DL   ; ADDS THE CHARACTER TO AN HELP STRING
    INC DI
    CMP AX, 0              ; CHECKS IF AX IS 0 (IF IT ENDED)
    JNZ BUILDLOOP          ; IF NO, JUMPS BACK TO DIVIDE IT ONCE MORE
    MOV DI, 0              ; RESETS DI
    MOV BX, 0              ; RESETS BX
 COUNT:                    ; COUNTS HOW LONG HELP_STR IS
    CMP HELP_STR[DI], '$'  ; CHECKS IF CHARACTER AT DI IS '$' WHICH MEANS THAT THE STRING ENDED 
    JZ NEXT_BUILD          ; IF YES, JUMPS TO BUILD THE MIRROR STRING
    INC DI                 ; IF  
    INC BX                 ; NO,
    JMP COUNT              ; CONTINUES TO COUNT
 NEXT_BUILD:
    MOV DI, 0              ; RESETS DI
    MOV CX, BX             ; MOVES BX TO CX FOR THE LOOP
    DEC BX                 ; DECREASES BX SO IT WON'T BE THE '$'
    ADD SI, BX             ; ADDS BX TO SI(OFFSET OF THE *BASE*_VALUE
 SWAPPING:                 ; SWAPPING THE TWO STRINGS, HELP_STR AND *BASE*_VALUE AND MIRRORING IT
    MOV AX, 0
    MOV AL, HELP_STR[DI]   ; MOVES THE CHARACTER FROM THE LEFT SIDE
    XCHG AL, [SI]          ; TO THE RIGHT SIDE
    CMP [SI], 39H          ; CHECKS IF IT IS ABOVE '9' (IF IT'S HEXA)
    JA ADDINGSEVEN         ; IF YES, JUMPS TO ADD IT 7H TO MATCH THE LETTER
CONTBUILD:                 ; IF NO, CONTINUES TO BUILD
    DEC SI
    INC DI
    LOOP SWAPPING          ; LOOPS BACK TO SWAPPING CX TIMES
    MOV DI, OFFSET HELP_STR; MOVES TO DI THE OFFSET OF HELP_STR IN ORDER TO RESET IT BACK TO '$'
    CALL RESETSTRING       ; CALLS THE RESET STRING FUNCTION
    RET
    
ADDINGSEVEN:               
    ADD [SI], 7H           ; IF IT IS A LETTER(HEXA) ADDS 7H TO MATCH THE CORRECT LETTER
    JMP CONTBUILD          ; JUMPS TO CONTINUE THE BUILD
ENDS 
 
VERIFY PROC
    CMP NUMBER[DI], 0FDH   ; CHECKS IF THE CHARACTER IS '-'
    JNZ CONVER             ; IF NO, CONTINUES TO VERIFY THE CHARACTER
    CMP DI, 2              ; IF YES, CHECKS IF IT IS THE MOST LEFT CHARACTER
    JNZ WRONG              ; IF NO, JUMPS TO GIVE WRONG INPUT MESSAGE
    CMP NUMBER[1], 1       ; CHECKS IF THE LENGTH IS MORE THAN 1
    JE WRONG               ; IF IT EQUALS TO 1 JUMPS TO GIVE WRONG INPUT MESSAGE 
    MOV ISNEGATIVE, 1      ; IF NO, RAISES THE ISNEGATIVE FLAG
    RET                    ; AND RETURNS

CONVER: 
    CMP BASE, 2
    JNZ NOTBINARY
    CMP NUMBER[DI], 1
    JBE CHECKBINARY
    JA WRONG 
    
NOTBINARY:
    CMP BASE, 8
    JNZ NOTOCTAL
    CMP NUMBER[DI], 7
    JBE CHECKOCTAL
    JA WRONG
    
NOTOCTAL:
    CMP BASE, 10
    JNZ NOTDECIMAL
    CMP NUMBER[DI], 9
    JBE CHECKDECIMAL
    JA WRONG
    
NOTDECIMAL:
    CMP NUMBER[DI], 31H
    JB UPPERCASE
    CMP NUMBER[DI], 36H
    JA WRONG
    SUB NUMBER[DI], 20H
UPPERCASE:   
    CMP NUMBER[DI], 16H
    JA WRONG
    JBE REMOVELETTER 
    
CHECKBINARY:
    CMP BASE, 2
    JZ EXIT5
    JMP NOTBINARY
    
CHECKOCTAL:
    CMP NUMBER[DI], 0
    JB WRONG
    JMP EXIT5
    
CHECKDECIMAL:    
    CMP BASE, 10 
    JZ EXIT5
    JNZ NOTDECIMAL 
    
 REMOVELETTER:
    CMP NUMBER[DI], 11H
    JB CHECKBASE
    SUB NUMBER[DI], 7H
    JMP EXIT5 
    
 CHECKBASE:
    CMP BASE, 2
    JNZ CHECK1
    CMP NUMBER[DI], 1
    JA WRONG
    
 CHECK1:
    CMP BASE, 8
    JNZ CHECK2
    CMP NUMBER[DI], 7
    JA WRONG
    
 CHECK2:
    CMP BASE, 10
    JNZ CHECK3
    CMP NUMBER[DI], 9
    JA WRONG
    
  CHECK3:
    JMP EXIT5
        
 WRONG:
        LEA DX, BADNUM_MSG
        MOV AH, 9
        INT 21H 
        MOV BADNUM, 1
 EXIT5:
    RET
ENDS
 
CHECKLENGTH PROC
    CMP BASE, 2
    JNZ BASE1
    CMP NUMBER[1], 16
    JA TOOLONG
  BASE1:
    CMP BASE, 8
    JNZ BASE2
    CMP NUMBER[1], 6
    JA TOOLONG
  BASE2:
    CMP BASE, 10
    JNZ BASE3
    CMP NUMBER[1], 5
    JA TOOLONG
  BASE3:
    CMP BASE, 16
    JNZ BASE4
    CMP NUMBER[1], 4
    JA TOOLONG
  BASE4:
    RET
 TOOLONG:
    LEA DX, LONG_MSG
    MOV AH, 9
    INT 21H
    JMP GETNUMBER 
ENDS
END START
