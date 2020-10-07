(* Execution of a VM program *)

exception Exit

open Common
open Vector
open Printf

(* configuration *)
let x_space = 32
let y_space = 32
let karel_width = 20
let karel_height = 20
let grid_color = Graphics.cyan
let back_color = Graphics.white
let text_color = Graphics.black
let wall_color = Graphics.black
let karel_color = Graphics.black
let karel_back = Graphics.white

(* beeper definition *)
let beeper_width = 16
let beeper_height = 16
let beeper_drawing = [
		COLOR Graphics.red;
		CIRCLE (beeper_width / 2);
		FILL_CIRCLE (beeper_width * 2 / 6)
	]


(* option processing *)
let just_compile = ref false
let time = ref 500
let itime = ref 0
let debug = ref false

let opts = [
	("-t", Arg.Set_int time, "time in ms between moves of the robot (default 500)");
	("-i", Arg.Set_int itime, "time in ms between two instructions (not used by default)");
	("-d", Arg.Set debug, "dump to stderr the executed quads")
]
let  doc = "Karel Game Emulator"

type mode =
	| STOPPED
	| RUNNING
	| PAUSED
	| STEPPING


(**** application ***)
let run prog world =
	let speed t = (float_of_int t) /. 1000. in
	let run_speed = speed !time in
	let step_speed = if !itime <> 0 then speed !itime else run_speed in

	let make_state _ = 
		let kstate = Karel.init_state world in
		((if !itime = 0 then RUNNING else STEPPING), Vm.new_state Karel.invoke kstate) in
	let reset_state w =
		Ui.set_app w (make_state ()) in
		
	let get_vm   w   = let (_, v) = Ui.get_app w in v in
	let set_vm   w v = let (m, _) = Ui.get_app w in Ui.set_app w (m, v) in
	let get_mode w   = let (m, _) = Ui.get_app w in m in
	let set_mode w m = let (_, v) = Ui.get_app w in Ui.set_app w (m, v) in
	let get_kstate w = Vm.get_istate (get_vm w) in

	let centerx x ox = ox + x * x_space + x_space / 2 in
	let centery y oy = oy - y * y_space - y_space / 2 in
	let make_info x y b = Printf.sprintf "x:%2d  y:%2d  bag:%2d" (x + 1) (y + 1) b in

	let draw_karel window state ox oy =
		let ((x, y, dir, _), _) = state in
		let xc, yc = centerx x ox, centery y oy in
		let xl = xc - karel_width / 2 in
		let xr = xc + karel_width / 2 in
		let yt = yc + karel_height / 2 in
		let yb = yc - karel_height / 2 in
		Graphics.set_color karel_back;
		Graphics.fill_rect xl yb karel_width karel_height;
		Graphics.set_color karel_color;
		Graphics.draw_poly [| (xl, yt); (xr, yt); (xr, yb); (xl, yb) |];
		let pts = (List.nth
					[
						(fun _ -> [| (xl, yb); (xc, yt); (xr, yb) |]);
						(fun _ -> [| (xl, yb); (xr, yc); (xl, yt) |]);
						(fun _ -> [| (xl, yt); (xc, yb); (xr, yt) |]);
						(fun _ -> [| (xr, yb); (xl, yc); (xr, yt) |])
					]
					(dir - 1)) () in
		Graphics.fill_poly pts in

	let clear_karel window (state: Karel.karel) ox oy =
		let ((x, y, _, _), (_, map)) = state in
		let xc, yc = centerx x ox, centery y oy in
		let xl = xc - karel_width / 2 in
		let xr = xc + karel_width / 2 in
		let yt = yc + karel_height / 2 in
		let yb = yc - karel_height / 2 in
		Graphics.set_color back_color;
		Graphics.fill_rect xl yb karel_width karel_height;
		Graphics.set_color grid_color;
		Graphics.moveto xl yc;
		Graphics.lineto xr yc;
		Graphics.moveto xc yt;
		Graphics.lineto xc yb;
		if (Karel.map_beeper map x y) > 0
		then draw xc yc beeper_drawing in

	(*let fst = ref true in*)
	let draw_grid window kstate widget =
		let (x, y, w, h) = Ui.widget_get_box window (Ui.widget_name widget) in
		let (_, (_, (ww, wh, _))) = kstate in
		let draw = Graphics.draw_poly_line in
		let y = y + h - 1 in
		
		(* clear the back *)
		Graphics.set_color back_color;
		Graphics.set_color back_color;
		Graphics.fill_rect x (y - h) w h;
		Graphics.set_color Graphics.black;
		
		(* display grid *)
		Graphics.set_color grid_color;
		for i = 0 to ww - 1 do
			draw [|
				(x + i * x_space + x_space / 2, y);
				(x + i * x_space + x_space / 2, y - wh * y_space)
			|]
		done;
		for i = 0 to wh - 1 do
			draw [|
				(x, y - i * y_space - y_space / 2);
				(x + ww * x_space, y - i * y_space - y_space / 2)
			|]
		done;
		
		(* draw walls *)		
		let draw_cell xc yc (w, b) =
			let xl = x + xc * x_space in
			let xr = xl + x_space - 1 in
			let yt = y - yc * y_space + 1 in
			let yb = yt - y_space + 1 in
			let draw = Graphics.draw_poly_line in
			Graphics.set_color wall_color;
			if Karel.has_wall Karel.north w then
				draw [| (xl, yt); (xr, yt) |];
			if Karel.has_wall Karel.east w then
				draw [| (xr, yt); (xr, yb) |];
			if Karel.has_wall Karel.south w then
				draw [| (xl, yb); (xr, yb) |];
			if Karel.has_wall Karel.west w then
				draw [| (xl, yt); (xl, yb) |];
			if b > 0 then
				Vector.draw (centerx xc x) (centery yc y) beeper_drawing in
				
		let (_, world) = kstate in
		Karel.iter_map world draw_cell;
		
		(* draw karel *)
		draw_karel window kstate x y in

	let handle_x window event =
		Ui.window_quit window in
	
	let update_info window =
		let (k, w) = get_kstate window in
		let (x, y, _d, bs) = k in
		Ui.label_set_text window "info" (make_info x y bs) in
	
	let rec exec_quad window =
		try
			let pc = Vm.get_pc (get_vm window) in
			let disasm = Printf.sprintf "%04d %s" pc (Quad.to_string prog.(pc)) in
			let window = Ui.console_add window "console" disasm in
			if !debug then Printf.fprintf stderr "%s\n" disasm;
			let window = set_vm window (Vm.step (get_vm window) prog) in
			if Vm.ended (get_vm window)
			then
				let window = Ui.statusbar_display_untimed (Ui.widget_config window "status" [Ui.TEXT_COLOR Ui.blue]) "status" "Stopped!" in
				set_mode window STOPPED
			else
				match prog.(Vm.get_pc (get_vm window)) with
				| Quad.INVOKE _ -> update_info window
				| _ -> window
		with
		| Karel.Error m ->
			let window = Ui.statusbar_display_untimed (Ui.widget_config window "status" [Ui.TEXT_COLOR Ui.red]) "status" m in
			set_mode (set_vm window (Vm.stop (get_vm window))) STOPPED
		| Vm.Error (_, m) ->
			let window = Ui.statusbar_display_untimed (Ui.widget_config window "status" [Ui.TEXT_COLOR Ui.red]) "status" ("VM Error: " ^ m) in
			set_mode (set_vm window (Vm.stop (get_vm window))) STOPPED in
	
	let rec exec_to_move window =
		let window = exec_quad window in
		if (get_mode window) = STOPPED then window else
		if (get_mode window) = STEPPING then window else
		if !itime <> 0 then window
		else
			match prog.(Vm.get_pc (get_vm window)) with
			| Quad.INVOKE (d, _, _) when d = Karel.move || d = Karel.turn_left
				-> window
			| _	
				-> exec_to_move window in

	let clear_robot window = 
		let (x, y, w, h) = Ui.widget_get_box window "world" in
		clear_karel window (Vm.get_istate (get_vm window)) x (y + h - 1) in
	
	let draw_robot window =
		let (x, y, w, h) = Ui.widget_get_box window "world" in
		draw_karel window (Vm.get_istate (get_vm window)) x (y + h -1) in

	let rec wind_robot_on window =
		match get_mode window with
		| STOPPED
		| PAUSED ->
			window
		| RUNNING ->
			Ui.window_handle_timeout window run_speed handle_time
		| STEPPING ->
			Ui.window_handle_timeout window step_speed handle_time

	and handle_time window =
		match get_mode window with
		| STOPPED ->
			window
		| PAUSED ->
			window
		| RUNNING ->
			clear_robot window;
			let window = exec_to_move window in
			draw_robot window;
			wind_robot_on window
		| STEPPING ->
			clear_robot window;
			let window = exec_to_move window in
			draw_robot window;
			wind_robot_on window in

	let handle_p window event =
		match get_mode window with
		| STOPPED ->
			window
		| PAUSED ->
			let window = Ui.statusbar_display (Ui.widget_config window "status" [Ui.TEXT_COLOR Ui.blue]) "status" "Started!" in
			wind_robot_on (set_mode window RUNNING)
		| RUNNING
		| STEPPING ->
			let window = Ui.statusbar_display_untimed (Ui.widget_config window "status" [Ui.TEXT_COLOR Ui.blue]) "status" "Paused!" in
			set_mode window PAUSED in

	let handle_s window event =
		match get_mode window with
		| STOPPED ->
			window
		| PAUSED
		| RUNNING ->
			let window = Ui.statusbar_display (Ui.widget_config window "status" [Ui.TEXT_COLOR Ui.blue]) "status" "Step by step enabled." in
			set_mode window STEPPING
		| STEPPING ->
			let window = Ui.statusbar_display (Ui.widget_config window "status" [Ui.TEXT_COLOR Ui.blue]) "status" "Running..." in
			set_mode window RUNNING in

	let handle_r window event =
		let window = Ui.statusbar_display (Ui.widget_config window "status" [Ui.TEXT_COLOR Ui.red]) "status" "Reset!" in
		let mode = get_mode window in
		let window = reset_state window in
		Ui.widget_draw window "world";
		let window = update_info window in
		match mode with
		| STOPPED
		| PAUSED ->
			wind_robot_on window
		| RUNNING
		| STEPPING ->
			window in

	let grid (widget: 'a Ui.widget) window msg =
		let kstate = Vm.get_istate (get_vm window) in
		let size _ =
			let (_, (_, (w, h, _))) = kstate in
			(x_space * w, y_space * h) in
		match msg with
		| Ui.DRAW ->
			draw_grid window kstate widget; (Ui.NOTHING, window)
		| Ui.GET_SIZE ->
			let (w, h) = size () in
			(Ui.SIZE (w, h), window)
		| Ui.GET_BOUNDS ->
			let (w, h) = size () in
			(Ui.BOUNDS (w, h, w, h), window)
		| _
			-> Ui.default_inst widget window msg in
	
	let window 	= Ui.window_make "Karel 1.0" (make_state ()) in

	let window 	= Ui.widget_make window "world" grid in
	let window  = Ui.statusbar_make window "status" "Welcome to karel!" in
	let window  = Ui.label_make window "info" (make_info 99 99 99) in
	let window  = Ui.console_make window "console" "XXXX XXXXXXXXXXXXXXXXXXXXX" in
	let window  = Ui.hbox_make window "bottom" ["status"; "info"] in
	let window  = Ui.hbox_make window "main" ["world"; "console"] in
	let window	= Ui.vbox_make window "all" ["main"; "bottom"] in	
	
	let window	= Ui.window_set_top window "all" in
	let window 	= Ui.window_handle_event window "" (Ui.KEY 'x') handle_x in
	let window 	= Ui.window_handle_event window "" (Ui.KEY 'q') handle_x in
	let window 	= Ui.window_handle_event window "" (Ui.KEY 'p') handle_p in
	let window 	= Ui.window_handle_event window "" (Ui.KEY ' ') handle_p in
	let window 	= Ui.window_handle_event window "" (Ui.KEY 's') handle_s in
	let window 	= Ui.window_handle_event window "" (Ui.KEY 'r') handle_r in
	let window 	= wind_robot_on window in
	Ui.window_run window


let process prog (world: Karel.world) =
	print_string ("Keys:\n"
		^ "\tx, q: quit\n"
		^ "\tp, space: enter/exit pause mode\n"
		^ "\ts: enter/exit step mode\n"
		^ "\tr: reset the program\n");
		flush stdout;
		ignore (run prog world)


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

let _ = 
	let free_args = ref [] in
	Arg.parse opts (fun arg -> free_args := arg :: !free_args) doc;
	scan !free_args


