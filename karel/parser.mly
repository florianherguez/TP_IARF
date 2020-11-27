%{

open Quad
open Common
open Comp
open Karel


%}

%token BEGIN_PROG
%token BEGIN_EXEC
%token END_EXEC
%token END_PROG

%token MOVE
%token TURN_LEFT
%token TURN_OFF

%token SEMI
%token BEGIN
%token END

%token PICK_BEEPER
%token PUT_BEEPER
%token NEXT_TO_A_BEEPER

%token <int> INT

%token FRONT_IS_CLEAR
%token FRONT_IS_BLOCKED
%token LEFT_IS_CLEAR
%token LEFT_IS_BLOCKED
%token RIGHT_IS_CLEAR
%token RIGHT_IS_BLOCKED
%token NOT_NEXT_TO_A_BEEPER
%token FACING_NORTH
%token NOT_FACING_NORTH
%token FACING_EAST
%token NOT_FACING_EAST
%token FACING_SOUTH
%token NOT_FACING_SOUTH
%token FACING_WEST
%token NOT_FACING_WEST
%token ANY_BEEPERS_IN_BEEPER_BAG
%token NO_BEEPERS_IN_BEEPER_BAG

%token ITERATE
%token TIMES
%token WHILE
%token DO
%token IF
%token THEN
%token DEFINE_NEW_INSTRUCTION
%token AS
%token <string> ID
%token ELSE

%type <unit> prog
%start prog

%%

prog:	begin_programm lst_define adresse BEGIN_EXEC stmts_opt END_EXEC END_PROG
		{ backpatch $1 $3 }
;

begin_programm : BEGIN_PROG {	let a = nextquad() in 
		  						let _ = gen (GOTO (0)) in 
		 						a };

stmts_opt:	/* empty */		{ () }
|			stmts			{ () }
;

stmts:		block				{ () }
|			stmts SEMI block 	{ () }
|			stmts SEMI			{ () }
;

stmt:		simple_stmt
			{ () }
|			ITERATE iterate_int TIMES goto_block
			{	let a = snd($2) in
				backpatch a (nextquad());
				let b = fst($2) in
				backpatch $4 b
			}
|			WHILE adresse gen_test DO goto_block 
			{	backpatch $3 (nextquad());
				backpatch $5 $2
			}
|			IF gen_test THEN block 
			{ backpatch $2 (nextquad()) }
|			IF gen_test THEN goto_inside_block ELSE adresse block
			{	backpatch $2 $6;
				backpatch $4 (nextquad()) }
;


define_new: adresse DEFINE_NEW_INSTRUCTION ID AS block { if(is_defined $3) then raise(SyntaxError "ID already exist") else define $3 $1;
												 			gen (RETURN )}
;

lst_define:								{ () }
|			lst_define define_new 		{ () }
|			lst_define define_new SEMI	{ () }
;

block:	BEGIN stmts_opt END { () }
|		stmt 				{ () }
;

inside_block :	BEGIN stmts_opt END 	{ () }
|				inside_stmt				{ () }
;

inside_stmt :	simple_stmt 											{ () }
|				IF gen_test THEN goto_inside_block ELSE adresse inside_block	
				{	backpatch $2 $6;
					backpatch $4 (nextquad()) }
|				WHILE adresse gen_test DO goto_inside_block					
				{	backpatch $3 (nextquad());
				 	backpatch $5 $2
				}
|				ITERATE iterate_int TIMES goto_inside_block			
				{	let a = snd($2) in 
					backpatch a (nextquad());
					let b = fst($2) in
					backpatch $4 b
				}
;


simple_stmt:TURN_LEFT
			{ gen (INVOKE (turn_left, 0, 0)) }
|			TURN_OFF
			{ gen STOP  }
|			MOVE
			{ gen (INVOKE (move, 0, 0)) }
|			PICK_BEEPER 
			{ gen (INVOKE (pick_beeper, 0, 0)) }
|			PUT_BEEPER 
			{ gen (INVOKE (put_beeper, 0, 0)) }
|			ID
			{ if( not (is_defined $1)) then raise(SyntaxError "ID not define") else gen (CALL (get_define $1)) }
;

test:	FRONT_IS_CLEAR
		{ let d = new_temp() in gen (INVOKE (is_clear, 1, d)); d   }
|		FRONT_IS_BLOCKED
		{ let d = new_temp() in gen (INVOKE (is_blocked, 1, d)); d }
|		LEFT_IS_CLEAR
		{ let d = new_temp() in gen (INVOKE (is_clear, 2, d)); d }
|		LEFT_IS_BLOCKED
		{ let d = new_temp() in gen (INVOKE (is_blocked, 2, d)); d }
|		RIGHT_IS_CLEAR
		{ let d = new_temp() in gen (INVOKE (is_clear, 3, d)); d }
|		RIGHT_IS_BLOCKED
		{ let d = new_temp() in gen (INVOKE (is_blocked, 3, d)); d}
|		NOT_NEXT_TO_A_BEEPER
		{ let d = new_temp() in gen (INVOKE (no_next_beeper, d, 0)); d }
|		NEXT_TO_A_BEEPER
		{ let d = new_temp() in gen (INVOKE (next_beeper, d, 0)); d }
|		FACING_NORTH
		{ let d = new_temp() in gen (INVOKE (facing, 1, d)); d }
|		NOT_FACING_NORTH
		{ let d = new_temp() in gen (INVOKE (not_facing, 1, d)); d }
|		FACING_EAST
		{ let d = new_temp() in gen (INVOKE (facing, 2, d)); d }
|		NOT_FACING_EAST
		{ let d = new_temp() in gen (INVOKE (not_facing, 2, d)); d }
|		FACING_SOUTH
		{ let d = new_temp() in gen (INVOKE (facing, 3, d)); d }
|		NOT_FACING_SOUTH
		{ let d = new_temp() in gen (INVOKE (not_facing, 3, d)); d }
|		FACING_WEST
		{ let d = new_temp() in gen (INVOKE (facing, 4, d)); d }
|		NOT_FACING_WEST		
		{ let d = new_temp() in gen (INVOKE (not_facing, 4, d)); d }
|		ANY_BEEPERS_IN_BEEPER_BAG
		{ let d = new_temp() in gen (INVOKE (any_beeper, d, 0)); d }
|		NO_BEEPERS_IN_BEEPER_BAG
		{ let d = new_temp() in gen (INVOKE (no_beeper, d, 0)); d }
;

gen_test : test {	let v' = new_temp() in 
					let _ = gen (SETI (v', 0)) in
					let a = nextquad() in 
					let _ = gen (GOTO_EQ (0, $1, v')) in 
					a
				}
;

goto_block : block
	{	let a = nextquad() in
		let _ = gen( GOTO(0)) in
		a
	}
;

goto_inside_block : inside_block	{	let a = nextquad() in
										let _ = gen( GOTO(0)) in
										a
									}
;


iterate_int : INT 	{	let v = new_temp() in
						let _ = gen (SETI (v, $1)) in

						let v' = new_temp() in
						let _ = gen (SETI (v', 0)) in

						let v'' = new_temp() in
						let _ = gen (SETI (v'', 1)) in

						let a = nextquad() in
						let _ = gen (ADD (v',v',v'')) in 

						let e = nextquad() in
			 			let _ = gen (GOTO_GT (0, v', v)) in 

			 			(a,e)
					}
;
/*
iterate_block : block	{	let d = nextquad() in
						 	let _ = gen (GOTO (0)) in 
						 	d
						}
;

iterate_inside_block : inside_block {	let d = nextquad() in
						 				let _ = gen (GOTO (0)) in 
						 				d
									}
;

first_block : inside_block	{	let a = new_temp() in
								let _ = gen( GOTO (0)) in
								a
							}
;
*/

adresse :	{	let a = nextquad() in
				a
			}
;