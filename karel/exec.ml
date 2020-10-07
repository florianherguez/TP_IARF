(* Execution of a VM program *)

exception Exit

open Common
open Printf



(* option processing *)
let dis = ref false

let opts = [
	("-d", Arg.Set dis, "disassemble instructions")
]
let  doc = "Karel console execution"


(** Exécute le programme donné.
	@param prog		Programme.
	@param world	Monde où se fera l'exécution.. *)
let process prog (world: Karel.world) =

	let rec run state =
		if Vm.ended state then state else
		let pc = Vm.get_pc state in
		(if !dis then
			Printf.printf "\t%04d %s\n" pc (Quad.to_string prog.(pc)));
		let need_dump =
			match prog.(Vm.get_pc state) with
			| Quad.INVOKE _ -> true
			| _				-> false in
		let statep = Vm.step state prog in
		(if need_dump then
			let ((x, y, d, b), w) = Vm.get_istate statep in
			printf "(%d, %d) %s [%d]\n" x y (Karel.string_of_dir d) b);
		run statep in

	try
		let kstate = Karel.init_state world in
		let state = Vm.new_state Karel.invoke kstate in
		ignore (run state)
	with
	| Karel.Error m ->
		fprintf stderr "ERROR: Karel: %s\n" m
	| Vm.Error (_, m) ->
		fprintf stderr "ERROR: VM: %s\n" m
	

(** Analyse les arguments, charge le programme et le mondet et lance
	l'exécution.
	@param args		Liste des paramètres libres. *)
let scan args =

	let load_prog prog =
		try
			Comp.load prog
		with Comp.LoadError ->
			Printf.fprintf stderr "ERROR: %s does not seem to be quad binary!\n" prog;
			exit 1 in
		
	let load_world path =
		let file = open_in path in
		let lexbuf = Lexing.from_channel file in
		try
			Wparser.top Wlexer.scan lexbuf;
			!Karel.world
		with
		|	Parsing.Parse_error		-> print_fatal lexbuf path "syntax error in world file"
		|	Common.LexerError msg 	-> print_fatal lexbuf path msg in
	
	match args with
	| [ prog ]			-> process (load_prog prog) Karel.empty_world
	| [ world; prog]	-> process (load_prog prog) (load_world world)
	| _					-> Arg.usage opts "ERROR: syntax: game program [map]"


(* Démarrage. *)
let _ = 
	let free_args = ref [] in
	Arg.parse opts (fun arg -> free_args := arg :: !free_args) doc;
	scan !free_args


