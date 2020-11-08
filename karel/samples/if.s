L0:
	goto L1
L1:
	invoke 12, 0, 0
L2:
	seti r1, #0
L3:
	goto_eq L5, r0, r1
L4:
	invoke 1, 0, 0
L5:
	invoke 8, 1, 2
L6:
	seti r3, #0
L7:
	goto_eq L9, r2, r3
L8:
	invoke 2, 0, 0
L9:
	invoke 8, 2, 4
L10:
	seti r5, #0
L11:
	goto_eq L16, r4, r5
L12:
	invoke 8, 4, 6
L13:
	seti r7, #0
L14:
	goto_eq L16, r6, r7
L15:
	invoke 2, 0, 0
L16:
	invoke 8, 1, 8
L17:
	seti r9, #0
L18:
	goto_eq L24, r8, r9
L19:
	invoke 2, 0, 0
L20:
	invoke 8, 1, 10
L21:
	seti r11, #0
L22:
	goto_eq L24, r10, r11
L23:
	invoke 2, 0, 0
L24:
	invoke 8, 1, 12
L25:
	seti r13, #0
L26:
	goto_eq L38, r12, r13
L27:
	invoke 2, 0, 0
L28:
	invoke 8, 1, 14
L29:
	seti r15, #0
L30:
	goto_eq L38, r14, r15
L31:
	invoke 8, 1, 16
L32:
	seti r17, #0
L33:
	goto_eq L38, r16, r17
L34:
	invoke 8, 1, 18
L35:
	seti r19, #0
L36:
	goto_eq L38, r18, r19
L37:
	invoke 2, 0, 0
L38:
	invoke 8, 2, 20
L39:
	seti r21, #0
L40:
	goto_eq L46, r20, r21
L41:
	invoke 8, 4, 22
L42:
	seti r23, #0
L43:
	goto_eq L46, r22, r23
L44:
	invoke 2, 0, 0
L45:
	invoke 2, 0, 0
L46:
	invoke 8, 2, 24
L47:
	seti r25, #0
L48:
	goto_eq L71, r24, r25
L49:
	invoke 8, 4, 26
L50:
	seti r27, #0
L51:
	goto_eq L71, r26, r27
L52:
	invoke 8, 2, 28
L53:
	seti r29, #0
L54:
	goto_eq L71, r28, r29
L55:
	invoke 8, 4, 30
L56:
	seti r31, #0
L57:
	goto_eq L71, r30, r31
L58:
	invoke 8, 2, 32
L59:
	seti r33, #0
L60:
	goto_eq L71, r32, r33
L61:
	invoke 8, 4, 34
L62:
	seti r35, #0
L63:
	goto_eq L71, r34, r35
L64:
	invoke 8, 2, 36
L65:
	seti r37, #0
L66:
	goto_eq L71, r36, r37
L67:
	invoke 8, 4, 38
L68:
	seti r39, #0
L69:
	goto_eq L71, r38, r39
L70:
	invoke 2, 0, 0
L71:
	stop
L72:
