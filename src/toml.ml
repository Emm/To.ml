open TomlType

exception Bad_type of (string * string)

type table = TomlType.tomlTable
type value = TomlType.tomlValue
type array = TomlType.tomlNodeArray

(** Parsing functions a TOML file. Return a toml table. *)

let parse lexbuf = TomlParser.toml TomlLexer.tomlex lexbuf
let from_string s = parse (Lexing.from_string s)
let from_channel c = parse (Lexing.from_channel c)
let from_filename f = from_channel (open_in f)

let create () = Hashtbl.create 0

let get = Hashtbl.find

let merge tbl1 tbl2 =
  Hashtbl.iter (fun k v -> Hashtbl.replace tbl1 k v) tbl2

let rec rec_merge tbl1 tbl2 =
  let concat_arr arr1 arr2 =
  match arr1, arr2 with
  | NodeEmpty, _ -> arr2
  | _, NodeEmpty -> arr1
  | NodeArray n1, NodeArray n2 -> NodeArray (List.rev_append n1 n2)
  | NodeBool n1, NodeBool n2 -> NodeBool (List.rev_append n1 n2)
  | NodeInt n1, NodeInt n2 -> NodeInt (List.rev_append n1 n2)
  | NodeFloat n1, NodeFloat n2 -> NodeFloat (List.rev_append n1 n2)
  | NodeString n1, NodeString n2 -> NodeString (List.rev_append n1 n2)
  | NodeDate n1, NodeDate n2 -> NodeDate (List.rev_append n1 n2)
  | _, _ -> raise (Bad_type ("", ""))
  in 
  Hashtbl.iter (fun k v ->
                try match Hashtbl.find tbl1 k, v with
                    | TArray a, TArray a' ->
                       Hashtbl.add tbl1 k @@ TArray (concat_arr a a')
                    | TTable t, TTable t' -> rec_merge t t'
                    | _, _ -> Hashtbl.replace tbl1 k v
                with Not_found -> Hashtbl.add tbl1 k v) tbl2

let get_table toml key = match (get toml key) with
  | TTable(tbl) -> tbl
  | _ -> raise (Bad_type (key, "value"))

let get_bool toml key = match get toml key with
  | TBool b -> b
  | _ -> raise (Bad_type (key, "boolean"))

let get_int toml key = match get toml key with
  | TInt i -> i
  | _ -> raise (Bad_type (key, "integer"))

let get_float toml key = match get toml key with
  | TFloat f -> f
  | _ -> raise (Bad_type (key, "float"))

let get_string toml key = match get toml key with
  | TString s -> s
  | _ -> raise (Bad_type (key, "string"))

let get_date toml key = match get toml key with
  | TDate d -> d
  | _ -> raise (Bad_type (key, "date"))

let get_bool_list toml key = match get toml key with
  | TArray (NodeBool b) -> b
  | TArray (NodeEmpty) -> []
  | _ -> raise (Bad_type (key, "boolean array"))

let get_int_list toml key = match get toml key with
  | TArray (NodeInt i) -> i
  | TArray (NodeEmpty) -> []
  | _ -> raise (Bad_type (key, "integer array"))

let get_float_list toml key = match get toml key with
  | TArray (NodeFloat f) -> f
  | TArray (NodeEmpty) -> []
  | _ -> raise (Bad_type (key, "float array"))

let get_string_list toml key = match get toml key with
  | TArray (NodeString s) -> s
  | TArray (NodeEmpty) -> []
  | _ -> raise (Bad_type (key, "string array"))

let get_date_list toml key = match get toml key with
  | TArray (NodeDate d) -> d
  | TArray (NodeEmpty) -> []
  | _ -> raise (Bad_type (key, "date array"))

let add_value = Hashtbl.add

let mk_bool v = TBool v
let mk_int v = TInt v
let mk_float v = TFloat v
let mk_string v = TString v
let mk_date v = TDate v

let mk_bool_array list = NodeBool list
let mk_int_array list = NodeInt list
let mk_float_array list = NodeFloat list
let mk_string_array list = NodeString list
let mk_date_array list = NodeDate list

let mk_array_array list = NodeArray list

let mk_array array = TArray array
