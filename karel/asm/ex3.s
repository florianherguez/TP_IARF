@
@ Question 3.2.3
@
@ Faire un programme où le robot dépose un beeper, avance
@ de 4 positions (sans boucle), se retourne et avance jusqu’à
@ avoir retrouvé un beeper.
@
_start:
	invoke	4, 0, 0
	
	seti r0, #0
	
	invoke	1, 0, 0
	invoke	1, 0, 0
	invoke	1, 0, 0
	invoke	1, 0, 0
	
	invoke	2, 0, 0
	invoke	2, 0, 0
loop:
	invoke	11, 1, 0
	goto_ne	end, r1, r0
	invoke	1, 0, 0
	goto	loop
end:
	stop
