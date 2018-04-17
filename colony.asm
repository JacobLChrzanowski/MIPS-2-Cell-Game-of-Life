#
# FILE:         $Colony.asm$
# Contributors:
#               <<<Jacob L. Chrzanowski>>>
#
# DESCRIPTION:
#       This program reads up to 10 of numbers (or until the user
#       enters the value 9999) from the standard input, and then 
#       computes and prints their sum.
#
# ARGUMENTS:
#       None
#
# INPUT:
#       The numbers to be summed.
#
# OUTPUT:
#       A "before" line with the 10 numbers in the order they were
#       entered, and an "Sum=" and then the sum of all the numbers
#
#
#


PRINT_STRING = 4                # arg for syscall to write string
PRINT_CHAR = 11                 # arg for syscall to write char
PRINT_INT = 1                   # arg for syscall to write int


#
# DATA AREAS
#

        .data

        .align  2               # word data must be on word boundaries
arrayP:  
        .space  900             # Reserve space for array to hold data
                                # the array is up to MAX_SIZE words (4 bytes
                                # each). Note the array isn't initialized.
arrayS:
        .space  900             # Scrap array

boardSize:
        .word 0                 # board size variable

genToRun:
        .word 0                 # generations to run variable

generation:
        .word 0                 # generations to run variable

updateBoardcol:
        .word 0                 # updateBoard col var




size:
        .word   0               # Actual number of values in the array

        .align  0               # string data doesn't have to be aligned
space:
        .asciiz " "
lf:
        .asciiz "\n"
plus:
        .asciiz "+"
dash:
        .asciiz "-"
pipe:
        .asciiz "|"
debug:
        .asciiz "DEBUG\n"
debuga:
        .asciiz "DEBUGa\n"

sText1:
        .asciiz "**********************\n"
sText2:
        .asciiz "****    Colony    ****\n"
sText3:
        .asciiz "**********************\n"

iText1:
        .asciiz "\n====    GENERATION "
iText2:
        .asciiz "    ====\n"


pText1:                         # 4 <= size <= 30
        .asciiz "\nEnter board size: "

pText2:                         # 0 <= generations <= 20
        .asciiz "Enter number of generations to run: "

pText3:                         # 0 <= numAlive_A <= (total 
                                #  number of cells in the board)
        .asciiz "Enter number of live cells for colony A: "

pText4:                         # 0 <= loc < boardSize
                                #  duplicate locations are not allowed
        .asciiz "Start entering locations\n"

pText5:                         # 0<= numAlive_B <= (total
                                #  number of cells in the board)
        .asciiz "Enter number of live cells for colony B: "



p1Warn:
        .asciiz "WARNING: illegal board size, try again: "

p2Warn:
        .asciiz "WARNING: illegal number of generations, try again: "

p3Warn:
        .asciiz "WARNING: illegal number of live cells, try again: "

p4Warn:
        .asciiz "ERROR: illegal point location\n"

#
# CODE AREAS
#
        .text                   # this is program code
        .align  2               # instructions must be on word boundaries

        .globl  main            # main is a global label



A_FRAMESIZE_8 = 8
A_FRAMESIZE_40 = 40


getInput:
        li      $v0, 5          # get the generations to run from user input
        syscall

        jr      $ra

printChar:
        li      $v0, PRINT_CHAR # set syscall to print char
        syscall
        jr      $ra

printString:
        li      $v0, 4          # print intro text
        syscall
        jr      $ra

printNum:
        li      $v0, 1
        syscall
        jr      $ra



pBoardT:                        # print top of board in a loop
        la      $a0, dash       # end of top row
        li      $v0, 4
        syscall

        addi    $s3, $s3, -1    # count down, loop if not done yet
        bne     $zero, $s3, pBoardT



        jr      $ra





printRowM:
        addi    $sp, $sp, -A_FRAMESIZE_8
        sw      $ra, -4+A_FRAMESIZE_8($sp)

        move    $s4, $s0        # counts col number (iterator)


        la      $a0, pipe       # side
        jal     printString

printRowMHelp:
        lbu     $s6, 0($s5)
        move    $a0, $s6
        
        jal     printChar
        addi    $s5, $s5, 1

        addi    $s4, $s4, -1
        bne     $zero, $s4, printRowMHelp


        la      $a0, pipe       # side
        jal     printString
        la      $a0, lf         # side
        jal     printString
        
        lw      $ra, -4+A_FRAMESIZE_8($sp)
        addi    $sp, $sp, A_FRAMESIZE_8

        jr      $ra


printRowS:
        addi    $sp, $sp, -A_FRAMESIZE_8
        sw      $ra, -4+A_FRAMESIZE_8($sp)
    
printRowSHelp:
        move    $s4, $s0        # counts col number (iterator)
        addi    $s3, $s3, -1
        jal     printRowM
        bne     $zero, $s3, printRowSHelp

        lw      $ra, -4+A_FRAMESIZE_8($sp)
        addi    $sp, $sp, A_FRAMESIZE_8

        jr $ra





printBoard:
        addi    $sp, $sp, -A_FRAMESIZE_40
        sw      $ra, -4+A_FRAMESIZE_40($sp)
        sw      $s7, 28($sp)
        sw      $s6, 24($sp)
        sw      $s5, 20($sp)
        sw      $s4, 16($sp)
        sw      $s3, 12($sp)
        sw      $s2, 8($sp)
        sw      $s1, 4($sp)
        sw      $s0, 0($sp)

        lw      $s0, boardSize  # boardSize
        lw      $s1, genToRun   # genToRun
        mul     $s2, $s0, $s0   # boardSize^2 (number of squares on the board)
        lw      $s3, generation

        la      $a0, iText1     # print out sequence for generation declaration
        jal     printString
        lw      $a0, generation
        jal     printNum
        la      $a0, iText2
        jal     printString


        la      $a0, plus       # start printing the top board wall
        jal     printString
        lw      $s3, boardSize  # holds boardSize but \/ iterator in pBoardT
        jal     pBoardT
        la      $a0, plus
        jal     printString
        la      $a0, lf
        jal     printString     # end of top row


        move    $s3, $s0        # counts row number (iterator)
        la      $s5, arrayP
        jal     printRowS

        la      $a0, plus       # start printing the bottom board wall
        jal     printString
        lw      $s3, boardSize  # holds boardSize but \/ iterator in pBoardT
        jal     pBoardT
        la      $a0, plus
        jal     printString
        la      $a0, lf
        jal     printString     # end of top row


        lw      $ra, -4+A_FRAMESIZE_40($sp)
        lw      $s7, 28($sp)
        lw      $s6, 24($sp)
        lw      $s5, 20($sp)
        lw      $s4, 16($sp)
        lw      $s3, 12($sp)
        lw      $s2, 8($sp)
        lw      $s1, 4($sp)
        lw      $s0, 0($sp)
        addi    $sp, $sp, A_FRAMESIZE_40
        jr      $ra


copyStP:
        addi    $sp, $sp, -A_FRAMESIZE_40
        sw      $ra, -4+A_FRAMESIZE_40($sp)
        sw      $s7, 28($sp)
        sw      $s6, 24($sp)
        sw      $s5, 20($sp)
        sw      $s4, 16($sp)
        sw      $s3, 12($sp)
        sw      $s2, 8($sp)
        sw      $s1, 4($sp)
        sw      $s0, 0($sp)

        lw      $s0, boardSize  # boardSize
        mul     $s2, $s0, $s0   # boardSize^2 (number of squares on the board)

        la      $s3, arrayP
        la      $s4, arrayS

        add     $s6, $s2, $s3

copyStPloop:
        lbu     $s5, 0($s4)
        sb      $s5, 0($s3)


        addi    $s4, $s4, 1
        addi    $s3, $s3, 1
        


        bne     $s3, $s6, copyStPloop
        
        


        lw      $ra, -4+A_FRAMESIZE_40($sp)
        lw      $s7, 28($sp)
        lw      $s6, 24($sp)
        lw      $s5, 20($sp)
        lw      $s4, 16($sp)
        lw      $s3, 12($sp)
        lw      $s2, 8($sp)
        lw      $s1, 4($sp)
        lw      $s0, 0($sp)
        addi    $sp, $sp, A_FRAMESIZE_40
        jr      $ra


getNeighbors:
        addi    $sp, $sp, -A_FRAMESIZE_8
        sw      $ra, -4+A_FRAMESIZE_8($sp)

        # right
        addi    $t0, $s1, 0     # row+0
        addi    $t1, $s2, 1     # col+1
        li      $t2, 0          # position in array (calculated later)
        li      $t5, -1         # load -1

        bne     $t1, $s0, getNeighborsRg
        sub     $t1, $t1, $s0
getNeighborsRg:
        mul     $t2, $t0, $s0   # boardSize * row
        add     $t2, $t2, $t1   # boardSize * row + col
        add     $t2, $t2, $s4   # boardSize * row + col + arrayP address
        lbu     $t2, 0($t2)     # get char at $t2, throw away $t2

        li      $t3, 65         # holds 'A'
        li      $t4, 66         # holds 'B'

        beq     $t2, $t3, getNeighborsRgA
        beq     $t2, $t4, getNeighborsRgB
        j       getNeighborsRgS

getNeighborsRgA:
        addi    $s6, $s6, 1     # add 1 to A_neighbor count
        j       getNeighborsRgS
getNeighborsRgB:
        addi    $s7, $s7, 1     # add 1 to B_neighbor count
        j       getNeighborsRgS
getNeighborsRgS:


        # left
        addi    $t0, $s1, 0     # row+0
        addi    $t1, $s2, -1    # col-1
        li      $t2, 0          # position in array (calculated later)
        li      $t5, -1         # load -1

        bne     $t1, $t5, getNeighborsLg
        add     $t1, $t1, $s0
getNeighborsLg:
        mul     $t2, $t0, $s0   # boardSize * row
        add     $t2, $t2, $t1   # boardSize * row + col
        add     $t2, $t2, $s4   # boardSize * row + col + arrayP address
        lbu     $t2, 0($t2)     # get char at $t2, throw away $t2

        li      $t3, 65         # holds 'A'
        li      $t4, 66         # holds 'B'

        beq     $t2, $t3, getNeighborsLgA
        beq     $t2, $t4, getNeighborsLgB
        j       getNeighborsLgS

getNeighborsLgA:
        addi    $s6, $s6, 1     # add 1 to A_neighbor count
        j       getNeighborsLgS
getNeighborsLgB:
        addi    $s7, $s7, 1     # add 1 to B_neighbor count
        j       getNeighborsLgS
getNeighborsLgS:


        # up
        addi    $t0, $s1, -1    # row-1
        addi    $t1, $s2, 0     # col+0
        li      $t2, 0          # position in array (calculated later)
        li      $t5, -1         # load -1

        bne     $t0, $t5, getNeighborsUg
        add     $t0, $t0, $s0
getNeighborsUg:
        mul     $t2, $t0, $s0   # boardSize * row
        add     $t2, $t2, $t1   # boardSize * row + col
        add     $t2, $t2, $s4   # boardSize * row + col + arrayP address
        lbu     $t2, 0($t2)     # get char at $t2, throw away $t2

        li      $t3, 65         # holds 'A'
        li      $t4, 66         # holds 'B'

        beq     $t2, $t3, getNeighborsUgA
        beq     $t2, $t4, getNeighborsUgB
        j       getNeighborsUgS

getNeighborsUgA:
        addi    $s6, $s6, 1     # add 1 to A_neighbor count
        j       getNeighborsUgS
getNeighborsUgB:
        addi    $s7, $s7, 1     # add 1 to B_neighbor count
        j       getNeighborsUgS
getNeighborsUgS:


        # down
        addi    $t0, $s1, 1     # row+1
        addi    $t1, $s2, 0     # col+0
        li      $t2, 0          # position in array (calculated later)
        li      $t5, -1         # load -1

        bne     $t0, $s0, getNeighborsDg
        sub     $t0, $t0, $s0
getNeighborsDg:
        mul     $t2, $t0, $s0   # boardSize * row
        add     $t2, $t2, $t1   # boardSize * row + col
        add     $t2, $t2, $s4   # boardSize * row + col + arrayP address
        lbu     $t2, 0($t2)     # get char at $t2, throw away $t2

        li      $t3, 65         # holds 'A'
        li      $t4, 66         # holds 'B'

        beq     $t2, $t3, getNeighborsDgA
        beq     $t2, $t4, getNeighborsDgB
        j       getNeighborsDgS

getNeighborsDgA:
        addi    $s6, $s6, 1     # add 1 to A_neighbor count
        j       getNeighborsDgS
getNeighborsDgB:
        addi    $s7, $s7, 1     # add 1 to B_neighbor count
        j       getNeighborsDgS
getNeighborsDgS:


        # right up
        addi    $t0, $s1, -1    # row-1
        addi    $t1, $s2, 1     # col+1
        li      $t2, 0          # position in array (calculated later)
        li      $t5, -1         # load -1

        bne     $t0, $t5, getNeighborsRUg
        add     $t0, $t0, $s0
getNeighborsRUg:
        bne     $t1, $s0, getNeighborsRUg2
        sub     $t1, $t1, $s0
getNeighborsRUg2:
        mul     $t2, $t0, $s0   # boardSize * row
        add     $t2, $t2, $t1   # boardSize * row + col
        add     $t2, $t2, $s4   # boardSize * row + col + arrayP address
        lbu     $t2, 0($t2)     # get char at $t2, throw away $t2

        li      $t3, 65         # holds 'A'
        li      $t4, 66         # holds 'B'

        beq     $t2, $t3, getNeighborsRUgA
        beq     $t2, $t4, getNeighborsRUgB
        j       getNeighborsRUgS

getNeighborsRUgA:
        addi    $s6, $s6, 1     # add 1 to A_neighbor count
        j       getNeighborsRUgS
getNeighborsRUgB:
        addi    $s7, $s7, 1     # add 1 to B_neighbor count
        j       getNeighborsRUgS
getNeighborsRUgS:


        # left up
        addi    $t0, $s1, -1    # row-1
        addi    $t1, $s2, -1    # col-1
        li      $t2, 0          # position in array (calculated later)
        li      $t5, -1         # load -1

        bne     $t0, $t5, getNeighborsLUg
        add     $t0, $t0, $s0
getNeighborsLUg:
        bne     $t1, $t5, getNeighborsLUg2
        add     $t1, $t1, $s0
getNeighborsLUg2:
        mul     $t2, $t0, $s0   # boardSize * row
        add     $t2, $t2, $t1   # boardSize * row + col
        add     $t2, $t2, $s4   # boardSize * row + col + arrayP address
        lbu     $t2, 0($t2)     # get char at $t2, throw away $t2

        li      $t3, 65         # holds 'A'
        li      $t4, 66         # holds 'B'

        beq     $t2, $t3, getNeighborsLUgA
        beq     $t2, $t4, getNeighborsLUgB
        j       getNeighborsLUgS

getNeighborsLUgA:
        addi    $s6, $s6, 1     # add 1 to A_neighbor count
        j       getNeighborsLUgS
getNeighborsLUgB:
        addi    $s7, $s7, 1     # add 1 to B_neighbor count
        j       getNeighborsLUgS
getNeighborsLUgS:


        # right down
        addi    $t0, $s1, 1     # row+1
        addi    $t1, $s2, 1     # col+1
        li      $t2, 0          # position in array (calculated later)
        li      $t5, -1         # load -1

        bne     $t0, $s0, getNeighborsRDg
        sub     $t0, $t0, $s0
getNeighborsRDg:
        bne     $t1, $s0, getNeighborsRDg2
        sub     $t1, $t1, $s0
getNeighborsRDg2:
        mul     $t2, $t0, $s0   # boardSize * row
        add     $t2, $t2, $t1   # boardSize * row + col
        add     $t2, $t2, $s4   # boardSize * row + col + arrayP address
        lbu     $t2, 0($t2)     # get char at $t2, throw away $t2

        li      $t3, 65         # holds 'A'
        li      $t4, 66         # holds 'B'

        beq     $t2, $t3, getNeighborsRDgA
        beq     $t2, $t4, getNeighborsRDgB
        j       getNeighborsRDgS

getNeighborsRDgA:
        addi    $s6, $s6, 1     # add 1 to A_neighbor count
        j       getNeighborsRDgS
getNeighborsRDgB:
        addi    $s7, $s7, 1     # add 1 to B_neighbor count
        j       getNeighborsRDgS
getNeighborsRDgS:


        # left down
        addi    $t0, $s1, 1     # row+0
        addi    $t1, $s2, -1    # col-1
        li      $t2, 0          # position in array (calculated later)
        li      $t5, -1         # load -1

        bne     $t0, $s0, getNeighborsLDg
        sub     $t0, $t0, $s0
getNeighborsLDg:
        bne     $t1, $t5, getNeighborsLDg2
        add     $t1, $t1, $s0
getNeighborsLDg2:
        mul     $t2, $t0, $s0   # boardSize * row
        add     $t2, $t2, $t1   # boardSize * row + col
        add     $t2, $t2, $s4   # boardSize * row + col + arrayP address
        lbu     $t2, 0($t2)     # get char at $t2, throw away $t2

        li      $t3, 65         # holds 'A'
        li      $t4, 66         # holds 'B'

        beq     $t2, $t3, getNeighborsLDgA
        beq     $t2, $t4, getNeighborsLDgB
        j       getNeighborsLDgS

getNeighborsLDgA:
        addi    $s6, $s6, 1     # add 1 to A_neighbor count
        j       getNeighborsLDgS
getNeighborsLDgB:
        addi    $s7, $s7, 1     # add 1 to B_neighbor count
        j       getNeighborsLDgS
getNeighborsLDgS:

        lw      $ra, -4+A_FRAMESIZE_8($sp)
        addi    $sp, $sp, A_FRAMESIZE_8

        jr      $ra


updateBoardM:
        addi    $sp, $sp, -A_FRAMESIZE_8
        sw      $ra, -4+A_FRAMESIZE_8($sp)


updateBoardMHelp:
        #lbu     $s6, 0($s4)
        #move    $a0, $s6
        
        li      $s6, 0          # reset A_neighbors
        li      $s7, 0          # reset B_neighbors


        jal     getNeighbors

                                # s0 is boardSize
                                # s1 is row
                                # s2 is col
                                # s4 is arrayP
                                # s5 is arrayS
        mul     $t0, $s0, $s1   # boardSize * row
        add     $t0, $t0, $s2   # boardSize * row + col
        add     $t1, $t0, $s4   # " " + load from address (arrayP)
        add     $t2, $t0, $s5   # " " + write to address  (arrayS)
        lbu     $t1, 0($t1)
        

        li      $t3, 65         # holds 'A'
        beq     $t1, $t3, updateBoardMfocA
        li      $t3, 66         # holds 'B'
        beq     $t1, $t3, updateBoardMfocB
        j       updateBoardMfocS



updateBoardMfocA:
        sub     $t4, $s6, $s7   # A-B (focus on A)
        li      $t5, 2          # $t5 is 1
        slt     $t6, $t4, $t5   # if $t4 < $t5, $t6 is 1
                                # if $t4 < $t5, goto updateBoardMfocAkill

        li      $t7, 1
        beq     $t6, $t7, updateBoardMfocAkill

        li      $t5, 2          # compare A-neighbors to 2
        beq     $t5, $t4, updateBoardMfocAlive
        li      $t5, 3          # compare A-neighbors to 3
        beq     $t5, $t4, updateBoardMfocAlive

        j       updateBoardMfocAkill

updateBoardMfocAkill:
        li      $t3, 32         # holds ' '
        sb      $t3, 0($t2)     # store ' ' in arrayS
        j       updateBoardMHelpD

updateBoardMfocAlive:
        li      $t3, 65         # holds 'A'
        sb      $t3, 0($t2)     # store 'A' in arrayS
        j       updateBoardMHelpD

updateBoardMfocB:
        sub     $t4, $s7, $s6   # B-A (focus on B)
        li      $t5, 2          # $t5 is 1
        slt     $t6, $t4, $t5   # if $t4 < $t5, $t6 is 1
                                # if $t4 < $t5, goto updateBoardMfocBkill
        li      $t7, 1
        beq     $t6, $t7, updateBoardMfocBkill

        li      $t5, 2          # compare B-neighbors to 2
        beq     $t5, $t4, updateBoardMfocBlive
        li      $t5, 3          # compare B-neighbors to 2
        beq     $t5, $t4, updateBoardMfocBlive

        j       updateBoardMfocBkill

updateBoardMfocBkill:
        li      $t3, 32         # holds ' '
        sb      $t3, 0($t2)     # store 'A' in arrayS
        j       updateBoardMHelpD

updateBoardMfocBlive:
        li      $t3, 66         # holds 'B'
        sb      $t3, 0($t2)     # store 'B' in arrayS
        j       updateBoardMHelpD

updateBoardMfocS:
        sub     $t4, $s6, $s7   # A-B (focus on Space)
        li      $t5, 3          # load 3 to compare neighbors
        beq     $t4, $t5, updateBoardMfocAlive
        sub     $t4, $s7, $s6   # B-A
        beq     $t4, $t5, updateBoardMfocBlive

        li      $t3, 32         # holds ' '
        sb      $t3, 0($t2)     # store ' ' in arrayS
        j       updateBoardMHelpD



updateBoardMHelpD:
        
        li      $s6, 0          # reset A_neighbors - Free var
        li      $s7, 0          # reset B_neighbors - Free var

        


        lw      $s2, updateBoardcol
        addi    $s2, $s2, 1     # col + 1
        sw      $s2, updateBoardcol


        bne     $s0, $s2, updateBoardMHelp

        lw      $ra, -4+A_FRAMESIZE_8($sp)
        addi    $sp, $sp, A_FRAMESIZE_8

        jr      $ra


updateBoardS:
        addi    $sp, $sp, -A_FRAMESIZE_8
        sw      $ra, -4+A_FRAMESIZE_8($sp)
    
updateBoardSHelp:
        move    $s2, $zero      # counts col number (iterator)
                                # protects this value
        sw      $s2, updateBoardcol

        jal     updateBoardM

        addi    $s1, $s1, 1
        bne     $s0, $s1, updateBoardSHelp

        lw      $ra, -4+A_FRAMESIZE_8($sp)
        addi    $sp, $sp, A_FRAMESIZE_8

        jr      $ra



updateBoard:
        addi    $sp, $sp, -A_FRAMESIZE_40
        sw      $ra, -4+A_FRAMESIZE_40($sp)
        sw      $s7, 28($sp)
        sw      $s6, 24($sp)
        sw      $s5, 20($sp)
        sw      $s4, 16($sp)
        sw      $s3, 12($sp)
        sw      $s2, 8($sp)
        sw      $s1, 4($sp)
        sw      $s0, 0($sp)

        lw      $s0, boardSize  # boardSize
        li      $s1, 0          # row
        li      $s2, 0          # col
        li      $s3, 0          # boardSize*row + col

        la      $s4, arrayP     # primary array
        la      $s5, arrayS     # scrap array
        


        jal     updateBoardS    # update to arrayS
        jal     copyStP         # move arrayS data to arrayP




        lw      $ra, -4+A_FRAMESIZE_40($sp)
        lw      $s7, 28($sp)
        lw      $s6, 24($sp)
        lw      $s5, 20($sp)
        lw      $s4, 16($sp)
        lw      $s3, 12($sp)
        lw      $s2, 8($sp)
        lw      $s1, 4($sp)
        lw      $s0, 0($sp)
        addi    $sp, $sp, A_FRAMESIZE_40
        jr      $ra






#
# Name:         main
#
# Description:  EXECUTION BEGINS HERE
# Arguments:    none
# Returns:      none
#
main:
        addi    $sp, $sp, -A_FRAMESIZE_8
        sw      $ra, -4+A_FRAMESIZE_8($sp)

        li      $v0, 4          # print intro text
        la      $a0, sText1
        syscall

        li      $v0, 4
        la      $a0, sText2
        syscall

        li      $v0, 4
        la      $a0, sText3
        syscall                 # end of intro text
        
                                # prompt user for board size
        li      $v0, 4
        la      $a0, pText1
        syscall

mainpText1b:
        jal     getInput        # get the board size from user input


        move    $s0, $v0        # store board size in $s0
        
                                # comparing data result to min
        addi    $t0, $zero, 4   # set constant 4 in $t0
        slt     $t1, $s0, $t0   # if board size < 4,   $t1 = 1
                                # if user input is < 4, $t1 = 1, error

        addi    $t2, $zero, 1   # set constant 1 in $t2
        beq     $t1, $t2, mainpText1err

                                # comparing data result to max
        addi    $t0, $zero, 30  # set constant 30 in $t0
        slt     $t1, $t0, $s0   # if 20 < board size,   $t1 = 1 (this is err)
                                # no need for constant
                                # jump out if 4 <= data <= 20
        beq     $t1, $zero, mainpText2a
        j       mainpText1err   # board size > 20, error

mainpText1err:                  # prompt user with board size ERROR
        li      $v0, PRINT_STRING
        la      $a0, p1Warn
        syscall

        j       mainpText1b


mainpText2a:                    # we now prompt and gather second user input
        sw      $s0, boardSize  # we need to save user input to a global
                                #  variable so it can be used later
                                # store in boardSize

                                # prompt user for num of generations to run
        li      $v0, PRINT_STRING
        la      $a0, pText2
        syscall

mainpText2b:
        jal     getInput        # get the generations to run from user input
        

        move    $s1, $v0        # store generations to run in $s1

                                # comparing data result to min
        addi    $t0, $zero, 0   # set constant 0 in $t0
        slt     $t1, $s1, $t0   # if board size < 4,   $t1 = 1
                                # if user input is < 4, $t1 = 1, error

        addi    $t2, $zero, 1   # set constant 1 in $t2
        beq     $t1, $t2, mainpText2err

                                # comparing data result to max
        addi    $t0, $zero, 20  # set constant 20 in $t0
        slt     $t1, $t0, $s1   # if 20 < board size,   $t1 = 1 (this is err)
                                # no need for constant
                                # jump out if 4 <= data <= 20
        beq     $t1, $zero, mainpText3a
        j       mainpText2err   # board size > 20, error

mainpText2err:                  # prompt user with board size ERROR

        li      $v0, PRINT_STRING
        la      $a0, p2Warn
        syscall

        j       mainpText2b

mainpText3a:
                                # we now prompt and gather third user input
                                #
                                # $s2 holds number of squares on the board
                                ##############################################
                                # we need to save user input to a global
                                #  variable so it can be used later
        sw      $s1, genToRun   # store in genToRun
                                # initialize generation counter
        sw      $zero, generation

                                # prompt user for num of generations to run
        li      $v0, PRINT_STRING
        la      $a0, pText3
        syscall

        mul     $s2, $s0, $s0   # $s2 holds number of squares on the board

mainpText3b:
                                
                                ##############################################
                                # s3 will hold numAlive_A

        

        jal     getInput        # get numAlive_A from user (0 <= nA_A <= $s2)

        move    $s3, $v0        # store numAlive_A in $s3

                                # comparing data result to min
        addi    $t0, $zero, 0   # set constant 0 in $t0
        slt     $t1, $s3, $t0   # if board size < 4,   $t1 = 1
                                # if user input is < 4, $t1 = 1, error

        addi    $t2, $zero, 1   # set constant 1 in $t2
        beq     $t1, $t2, mainpText3err

                                # comparing data result to max
        add     $t0, $zero, $s2 # set constant boardSize^2 in $t0
        slt     $t1, $t0, $s3   # if 20 < board size,   $t1 = 1 (this is err)
                                # no need for constant
                                # jump out if 4 <= data <= 20
        beq     $t1, $zero, mainpText4a
        j       mainpText3err   # board size > 20, error

mainpText3err:

                                        # prompt user with board size ERROR
        li      $v0, PRINT_STRING
        la      $a0, p3Warn
        syscall

        j       mainpText3b


mainpText4a:
                                ##############################################
                                # we now initialize both arrays
        la      $s4, arrayP     # $s4 temp array address holder
        move    $s5, $s4        # $s5 temp array location holder
        la      $s6, arrayP     # $s6 temp array address holder
        move    $s7, $s6        # $s7 temp array location holder
        addi    $t0, $zero, 0   # $t0 temp index, comparing to $s2

        li      $t1, 32

                                # prompt user for locations
        li      $v0, PRINT_STRING
        la      $a0, pText4
        syscall

mainpText4loop:                 # only mainpText4 needs to initialize arrays
        beq     $t0, $s2, mainpText4bPre

        sb      $t1, 0($s5)
        sb      $t1, 0($s7)

        addi    $s5, $s5, 1
        addi    $s7, $s7, 1
        addi    $t0, $t0, 1
        j       mainpText4loop



mainpText4bPre:
                                # throw array $s6 $s7
                                # grab locations from users
                                #  throw out out of bounds locations

        li      $s6, 0          # erase $s6
        li      $s7, 0          # erase $s7

mainpText4b:
        beq     $s3, $zero, mainpText5a
                                # check how many locs. are left to be placed


        jal     getInput        # get row from user (0 <= nA_A <= $s2)

        move    $s6, $v0        # store row in $s6

                                # comparing data result to min
        addi    $t0, $zero, 0   # set constant 0 in $t0
        slt     $t1, $s6, $t0   # if row < 0,   $t1 = 1

        addi    $t2, $zero, 1   # set constant 1 in $t2
        beq     $t1, $t2, mainpText4err

                                # comparing data result to max
        addi    $t3, $s0, -1    # boardSize -1 to account for zero-indexing
        slt     $t1, $t3, $s6   # if $s0 (boardSize) -1 < row, $t1 = 1 (err)
                                # jump out if 4 <= data <= 20
                                # row > $s0 (boardSize), error
        beq     $t1, $t2, mainpText4err



        jal     getInput        # get col from user (0 <= nA_A <= $s2)

        move    $s7, $v0        # store col in $s7

                                # comparing data result to min
        addi    $t0, $zero, 0   # set constant 0 in $t0
        slt     $t1, $s7, $t0   # if row < 0,   $t1 = 1

        addi    $t2, $zero, 1   # set constant 1 in $t2
        beq     $t1, $t2, mainpText4err

                                # comparing data result to max
        addi    $t3, $s0, -1    # boardSize -1 to account for zero-indexing
        slt     $t1, $t3, $s7   # if $s0 (boardSize) < row, $t1 = 1 (err)
                                # jump out if 4 <= data <= 20
                                # row > $s0 (boardSize), error
        beq     $t1, $t2, mainpText4err


                                # NumCols * row + col
        mul     $s6, $s0, $s6   # NumCols * row
        add     $s6, $s7, $s6   # + col
        add     $s6, $s4, $s6   # add on memory address in matrix

        li      $t0, 65         # ascii 'A'
        sb      $t0, 0($s6)     # store 'A' in array

        addi    $s3, $s3, -1    # decrease number of inputs to take in by one

        j       mainpText4b     # loop, check at loop



mainpText4err:
                                # prompt user, illegal point location
        li      $v0, PRINT_STRING
        la      $a0, p4Warn
        syscall

        j       mainpText4b



mainpText5a:
                                # prompt user for num of generations to run
        li      $v0, PRINT_STRING
        la      $a0, pText5
        syscall

mainpText5b: 
                                ##############################################
                                # s3 will hold numAlive_B

        jal     getInput        # get numAlive_B from user (0 <= nA_A <= $s2)

        move    $s3, $v0        # store numAlive_B in $s3

                                # comparing data result to min
        addi    $t0, $zero, 0   # set constant 0 in $t0
        slt     $t1, $s3, $t0   # if board size < 4,   $t1 = 1
                                # if user input is < 4, $t1 = 1, error

        addi    $t2, $zero, 1   # set constant 1 in $t2
        beq     $t1, $t2, mainpText5err

                                # comparing data result to max
        add     $t0, $zero, $s2 # set constant boardSize^2 in $t0
        slt     $t1, $t0, $s3   # if 20 < board size,   $t1 = 1 (this is err)
                                # no need for constant
                                # jump out if 4 <= data <= 20
        beq     $t1, $zero, mainpText6a
        j       mainpText5err   # board size > 20, error

mainpText5err:

                                        # prompt user with board size ERROR
        li      $v0, PRINT_STRING
        la      $a0, p3Warn
        syscall

        j       mainpText5b

mainpText6a:
                                # prompt user for locations
        li      $v0, PRINT_STRING
        la      $a0, pText4
        syscall

mainpText6b:
        beq     $s3, $zero, mainProc1pre
                                # check how many locs. are left to be placed


        jal     getInput        # get row from user (0 <= nA_A <= $s2)

        move    $s6, $v0        # store row in $s6

                                # comparing data result to min
        addi    $t0, $zero, 0   # set constant 0 in $t0
        slt     $t1, $s6, $t0   # if row < 0,   $t1 = 1

        addi    $t2, $zero, 1   # set constant 1 in $t2
        beq     $t1, $t2, mainpText6err

                                # comparing data result to max
        addi    $t3, $s0, -1    # boardSize -1 to account for zero-indexing
        slt     $t1, $t3, $s6   # if $s0 (boardSize) -1 < row, $t1 = 1 (err)
                                # jump out if 4 <= data <= 20
                                # row > $s0 (boardSize), error
        beq     $t1, $t2, mainpText6err



        jal     getInput        # get col from user (0 <= nA_A <= $s2)

        move    $s7, $v0        # store col in $s7

                                # comparing data result to min
        addi    $t0, $zero, 0   # set constant 0 in $t0
        slt     $t1, $s7, $t0   # if row < 0,   $t1 = 1

        addi    $t2, $zero, 1   # set constant 1 in $t2
        beq     $t1, $t2, mainpText6err

                                # comparing data result to max
        addi    $t3, $s0, -1    # boardSize -1 to account for zero-indexing
        slt     $t1, $t3, $s7   # if $s0 (boardSize) < row, $t1 = 1 (err)
                                # jump out if 4 <= data <= 20
                                # row > $s0 (boardSize), error
        beq     $t1, $t2, mainpText6err


                                # NumCols * row + col
        mul     $s6, $s0, $s6   # NumCols * row
        add     $s6, $s7, $s6   # + col
        add     $s6, $s4, $s6   # add on memory address in matrix

        li      $t0, 66         # ascii 'B'
        sb      $t0, 0($s6)     # store 'B' in array

        addi    $s3, $s3, -1    # decrease number of inputs to take in by one

        j       mainpText6b     # loop, check at loop



mainpText6err:
                                # prompt user, illegal point location
        li      $v0, PRINT_STRING
        la      $a0, p4Warn
        syscall

        j       mainpText6b


mainProc1pre:
        jal     printBoard      # print the board regardless of # genToRun
        j       mainProc1

mainProc1:                      # code that iterates the simulation steps

        
                                # if #genToRun is above 0, updateBoard
        bne     $s1, $zero, mainProc1uB
        j       mainProc1duB

mainProc1uB:                    # update the board subfunction
        jal     updateBoard

        addi    $s1, $s1, -1    # genToRun -1

        lw      $t9, generation # load generation number from memory
        addi    $t9, $t9, 1     # increase generation number by one
        sw      $t9, generation # store generation number back into memory
        

        jal     printBoard      # print updated board

mainProc1duB:                   # don't update the board
        bne     $s1, $zero, mainProc1
        


        lw      $ra, -4+A_FRAMESIZE_8($sp)
        addi    $sp, $sp, A_FRAMESIZE_8

        jr      $ra

