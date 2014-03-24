(** The TOML parser interface *)

(** [t] is **NOT** a persistent data structure  *)
type table = TomlType.tomlTable
type value = TomlType.tomlValue
type array = TomlType.tomlNodeArray

(** {2 Parsing functions } *)

val parse : Lexing.lexbuf -> table
val from_string : string -> table
val from_channel : in_channel -> table
val from_filename : string -> table

(** {2 General table manipulations } *)

(** Create a empty TOML table *)
val create : unit -> table

(** Second table is merged into first one, if a key is present in two 
    tables, the second will override the first  *)
val merge : table -> table -> unit

(** Same as merge function, except that everything that can be merged will 
    be merged instead of erasing the first one (sub tables and arrays) *)
val rec_merge : table -> table -> unit

(** {2 Extract a specific value }
    These functions take the toml table as first argument and the key of 
    value as second one. They have three behaviors:{ul list}
    - The key is found and the type is good. The primitive value is returned
    - The key is not found: raise Not_found
    - The key is found but the type doesn't match: raise Bad_type *)

(** Bad_type expections carry (key, expected type) data *)
exception Bad_type of (string * string)

(** {3 Primitive getters }
    Use these functions to get a single value of a known OCaml type *)

val get_bool : table -> string -> bool
val get_int : table -> string -> int
val get_float : table -> string -> float
val get_string : table -> string -> string
val get_date : table -> string -> Unix.tm

(** {3 Table getter }
    Get a subtable *)

val get_table : table -> string -> table

(** {3 Array getters}
    Arrays contents are returned as lists *)

val get_bool_list : table -> string -> bool list
val get_int_list : table -> string -> int list
val get_float_list : table -> string -> float list
val get_string_list : table -> string -> string list
val get_date_list : table -> string -> Unix.tm list

(** {2 Adding a value to a TOML table } *)

(** In order to add a value into a table, you must follow these steps:
    {ol list}
    - prepare the value for insertion, using [mk_x] functions
    - add your preparation using [add_value] function *)

(** {3 Prepare ocaml primitive values } *)

(** Use these functions to prepare ocaml primitive values for insertion in
    a toml table *)

val mk_bool : bool -> value
val mk_int : int -> value
val mk_float : float -> value
val mk_string : string -> value
val mk_date : Unix.tm -> value
val mk_table : table -> value

(** {3 Prepare lists for insertion as an array } *)

(** Functions for making a toml array from a ocaml primitive type list.
    Resulting arrays can not be directly inserted into a toml table but need 
    to be transformed by the [mk_array] function *)

val mk_bool_array : bool list -> array
val mk_int_array : int list -> array
val mk_float_array : float list -> array
val mk_string_array : string list -> array
val mk_date_array : Unix.tm list -> array


(** Combine a list of toml array into a array of array *)
val mk_array_array : array list -> array

(** Use this function to make a toml value from toml array made with 
    [mk_x_array] functions. Result will be able to be include into a TOML 
    table using [add_value]. *)
val mk_array : array -> value

(** {3 Insert prepared value } *)

(** Add a tomlValue to a tomlTable *)
val add_value : table -> string -> value -> unit
