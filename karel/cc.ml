(* Command to compile a .karel file. *)
open Common

let just_compile = ref false

let opts = [
	("-c", Arg.Set just_compile, "Stop after compilation and print quadruplets.")
]

let  doc = "Karel Game Emulator"


(** Affiche une ligne de quadruplet.
	@param a	Adresse du quadruplet.
	@param q	Quadruplet à afficher. *)
let output_quad out a q =
	Printf.fprintf out "L%d:\n" a;
	Printf.fprintf out "\t%s\n"
		(match q with
		| Quad.GOTO d 			-> Printf.sprintf "goto L%d" d
		| Quad.GOTO_EQ (d, a, b) -> Printf.sprintf "goto_eq L%d, r%d, r%d" d a b
		| Quad.GOTO_NE (d, a, b) -> Printf.sprintf "goto_ne L%d, r%d, r%d" d a b
		| Quad.GOTO_LT (d, a, b) -> Printf.sprintf "goto_lt L%d, r%d, r%d" d a b
		| Quad.GOTO_LE (d, a, b) -> Printf.sprintf "goto_le L%d, r%d, r%d" d a b
		| Quad.GOTO_GT (d, a, b) -> Printf.sprintf "goto_gt L%d, r%d, r%d" d a b
		| Quad.GOTO_GE (d, a, b) -> Printf.sprintf "goto_ge L%d, r%d, r%d" d a b
		| Quad.CALL d			-> Printf.sprintf "call L%d" d
		| _					-> Quad.to_string q
		)


(** Compile le fichier Karel correspondant au chemin donné.
	@param path		Chemin du fichier à compiler. *)
let compile path =
		let file = open_in path in
		let lexbuf = Lexing.from_channel file in
		try
		
			(* parse the program *)
			Parser.prog Lexer.scan lexbuf;
			
			(* write the program to assembly file *)
			if !just_compile then begin
				Comp.iter (fun i -> fun  q -> Printf.printf "%04d: %s\n" i (Quad.to_string q))
			end
			else
				let out = open_out (Common.replace_suffix path ".karel" ".s") in
				Comp.iter (output_quad out);
				Printf.fprintf out "L%d:\n" !Comp.cnt;
				close_out out

		with
		|	Parsing.Parse_error	-> print_fatal lexbuf path "syntax error"
		|	LexerError msg 		-> print_fatal lexbuf path msg
		|	SyntaxError msg 	-> print_fatal lexbuf path msg

let _ =
	Arg.parse opts compile doc

