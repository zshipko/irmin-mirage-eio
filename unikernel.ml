open Cmdliner

let now clock = Eio.Time.now clock |> Int64.of_float

let n =
  let doc = Arg.info ~doc:"Number of iterations" [ "n" ] in
  Mirage_runtime.register_arg Arg.(value & opt int 10000 doc)

let sleep =
  let doc = Arg.info ~doc:"Sleep time, in milliseconds" [ "sleep" ] in
  Mirage_runtime.register_arg Arg.(value & opt float 0.001 doc)


module Make(Stack : Tcpip.Stack.V4V6) = struct
  module Tcp = Stack.TCP

  let info env () =
    Irmin.Info.Default.v ~author:"test" ~message:"test" (now env#clock)
  
  let start stack =
    let _tcp = Stack.tcp stack in
    Eio_unikraft.run @@ fun env ->
    Eio.Switch.run @@ fun _ ->
    let info = info env in 
    let repo = Bench.Mem.Repo.v (Irmin_mem.config ()) in
    let main = Bench.Mem.main repo in
    Bench.run ~info ~sleep:(sleep ()) ~clock:env#clock main (n ());
    Lwt.return_unit
end
