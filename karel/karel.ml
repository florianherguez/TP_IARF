(** Module d'implantation du robot Karel. *)
open Printf
open Vm

(** Levé quand une erreur arrive dans les primitives de Karel. *)
exception Error of string


(** Thrown if there is an error when reading a Karel world file. *)
exception WorldError of string

(* directions *)
let north = 1
let east = 2
let south = 3
let west = 4

let front = 1
let left = 2
let right = 3

(** Identificateur d'action de mouvement.
	Raise error if there is a wall in the move direction. *)
let move = 1


(** Identificateur d'action de tourner à gauche. *)
let turn_left = 2


(** Action identifier to pick a beeper.
	Raise Error if there is no beeper. *)
let pick_beeper = 3


(** Action identifier to put a beeper.
	Raise Error if there is no more beeper in the bag.*)
let put_beeper = 4


(** Action identifier to test if there is no wall.
	1st argument: direction to test (front, left, right).
	2nd argument: register to store result into. *)
let is_clear = 5


(** Action identifier to test if there is a wall.
	1st argument: direction to test (front, left, right).
	2nd argument: register to store result into. *)
let is_blocked = 6


(** Action identifier to test which direction Karel is facing.
	1st argument: direction to test (north, south, west, east).
	2nd argument: register to store result into. *)
let facing = 7


(** Action identifier to test which direction Karel is not facing.
	1st argument: direction to test (north, south, west, east).
	2nd argument: register to store result into. *)
let not_facing = 8


(** Action identifier to test if it remains a beeper in the bag.
	1st argument: register to store result into. *)
let any_beeper = 9


(** Action identifier to test if it doesn't remain a beeper in the bag.
	1st argument: register to store result into. *)
let no_beeper = 10


(** Action identifier to test if there is a beeper at current position.
	1st argument: register to store result into. *)
let next_beeper = 11


(** Action identifier to test if there is no beeper at current position.
	1st argument: register to store result into. *)
let no_next_beeper = 12


(** Identificateur d'action affichant simplement l'état du robot.
	Aucun paramètre utilisé. *)
let display = 13


(* Calcule le déplacement d'un pas dans une direction.
	@param d	Direction.
	@return		déplacement (dx, dy). *)
let offset d =
	List.nth [(0, -1); (+1, 0); (0, +1); (-1, 0)] (d - 1)


(** Calcul l'oppose d'une direction.
	@param d	Direction.
	@return		Direction opposée. *)
let reverse d =
	List.nth [south; west; north; east] (d - 1)


(** Calcule la nouvelle direction en tournant à gauche.
	@param d	Direction initiale.
	@return		Nouvelle direction. *)
let to_left d =
	List.nth [west; north; east; south] (d - 1)


(** Calcule la nouvelle direction en tournant à droite.
	@param d	Direction initiale.
	@return		Direction après rotation. *)
let to_right d =
	List.nth [east; south; west; north] (d - 1)


(** Calcule la nouvelle direction en tournant selon le paramètre donné.
	@param d	Direction initiale.
	@param t	Sens de rotation (front, left, right). *)
let turn d t =
	(List.nth [(fun d -> d); to_left; to_right] (t - 1)) d


(** Représentation de la carte. *)
type cell = int * int					(** walls, beeper count *)
type robot = int * int * int * int		(** x, y, direction, beeper number *)
type map = int * int * cell list list	(** width, height, cells *)
type world = robot * map				(** robot initial, carte *)
type karel = robot * world				(** robot courant, monde *)


(** Cellule sans mur. *)
let empty	= 0


(** Produit la chaîne de caractère correspondant à une direction.
	@param d	Direction.
	@return		Chaîne de caractère. *)
let string_of_dir d =
	List.nth ["north"; "east"; "south"; "west"] (d - 1)


(** Ajoute un mur à la cellule donnée.
	@param c	Cellule à modifier.
	@param d	Direction du mur.
	@return		Cellule modifiée. *)
let wall d c = c lor (1 lsl d)


(** Test si une cellule a un mur dans la direction donnée.
	@param d	Direction.
	@param c	Cellule à tester.
	@return		Vrai s'il y a un mur. *)
let has_wall d c =
	(c land (1 lsl d)) <> 0


(** Initialise une carte en traçant un bord autour.
	@param w	Largeur.
	@param h	Hauteur.
	@return		Carte construite. *)
let map_init w h =

	let rec mult n h i t =
		if n == 0 then h::t else
		mult (n - 1) h i (i::t) in
	
	let top = mult	(w - 2)
					(wall north (wall west empty), 0)
					(wall north empty, 0) 
					[(wall north (wall east empty), 0)] in
	let line = mult	(w - 2)
					(wall west empty, 0)
					(empty, 0) 
					[(wall east empty, 0)] in
	let bot = mult	(w - 2)
					(wall south (wall west empty), 0)
					(wall south empty, 0) 
					[(wall south (wall east empty), 0)] in
	(w, h, mult (h - 2) top line [bot])


(** Teste si une direction est libre sur une carte.
	@param map	La carte.
	@param x	X
	@param y	Y
	@param d	direction
	@return		Vraie si la voie est libre, faux sinon. *)
let map_dir map (x: int) (y: int) d =
	let (_, _, c) = map in
	let (w, _) = List.nth (List.nth c y) x in
	has_wall d w


(** Renvoie le nombre de beeper sur une case.
	@param map	Carte à utiliser.
	@param x	X
	@param y	Y
	@return		Nombre de beeper. *)
let map_beeper map x y =
	let (_, _, c) = map in
	let (_, b) = List.nth (List.nth c y) x in
	b


(** Réalise une modification sur la carte.
	@param map	Carte à modifier.
	@param x	X
	@param y	Y
	@param f	Fonction à appeler: cell -> cell.
	@return		Nouvelle carte. *)
let map_set map x y f = 

	let rec lookx r x =
		match r with
		| h::t when x = 0 	-> (f h)::t
		| h::t				-> h :: (lookx t (x - 1))
		| _					-> failwith (sprintf "bad X: %d, %d!" x y) in
		
	let rec looky r y =
		match r with
		| h::t when y = 0 	-> (lookx h x)::t
		| h::t				-> h :: (looky t (y - 1))
		| _					-> failwith "bad Y!" in

	let (w, h, c) = map in
	(w, h, looky c y)


(** Ajoute un mur dans la direction donnée.
	@param map	Carte à modifier.
	@param x	X
	@param y	Y
	@param d	Direction du mur.
	@return		Carte modifiée. *)
let set_wall map x y d =
	let (w, h, _) = map in
	let map = map_set map x y (fun (c, b) -> (wall d c, b)) in
	let (dx, dy) = offset d in
	let x, y = x + dx, y + dy in
	if x < 0 || x >= w || y < 0 || y >= h then map else
	map_set map x y (fun (c, b) -> (wall (reverse d) c, b))


(** Ajoute un beeper.
	@param map	Carte à modifier.
	@param x	X
	@param y	Y
	@return		Carte modifiée. *)
let add_beeper map x y =
	map_set map x y (fun (c, b) -> (c, b + 1))


(** Enlève un beeper.
	@param map	Carte à modifier.
	@param x	X
	@param y	Y
	@return		Carte modifiée. *)
let remove_beeper map x y =
	map_set map x y (fun (c, b) -> (c, b - 1))


(** Met le nombre de beeper.
	@param map	Carte à modifier.
	@param x	X
	@param y	Y
	@param b	Nombre de beeper.
	@return		Carte modifiée. *)
let set_beepers map x y b =
	map_set map x y (fun (c, _) -> (c, b))


(** Monde vide 20x20. *)
let empty_world =
	((10, 10, north, 4), map_init 20 20)


(** Appelé pour visiter chaque case d'un monde.
	@param w	Monde.
	@param f	Fonction à appeler (X -> Y -> (murs, beepers) -> unit) *)
let iter_map w (f: int -> int -> cell -> unit) =
	
	let rec iterx x y l =
		match l with
		| [] -> ()
		| c::t -> begin f x y c; iterx (x + 1) y t end in
	
	let rec itery y l =
		match l with
		| [] -> ()
		| r::t -> begin iterx 0 y r; itery (y + 1) t end in
	
	let  (_, (_, _, m)) = w in
	itery 0 m


(** Calcule l'état initial. *)
let init_state w =
	let ((x, y, d, b), m) = w in
	((x, y, d, b), w)


(** Réalise l'appel à invoke.
	@param vs	Etat de la VM.
	@param ks	Etat de Karel.
	@param d	Paramètre d.
	@param a	Paramètre a.
	@param b	Paramètre b.
	@return		Nouvel état de Karel. *)
let invoke vs ks d a b =
	let (k, w) = ks in
	let (x, y, _d, bs) = k in
	let (i, m) = w in
	
	let do_display _ =
		Printf.printf "x=%d, y=%d, dir=%s, bag=%d\n"
			x y (string_of_dir _d) bs;
		(vs, ks) in
	
	let do_move _ =
		let dx, dy = offset _d in
		if map_dir m x y _d
		then raise (Error "Karel hit a wall!")
		else (vs, ((x + dx, y + dy, _d, bs), w)) in
	
	let do_turn_left _ =
		(vs, ((x, y, to_left _d, bs), w)) in
	
	let do_pick_beeper _ =
		if (map_beeper m x y) = 0
		then raise (Error "No beeper to pick here!")
		else (vs, ((x, y, _d, bs + 1), (i, remove_beeper m x y))) in

	let do_put_beeper _ =
		if bs = 0
		then raise (Error "No more beeper in bag!")
		else (vs, ((x, y, _d, bs - 1), (i, add_beeper m x y))) in

	let do_is_clear _ =
		let (d: int) = turn _d a in
		let r = if map_dir m x y d then 0 else 1 in
		(Vm.set vs b r, ks) in

	let do_is_blocked _ =
		let (d: int) = turn _d a in
		let r = if map_dir m x y d then 1 else 0 in
		(Vm.set vs b r, ks) in

	let do_facing _ =
		let r = if a = _d then 1 else 0 in
		(Vm.set vs b r, ks) in

	let do_not_facing _ =
		let r = if a = _d then 0 else 1 in
		(Vm.set vs b r, ks) in

	let do_any_beeper _ =
		let r = if bs = 0 then 0 else 1 in
		(Vm.set vs b r, ks) in

	let do_no_beeper _ =
		let r = if bs = 0 then 1 else 0 in
		(Vm.set vs b r, ks) in

	let do_next_beeper _ =
		let r = if (map_beeper m x y) = 0 then 0 else 1 in
		(Vm.set vs a r, ks) in

	let do_no_next_beeper _ =
		let r = if (map_beeper m x y) = 0 then 1 else 0 in
		(Vm.set vs a r, ks) in

	let actions = [
		(move, do_move);
		(turn_left, do_turn_left);
		(pick_beeper, do_pick_beeper);
		(put_beeper, do_put_beeper);
		(is_clear, do_is_clear);
		(is_blocked, do_is_blocked);
		(facing, do_facing);
		(not_facing, do_not_facing);
		(any_beeper, do_any_beeper);
		(no_beeper, do_no_beeper);
		(next_beeper, do_next_beeper);
		(no_next_beeper, do_no_next_beeper);
		(display, do_display)
	] in
	
	try
		(List.assoc d actions)()
	with Not_found ->
		raise (Vm.Error (vs, Printf.sprintf "unknown action: %d" d))


let world = ref empty_world
