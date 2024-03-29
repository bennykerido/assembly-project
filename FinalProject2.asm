DATA SEGMENT
    N=4
    WELCOME_MSG DB "Welcome to Bullseye!",10,13
    ENTER_MSG DB "Press ENTER to start the game",10,13,"$"
    GENERATE_MSG DB "The system is generating a number...",10,13,"$"
    REVEAL_MSG DB "The number was: $"
    PCNUM DB N+1,?,  N+1 DUP(?), 10,13,"$"
    INPUT_MSG DB "Enter your guess: $"
    USERNUM DB N+1,?, N+1 DUP("$")
    LOST_MSG DB 10,13,"You've tried 12 times and lost :(",10,13,"$"
    ERRORF  DB  0 
    INFO_MSG1 DB 10,13,"You've got "
    BULLS DB 0 
    INFO_MSG2 DB " BULLS and "
    HITS DB 0 
    INFO_MSG3 DB " HITS", 10,13,"$"  
    WON_MSG DB 10,13,"You WON! You've had $"
    TRIES DB 30H," guesses",10,13,"$" 
    INPUTERROR_MSG DB 10,13,"Number must be 4-digit long, and all digits must be different!",10,13,"$"
    PLAYAGAIN DB "Would you like to play again? (Y/N) ",10,13,"$"
    BYE_MSG DB "BYE BYE!$" 
    INPUTFLAG DB 0
ENDS

STACK SEGMENT
    DW   128  DUP(0)
ENDS

CODE SEGMENT
START:
    MOV AX, DATA
    MOV DS, AX
    MOV ES, AX
 
STARTOVER: 
    MOV TRIES, 30H ; MAKING SURE TRIES = 0 (FOR A REMATCH)
 
    LEA DX, WELCOME_MSG  ; PRINTING WELCOME MESSAGE 
    MOV AH, 9
    INT 21H
    
JUMPMSG:   ; JUMP POINT FOR REPRINTING THE "HIT THE ENTER TO START" MESSAGE  
    MOV AH, 7
    INT 21H
    
    CMP AL, 0DH  ; MAKING SURE THE KEY IS 'ENTER'
    JNZ JUMPMSG
  
    LEA DX, GENERATE_MSG  
    MOV AH, 9
    INT 21H
    
    CALL GENERATE   ; FUNCTION TO GENERATE A NUMBER FOR PC
    
COMMENT @               ; SHOWING
    LEA DX, REVEAL_MSG  ; THE
    MOV AH, 9           ; PC
    INT 21H             ; NUMBER
                        ; FOR
    LEA DX, PCNUM+2     ; DEVELOPMENT 
    MOV AH, 9           ; PURPOSES
    INT 21H             ; ***NOW HIDDEN***
@
    JMP FIRSTRY ; JUMPING OVER THE HITS AND BULLS MESSAGE FOR THE FIRST TRY  
TRY:
    CMP TRIES, 3CH ; CHECKING IF PLAYER HAS ALREADY TRIED FOR 12 TIMES
    JZ LOST
    
    LEA DX, INFO_MSG1 ; SHOWING HOW MANY BULLS AND HITS YOU GOT ON YOUR LAST GUESS
    MOV AH, 9
    INT 21H
  
FIRSTRY:    
    LEA DX, INPUT_MSG  ; ASKING TO ENTER THE PLAYER'S GUESS
    MOV AH, 9
    INT 21H   
    
    MOV DX, OFFSET USERNUM  ; GETTING THE PLAYER'S GUESS
    MOV AH, 0AH              
    INT 21H
     
    CMP USERNUM[1], 4 ; MAKING SURE THE PLAYER'S NUMBER IS 4 DIGIT LONG
    JNZ WRONGINPUT 
    
    CALL CHECKINPUT   ; CHECKING THE INPUT TO SEE IF THERE'S DUPLICATES
    CMP INPUTFLAG, 1
    JZ WRONGINPUT
     
    CALL CHECKBULLS  ; CHECKING FOR HITS AND BULLS
    
    CMP BULLS, 34H   ; CHECKING IF THERE ARE 4 BULLS
    JNZ TRY          ; JUMPING BACK TO TRY AGAIN IF LESS THAN 4 BULLS
    LEA DX, WON_MSG  ; PRINTING "YOU WON" MESSAGE
    MOV AH, 9
    INT 21H
    
    CMP TRIES, 39H   ; CHECKING IF TRIES > 9
    JB NEXT4
    
    MOV DL, 31H      ; IF TRIES > 9, PRINTING '1'
    MOV AH, 6
    INT 21H
    SUB TRIES, 0AH   ; AND SUBTRACTING 10

NEXT4:
    LEA DX, TRIES    ; PRINTING THE REMAINING TRIES
    MOV AH, 9
    INT 21H
    JMP ENDGAME      ; JUMPING TO THE END

WRONGINPUT:
    LEA DX, INPUTERROR_MSG  ; PRINTING WRONG INPUT MESSAGE
    MOV AH, 9
    INT 21H
    JMP FIRSTRY  ; JUMPING TO ENTER INPUT AGAIN  

LOST:
    LEA DX, LOST_MSG   ; PRINTING THE "YOU TRIED 12 TIMES" MESSAGE
    MOV AH, 9
    INT 21H
     
    LEA DX, REVEAL_MSG ; PRINTING "THE PC NUMBER WAS:"
    MOV AH, 9
    INT 21H
    
    LEA DX, PCNUM+2    ; PRINTING THE PC'S NUMBER
    MOV AH, 9
    INT 21H

ENDGAME:
    LEA DX, PLAYAGAIN  ; PRINTING "WOULD YOU LIKE TO TRY AGAIN?"
    MOV AH, 9
    INT 21H
    
    MOV AH, 7          ; GETTING CHAR FROM USER
    INT 21H
    
    CMP AL, 'a'        ; MAKING
    JB UPPERCASE       ; SURE
    CMP AL, 'z'        ; IT'S
    JA ENDGAME         ; A
    XOR AL, 20H        ; LETTER
UPPERCASE:             ; IF
    CMP AL, 'A'        ; LOWERCASE
    JB ENDGAME         ; MAKING
    CMP AL, 'Z'        ; IT
    JA ENDGAME         ; UPPERCASE
    
    CMP AL, 'Y'        ; CHECKING IF IT'S A 'Y'
    JZ STARTOVER       ; IF YES, JUMPING BACK TO THE START
    
    CMP AL, 'N'        ; CHECKING IF IT'S A 'N'
    JNZ ENDGAME        ; IF NO, GOING BACK TO ASK IF YOU WANT TO PLAY AGAIN
    
    LEA DX, BYE_MSG    ; PRINTING "BYE BYE" MESSAGE
    MOV AH, 9
    INT 21H
    
    MOV AX, 4C00H ; EXIT TO OPERATING SYSTEM.
    INT 21H    
ENDS

CHECKINPUT PROC  
    MOV INPUTFLAG, 0     ; MAKING SURE INPUTFLAG = 0
    MOV DI, 1            ; MOVING DI TO THE BEGINING OF THE STRING
 CHECKPOINT:
    INC DI               ; MOVING IT ONE PLACE AHEAD
    CMP DI, 7            ; CHECKING IF IT IS THE END
    JZ FUNCEND           ; IF YES, GOING TO THE END OF THE FUNCTION
    MOV SI, DI           ; SI = DI
    INC SI               ; SI++
    CMP SI, 7            ; SI < 7
    JZ FUNCEND           ; IF YES, GOING TO THE END OF THE FUNCTION
    MOV AL, USERNUM[DI]
    POINT2:
        CMP AL, USERNUM[SI] ; USERNUM[DI] == USERNUM[SI] ?
        JZ BADINPUT         ; IF YES, JUMPS TO BADINPUT
        INC SI              ; IF NO, SI++
        CMP SI, 6           ; SI < 6
        JB POINT2           ; IF YES, CHECKING AGAIN WITH THE NEXT SI
        JMP CHECKPOINT      ; IF NO, GOING BACK TO INCREASE DI AND CHECK THE NEXT CHARACTER
 BADINPUT:
    MOV INPUTFLAG, 1        ; TURNS THE FLAG TO 1, BECAUSE THERE'S A DUPLICATE
 FUNCEND:
    RET
ENDS
   
CHECKBULLS PROC  
    MOV DI, 2     ; MOVING SI TO THE BEGINING OF THE STRING
    MOV SI, 2     ; MOVING DI TO THE BEGINING OF THE STRING
    MOV BULLS, 0  ; MAKING SURE BULLS = 0
    MOV HITS, 0   ; MAKING SURE HITS = 0
    MOV CX, 4     ; MOVING 4 TO CX FOR THE LOOP
 FOR1:
    PUSH CX       ; SAVING CX'S VALUE
    MOV AL, PCNUM[DI]
   FOR2: 
        MOV CX, 4  ; GIVING CX 4 FOR THE INNER LOOP
      INNER:
        CMP AL, USERNUM[SI]  ; USERNUM[SI] == USERNUM[DI] ?
        JZ CHECKLOC          ; IF YES, IT JUMPS TO CHECK THE LOCATION OF THE TWO CARACTERS
        JMP NEXTCHAR         ; IF NO, IT GOING TO CHECK THE NEXT CHARACTER
      CHECKLOC:
        CMP SI, DI           ; SI == DI ?
        JZ ADDBULL           ; IF YES, IT JUMPS TO ADD A BULL
        INC HITS             ; IF NO, IT INCREASES THE HITS (HITS++)
        JMP CONTFOR          ; AND JUMPS TO CONTINUE
      ADDBULL:
        INC BULLS            ; INCREASES THE BULLS (BULLS++)
        JMP CONTFOR          ; AND JUMPS TO CONTINUE
      NEXTCHAR:
        INC SI               ; INCREASES SI (SI++)
        LOOP INNER           ; AND LOOPS TO CHECK THE NEXT CHARACTER
    CONTFOR:
        INC DI               ; INCREASES DI (DI++)
        MOV SI, 2            ; PUTTING SI BACK ON THE FIRST INDEX OF THE STRING
        POP CX               ; GETTING CX FROM THE STACK 
        LOOP FOR1            ; LOOPING BACK CX TIMES
    INC TRIES                ; INCREASES THE TRIES (TRIES++)
    ADD HITS, 30H            ; ADDING 30H TO HITS, SO IT WILL BE A CHARACTER
    ADD BULLS, 30H           ; ADDING 30H TO BULLS, SO IT WILL BE A CHARACTER
    RET
ENDS
    
GENERATE PROC
    MOV DI, 2  ; PUTTING DI ON THE FIRST INDEX OF PCNUM
    MOV CX, 4  ; MOVING CX VALUE OF 4 FOR THE LOOP
 AGAIN:
    PUSH CX
    MOV AH, 00h  ; INTERRUPT       
    INT 1AH      ; TO
    POP CX       ; GET
    MOV AX, DX   ; THE
    XOR DX, DX   ; SYSTEM
    MOV  BX, 10  ; TIME 
    DIV  BX      ; GETS A NUMBER
    ADD DL, '0'  ; 0-9
    CMP DL, '0'  ; CHECKING IF THE NUMBER IS '0'
    JZ FIRSTCHAR ; IF YES, JUMPS TO CHECK IF IT IS THE FIRST DIGIT
CONTGEN:
    MOV ERRORF, 0     ; MAKING SURE ERRORF(LAG) IS 0
    CALL CHECK        ; CHECKING IF THE NUMBER IS ALREADY EXISTS
    CMP ERRORF, 0     ; ERRORF == 0 ?
    JNZ AGAIN         ; IF NO, IT JUMPS TO THE BEGINING TO GENERATE A NEW NUMBER
    MOV PCNUM[DI], DL ; MOVING THE GENERATED NUMBER TO PCNUM[DI]
    INC DI            ; INCREASES DI (DI++)
    LOOP AGAIN        ; LOOPING TO GENERATE THE NEXT NUMBER (IF CX ISN'T 0)
    JMP EXIT2         ; JUMP TO THE END
FIRSTCHAR:
    CMP DI, 2         ; CHECKING IF IT IS THE FIRST DIGIT
    JNZ CONTGEN       ; IF NO, IT GOES BACK TO PUT THE NUMBER IN PCNUM[DI]
    JMP AGAIN         ; IF YES, IT JUMPS TO GENERATE A NEW NUM
EXIT2:
    RET 
ENDS

CHECK PROC
    PUSH CX             ; FUNCTION
    MOV CX, DI          ; TO
    MOV SI, DI          ; CHECK
 LOOPBACK:              ; IF 
    CMP PCNUM[SI], DL   ; GENERATED
    JZ ERROR            ; DIGIT
    DEC SI              ; ALREADY
    LOOP LOOPBACK       ; EXISTS
    JMP EXIT            ; SOMEWHERE
ERROR:                  ; IN
    MOV ERRORF, 1       ; THE
 EXIT:                  ; NUMBER
    POP CX              
    RET
ENDS   
END START 
