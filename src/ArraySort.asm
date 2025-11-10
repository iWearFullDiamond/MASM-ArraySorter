; -----------------------------------------------------------------------------
; 8086 Integer Sorter - MASM/TASM, 16-bit DOS
; Reads up to 10 unsigned integers (0..65535) from keyboard, validates them,
; stores them in a vector, sorts ascending, and prints the result.
; Assembled & run with MASM/TASM + DOSBox / VS Code DOSBox extension.
; -----------------------------------------------------------------------------

.model small
.stack 100h

.data
    InputBuffer DB 50, 0, 50 DUP(?) 
    Vector DW 10 DUP(0)
    n DB 0
    ct DB 0
    i DW 0
    j DW 0
    msg1 db 13,10, "Introdu max 10 numere (intre 0 si 65.535) separate prin spatiu : $"
    msg2 db 13,10, "Numerele sortate crescator : $"
    msg3 db 13,10, "Numerele au fost introduse gresit!$"
.code

main:
    ; Initializam Data Segment
    MOV AX, @DATA
    MOV DS, AX

    ;- - - - - - - - - - - - - - - - - - - - - - - - Citire Vector - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

    ; Afisam primul mesaj
    LEA DX, msg1
    MOV AH, 09h                         ; Funcția DOS pentru afișare string
    INT 21h

    ; Citeste de la tastatura stringul
    LEA DX, InputBuffer
    MOV AH, 0Ah                         ; Funcția DOS pentru citire string
    INT 21h

    ; Initializam registrii
    LEA SI, InputBuffer + 2       
    LEA DI, Vector
    XOR AX, AX
    MOV BX, 10       

StringLoop:
    MOV Cl, [SI]

    CMP CL, 0DH                             ; Verificăm dacă este Enter 
    JE FinalCitire

    CMP Cl, ' '                             ; Verificăm dacă este Space 
    JE FinalNumar

    CMP Cl, '0'
    JB NumarGresit
    CMP Cl, '9'
    JA NumarGresit

    JMP Cifra

NumarGresit:
    LEA DX, msg3
    MOV AH, 09h                         
    INT 21h
    JMP TerminareProgram

Cifra:
    MOV ct, 1
    SUB CL, '0'                          ; Convertim caracterul ASCII în valoare numerică
    MUL BX                              
    ADD AX, CX                           ; Adăugăm cifra curentă la rezultat
    INC SI                               ; Avansăm la următorul caracter
    JMP StringLoop                       ; Repetăm bucla

FinalNumar:
    CMP ct, 0
    JE SaritSpatiu
    MOV ct, 0

    MOV [DI], AX
    ADD DI, 2
    XOR AX, AX
    INC SI
    INC n
    JMP StringLoop

SaritSpatiu:
    INC SI
    JMP StringLoop

FinalCitire: 
    CMP ct, 0
    JE Initializare

    MOV [DI], AX
    INC n

;- - - - - - - - - - - - - - - - - - - - - - - - - - - - Sortare Vector - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Initializare:
    XOR AX, AX
    XOR CX, CX
    MOV Cl, n
    
    MOV BX, CX
    INC CX

    MOV SI, 32h
    MOV DI, SI

primul_loop:
    INC i
    MOV DX, i
    MOV j, DX

    ADD SI, 2
    MOV DI, SI

    CMP i, BX
    JE Mesaj2

al_doilea_loop:
    INC j
    ADD DI, 2

    CMP j, CX
    JE primul_loop

    MOV AX, [SI]
    CMP AX, [DI]
    JLE no_swap
    JG swap

swap:
    xchg AX, [DI]
    MOV [SI], AX
    JMP al_doilea_loop

no_swap:
    JMP al_doilea_loop

;- - - - - - - - - - - - - - - - - - - - - - - - Afisare Vector Sortat - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Mesaj2:
    MOV SI, 34h

    LEA DX, msg2
    MOV AH, 09h
    INT 21h

ScosDinVector:
    MOV AX, [SI]
    ADD SI, 2
    CMP n, 0
    JE TerminareProgram
    DEC n

IntrodusStiva:
    XOR DX, DX
    MOV BX, 10
    DIV BX                  
    PUSH DX
    CMP AX, 0
    JNE IntrodusStiva

AfisareNumar:
    POP DX
    ADD DX, '0'
    MOV ah, 02h             
    INT 21h
    CMP SP, 100h
    JE PusSpatiu
    JMP AfisareNumar

PusSpatiu:
    MOV DX, ' '
    MOV ah, 02h             
    INT 21h
    JMP ScosDinVector

TerminareProgram:          
    MOV ah, 4Ch
    INT 21h

end main