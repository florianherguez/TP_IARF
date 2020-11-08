L0:
	goto L1
L1:
	invoke 12, 0, 0
L2:
	seti r1, #0
L3:
	goto_eq L33, r0, r1
L4:
	invoke 5, 1, 2
L5:
	seti r3, #0
L6:
	goto_eq L13, r2, r3
L7:
	invoke 1, 0, 0
L8:
	invoke 11, 4, 0
L9:
	seti r5, #0
L10:
	goto_eq L12, r4, r5
L11:
	stop
L12:
	goto L4
L13:
	invoke 2, 0, 0
L14:
	invoke 1, 0, 0
L15:
	invoke 2, 0, 0
L16:
	invoke 5, 1, 6
L17:
	seti r7, #0
L18:
	goto_eq L25, r6, r7
L19:
	invoke 1, 0, 0
L20:
	invoke 11, 8, 0
L21:
	seti r9, #0
L22:
	goto_eq L24, r8, r9
L23:
	stop
L24:
	goto L16
L25:
	invoke 2, 0, 0
L26:
	invoke 2, 0, 0
L27:
	invoke 2, 0, 0
L28:
	invoke 1, 0, 0
L29:
	invoke 2, 0, 0
L30:
	invoke 2, 0, 0
L31:
	invoke 2, 0, 0
L32:
	goto L1
L33:
	stop
L34:
