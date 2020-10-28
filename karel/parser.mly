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

%type <unit> prog
%start prog

%%

prog:	BEGIN_PROG BEGIN_EXEC stmts_opt END_EXEC END_PROG
			{ () }
;



stmts_opt:	/* empty */		{ () }
|			stmts			{ () }
;

stmts:		block
				{ () }
|			stmts SEMI block
				{ () }
|			stmts SEMI
				{ () }
;

stmt:		simple_stmt
				{ () }
|			ITERATE iterate_test TIMES block
				{ backpatch $2 (nextquad ()) }
|			WHILE while_test DO block
				{ () }
|			IF if_test THEN block
				{ backpatch $2 (nextquad ()) }
;

iterate_test: INT
				{
					print_int $1;
					let d = new_temp() in
					let _ = gen(SETI(d, $1)) in
					let r0 = new_temp() in 
					let _ = gen(SETI(r0, 0)) in
					let r1 = new_temp() in 
					let _ = gen(SETI(r1, 1)) in
					let _ = gen(SUB(d, d, r1)) in
					let a = nextquad() in
					let _ = gen(GOTO_GE(0, d, r0)) in
					a
				}
;

while_test:	test
				{
				
				}
;

if_test:	test
				{
					let v = new_temp() in
					let _ = gen (SETI (v, 0)) in
					let a = nextquad() in
					let _ = gen (GOTO_EQ (0, $1, v)) in
					a	
				}
;


simple_stmt: TURN_LEFT
				{ gen (INVOKE (turn_left, 0, 0)) }
|			TURN_OFF
				{ gen STOP  }
|			MOVE
				{ gen (INVOKE (move, 0, 0)) }
|			PICK_BEEPER
				{ gen (INVOKE (pick_beeper, 0, 0)) }
|			PUT_BEEPER
				{ gen (INVOKE (put_beeper, 0, 0)) }
|			NEXT_TO_A_BEEPER
				{ gen (INVOKE (next_beeper, 0, 0)) }
;

define_new:	DEFINE_NEW_INSTRUCTION ID AS stmts_opt
				{ () }
;

block:		BEGIN stmts_opt END
				{ () }
|			stmt
				{ () }
;

test:		FRONT_IS_CLEAR
				{ let res = new_temp() in gen(INVOKE (is_clear, front, res)); res }
|			FRONT_IS_BLOCKED
				{ let res = new_temp() in gen(INVOKE (is_blocked, front, res)); res }
|			LEFT_IS_CLEAR
				{ let res = new_temp() in gen(INVOKE (is_clear, left, res)); res }
|			LEFT_IS_BLOCKED
				{ let res = new_temp() in gen(INVOKE (is_blocked, left, res)); res }
|			RIGHT_IS_CLEAR
				{ let res = new_temp() in gen(INVOKE (is_clear, right, res)); res }
|			RIGHT_IS_BLOCKED
				{ let res = new_temp() in gen(INVOKE (is_blocked, right, res)); res }

|			NOT_NEXT_TO_A_BEEPER
				{ let res = new_temp() in gen(INVOKE (next_beeper, res, 0)); res }
|			NEXT_TO_A_BEEPER
				{ let res = new_temp() in gen(INVOKE (no_next_beeper, res, 0)); res }

|			FACING_NORTH
				{ let res = new_temp() in gen(INVOKE (facing, north, res)); res }
|			NOT_FACING_NORTH
				{ let res = new_temp() in gen(INVOKE (not_facing, north, res)); res }
|			FACING_EAST
				{ let res = new_temp() in gen(INVOKE (facing, east, res)); res }
|			NOT_FACING_EAST
				{ let res = new_temp() in gen(INVOKE (not_facing, east, res)); res }
|			FACING_SOUTH
				{ let res = new_temp() in gen(INVOKE (facing, south, res)); res }
|			NOT_FACING_SOUTH
				{ let res = new_temp() in gen(INVOKE (not_facing, south, res)); res }
|			FACING_WEST
				{ let res = new_temp() in gen(INVOKE (facing, west, res)); res }
|			NOT_FACING_WEST
				{ let res = new_temp() in gen(INVOKE (not_facing, west, res)); res }

|			ANY_BEEPERS_IN_BEEPER_BAG
				{ let res = new_temp() in gen(INVOKE (any_beeper, res, 0)); res }
|			NO_BEEPERS_IN_BEEPER_BAG
				{ let res = new_temp() in gen(INVOKE (no_beeper, res, 0)); res }
;