open Ctypes

module Def (F : Cstubs.FOREIGN) = struct
  include Lilv_types.Def(Lilv_generated_types)

  open F

  module Node = struct
    let free = foreign "lilv_node_free" (node @-> returning void)
  end
end
