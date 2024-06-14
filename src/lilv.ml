include C.Functions

module Node = struct
  include Node

  let finalise n = Gc.finalise free n

  let finalised n = finalise n; n

  let uri w s = finalised (uri w s)

  let string w s = finalised (string w s)

  let int w s = finalised (int w s)

  let float w s = finalised (float w s)

  let bool w s = finalised (bool w s)
end

module Nodes = struct
  include Nodes

  let length p = length p

  let iterate p : nodes_iterator = (p, iterate p)

  let get ((p, i) : nodes_iterator) = get p i

  let next ((p, i) : nodes_iterator) = (p, next p i)

  let is_end ((p, i) : nodes_iterator) = is_end p i
      
  let iter f p =
    let i = ref (iterate p) in
    while not (is_end !i) do
      f (get !i);
      i := next !i
    done

  let to_list p : Node.t list =
    let ans = ref [] in
    iter (fun p -> ans := p :: !ans) p;
    List.rev !ans
end
