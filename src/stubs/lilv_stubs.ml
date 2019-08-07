open Ctypes

module Def (F : Cstubs.FOREIGN) = struct
  open F

  let core_uri = foreign "ocaml_lv2_core_uri" (void @-> returning string)
end
