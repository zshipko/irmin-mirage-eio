
module Mem = Irmin_mem.KV.Make(Irmin.Contents.String)

let gen_val n =
  String.make n (char_of_int (n mod 255))

let gen_key n =
  let v = gen_val n in
  [v; v; v]

let run ~info ~sleep ~clock branch n =
  let rec set_loop = function
    | 0 -> ()
    | n ->
      let k = gen_key n in
      let v = gen_val n in
      Mem.set_exn branch ~info k v;
      Eio.traceln "Set %d" n;
      Eio.Time.sleep clock sleep; 
      set_loop (n - 1)
  in
  let rec get_loop = function
    | 0 -> ()
    | n ->
      let k = gen_key n in
      let v = Mem.get branch k in
      Eio.traceln "Get %d %s" n v;
      Eio.Time.sleep clock sleep; 
      get_loop (n - 1)
  in
  set_loop n;
  get_loop n
  
