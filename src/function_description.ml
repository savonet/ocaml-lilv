open Ctypes

(* This Types_generated module is an instantiation of the Types functor defined
   in the type_description.ml file. *)
module Types = Types_generated

module Functions (F : Ctypes.FOREIGN) = struct
  open F

  module LV2 = struct
    type handle = unit ptr

    let handle : handle typ = ptr void

    type descriptor

    let descriptor : descriptor structure typ = structure "LV2_Descriptor"
    let descriptor_uri = field descriptor "URI" string

    (* let descriptor_instantiate = field descriptor "instantiate" (funptr (ptr descriptor @-> double @-> string @-> ptr void @-> returning handle)) *)

    (* let descriptor_connect_port = field descriptor "instantiate" (funptr (handle @-> uint32_t @-> ptr void @-> returning void)) *)

    (* let descriptor_activate = field descriptor "activate" (funptr (handle @-> returning void)) *)

    (* let descriptor_run = field descriptor "run" (funptr (handle @-> uint32_t @-> returning void)) *)

    (* let descriptor_deactivate = field descriptor "deactivate" (funptr (handle @-> returning void)) *)

    (* let descriptor_cleanup = field descriptor "cleanup" (funptr (handle @-> returning void)) *)

    (* let descriptor_extension_data = field descriptor "extension_data" (funptr (string @-> returning (ptr void))) *)

    (* let () = *)
      (* ignore descriptor_uri; *)
      (* ignore descriptor_instantiate; *)
      (* ignore descriptor_cleanup; *)
      (* ignore descriptor_extension_data; *)
      (* seal descriptor *)

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

  type world = unit ptr

  let world : world typ = ptr void

  type plugin = unit ptr

  let plugin : plugin typ = ptr void
  let plugin_opt : plugin option typ = ptr_opt void

  type instance_impl

  let instance_impl : instance_impl structure typ = structure "LilvInstanceImpl"

  let instance_impl_descriptor = field instance_impl "lv2_descriptor" (ptr LV2.descriptor)

  let instance_impl_handle = field instance_impl "lv2_handle" LV2.handle
  let instance_impl_pimpl = field instance_impl "pimpl" (ptr void)

  let () =
    ignore instance_impl_pimpl;
    seal instance_impl

  type instance = instance_impl structure ptr

  let instance : instance typ = ptr instance_impl

  type plugins = unit ptr

  let plugins : plugins typ = ptr void

  type port = unit ptr

  let port : port typ = ptr void

  type plugin_class = unit ptr

  let plugin_class : plugin_class typ = ptr void

  type node = unit ptr

  let node : node typ = ptr void
  let node_opt : node option typ = ptr_opt void

  type nodes = unit ptr

  let nodes : nodes typ = ptr void

  type iterator = unit ptr

  let iterator : iterator typ = ptr void

  module Node = struct
    type t = node

    let null : t = from_voidp void null
    let free = foreign "lilv_node_free" (node @-> returning void)
    let equals = foreign "lilv_node_equals" (node @-> node @-> returning bool)
    let is_uri = foreign "lilv_node_is_uri" (node @-> returning bool)
    let to_uri = foreign "lilv_node_as_uri" (node @-> returning string)
    let uri = foreign "lilv_new_uri" (world @-> string @-> returning node)
    let is_blank = foreign "lilv_node_is_blank" (node @-> returning bool)
    let to_blank = foreign "lilv_node_as_blank" (node @-> returning string)
    let is_string = foreign "lilv_node_is_string" (node @-> returning bool)
    let to_string = foreign "lilv_node_as_string" (node @-> returning string)
    let string = foreign "lilv_new_string" (world @-> string @-> returning node)
    let is_int = foreign "lilv_node_is_int" (node @-> returning bool)
    let to_int = foreign "lilv_node_as_int" (node @-> returning int)
    let int = foreign "lilv_new_int" (world @-> int @-> returning node)
    let is_float = foreign "lilv_node_is_float" (node @-> returning bool)
    let to_float = foreign "lilv_node_as_float" (node @-> returning float)
    let float = foreign "lilv_new_float" (world @-> float @-> returning node)
    let is_bool = foreign "lilv_node_is_bool" (node @-> returning bool)
    let bool = foreign "lilv_new_bool" (world @-> bool @-> returning node)
  end

  module Nodes = struct
    type t = nodes
    type nodes_iterator = t * iterator

    let length = foreign "lilv_nodes_size" (nodes @-> returning int)
    let iterate = foreign "lilv_nodes_begin" (nodes @-> returning iterator)
    let get = foreign "lilv_nodes_get" (nodes @-> iterator @-> returning plugin)
    let next = foreign "lilv_nodes_next" (nodes @-> iterator @-> returning iterator)
    let is_end = foreign "lilv_nodes_is_end" (nodes @-> iterator @-> returning bool)
  end

  module Port = struct
    type t = (world * plugin) * port

    let make plugin port : t = (plugin, port)
    let get_world (p : t) = fst (fst p)
    let get_plugin (p : t) = snd (fst p)
    let get_port (p : t) = snd p

    let is_a = foreign "lilv_port_is_a" (plugin @-> port @-> node @-> returning bool)
    let has_property = foreign "lilv_port_has_property" (plugin @-> port @-> node @-> returning bool)
    let index = foreign "lilv_port_get_index" (plugin @-> port @-> returning uint32_t)
    let symbol = foreign "lilv_port_get_symbol" (plugin @-> port @-> returning node)
    let name = foreign "lilv_port_get_name" (plugin @-> port @-> returning node)
    let range = foreign "lilv_port_get_range" (plugin @-> port @-> ptr node @-> ptr node @-> ptr node @-> returning void)
  end

  module Plugin = struct
    type t = world * plugin

    let make w p : t = (w, p)
    let get_world (p : t) = fst p
    let get_plugin (p : t) = snd p
    let uri = foreign "lilv_plugin_get_uri" (plugin @-> returning node)
    let name = foreign "lilv_plugin_get_name" (plugin @-> returning node)
    let author_name = foreign "lilv_plugin_get_author_name" (plugin @-> returning node_opt)
    let author_email = foreign "lilv_plugin_get_author_email" (plugin @-> returning node_opt)
    let author_homepage = foreign "lilv_plugin_get_author_homepage" (plugin @-> returning node_opt)

    module Class = struct
      type t = plugin_class

      let label = foreign "lilv_plugin_class_get_label" (plugin_class @-> returning node)
    end

    let plugin_class = foreign "lilv_plugin_get_class" (plugin @-> returning plugin_class)
    let supported_features = foreign "lilv_plugin_get_supported_features" (plugin @-> returning nodes)
    let required_features = foreign "lilv_plugin_get_required_features" (plugin @-> returning nodes)
    let optional_features = foreign "lilv_plugin_get_optional_features" (plugin @-> returning nodes)
    let num_ports = foreign "lilv_plugin_get_num_ports" (plugin @-> returning int32_t)
    let is_replaced = foreign "lilv_plugin_is_replaced" (plugin @-> returning bool)
    let port_by_index = foreign "lilv_plugin_get_port_by_index" (plugin @-> int32_t @-> returning port)
    let port_by_symbol = foreign "lilv_plugin_get_port_by_symbol" (plugin @-> node @-> returning port)
    let has_latency = foreign "lilv_plugin_has_latency" (plugin @-> returning bool)
    let latency_port_index = foreign "lilv_plugin_get_latency_port_index" (plugin @-> returning int32_t)

    module Instance = struct
      type t = instance

      let free = foreign "lilv_instance_free" (instance @-> returning void)

      let descriptor (i : t) = getf !@i instance_impl_descriptor
      let handle (i : t) = getf !@i instance_impl_handle
    end

    let instantiate = foreign "lilv_plugin_instantiate" (plugin @-> double @-> ptr void @-> returning instance)
  end

    (*
module Plugins = struct
  type t = world * plugins
  type plugins_iterator = t * iterator

  let make world plugins : t = (world, plugins)
  let get_world (p : t) = fst p
  let get_plugins (p : t) = snd p
  let length = foreign "lilv_plugins_size" (plugins @-> returning int)
  let length p = length (get_plugins p)
  let iterate = foreign "lilv_plugins_begin" (plugins @-> returning iterator)
  let iterate p : plugins_iterator = (p, iterate (get_plugins p))

  let get =
    foreign "lilv_plugins_get" (plugins @-> iterator @-> returning plugin)

  let get ((p, i) : plugins_iterator) =
    Plugin.make (get_world p) (get (get_plugins p) i)

  let get_by_uri =
    foreign "lilv_plugins_get_by_uri" (plugins @-> node @-> returning plugin_opt)

  let get_by_uri p uri =
    match get_by_uri (get_plugins p) (Node.uri (get_world p) uri) with
      | Some plugin -> Plugin.make (get_world p) plugin
      | None -> raise Not_found

  let next =
    foreign "lilv_plugins_next" (plugins @-> iterator @-> returning iterator)

  let next ((p, i) : plugins_iterator) = (p, next (get_plugins p) i)

  let is_end =
    foreign "lilv_plugins_is_end" (plugins @-> iterator @-> returning bool)

  let is_end ((p, i) : plugins_iterator) = is_end (get_plugins p) i

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

module State = struct end

module World = struct
  type t = world

  let t = world
  let free = foreign "lilv_world_free" (t @-> returning void)
  let create = foreign "lilv_world_new" (void @-> returning t)

  let create () =
    let w = create () in
    Gc.finalise free w;
    w

  let load_all = foreign "lilv_world_load_all" (t @-> returning void)
  let plugins = foreign "lilv_world_get_all_plugins" (t @-> returning plugins)
  let plugins w = Plugins.make w (plugins w)
end
     *)
end
