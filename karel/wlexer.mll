{
open Wparser
}

let space = [' ' '\t' '\n']
let int = ['0' - '9']+
let comment = '/' '*' ([^'*'] | ('*' [^ '*']))* '*' '/'

rule scan =
parse	int as i					{ INT (int_of_string i) }
|		"World"						{ WORLD }
|		"Beepers"					{ BEEPERS }
|		"Robot"						{ ROBOT }
|		"Wall"						{ WALL }
|		space+						{ scan lexbuf }
|		eof							{ EOF }
|		comment						{ scan lexbuf }
|		_ as c						{ raise (Common.LexerError (Printf.sprintf "unknown character '%c'" c)) }
