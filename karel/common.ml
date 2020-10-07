exception LexerError of string
exception SyntaxError of string

let number path offset =
	let file = open_in path in
	let rec next n sum =
		let size = String.length (input_line file) + 1 in
		if sum + size > offset then (n, offset - sum + 1)
		else next (n + 1) (sum + size) in
	next 1 0

let print_error lexbuf prog msg =
	let (line, col) = number prog (Lexing.lexeme_start lexbuf) in
	Printf.printf "ERROR:%d:%d: %s\n" line col msg

(** Print a fatal error for a lexer and stop the program.
	@param lexbuf	Current lexer.
	@param prog		Current program.
	@param msg		Message to display. *)
let print_fatal lexbuf prog msg =
	print_error lexbuf prog msg;
	exit 1

(** Hash module for strings. *)
module StringHash = struct
	type t = string
	let equal s1 s2 = s1 = s2
	let hash s = Hashtbl.hash s
end

(** Hash table using strings as keys *)
module StringHashtbl = Hashtbl.Make(StringHash)


(** Si c'est possible, remplace l'ancien suffixe par le nouveau suffixe
	dans le chemin donné. Si l'ancien suffixe n'est pas en fin de chemin,
	ajoute simplement le nouveau suffixe.
	@param path		Chemin où s'effectue le remplacement.
	@param os		Ancien suffixe.
	@param ns		Nouveau suffixe. *)
let replace_suffix path os ns =
	let ps = String.length path in
	let oss = String.length os in
	if ps < oss || (String.sub path (ps - oss) oss) = os
	then (String.sub path 0 (ps - oss)) ^ ns
	else path ^ ns

