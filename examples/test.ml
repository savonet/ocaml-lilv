open Lilv

let () =
  let w = World.create () in
  World.load_all w;
  let pp = World.plugins w in
  Printf.printf "size: %d\n\n%!" (Plugins.length pp);
  Plugins.iter (fun p -> Printf.printf "%s: %s by %s: %d ports\n%!" (Plugin.uri p) (Plugin.name p) (Plugin.author_name p) (Plugin.num_ports p)) pp;
  let uri = "http://plugin.org.uk/swh-plugins/flanger" in
  Printf.printf "\n\nLoading uri...\n\n%!";
  let p = Plugins.get_by_uri pp uri in
  let n = Plugin.num_ports p in
  Printf.printf "%d ports\n%!" n;
  for i = 0 to n - 1 do
    let p = Plugin.port_by_index p i in
    Printf.printf "- port %d: %s (%s)\n%!" i (Port.symbol p) (Port.name p);
    if Port.is_input p then Printf.printf "input\n%!";
    if Port.is_output p then Printf.printf "output\n%!";
    if Port.is_audio p then Printf.printf "audio\n%!";
    if Port.is_control p then Printf.printf "control\n%!";
    if Port.is_connection_optional p then Printf.printf "optional connect ion\n%!";
    let d, a, b = Port.range_float p in Printf.printf "range: from %f to %f (default: %f)\n%!" a b d;
  done;
  let i = Plugin.instantiate p 44100. in
  Plugin.Instance.activate i;
  Gc.full_major ()
