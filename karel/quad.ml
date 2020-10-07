type quad =
		| ADD of int * int * int
		| SUB of int * int * int
		| MUL of int * int * int
		| DIV of int * int * int
		| NAND of int * int * int
		| NOR of int * int * int
		| SET of int * int
		| SETI of int * int
		| GOTO of int
		| GOTO_EQ of int * int * int
		| GOTO_NE of int * int * int
		| GOTO_LT of int * int * int
		| GOTO_LE of int * int * int
		| GOTO_GT of int * int * int
		| GOTO_GE of int * int * int
		| CALL of int
		| RETURN
		| INVOKE of int * int * int
		| STOP


(** Convertit un quadruplet en chaîne de caractère.
	@param q	Quadruplet à convertir.
	@return		Chaîne de caractère. *)
let to_string q =
	match q with
	| ADD (d, a, b) 	-> Printf.sprintf "add r%d, r%d, r%d" d a b
	| SUB (d, a, b) 	-> Printf.sprintf "sub r%d, r%d, r%d" d a b
	| MUL (d, a, b) 	-> Printf.sprintf "mul r%d, r%d, r%d" d a b
	| DIV (d, a, b) 	-> Printf.sprintf "div r%d, r%d, r%d" d a b
	| NAND (d, a, b)	-> Printf.sprintf "nand r%d, r%d, r%d" d a b
	| NOR (d, a, b)		-> Printf.sprintf "nor r%d, r%d, r%d" d a b
	| SET (d, a)		-> Printf.sprintf "set r%d, r%d" d a
	| SETI (d, a) 		-> Printf.sprintf "seti r%d, #%d" d a
	| GOTO d 			-> Printf.sprintf "goto %d" d
	| GOTO_EQ (d, a, b) -> Printf.sprintf "goto_eq %d, r%d, r%d" d a b
	| GOTO_NE (d, a, b) -> Printf.sprintf "goto_ne %d, r%d, r%d" d a b
	| GOTO_LT (d, a, b) -> Printf.sprintf "goto_lt %d, r%d, r%d" d a b
	| GOTO_LE (d, a, b) -> Printf.sprintf "goto_le %d, r%d, r%d" d a b
	| GOTO_GT (d, a, b) -> Printf.sprintf "goto_gt %d, r%d, r%d" d a b
	| GOTO_GE (d, a, b) -> Printf.sprintf "goto_ge %d, r%d, r%d" d a b
	| CALL d			-> Printf.sprintf "call %d" d
	| RETURN			-> Printf.sprintf "return"
	| INVOKE (d, a, b)	-> Printf.sprintf "invoke %d, %d, %d" d a b
	| STOP				-> Printf.sprintf "stop"


(** Affiche un quadruplet sur la sortie standard.
	@param q	Quadruplet à afficher. *)
let print q =
	print_string (to_string q)

let print_prog prog =

	let rec process n =
		if n >= (Array.length prog) then
			()
		else
			begin
				Printf.printf "%4d\t" n;
				print prog.(n);
				print_string "\n";
				process (n + 1)
			end in

	process 0
