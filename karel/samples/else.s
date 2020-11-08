L0:
	goto L1
L1:
	invoke 12, 0, 0
L2:
	seti r1, #0
L3:
	goto_eq L10, r0, r1
L4:
	invoke 12, 2, 0
L5:
	seti r3, #0
L6:
	goto_eq L9, r2, r3
L7:
	invoke 1, 0, 0
L8:
	goto L10
L9:
	invoke 2, 0, 0
L10:
	invoke 12, 4, 0
L11:
	seti r5, #0
L12:
	goto_eq L20, r4, r5
L13:
	invoke 12, 6, 0
L14:
	seti r7, #0
L15:
	goto_eq L18, r6, r7
L16:
	invoke 1, 0, 0
L17:
	goto L19
L18:
	invoke 1, 0, 0
L19:
	goto L21
L20:
	invoke 2, 0, 0
L21:
	invoke 12, 8, 0
L22:
	seti r9, #0
L23:
	goto_eq L31, r8, r9
L24:
	invoke 12, 10, 0
L25:
	seti r11, #0
L26:
	goto_eq L29, r10, r11
L27:
	invoke 1, 0, 0
L28:
	goto L30
L29:
	invoke 1, 0, 0
L30:
	goto L37
L31:
	invoke 12, 12, 0
L32:
	seti r13, #0
L33:
	goto_eq L36, r12, r13
L34:
	invoke 1, 0, 0
L35:
	goto L37
L36:
	invoke 1, 0, 0
L37:
	invoke 12, 14, 0
L38:
	seti r15, #0
L39:
	goto_eq L52, r14, r15
L40:
	invoke 12, 16, 0
L41:
	seti r17, #0
L42:
	goto_eq L52, r16, r17
L43:
	invoke 12, 18, 0
L44:
	seti r19, #0
L45:
	goto_eq L52, r18, r19
L46:
	invoke 12, 20, 0
L47:
	seti r21, #0
L48:
	goto_eq L51, r20, r21
L49:
	invoke 1, 0, 0
L50:
	goto L52
L51:
	invoke 2, 0, 0
L52:
	seti r22, #5
L53:
	seti r23, #1
L54:
	goto_lt L61, r22, r23
L55:
	invoke 12, 24, 0
L56:
	seti r25, #0
L57:
	goto_eq L59, r24, r25
L58:
	invoke 1, 0, 0
L59:
	sub r22, r22, r23
L60:
	goto L54
L61:
	seti r26, #5
L62:
	seti r27, #1
L63:
	goto_lt L72, r26, r27
L64:
	invoke 12, 28, 0
L65:
	seti r29, #0
L66:
	goto_eq L69, r28, r29
L67:
	invoke 1, 0, 0
L68:
	goto L70
L69:
	invoke 2, 0, 0
L70:
	sub r26, r26, r27
L71:
	goto L63
L72:
	invoke 12, 30, 0
L73:
	seti r31, #0
L74:
	goto_eq L80, r30, r31
L75:
	invoke 12, 32, 0
L76:
	seti r33, #0
L77:
	goto_eq L79, r32, r33
L78:
	invoke 1, 0, 0
L79:
	goto L72
L80:
	invoke 12, 34, 0
L81:
	seti r35, #0
L82:
	goto_eq L90, r34, r35
L83:
	invoke 12, 36, 0
L84:
	seti r37, #0
L85:
	goto_eq L88, r36, r37
L86:
	invoke 1, 0, 0
L87:
	goto L89
L88:
	invoke 2, 0, 0
L89:
	goto L80
L90:
	invoke 12, 38, 0
L91:
	seti r39, #0
L92:
	goto_eq L95, r38, r39
L93:
	invoke 1, 0, 0
L94:
	goto L105
L95:
	invoke 12, 40, 0
L96:
	seti r41, #0
L97:
	goto_eq L105, r40, r41
L98:
	invoke 12, 42, 0
L99:
	seti r43, #0
L100:
	goto_eq L103, r42, r43
L101:
	invoke 1, 0, 0
L102:
	goto L104
L103:
	invoke 2, 0, 0
L104:
	goto L95
L105:
	invoke 12, 44, 0
L106:
	seti r45, #0
L107:
	goto_eq L110, r44, r45
L108:
	invoke 1, 0, 0
L109:
	goto L118
L110:
	invoke 12, 46, 0
L111:
	seti r47, #0
L112:
	goto_eq L118, r46, r47
L113:
	invoke 12, 48, 0
L114:
	seti r49, #0
L115:
	goto_eq L117, r48, r49
L116:
	invoke 1, 0, 0
L117:
	goto L110
L118:
	invoke 12, 50, 0
L119:
	seti r51, #0
L120:
	goto_eq L132, r50, r51
L121:
	invoke 12, 52, 0
L122:
	seti r53, #0
L123:
	goto_eq L131, r52, r53
L124:
	invoke 12, 54, 0
L125:
	seti r55, #0
L126:
	goto_eq L129, r54, r55
L127:
	invoke 1, 0, 0
L128:
	goto L130
L129:
	invoke 2, 0, 0
L130:
	goto L121
L131:
	goto L133
L132:
	invoke 2, 0, 0
L133:
	stop
L134:
