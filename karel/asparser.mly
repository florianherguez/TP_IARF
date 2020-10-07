%{

open Quad
open Common
open Comp
open Karel

let labels: int StringHashtbl.t = StringHashtbl.create 253

let backpatches: (string * int) list ref = ref []

let resolve_label label = 
	try
		StringHashtbl.find labels label
	with Not_found ->
		(backpatches := (label, Comp.nextquad ()) :: !backpatches; 0)

let resolve_backpatches _ =
	let rec resolve patches =
		match patches with
		| [] -> ()
		| (l, a)::t -> 
			try
				Comp.backpatch a (StringHashtbl.find labels l);
				resolve t
			with Not_found ->
				Printf.fprintf stderr "ERROR: cannot resolve %s" l;
				raise Exit in
	resolve !backpatches

%}

%token ADD
%token SUB
%token MUL
%token DIV
%token NAND
%token NOR
%token SET
%token SETI
%token GOTO
%token GOTO_EQ
%token GOTO_NE
%token GOTO_LT
%token GOTO_LE
%token GOTO_GT
%token GOTO_GE
%token CALL
%token RETURN
%token INVOKE
%token STOP

%token <int> 	REG
%token <int> 	INT
%token <string>	LABEL

%token COMMA
%token SHARP
%token COLON
%token EOF

%type <unit> listing
%start listing

%%

listing: commands EOF
	{ resolve_backpatches () }
;

commands:
	command
		{ () }
|	command commands
		{ () }
;

command:
	LABEL COLON
		{
			if StringHashtbl.mem labels $1
			then raise (SyntaxError (Printf.sprintf "label %s already used!" $1))
			else StringHashtbl.add labels $1 (Comp.nextquad ())
		}
|	STOP
		{ Comp.gen Quad.STOP }
|	ADD REG COMMA REG COMMA REG
		{ Comp.gen (Quad.ADD ($2, $4, $6)) }
|	SUB REG COMMA REG COMMA REG
		{ Comp.gen (Quad.SUB ($2, $4, $6)) }
|	MUL REG COMMA REG COMMA REG
		{ Comp.gen (Quad.MUL ($2, $4, $6)) }
|	DIV REG COMMA REG COMMA REG
		{ Comp.gen (Quad.DIV ($2, $4, $6)) }
|	NAND REG COMMA REG COMMA REG
		{ Comp.gen (Quad.NAND ($2, $4, $6)) }
|	NOR REG COMMA REG COMMA REG
		{ Comp.gen (Quad.NOR ($2, $4, $6)) }
|	SET REG COMMA REG
		{ Comp.gen (Quad.SET ($2, $4)) }
|	SETI REG COMMA SHARP INT
		{ Comp.gen (Quad.SETI ($2, $5)) }
|	GOTO LABEL
		{ Comp.gen (Quad.GOTO (resolve_label $2)) }
|	GOTO_EQ LABEL COMMA REG COMMA REG
		{ Comp.gen (Quad.GOTO_EQ (resolve_label $2, $4, $6)) }
|	GOTO_NE LABEL COMMA REG COMMA REG
		{ Comp.gen (Quad.GOTO_NE (resolve_label $2, $4, $6)) }
|	GOTO_GT LABEL COMMA REG COMMA REG
		{ Comp.gen (Quad.GOTO_GT (resolve_label $2, $4, $6)) }
|	GOTO_GE LABEL COMMA REG COMMA REG
		{ Comp.gen (Quad.GOTO_GE (resolve_label $2, $4, $6)) }
|	GOTO_LT LABEL COMMA REG COMMA REG
		{ Comp.gen (Quad.GOTO_LT (resolve_label $2, $4, $6)) }
|	GOTO_LE LABEL COMMA REG COMMA REG
		{ Comp.gen (Quad.GOTO_LE (resolve_label $2, $4, $6)) }
|	CALL LABEL
		{ Comp.gen (Quad.CALL (resolve_label $2)) }
|	RETURN
		{ Comp.gen Quad.RETURN }
|	INVOKE INT COMMA INT COMMA INT
		{ Comp.gen (Quad.INVOKE ($2, $4, $6)) }
;

%%

