L0:
	seti r0, #4
L1:
	seti r1, #1
L2:
	goto_lt L7, r0, r1
L3:
	invoke 1, 0, 0
L4:
	invoke 2, 0, 0
L5:
	sub r0, r0, r1
L6:
	goto L2
L7:
	seti r2, #4
L8:
	seti r3, #1
L9:
	goto_lt L13, r2, r3
L10:
	invoke 1, 0, 0
L11:
	sub r2, r2, r3
L12:
	goto L9
L13:
	seti r4, #4
L14:
	seti r5, #1
L15:
	goto_lt L24, r4, r5
L16:
	seti r6, #2
L17:
	seti r7, #1
L18:
	goto_lt L22, r6, r7
L19:
	invoke 2, 0, 0
L20:
	sub r6, r6, r7
L21:
	goto L18
L22:
	sub r4, r4, r5
L23:
	goto L15
L24:
	stop
L25:
