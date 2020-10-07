(** Vector graphics support. *)

open Graphics

(** Describe the coordinates. *)
type coordinates =
	| ABS of int * int	(** Absolute coordinates, (0, 0) at left-bottom *)
	| REL of int * int	(** Relative coordinates at current position. *)

(** Describe the figure to draw .*)
type drawing =
	| MOVE of coordinates
	| LINE of coordinates
	| RECT of coordinates
	| CIRCLE of int
	| ELLIPSE of int * int
	| FILL_RECT of coordinates
	| FILL_CIRCLE of int
	| FILL_ELLIPSE of int * int
	| COLOR of color
	| LINE_WIDTH of int
	| TEXT of string

(** Draw the given drawing.
	@param x	Left position of the drawing.
	@param y	Bottom position of the drawing.
	@param d	Drawing to display. *)
let draw x y d =

	let draw xc yc d =
		match d with
		| MOVE (ABS (dx, dy)) ->
			(x + dx, y + dy)
		| MOVE (REL (dx, dy)) ->
			(xc + dx, yc + dy)
		| LINE (ABS (dx, dy)) ->
			moveto xc yc;
			lineto (x + dx) (y + dy);
			(x + dx, y + dy)
		| LINE (REL (dx, dy)) ->
			moveto xc yc;
			lineto (xc + dx) (yc + dy);
			(xc + dx, yc + dy)
		| CIRCLE r ->
			draw_circle xc yc r;
			(xc, yc)
		| ELLIPSE (rx, ry) ->
			draw_ellipse xc yc rx ry;
			(xc, yc)
		| FILL_RECT (ABS (dx, dy)) ->
			let xl = min xc (x + dx) in
			let xr = max xc (x + dx) in
			let yb = min yc (y + dy) in
			let yt = max yc (y + dy) in
			fill_rect xl yb (xr - xl + 1) (yt - yb + 1);
			(xl, yt)
		| FILL_RECT (REL (dx, dy)) ->
			fill_rect xc yc dx dy;
			(xc + dx, yc + dy)
		| FILL_CIRCLE r ->
			fill_circle xc yc r;
			(xc, yc)
		| FILL_ELLIPSE (rx, ry) ->
			fill_ellipse xc yc rx ry;
			(xc, yc)
		| COLOR r ->
			set_color r;
			(xc, yc)
		| LINE_WIDTH w ->
			set_line_width w;
			(xc, yc)
		| TEXT t ->
			moveto xc yc;
			draw_string t;
			let w, _ = text_size t in
			(xc + w, yc)
		| _ -> (xc, yc) in

	let rec process (xc, yc) d =
		match d with
		| [] -> ()
		| h::t -> process (draw xc yc h) t in

	process (x, y) d
