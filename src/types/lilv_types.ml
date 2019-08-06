module Def (S : Cstubs.Types.TYPE) = struct
  open Ctypes_static
  open S

  type node = unit ptr
  let node : node typ = ptr void
  let node_opt : node option typ = ptr_opt void
end
