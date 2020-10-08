_start:
	invoke	1, 0, 0
	seti	r0, #0
loop:
	invoke	11, 1, 0
	goto_ne	end, r1, r0
	invoke	1, 0, 0
	goto	loop
end:
	stop
