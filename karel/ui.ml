(** Module implantant la partie graphique de Karel. *)

(* References
	http://caml.inria.fr/pub/docs/oreilly-book/pdf/chap5.pdf
*)

open Printf

(***** Useful constants ******)

let black = Graphics.black
let white = Graphics.white
let red = Graphics.red
let green = Graphics.green
let blue = Graphics.blue
let yellow = Graphics.yellow
let cyan = Graphics.cyan
let magenta = Graphics.magenta

(** Build a color from the RGB components.
	@param r	Red component (in 0..255).
	@param g	Green component (in 0..255).
	@param b	Blue component (in 0..255).
	@return		Built color. *)
let color r g b = Graphics.rgb r g b


(**** widget definition ****)

module OrderedString = struct
	type t = string
	let compare = compare
end
module StringMap = Map.Make(OrderedString)

let window_pad_x = 5
let window_pad_y = 5

type event =
	|	KEY of char
	|	PRESS of int * int
	|	RELEASE of int * int

type box = int * int * int * int	(* x, y, w, h *)

type value =
	|	NOTHING
	| 	WIDGET of string					(* widget name *)
	|	SIZE of int * int					(* (width, height) *)
	|	BOUNDS of int * int * int * int		(* min width, min height, max width, max height *)
	|	INT of int
	|	FLOAT of float
	|	STRING of string
	|	COLOR of Graphics.color

type widget_method =
	| DRAW							(* no result *)
	| MOVE of int * int				(* x, y *)
	| AT of int * int				(* x, y; widget name *)
	| GET_SIZE						(* ; size *)
	| GET_BOUNDS					(* ; bounds *)
	| SET_BOX of box				(* box ; *)
	| CUSTOM of string * value list	(* custom method *)

(** Configuration of widgets. *)
type config =
	| PAD_LEFT of int
	| PAD_RIGHT of int
	| PAD_TOP of int
	| PAD_BOTTOM of int
	| BACK_COLOR of Graphics.color
	| TEXT_COLOR of Graphics.color
	| CONF of string * value

(** Default configuration. *)
let default_config = [
	PAD_LEFT 4;
	PAD_RIGHT 4;
	PAD_TOP 4;
	PAD_BOTTOM 4;
	BACK_COLOR Graphics.white;
	TEXT_COLOR Graphics.black
]


type 'a widget = string * box * 'a widget_inst * config list
and	 'a widget_inst = METHOD of ('a widget -> 'a window -> widget_method -> (value * 'a window))
and	 'a event_handler = EVENT_HANDLER of ('a window -> event -> 'a window)
and	 'a time_handler = TIME_HANDLER of ('a window -> 'a window)
and  window_state = string * string * bool * Graphics.status	(* title, top, ended, event *)
and  window_look  = int * int * Graphics.color * Graphics.color	(* width, height, color, back *)
and  'a window_handlers =
		((string * event) * 'a event_handler) list
	  * (float * 'a time_handler) list
and	 'a window = window_state
			   * 'a window_handlers
			   * 'a widget StringMap.t
			   * window_look
			   * 'a
		(* title, top widget, ended, last event, event handlers, timer list, widget map, application state *)


(** Find a configuration item.
	@param f			Function to check configuration.
	@param confs		Configuration.
	@return				Found configuration.
	@raise	Not_found	If configuration is not found. *)
let rec config_of f confs =
	match confs with
	| [] -> raise Not_found
	| h::t ->
		match f h with
		| None -> config_of f t
		| Some x -> x

(* configuration fast accessores *)
let pad_left = config_of (fun c -> match c with PAD_LEFT x -> Some x | _ -> None) 
let pad_right = config_of (fun c -> match c with PAD_RIGHT x -> Some x | _ -> None) 
let pad_top = config_of (fun c -> match c with PAD_TOP x -> Some x | _ -> None) 
let pad_bottom = config_of (fun c -> match c with PAD_BOTTOM x -> Some x | _ -> None) 
let back_color = config_of (fun c -> match c with BACK_COLOR x -> Some x | _ -> None)
let text_color = config_of (fun c -> match c with TEXT_COLOR x -> Some x | _ -> None)
let int_conf s = config_of (fun c -> match c with CONF(n, INT x) when s = n -> Some x | _ -> None)
let float_conf s = config_of (fun c -> match c with CONF(n, FLOAT x) when s = n -> Some x | _ -> None)


(* window accessors *)
let get_title	(((x, _, _, _), _, _, _, _): 'a window) = x
let get_top 	(((_, x, _, _), _, _, _, _): 'a window) = x
let get_ended 	(((_, _, x, _), _, _, _, _): 'a window) = x
let get_prev	(((_, _, _, x), _, _, _, _): 'a window) = x
let get_evts	((_, (x, _), _, _, _): 'a window) = x
let get_times	((_, (_, x), _, _, _): 'a window) = x
let get_map		((_, _, x, _, _): 'a window) = x
let get_width	((_, _, _, (x, _, _, _), _): 'a window) = x
let get_height	((_, _, _, (_, x, _, _), _): 'a window) = x
let get_color	((_, _, _, (_, _, x, _), _): 'a window) = x
let get_back	((_, _, _, (_, _, _, x), _): 'a window) = x
let get_app		((_, _, _, _, x): 'a window) = x

(* window constructor *)
let set_title	(((_    , top, ended, prev), handlers, map, look, app): 'a window) x =
				 ((x    , top, ended, prev), handlers, map, look, app)
let set_top		(((title, _  , ended, prev), handlers, map, look, app): 'a window) x =
				 ((title, x  , ended, prev), handlers, map, look, app)
let set_ended	(((title, top, _    , prev), handlers, map, look, app): 'a window) x =
				 ((title, top, x    , prev), handlers, map, look, app)
let set_prev	(((title, top, ended, _   ), handlers, map, look, app): 'a window) x =
				 ((title, top, ended, x   ), handlers, map, look, app)
let set_evts	((state, (_   , times), map, look, app): 'a window) x =
				 (state, (x   , times), map, look, app)
let set_times	((state, (evts, _    ), map, look, app): 'a window) x =
				 (state, (evts, x    ), map, look, app)
let set_map		((state, handlers, _, look, app): 'a window) x =
				 (state, handlers, x, look, app)
let set_width	((state, handlers, map, (_    , height, color, back), app): 'a window) x =
				 (state, handlers, map, (x    , height, color, back), app)
let set_height	((state, handlers, map, (width, _     , color, back), app): 'a window) x =
				 (state, handlers, map, (width, x     , color, back), app)
let set_color	((state, handlers, map, (width, height, _    , back), app): 'a window) x =
				 (state, handlers, map, (width, height, x    , back), app)
let set_back	((state, handlers, map, (width, height, color, _   ), app): 'a window) x =
				 (state, handlers, map, (width, height, color, x   ), app)
let set_app		((state, handlers, map, look, _): 'a window) x =
				 (state, handlers, map, look, x)

let debug_line = ref 0
let debug window msg =
	let (_, h) = Graphics.text_size msg in
	Graphics.set_color (get_color window);
	Graphics.moveto 10 !debug_line;
	Graphics.draw_string msg;
	debug_line := !debug_line - h - 2;
	if !debug_line < 0 then debug_line := (get_height window) - 20;
	Graphics.set_color (get_back window);
	Graphics.fill_rect 10 !debug_line 200 h (*;
	Printf.printf "%s\n" msg *)

let debug_event window event = 
	(*debug window (Printf.sprintf "event: %d,%d %B %B %c (%d)"
		event.Graphics.mouse_x
		event.Graphics.mouse_y
		event.Graphics.button
		event.Graphics.keypressed
		event.Graphics.key
		(Char.code event.Graphics.key))*)
	()


(** Get a widget by its name.
	@param window		Window.
	@param name			Name of looked widget.
	@return				Found widget.
	@raise Not_found	No widget matches the name. *)
let window_get (window: 'a window) (name: string) =
	StringMap.find name (get_map window)


(** Get the surrounding box of a widget.
	@param name		Name of widget to get box from.
	@return			Widget box. *)
let widget_get_box (window: 'a window) (name: string) =
	let (_, box, _, _) = window_get window name in
	box


(** Update the state of a widget.
	@param window	Owner window.
	@param name		Name of widget to update.
	@param inst		New instance.
	@return			New window. *)
let widget_update (window: 'a window) (widget: 'a widget) inst =
	let (name, box, _, conf) = widget in
	set_map window (StringMap.add name (name, box, METHOD inst, conf) (get_map window))


(** Add the given configuration to the one of the widget.
	@param window	Owner window.
	@param name		Widget name.
	@param conf		Configuration.
	@return			Updated window. *)
let widget_config (window: 'a window) (name: string) conf =
	let (name, box, inst, oconf) = window_get window name in
	set_map window (StringMap.add name (name, box, inst, conf @ oconf) (get_map window))


(** Get the name of the widget.
	@param widget	Widget to get name from.
	@return			Widget name. *)
let widget_name (widget: 'a widget) =
	let (name, _, _, _) = widget in name


(** get the instance of a widget.
	@param widget	Widget to get instance from.
	@return			Widget instance. *)
let widget_inst (widget: 'a widget) =
	let (_, _, METHOD inst, _) = widget in inst


(** Get the configuration of a widget.
	@param widget	Looked widget.
	@return			Configuration. *)
let widget_conf (widget: 'a widget) =
	let (_, _, _, conf) = widget in conf


(** Get the box of a widget.
	@param widget	Widget to get box.
	@return			Widget box. *)
let widget_box (widget: 'a widget) =
	let (_, box, _, _) = widget in box


(** Compute the size of a widget
	@param window	Owner window.
	@param name		Name of widget.
	@return			(width, height) *)
let widget_size (window: 'a window) (name: string) =
	let widget = window_get window name in
	let inst = widget_inst widget in
	match fst (inst widget window GET_SIZE) with
	|	SIZE (w, h) -> (w, h)
	|	_			-> failwith "size required here!"


(** Compute the bounds of a widget
	@param window	Owner window.
	@param name		Name of widget.
	@return			(min width, min height, max width, max height) *)
let widget_bounds (window: 'a window) (name: string) =
	let widget = window_get window name in
	let inst = widget_inst widget in
	match fst (inst widget window GET_BOUNDS) with
	|	BOUNDS (miw, mih, maw, mah) -> (miw, mih, maw, mah)
	|	_							-> failwith "bad result"


(** draw the widget
	@param window	Owner window.
	@param name		Name of widget to draw. *)
let widget_draw (window: 'a window) (name: string) =
	let widget = window_get window name in
	let inst = widget_inst widget in
	ignore (inst widget window DRAW)


(** set the position of a widget.
	@param widget	Widget to locate.
	@param x		X position.
	@param y		Y position.
	@return			New window. *)
let widget_move (window: 'a window) (widget: 'a widget) x y =
	let inst = widget_inst widget in
	snd (inst widget window (MOVE (x, y)))


(** run the given widget in a window.
	@param title	Window title.
	@param app		Application state.
	@return			Built window. *)
let window_make title app =
	let empty_event =
		{
			Graphics.mouse_x = 0;
			Graphics.mouse_y = 0;
			Graphics.button = false;
			Graphics.keypressed = false;
			Graphics.key = '0'
		} in
	(
		(title, "", true, empty_event),
		([], []),
		StringMap.empty,
		(0, 0, Graphics.black, Graphics.white),
		app
	)


(** Change the box of a widget.
	@param window	Owner window.
	@param widget	Widget to update.
	@param box		New box.
	@return			New window. *)
let widget_change_box (window: 'a window) (widget: 'a widget) box =
	let (name, _, inst, conf) = widget in
	set_map window (StringMap.add name (name, box, inst, conf) (get_map window))


(** Call the method to change the size of a widget.
	@param window	Owner window.
	@param name		Name of widget to update.
	@param box		New box.
	@return			New window. *)
let widget_set_box (window: 'a window) (name: string) box =
	let widget = window_get window name in
	let inst = widget_inst widget in
	snd (inst widget window (SET_BOX box))


(** Default implementation of a widget instance. *)
let default_inst (widget: 'a widget) (window: 'a window) msg =
	let (name, (x, y, w, h), inst, conf) = widget in
	match msg with
	| DRAW			->
		(NOTHING, window)
	| GET_SIZE		->
		(SIZE (w, h), window)
	| GET_BOUNDS	->
		(BOUNDS (w, h, w, h), window)
	| AT (mx, my)	->
		(WIDGET (if x <= mx && mx < (x + w) && y <= my && my < (y + h)
		then name else ""), window)
	| MOVE (nx, ny) ->
		(NOTHING, widget_change_box window widget (nx, ny, w, h))
	| SET_BOX box ->
		(NOTHING, widget_change_box window widget box) 
	| CUSTOM (n, _) ->
		failwith (Printf.sprintf "unsupported method %s" n)
		

(** build a widget
	@param window	Parent window.
	@param name		Widget name.
	@param inst		Widget inst.
	@return			Built widget. *)
let widget_make (window: 'a window) name inst =
	set_map window (StringMap.add name (name, (0, 0, 0, 0), METHOD inst, default_config) (get_map window))


(** Set the given widget as top.
	@param window	Window.
	@param name		Name of widget.
	@return			New window. *)
let window_set_top (window: 'a window) (name: string) =
	set_top window name


(** Stop the window.
	@param window	Window to work on.
	@return			New window state. *)
let window_quit window =
	set_ended window true


(** Call a custom method.
	@param window	Owner window.
	@param name		Name to call to.
	@param call		Custom method call.
	@param args		Custom method arguments.
	@return			(call result, updated window). *)
let widget_call (window: 'a window) (name: string) call =
	let widget = window_get window name in
	let inst = widget_inst widget in
	inst widget window call


(** Call a custom method.
	@param window	Owner window.
	@param wname	Name of widget to call to.
	@param name		Custom method name.
	@param args		Custom method arguments. *)
let widget_call_custom (window: 'a window) (wname: string) name args =
	widget_call window wname (CUSTOM (name, args))


(** Add an handler for an event on a widget.
	@param window	Window to add handle to.
	@param event	Event to handle.
	@param name		Widget name supporting the event.
	@param handle	Handle function.
	@return			New version of window. *)
let window_handle_event (window: 'a window) name event handle =
	set_evts window (((name, event), EVENT_HANDLER handle) :: (get_evts window))
	

(** Add an handler for an event on a widget.
	@param window	Window to add handle to.
	@param name		Widget name supporting the event.
	@param time		Time to wait (in s).
	@param handle	Handle function.
	@return			New version of window. *)
let window_handle_timeout window time handle =
	let ctime = Unix.gettimeofday () in
	let cmp (t1, h1) (t2, h2) = compare t1 t2 in
	let times = List.sort cmp ((ctime +. time, TIME_HANDLER handle) :: (get_times window)) in
	set_times window times


(** Get the top widget of the window.
	@param window	Windodw.
	@return			Top widget (fail if there is no top widget!). *)
let window_get_top (window: 'a window) =
	get_top window


(** Open and execute the window.
	@param window	Window to run.
	@return			Output application state. *)
let window_run window =

	(* open the window *)
	Graphics.open_graph "";
	let (w, h) = widget_size window (window_get_top window) in
	let ww, wh = w + 2 * window_pad_x, h + 2 * window_pad_y in
	let window = set_width (set_height window wh) ww in
	debug_line := h - 20;
	Graphics.resize_window ww wh;
	let window = widget_set_box window (window_get_top window) (window_pad_x, window_pad_y, w, h) in
	widget_draw window (window_get_top window);

	(* manage events *)
	let rec handle_keyboard (window: 'a window) event: unit =
		try
			let event = KEY event.Graphics.key in
			let EVENT_HANDLER h = List.assoc ("", event) (get_evts window) in
			poll_events (h window event)
		with Not_found ->
			poll_events window
	
	and handle_time (window: 'a window): unit =
		match get_times window with
		| (time, TIME_HANDLER h) :: times ->
			handle_timed (h (set_times window times))
		| _ -> failwith "internal error: no time handler to run?"
	
	and handle_timed (window: 'a window): unit =
		if get_ended window then () else
		
		(* determine wait time *)
		let ctime = Unix.gettimeofday () in
		let time =
			match get_times window with
			| [] -> 0.1
			| (time, _)::_ -> min 0.1 (time -. ctime) in
		
		(* any event pending? *)
		if time <= 0. then handle_time window

		(* perform the wait *)
		else begin
			(try
				Thread.delay time
			with Unix.Unix_error(_, _, _) ->
				());
			
			(* look for events *)
			poll_events window 
		end
				
	and poll_events (window: 'a window): unit =
				
		(* key test *)
		let event = Graphics.wait_next_event [ Graphics.Key_pressed; Graphics.Poll ] in
		if event.Graphics.keypressed then
			begin
				debug_event window event;
				ignore (Graphics.wait_next_event [ Graphics.Key_pressed ]);
				handle_keyboard (set_prev window event) event
			end
		else
		
		(* button up / down *)
		let event = Graphics.wait_next_event [ Graphics.Button_down; Graphics.Button_up; Graphics.Poll ] in
		if event.Graphics.button <> (get_prev window).Graphics.button then
			begin
				debug_event window event;
				poll_events (set_prev window event)
			end
		
		(* no more things to poll *)
		else
			begin
				(*debug "no more";*)
				handle_timed window
			end in
	
	(try
		handle_timed (set_ended window false);
	with Graphics.Graphic_failure _
		-> print_string "Closed by user.\n");

	(* close the window *)
	Graphics.close_graph ()


(** Display an message in the window.
	@param color	Message color.
	@param window	Current window.
	@param msg		Message to display. *)
let window_display color (window: 'a window) (msg: string) =
	Graphics.set_color color;
	Graphics.set_text_size 64;
	let _, _, ww, wh = widget_get_box window (window_get_top window)  in
	let tw, th = Graphics.text_size msg in
	let x = (ww - tw) / 2 in
	let y = (wh - th) / 2 in
	Graphics.moveto x y;
	Graphics.draw_string msg


(** Display an alert message in the window.
	@param window	Current window.
	@param msg		Message to display. *)
let window_alert (window: 'a window) (msg: string) =
	window_display Graphics.red window msg


(********* label widget *********)
let rec label_inst text (widget: 'a widget) window msg =
	let size _ = 
		let tw, th = Graphics.text_size text in
		let conf = widget_conf widget in
		(	tw + (pad_left conf) + (pad_right conf),
			th + (pad_top conf) + (pad_bottom conf)) in
	match msg with
	| GET_SIZE ->
		let (w, h) = size () in
		(SIZE (w, h), window)
	| GET_BOUNDS ->
		let (w, h) = size () in
		(BOUNDS (w, h, w, h), window)
	| DRAW ->
		let conf = widget_conf widget in
		let (x, y, w, h) = widget_get_box window (widget_name widget) in
		Graphics.set_color (back_color conf);
		Graphics.fill_rect x y w h;
		Graphics.set_color (text_color conf);
		Graphics.moveto (x + (pad_left conf)) (y + (pad_right conf));
		Graphics.draw_string text;
		(NOTHING, window)
	| CUSTOM ("set_text", [STRING text]) ->
		let (name, box, _, _) = widget in
		let window = widget_update window widget (label_inst text) in
		widget_draw window name;
		(NOTHING, window)
	| _ ->
		default_inst widget window msg 


(** Build a	label.
	@param win		Window.
	@param name		Widget name.
	@param text		Label content.
	@return			Updated window. *)
let label_make (win: 'a window) name text =
	widget_make win name (label_inst text)


(** Change text of the label.
	@param window	Owner window.
	@param name		Name of label to change.
	@param text		New text.
	@return			Window updated. *)
let label_set_text (window: 'a window) (name: string) text =
	snd (widget_call_custom window name "set_text" [STRING text])


(********* vertical box widget *********)
let vbox_inst names widget window msg =
	match msg with
	
	| GET_SIZE ->
		let (win, w, h) = 
			List.fold_left (fun (win, w, h) name ->
				match widget_call win name GET_SIZE with
				| (SIZE(cw, ch), win) -> (win, max w cw, h + ch)
				| _ -> failwith "bug")
				(window, 0, 0) names in
		(SIZE (w, h), win)

	| SET_BOX (x, y, w, h) ->
		let window = widget_change_box window widget (x, y, w, h) in
		let (win, y) =
			List.fold_right (fun name (win, y) ->
				match widget_call win name GET_SIZE with
				| (SIZE (cw, ch), win) ->
					let win = widget_set_box win name (x, y, w, ch) in
					(win, y + ch)
				| _ -> failwith "bug")
				names (window, y) in
			(NOTHING, win)

	| DRAW ->
		List.fold_left (fun (_, win) name -> widget_call win name DRAW) (NOTHING, window) names

	| _ ->
		default_inst widget window msg

(** Build a vertical box.
	@param win		Owner window.
	@param name		Widget name.
	@param content	Contained widgets.
	@return			Updated window. *)
let vbox_make (win: 'a window) name content = 
	widget_make win name (vbox_inst content)


(********* statusbar widget *********)

let statusbar_time = 3.0

(* internal use *)
let statusbar_update name inst (window: 'a window) =
	if inst == (widget_inst (window_get window name))
	(* to fix *)
	then label_set_text window name ""
	else window

(* internal use *)
let statusbar_start window name =
	let widget = window_get window name in
	window_handle_timeout window
		(float_conf "time" (widget_conf widget))
		(statusbar_update name (widget_inst widget))

(* internal use *)
let rec statusbar_inst text (widget: 'a widget) window msg =
	match msg with
	| GET_BOUNDS ->
		let (answer, window) = label_inst text widget window msg in
		(match answer with
		| BOUNDS (miw, mih, maw, mah) -> (BOUNDS (miw, mih, 0, 0), window)
		| _ -> failwith "internal statusbar error")
	| _ ->
		label_inst text widget window msg

(** Build a status bar.
	@param window	Owner window.
	@param name		Widget name.
	@param msg		Initial message.
	@return			Window updated. *)
let statusbar_make (win: 'a window) name msg =
	let window = widget_make win name (statusbar_inst msg) in
	let window = widget_config window name [CONF ("time", FLOAT statusbar_time)] in
	statusbar_start window name

(** Display a message and do not remove it.
	@param window	Owner window.
	@param name		Status bar name.
	@param msg		Message to display.
	@return			Updated window. *)
let statusbar_display_untimed (window: 'a window) name msg =
	(* to fix *)
	label_set_text window name msg


(** Display a timed message.
	@param window	Owner window.
	@param name		Status bar name.
	@param msg		Message to display.
	@return			Updated window. *)
let statusbar_display (window: 'a window) name msg =
	let window = statusbar_display_untimed window name msg in
	statusbar_start window name


(********* horizontal box widget *********)
let hbox_inst names widget window msg =
	let max0 x y = if x = 0  || y = 0 then 0 else max x y in

	let map window x y w h =
	
		let wids = List.map (fun name ->
				match widget_call window name GET_BOUNDS with
				| (BOUNDS(miw, mih, maw, mah), _) -> (name, miw, mih, maw, mah)
				| _ -> failwith "bug in hbox"
			) names in
			
		let (rem, free) =
			List.fold_left
				(fun (r, f) (name, miw, mih, maw, mah) -> (r - miw, if maw = 0 then f + 1 else f))
				(w, 0)
				wids in
		let arem = if free = 0 then 0 else rem / free in
		
		let (window, _) =
			List.fold_left 
				(fun (win, x) (name, miw, mih, maw, mah) ->
					let ww = if maw = 0 then miw + arem else miw in
					(widget_set_box win name (x, y, ww, h), x + ww))
				(window, x)
				wids in
		
		window in

	match msg with
	
	| GET_SIZE ->
		let (win, w, h) = 
			List.fold_left (fun (win, w, h) name ->
				match widget_call win name GET_SIZE with
				| (SIZE(cw, ch), win) -> (win, w + cw, max h ch)
				| _ -> failwith "bug")
				(window, 0, 0) names in
		(SIZE (w, h), win)

	| GET_BOUNDS ->
		let (win, miw, mih, maw, mah) = 
			List.fold_left (fun (win, minw, minh, maw, mah) name ->
				match widget_call win name GET_BOUNDS with
				| (BOUNDS(wmiw, wmih, wmaw, wmah), win) -> (win, min minw wmiw, min minh wmih, max0 maw wmaw, max0 mah wmah)
				| _ -> failwith "hbox bad bounds")
				(window, 0, 0, 1, 1) names in
		(BOUNDS (miw, mih, maw, mah), win)

	| SET_BOX (x, y, w, h) ->
		let window = widget_change_box window widget (x, y, w, h) in
		(NOTHING, map window x y w h)

	| DRAW ->
		List.fold_left (fun (_, win) name -> widget_call win name DRAW) (NOTHING, window) names

	| _ ->
		default_inst widget window msg


(** Build a horizontal box.
	@param win		Owner window.
	@param name		Widget name.
	@param content	Contained widgets.
	@return			Updated window. *)
let hbox_make (win: 'a window) name content = 
	widget_make win name (hbox_inst content)


(****** console definition ******)

let rec console_inst rline lines widget window msg =

	let up y h conf = y + h - (pad_top conf) in
	let left x w conf = x + (pad_left conf) in
	let max h lh conf = (h - (pad_top conf) - (pad_bottom conf)) / lh in
	let linfo _ = Graphics.text_size rline in
	
	let display_line conf x line y =
		Graphics.set_color (text_color conf);
		Graphics.moveto x y;
		Graphics.draw_string line; 
		y - (snd (linfo ())) in
	
	let display_all lines =
		let (x, y, w, h) = widget_box widget in
		let conf = widget_conf widget in
		Graphics.set_color (back_color conf);
		Graphics.fill_rect x y w h;
		ignore (List.fold_right
			(display_line conf (left x w conf))
			lines
			((up y h conf) - (snd (linfo rline)))) in
	
	let rec remove l =
		match l with
		| [] 	-> l
		| [h]	-> []
		| h::t	-> h::(remove t) in
	
	let add_line line =
		let (x, y, w, h) = widget_box widget in
		let conf = widget_conf widget in
		let lcnt = List.length lines in
		let lw, lh = linfo () in
		let max = max h lh conf in
		let lines = line :: 
			(if lcnt < max
			then lines
			else remove lines) in
		display_all lines;	
		widget_update window widget (console_inst rline lines) in

	let size _ =
		let conf = widget_conf widget in
		let w, h = Graphics.text_size rline in
		(	w + (pad_left conf) + (pad_right conf),
			h + (pad_top conf) + (pad_bottom conf)) in

	match msg with
	| DRAW ->

		display_all lines;
		(NOTHING, window)
		
	| GET_SIZE ->
		let (w, h) = size () in
		(SIZE (w, h), window)
	
	| GET_BOUNDS ->
		let (w, h) = size () in
		(BOUNDS (w, h, 0, 0), window)	

	| CUSTOM("add", [STRING line]) ->
		(NOTHING, add_line line)

	| _ ->
		default_inst widget window msg



(** Build a console.
	@param window	Owner window.
	@param name		Widget name.
	@param rline	Reference line to size the console.
	@return			Updated window. *)
let console_make window name rline =
	widget_make window name (console_inst rline [])


(** Add a line to the console.
	@param window	Owner window.
	@param name		Console name.
	@param line		Added line.
	@return			Updated window. *)
let console_add (window: 'a window) name line =
	snd (widget_call window name (CUSTOM ("add", [STRING line])))

