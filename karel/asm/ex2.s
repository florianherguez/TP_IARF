@
@ Question 3.2.2
@
@ En utilisant une boucle, réalisez un programme permettant
@ au robot de se déplacer 5 fois vers le sud.
@
_start:
	invoke	2, 0, 0
	invoke	2, 0, 0
	seti	r0, #0
	seti	r1, #4
	seti	r2, #1
loop:
	add	r0, r0, r2
	invoke	1, 0, 0
	goto_gt	end, r0, r1
	goto	loop
end:
	stop
