{
open Parser
}

let comment = '{' [^ '}']* '}'
let space = [' ' '\t' '\n']+
let integer = ['0'-'9']+

rule scan =
parse	"BEGINNING-OF-PROGRAM"		{ BEGIN_PROG }
|		"BEGINNING-OF-EXECUTION"	{ BEGIN_EXEC }
|		"END-OF-EXECUTION"			{ END_EXEC }
|		"END-OF-PROGRAM"			{ END_PROG }
|		"move"						{ MOVE }
|		"turnleft"					{ TURN_LEFT }
|		"turnoff"					{ TURN_OFF }
|		"BEGIN"						{ BEGIN }
|		"END"						{ END }
		
|		";"							{ SEMI }


|		space						{ scan lexbuf }
|		comment						{ scan lexbuf }

|		integer	as integer			{ INT (int_of_string integer) }

|		"pickbeeper"				{ PICK_BEEPER }
|		"putbeeper"					{ PUT_BEEPER }
|		"next-to-a-beeper"			{ NEXT_TO_A_BEEPER }

|		_ as c						{ raise (Common.LexerError (Printf.sprintf "unknown character '%c'" c)) } 
