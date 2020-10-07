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

val prog :
  (Lexing.lexbuf  -> token) -> Lexing.lexbuf -> unit
