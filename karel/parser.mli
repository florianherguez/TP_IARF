type token =
  | BEGIN_PROG
  | BEGIN_EXEC
  | END_EXEC
  | END_PROG
  | MOVE
  | TURN_LEFT
  | TURN_OFF
  | SEMI
  | BEGIN
  | END
  | PICK_BEEPER
  | PUT_BEEPER
  | NEXT_TO_A_BEEPER
  | INT of (int)

val prog :
  (Lexing.lexbuf  -> token) -> Lexing.lexbuf -> unit
