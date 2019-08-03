open Ctypes
open Foreign

type world = unit ptr
let world : world typ = ptr void

type plugin = unit ptr
let plugin : plugin typ = ptr void

type instance = unit ptr
let instance : instance typ = ptr void

type plugins = unit ptr
let plugins : plugins typ = ptr void

type port = unit ptr
let port : port typ = ptr void

type node = unit ptr
let node : node typ = ptr void

type iterator = unit ptr
let iterator : iterator typ = ptr void

module LV2 = struct
  module Core = struct
    let uri = "http://lv2plug.in/ns/lv2core"

    let prefix s = uri ^ "#" ^ s

    let input_port = prefix "InputPort"

    let output_port = prefix "OutputPort"

    let audio_port = prefix "AudioPort"

    let control_port = prefix "ControlPort"

    let connection_optional = prefix "connectionOptional"
  end
end

module Node = struct
  type t = node

  let null : t = from_voidp void null

  let free = foreign "lilv_node_free" (node @-> returning void)

  let finalise n = Gc.finalise free n

  let finalised n = finalise n; n

  let to_string = foreign "lilv_node_as_string" (node @-> returning string)

  let uri = foreign "lilv_new_uri" (world @-> string @-> returning node)
  let uri w s = finalised (uri w s)

  let to_uri = foreign "lilv_node_as_uri" (node @-> returning string)

  let to_float = foreign "lilv_node_as_float" (node @-> returning float)
end

module Port = struct
  type t = (world * plugin) * port

  let make plugin port : t = plugin, port

  let get_world (p:t) = fst (fst p)
  let get_plugin (p:t) = snd (fst p)
  let get_port (p:t) = snd p

  let is_a = foreign "lilv_port_is_a" (plugin @-> port @-> node @-> returning bool)
  let is_a n p = is_a (get_plugin p) (get_port p) n

  let is_input p = is_a (Node.uri (get_world p) LV2.Core.input_port) p

  let is_output p = is_a (Node.uri (get_world p) LV2.Core.output_port) p

  let is_audio p = is_a (Node.uri (get_world p) LV2.Core.audio_port) p

  let is_control p = is_a (Node.uri (get_world p) LV2.Core.control_port) p

  let has_property = foreign "lilv_port_has_property" (plugin @-> port @-> node @-> returning bool)
  let has_property n p = has_property (get_plugin p) (get_port p) n

  let is_connection_optional p = has_property (Node.uri (get_world p) LV2.Core.connection_optional) p

  let symbol = foreign "lilv_port_get_symbol" (plugin @-> port @-> returning node)
  let symbol p = Node.to_string (symbol (get_plugin p) (get_port p))

  let name = foreign "lilv_port_get_name" (plugin @-> port @-> returning node)
  let name p = Node.to_string (Node.finalised (name (get_plugin p) (get_port p)))

  let range = foreign "lilv_port_get_range" (plugin @-> port @-> ptr node @-> ptr node @-> ptr node @-> returning void)
  let range p =
    let def = allocate node Node.null in
    let min = allocate node Node.null in
    let max = allocate node Node.null in
    range (get_plugin p) (get_port p) def min max;
    let def = Node.finalised !@def in
    let min = Node.finalised !@min in
    let max = Node.finalised !@max in
    def, min, max

  let range_float p =
    let def, min, max = range p in
    Node.to_float def, Node.to_float min, Node.to_float max
end

module Plugin = struct
  type t = world * plugin

  let make w p : t = w, p
  let get_world (p:t) = fst p
  let get_plugin (p:t) = snd p

  let uri = foreign "lilv_plugin_get_uri" (plugin @-> returning node)
  let uri p = Node.to_uri (uri (get_plugin p))

  let name = foreign "lilv_plugin_get_name" (plugin @-> returning node)
  let name p = Node.to_string (Node.finalised (name (get_plugin p)))

  let author_name = foreign "lilv_plugin_get_author_name" (plugin @-> returning node)
  let author_name p = Node.to_string (Node.finalised (author_name (get_plugin p)))

  let num_ports = foreign "lilv_plugin_get_num_ports" (plugin @-> returning int32_t)
  let num_ports p = Int32.to_int (num_ports (get_plugin p))

  let port_by_index = foreign "lilv_plugin_get_port_by_index" (plugin @-> int32_t @-> returning port)
  let port_by_index p i = Port.make p (port_by_index (get_plugin p) (Int32.of_int i))

  module Instance = struct
    type t = instance

    let free = foreign "lilv_instance_free" (instance @-> returning void)

    let finalised i = Gc.finalise free i; i

    let connect_port = foreign "lilv_instance_connect_port" (instance @-> uint32_t @-> ptr void @-> returning void)
    let connect_port i n data = connect_port i (Unsigned.UInt32.of_int n)

    let activate = foreign "lilv_instance_activate" (instance @-> returning void)

    let deactivate = foreign "lilv_instance_deactivate" (instance @-> returning void)

    let run = foreign "lilv_instance_run" (instance @-> uint32_t @-> returning void)
    let run i n = run i (Unsigned.UInt32.of_int n)
  end

  let instantiate = foreign "lilv_plugin_instantiate" (plugin @-> double @-> ptr void @-> returning instance)
  (* TODO: features *)
  let instantiate p samplerate = Instance.finalised (instantiate p samplerate (from_voidp void null))
end

module Plugins = struct
  type t = world * plugins
  type plugins_iterator = t * iterator

  let make world plugins : t = world, plugins
  let get_world (p:t) = fst p
  let get_plugins (p:t) = snd p

  let length = foreign "lilv_plugins_size" (plugins @-> returning int)
  let length p = length (get_plugins p)

  let iterate = foreign "lilv_plugins_begin" (plugins @-> returning iterator)
  let iterate p : plugins_iterator = p, iterate (get_plugins p)

  let get = foreign "lilv_plugins_get" (plugins @-> iterator @-> returning plugin)
  let get ((p,i):plugins_iterator) = Plugin.make (get_world p) (get (get_plugins p) i)

  let get_by_uri = foreign "lilv_plugins_get_by_uri" (plugins @-> node @-> returning plugin)
  let get_by_uri p uri = Plugin.make (get_world p) (get_by_uri (get_plugins p) (Node.uri (get_world p) uri))

  let next = foreign "lilv_plugins_next" (plugins @-> iterator @-> returning iterator)
  let next ((p,i):plugins_iterator) = p, next (get_plugins p) i

  let is_end = foreign "lilv_plugins_is_end" (plugins @-> iterator @-> returning bool)
  let is_end ((p,i):plugins_iterator) = is_end (get_plugins p) i

  let iter f p =
    let i = ref (iterate p) in
    while not (is_end !i) do
      f (get !i);
      i := next !i
    done

  let to_list p =
    let ans = ref [] in
    iter (fun p -> ans := p :: !ans) p;
    List.rev !ans

end

module State = struct
end

module World = struct
  type t = world

  let t = world

  let free = foreign "lilv_world_free" (t @-> returning void)

  let finalise w = Gc.finalise free w

  let load_all = foreign "lilv_world_load_all" (t @-> returning void)
  let load_all_fun = load_all

  let create = foreign "lilv_world_new" (void @-> returning t)
  let create ?(load_all=true) () =
    let w = create () in
    finalise w;
    if load_all then load_all_fun w;
    w

  let plugins = foreign "lilv_world_get_all_plugins"  (t @-> returning plugins)
  let plugins w = Plugins.make w (plugins w)
end
