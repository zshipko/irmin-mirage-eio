open Mirage

let main = main "Unikernel" job ~packages:[ package "duration"; package "eio"; package ~sublibs:["mem"] "irmin"; package "eio-unikraft"; package "lwt_eio" ]
let () = register "hello" [ main ]
