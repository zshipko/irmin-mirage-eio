open Lwt.Infix

module Mem = Irmin_mem.KV.Make(Irmin.Contents.String)

let now env = Eio.Time.now env#clock |> Int64.of_float

let start () =
  Eio_unikraft.run @@ fun env ->
  let repo = Mem.Repo.v (Irmin_mem.config ()) in
  let main = Mem.main repo in
  let info () =
    Irmin.Info.Default.v ~author:"test" ~message:"test" (now env)
  in
  let () = Mem.set_exn main ~info ["greeting"] "Hello from Irmin!" in
  let rec loop = function
    | 0 -> Lwt.return_unit
    | n ->
        Logs.info (fun f -> f "%s" (Mem.get main ["greeting"]));
        Eio.Time.sleep env#clock 1.0;
        loop (n - 1)
  in
  loop 4
