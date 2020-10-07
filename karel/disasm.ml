(* Programme pour désabler un exécutable en quadruplets. *)

let doc = "Karel v2 disassembler"
let opts = []

let free_arg path =
	begin
		ignore (Comp.load path);
		Comp.iter (fun i -> fun q ->
			Printf.printf "%04d: %s\n" i (Quad.to_string q))
	end

let _ = 
	Arg.parse opts free_arg doc
