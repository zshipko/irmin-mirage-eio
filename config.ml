open Mirage

let main = main "Unikernel.Make" ~packages:[
  package "duration";
  package "lwt_eio";
  package "eio_unikraft";
  package ~sublibs:["mem"] "irmin";
] (stackv4v6 @-> job)

let stackv4v6 = generic_stackv4v6 default_network
(* let tcpv4v6 = tcpv4v6_of_stackv4v6 stackv4v6 *)

let () = register "hello" [ main $ stackv4v6  ]
