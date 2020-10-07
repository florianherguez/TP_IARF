type token =
  | ADD
  | SUB
  | MUL
  | DIV
  | NAND
  | NOR
  | SET
  | SETI
  | GOTO
  | GOTO_EQ
  | GOTO_NE
  | GOTO_LT
  | GOTO_LE
  | GOTO_GT
  | GOTO_GE
  | CALL
  | RETURN
  | INVOKE
  | STOP
  | REG of (int)
  | INT of (int)
  | LABEL of (string)
  | COMMA
  | SHARP
  | COLON
  | EOF

val listing :
  (Lexing.lexbuf  -> token) -> Lexing.lexbuf -> unit
