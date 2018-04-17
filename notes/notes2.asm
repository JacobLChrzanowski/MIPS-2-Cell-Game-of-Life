



        la      $a0, plus       # start ptinting the board
        jal     printString
        lw      $s3, boardSize  # holds boardSize but \|/ iterator in pBoardT
        jal     pBoardT
        la      $a0, plus       # end of top row
        jal     printString





        la      $a0, plus       # start printing the top board wall
        jal     printString
        la      $a0, plus       # start printing the top board wall
        jal     printString
        la      $a0, plus       # start printing the top board wall
        jal     printString
        la      $a0, plus       # start printing the top board wall
        jal     printString
        la      $a0, lf         # start printing the top board wall
        jal     printString


5
3
2
0
0
0
1
2
0
2
0
3


# make sure I use la in kill/live