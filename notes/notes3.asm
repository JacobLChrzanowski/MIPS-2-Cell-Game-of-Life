
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

        jr      $ra             # Return to the caller.


	li      $v0, 1          # print user's input
        move    $a0, $t0
        syscall

        sw      $s0, boardSize 	# store in boardSize
        lw      $s1, boardSize  # retrieve from boardSize
        li      $v0, 1 		# set print type to int
        move    $a0, $s1	# move data to a0
        syscall			# print