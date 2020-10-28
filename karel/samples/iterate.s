L0:
	seti r0, #4
L1:
	seti r1, #0
L2:
	seti r2, #1
L3:
	sub r0, r0, r2
L4:
	goto_ge L7, r0, r1
L5:
	invoke 1, 0, 0
L6:
	invoke 2, 0, 0
L7:
	seti r3, #4
L8:
	seti r4, #0
L9:
	seti r5, #1
L10:
	sub r3, r3, r5
L11:
	goto_ge L13, r3, r4
L12:
	invoke 1, 0, 0
L13:
	seti r6, #4
L14:
	seti r7, #0
L15:
	seti r8, #1
L16:
	sub r6, r6, r8
L17:
	goto_ge L24, r6, r7
L18:
	seti r9, #2
L19:
	seti r10, #0
L20:
	seti r11, #1
L21:
	sub r9, r9, r11
L22:
	goto_ge L24, r9, r10
L23:
	invoke 2, 0, 0
L24:
	stop
L25:
