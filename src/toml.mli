(** The TOML parser interface *)

(** Note about the Toml.tomlTable type: it is **NOT** a persistent 
    data structure  *)

(** {2 Parsing functions } *)

val parse : Lexing.lexbuf -> TomlType.tomlTable
val from_string : string -> TomlType.tomlTable
val from_channel : in_channel -> TomlType.tomlTable
val from_filename : string -> TomlType.tomlTable

(** {2 General table manipulations } *)

(** Second table is merged into first one, if a key is present in two 
    tables, the second will override the first  *)
val merge : TomlType.tomlTable -> TomlType.tomlTable -> unit

(** Same as merge function, except that everything that can be merged will 
    be merged instead of erasing the first one (sub tables and arrays) *)
val rec_merge : TomlType.tomlTable -> TomlType.tomlTable -> unit

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

val get_bool : TomlType.tomlTable -> string -> bool
val get_int : TomlType.tomlTable -> string -> int
val get_float : TomlType.tomlTable -> string -> float
val get_string : TomlType.tomlTable -> string -> string
val get_date : TomlType.tomlTable -> string -> Unix.tm

(** {3 Table getter }
    Get a subtable *)

val get_table : TomlType.tomlTable -> string -> TomlType.tomlTable

(** {3 Array getters}
    Arrays contents are returned as lists *)

val get_bool_list : TomlType.tomlTable -> string -> bool list
val get_int_list : TomlType.tomlTable -> string -> int list
val get_float_list : TomlType.tomlTable -> string -> float list
val get_string_list : TomlType.tomlTable -> string -> string list
val get_date_list : TomlType.tomlTable -> string -> Unix.tm list

(** {2 Adding a value to a TOML table } *)

(** In order to add a value into a table, you must follow these steps:
    {ol list}
    - prepare the value for insertion, using [mk_x] functions
    - add your preparation using [add_value] function *)

(** {3 Prepare ocaml primitive values } *)

(** Use these functions to prepare ocaml primitive values for insertion in
    a toml table *)

val mk_bool : bool -> TomlType.tomlValue
val mk_int : int -> TomlType.tomlValue
val mk_float : float -> TomlType.tomlValue
val mk_string : string -> TomlType.tomlValue
val mk_date : Unix.tm -> TomlType.tomlValue

(** {3 Prepare lists for insertion as an array } *)

(** Functions for making a toml array from a ocaml primitive type list.
    Resulting arrays can not be directly inserted into a toml table but need 
    to be transformed by the [mk_array] function *)

val mk_bool_array : bool list -> TomlType.tomlNodeArray
val mk_int_array : int list -> TomlType.tomlNodeArray
val mk_float_array : float list -> TomlType.tomlNodeArray
val mk_string_array : string list -> TomlType.tomlNodeArray
val mk_date_array : Unix.tm list -> TomlType.tomlNodeArray

(** {3 Insert prepared value } *)

(** Combine a list of toml array into a array of array *)
val mk_array_array : TomlType.tomlNodeArray list -> TomlType.tomlNodeArray


(** Use this function to make a toml value from toml array made with 
    [mk_x_array] functions. Result will be able to be include into a TOML 
    table using [add_value]. *)
val mk_array : TomlType.tomlNodeArray -> TomlType.tomlValue


(** Add a tomlValue to a tomlTable *)
val add_value : TomlType.tomlTable -> string -> TomlType.tomlValue -> unit
