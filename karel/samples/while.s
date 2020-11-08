L0:
	goto L1
L1:
	invoke 12, 0, 0
L2:
	seti r1, #0
L3:
	goto_eq L6, r0, r1
L4:
	invoke 1, 0, 0
L5:
	goto L1
L6:
	invoke 8, 1, 2
L7:
	seti r3, #0
L8:
	goto_eq L11, r2, r3
L9:
	invoke 2, 0, 0
L10:
	goto L6
L11:
	invoke 8, 2, 4
L12:
	seti r5, #0
L13:
	goto_eq L20, r4, r5
L14:
	invoke 8, 4, 6
L15:
	seti r7, #0
L16:
	goto_eq L19, r6, r7
L17:
	invoke 2, 0, 0
L18:
	goto L14
L19:
	goto L11
L20:
	stop
L21:
