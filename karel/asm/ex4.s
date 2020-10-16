@
@ Question 5.2
@
@ Ecrivez un programme qui fait un parcours vertical depuis
@ sa position courante jusqu’à ce qu’il trouve un beeper.
@ Il partira vers le nord puis, quand il trouvera un mur,
@ il tournera à gauche et avancera avant de repartir vers
@ le sud et ainsi de suite.
@
_start:

	seti r0, #0
	seti r2, #1
	seti r3, #0
	seti r4, #1
	seti r6, #0

loop:
	invoke 11, 5, 0
	goto_ne end, r5, r6
	invoke 1, 0, 0
	invoke 6, 1, 1
	goto_ne turn, r0, r1
	goto loop

turn:
	goto_eq leftTurn, r2, r4
	goto_eq rightTurn, r2, r3


leftTurn:
	invoke 2, 0, 0
	invoke 1, 0, 0
	invoke 2, 0, 0
	seti r2, #0
	goto loop

rightTurn:
	invoke 2, 0, 0
	invoke 2, 0, 0
	invoke 2, 0, 0
	invoke 1, 0, 0
	invoke 2, 0, 0
	invoke 2, 0, 0
	invoke 2, 0, 0
	seti r2, #1
	goto loop


end:
	stop
