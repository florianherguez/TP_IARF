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

%token BEGIN
%token END

%token PICK_BEEPER
%token PUT_BEEPER
%token NEXT_TO_A_BEEPER

%token FRONT_IS_CLEAR
%token FRONT_IS_BLOCKED
%token LEFT_IS_CLEAR
%token LEFT_IS_BLOCKED
%token RIGHT_IS_CLEAR
%token RIGHT_IS_BLOCKED
%token NOT_NEXT_TO_A_BEEPER
%token FACING_EAST
%token NOT_FACING_EAST
%token FACING_SOUTH
%token NOT_FACING_SOUTH
%token FACING_NORTH
%token NOT_FACING_NORTH
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

%token ELSE

%token DEFINE_NEW_INSTRUCTION
%token AS

%token SEMI

%token <string> ID

%token <int> INT

%type <unit> prog
%start prog

%%

prog:	
		begin_programm lst_define adress BEGIN_EXEC stmts_opt END_EXEC END_PROG
							{ 
								backpatch $1 $3 
							}
;

begin_programm: 
		BEGIN_PROG 
							{	
								let a = nextquad() in 
		  						let _ = gen (GOTO (0)) in 
		 						a 
							}
;

stmts_opt:	
		/* empty */			
							{ () }
|		stmts				
							{ () }
;

stmts:		
		block				
							{ () }
|		stmts SEMI block 	
							{ () }
|		stmts SEMI			
							{ () }
;

stmt:		
		simple_stmt			
							{ () }
|		ITERATE iterate_int TIMES block
							{
								let (v1, v2, a) = $2 in gen (SUB (v1, v1, v2));
								gen (GOTO a);
								backpatch a (nextquad ())
							}
|		WHILE adress if_test DO goto_block 
							{
								backpatch $3 (nextquad());
								backpatch $5 $2
							}
|		IF if_test THEN block
							{	
								backpatch $2 (nextquad ())
							}
|		IF if_test THEN closed_block adress_else ELSE block
							{	
								let (a, b) = $5 in backpatch $2 b;
								backpatch a (nextquad ())
							}
;

closed_block:
		simple_stmt
							{ () }
|		IF if_test THEN closed_block adress_else ELSE closed_block
							{
								let (a, b) = $5 in backpatch $2 b;
								backpatch a (nextquad ())
							} 
|		WHILE adress if_test DO closed_block
							{
								gen (GOTO $2);
								backpatch $3 (nextquad ())
							}
;


define_new: 
		adress DEFINE_NEW_INSTRUCTION ID AS block 
							{	if(is_defined $3) then 
									raise(SyntaxError "ID already exist") 
								else 
									define $3 $1;
								gen (RETURN )
							}
;

lst_define:		
		/* empty */			
							{ () }
|		lst_define define_new 		
							{ () }
|		lst_define define_new SEMI	
							{ () }
;

block:	
		BEGIN stmts_opt END 
							{ () }
|		stmt 				
							{ () }
;

simple_stmt:
		TURN_LEFT
							{ 
								gen (INVOKE (turn_left, 0, 0)) 
							}
|		TURN_OFF
							{ 
								gen STOP  
							}
|		MOVE
							{ 
								gen (INVOKE (move, 0, 0)) 
							}
|		PICK_BEEPER 
							{ 
								gen (INVOKE (pick_beeper, 0, 0))
							}
|		PUT_BEEPER 
							{ 
								gen (INVOKE (put_beeper, 0, 0)) 
							}
|		ID
							{ 
								if( not (is_defined $1)) then 
									raise(SyntaxError "ID not define") 
								else 
									gen (CALL (get_define $1)) 
							}
;

test:	
		FRONT_IS_CLEAR
							{ 
								let res = new_temp() in gen (INVOKE (is_clear, front, res)); 
								res
							}
|		FRONT_IS_BLOCKED
							{ 
								let res = new_temp() in gen (INVOKE (is_blocked, front, res));
								res 
							}
|		LEFT_IS_CLEAR
							{ 
								let res = new_temp() in gen (INVOKE (is_clear, left, res));
								res 
							}
|		LEFT_IS_BLOCKED
							{ 
								let res = new_temp() in gen (INVOKE (is_blocked, left, res));
								res }
|		RIGHT_IS_CLEAR
							{ 
								let res = new_temp() in gen (INVOKE (is_clear, right, res)); 
								res 
							}
|		RIGHT_IS_BLOCKED
							{	
								let res = new_temp() in gen (INVOKE (is_blocked, right, res)); 
								res
							}
|		NOT_NEXT_TO_A_BEEPER
							{ 
								let res = new_temp() in gen (INVOKE (no_next_beeper, res, 0));
								res 
							}
|		NEXT_TO_A_BEEPER
							{ 
								let res = new_temp() in gen (INVOKE (next_beeper, res, 0)); 
								res
							}
|		FACING_EAST
							{ 
								let res = new_temp() in gen (INVOKE (facing, east, res));
								res 
							}
|		NOT_FACING_EAST
							{	
								let res = new_temp() in gen (INVOKE (not_facing, east, res));
								res 
							}
|		FACING_SOUTH
							{ 
								let res = new_temp() in gen (INVOKE (facing, south, res));
								res 
							}
|		NOT_FACING_SOUTH
							{ 
								let res = new_temp() in gen (INVOKE (not_facing, south, res)); 
								res 
							}
|		FACING_NORTH
							{ 
								let res = new_temp() in gen (INVOKE (facing, north, res));
								res 
							}
|		NOT_FACING_NORTH
							{ 
								let res = new_temp() in gen (INVOKE (not_facing, north, res)); 
								res 
							}
|		FACING_WEST
							{ 
								let res = new_temp() in gen (INVOKE (facing, west, res)); 
								res
							}
|		NOT_FACING_WEST		
							{ 
								let res = new_temp() in gen (INVOKE (not_facing, west, res)); 
								res
							}
|		ANY_BEEPERS_IN_BEEPER_BAG
							{
								let res = new_temp() in gen (INVOKE (any_beeper, res, 0)); 
								res 
							}
|		NO_BEEPERS_IN_BEEPER_BAG
							{ 
								let res = new_temp() in gen (INVOKE (no_beeper, res, 0));
								res
							}
;

if_test: 
		test 
							{	
								let v = new_temp() in 
								let _ = gen (SETI (v, 0)) in
								let a = nextquad() in 
								let _ = gen (GOTO_EQ (0, $1, v)) in 
								a
							}
;

goto_block: 
		block
						{
							let a = nextquad() in
							let _ = gen( GOTO(0)) in
							a
						}
;


iterate_int: 
		INT 	
					{	
						let v1 = new_temp() in
						let _ = gen (SETI (v1, $1)) in
						
						let v2 = new_temp() in
						let _ = gen (SETI (v2, 1)) in
						
						let a = nextquad () in
						let _ = gen (GOTO_LT (0, v1, v2)) in
						
						(v1, v2, a)
					}
;

adress:	
		/* empty */ 
					{	
						let a = nextquad () in
						a
					}
;

adress_else:
		/* empty */ 
					{
						let a = nextquad () in
						let _ = gen (GOTO 0) in
						(a, nextquad())
					}