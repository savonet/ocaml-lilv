open Lilv

let show_plugin p =
  Printf.printf "%s\n%!" (Plugin.uri p);
  Printf.printf "%s%!" (Plugin.name p);
  if Plugin.author_name p <> "" then Printf.printf " by %s\n%!" (Plugin.author_name p);
  Printf.printf "Class: %s\n%!" (Plugin.Class.label (Plugin.get_class p));
  Printf.printf "Ports: %d\n%!" (Plugin.num_ports p);
  for i = 0 to Plugin.num_ports p - 1 do
    let p = Plugin.port_by_index p i in
    Printf.printf ". port %d, %s (%s):%!" i (Port.symbol p) (Port.name p);
    if Port.is_input p then Printf.printf " input%!";
    if Port.is_output p then Printf.printf " output%!";
    if Port.is_audio p then Printf.printf " audio%!";
    if Port.is_control p then Printf.printf " control%!";
    if Port.is_connection_optional p then Printf.printf " optional connection%!";
    let d, a, b = Port.range_float p in
    if compare (d, a, b) (nan, nan, nan) <> 0 then Printf.printf " from %f to %f (default: %f)%!" a b d;
    Printf.printf "\n%!"
  done;
  Printf.printf "\n%!"

let () =
  let w = World.create () in
  World.load_all w;
  let pp = World.plugins w in
  Printf.printf "We have %d plugins.\n\n%!" (Plugins.length pp);
  Plugins.iter show_plugin pp;
  Gc.full_major ()
