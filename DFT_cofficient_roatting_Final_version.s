#DFT rotating
#register assignments :  	$t0= cofficient rotate step length
#							$t1= index of original matrix
#							$t2= index of cofficient
#							$t3= offset of element of cos matrix
#							$t4= offset of element of sin matrix
#							$a1= store cosine(real cofficient) array address 
#							$a2= store sine(imaginary cofficient) array address
#							$a3= store  address of dft input matrix

#################################################################################################################################
		.data
cosar:	.float 	1.0 0.9239 0.7071 0.3827 0.0 -0.3827 -0.7071 -0.9239 -1.0 -0.9239 -0.7071 -0.3827 0.0 0.3827 0.7071 0.9239 #real coffecients 
sinar:	.float 	0.0 0.3827 0.7071 0.9239 1.0 0.9239 0.7071 0.3827 0.0 -0.3827 -0.7071 -0.9239 -1.0 -0.9239 -0.7071 -0.3827 #imginal coffecients
ori_matr:.float 2.1 3.5 -1.4 3.3 -2.3 5.5 6.1 -1.5 -2.4 -13.5 9.4 3.7 2.9 4.4 0.9 1.5		#original sequence
impat: 	.asciiz "i"
plus:	.asciiz "+"
blank:	.asciiz " "
newl:	.asciiz "\n"

		.text
main:	
		la 		$a1, cosar
		la 		$a2, sinar
		la 		$a3, ori_matr
		li 		$t0, -16			# t0 is the step length of cofficient rotate
		li  	$t1, -1  			# reset the index of original matrix
		li  	$t2, 0 			# reset the index of cofficient


cnvt_lp:		
								
#load current cos and sin cofficient to coprossor
		add 	$t2, $t2, $t0		# get current index: fromal index+step
		andi 	$t2, $t2, 0x000f	# make sure not exceed the bound
		mul 	$t3, $t2, 4			# get the offset of the element
		add 	$t3, $t3, $a1		# get cos cofficient offset
		lw	 	$t5, ($t3)
		mtc1 	$t5, $f0			# load the element to the float point regisister f0
		mul 	$t3, $t2, 4	
		add 	$t4, $t3, $a2		# get sin cofficient offset 
		lw  	$t6, ($t4)
		mtc1 	$t6, $f2			# load the element to the float point regisister f1

# load original element to the coprocessor
		addi 	$t1, $t1, 1 		# get index: fromal index+1
		andi 	$t1, $t1, 0x000f	
		mul 	$t3, $t1, 4			# get the offset of the element
		add 	$t3, $t3, $a3		# get the address of element
		lw	 	$t7, ($t3)
		mtc1 	$t7, $f4

#process data
		mul.s 	$f6, $f0, $f4		# real part
		mul.s 	$f8, $f2, $f4		# imaginary part
		add.s 	$f10, $f10, $f6		# sum of real part
		add.s 	$f14, $f14, $f8		# sum of imaginary part

		blt 	$t1, 15, cnvt_lp	# inner loop sentinel

# print the result
        mov.s   $f12,$f10            # $f12 = argument
        li      $v0,2               # print real part
        syscall

        la      $a0,blank           # print blank
        li      $v0,4               # print string
        syscall

        la      $a0,plus           # print +
        li      $v0,4               # print string
        syscall

        la      $a0,blank           # print blank
        li      $v0,4               # print string
        syscall

        mov.s   $f12,$f14           # $f12 = argument
        li      $v0,2               # print imginary part
        syscall

        la      $a0,impat           # print i
        li      $v0,4               # print string
        syscall
        
        la      $a0,newl            # new line
        li      $v0,4               # print string
        syscall

# rest index and add steps
		addi 	$t0, $t0, 1 		# cofficient access step +1
		move 	$t1, $0 			# reset original matrix index
		move 	$t2, $0 			# reset cofficient matrix index
		li.s 	$f10, 0.0
		li.s 	$f14. 0.0
		bgtz	$t0, cnvt_lp 	# outter loop sentinel
		
		li      $v0,10              # code 10 == exit
        syscall                     # Return to OS.

