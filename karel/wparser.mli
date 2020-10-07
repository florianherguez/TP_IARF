type token =
  | WORLD
  | BEEPERS
  | ROBOT
  | WALL
  | EOF
  | INT of (int)

val top :
  (Lexing.lexbuf  -> token) -> Lexing.lexbuf -> unit
