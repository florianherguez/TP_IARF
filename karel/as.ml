(* Programme réalisant l'assembleur de quadruplets. *)

let source = ref ""
let target = ref ""

let opts = [
	("-o", Arg.Set_string target, "Use the given file as output.")
]
let  doc = "Karel V2 Assembler"

let free_arg s =
	if !source <> ""
	then raise (Arg.Bad "Too many source files specified.")
	else source := s

let _ =
	Arg.parse opts free_arg doc;
	let path, file =
		if !source = ""
		then ("<stdin>", stdin)
		else (!source, open_in !source) in
	let lexbuf = Lexing.from_channel file in
	try
		Asparser.listing Aslexer.scan lexbuf;
		Comp.gen Quad.STOP;
		let out_path =
			if !target <> "" then !target
			else if !source = "" then "a.out"
			else Common.replace_suffix !source ".s" ".exe" in
		Comp.save out_path;
		Printf.fprintf stderr "Saved to %s!\n" out_path
	with
	|	Parsing.Parse_error		-> Common.print_fatal lexbuf path "syntax error"
	|	Common.LexerError msg 	-> Common.print_fatal lexbuf path msg
	|	Common.SyntaxError msg 	-> Common.print_fatal lexbuf path msg
