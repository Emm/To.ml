open TomlType

let toml_to_list toml = Hashtbl.fold (fun k v acc -> (k, v)::acc) toml []

let tables_to_list toml =
  Hashtbl.fold (fun k v acc ->
                match v with
                | TTable v -> (k, v) :: acc
                | _ -> acc) toml []

let values_to_list toml =
  Hashtbl.fold (fun k v acc ->
                match v with
                | TTable _ -> acc
                | _ -> (k, v) :: acc) toml []
