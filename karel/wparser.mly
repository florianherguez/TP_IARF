%{

open Karel

%}

%token WORLD
%token BEEPERS
%token ROBOT
%token WALL
%token EOF
%token <int> INT

%type <unit> top
%start top

%%

top:	cmds EOF				{ world := $1 }

cmds:	cmds cmd				{ $2 $1 }
|		WORLD INT INT			{ ((0, 0, north, 0), map_init $2 $3) }
;

cmd:	BEEPERS INT INT INT
			{ fun (r, m) -> (r, set_beepers m ($2 - 1) ($3 - 1) $4) }
|		ROBOT INT INT INT INT
			{ fun (_, m) -> (($2 - 1, $3 - 1, $4, $5), m) }
|		WALL INT INT INT
			{ fun (r, m) -> (r, set_wall m ($2 - 1) ($3 - 1) $4) }
;
