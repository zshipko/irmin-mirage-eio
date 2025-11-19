type stdenv =
  < clock : float Eio.Time.clock_ty Eio.Time.clock
  ; mono : Mtime.t Eio.Time.clock_ty Eio.Time.Mono.t >

module Fiber_context = Eio.Private.Fiber_context
module Zzz = Eio_utils.Zzz

module Mono_clock = struct
  type t = unit
  type time = Mtime.t

  let now () = Time.now ()

  let sleep_until () time =
    Sched.enter @@ fun t k ->
    match Fiber_context.get_error k.fiber with
    | Some e -> Eio_utils.Suspended.discontinue k e
    | None ->
        let node = Zzz.add t.sleep_q time (Fiber k) in
        Fiber_context.set_cancel_fn k.fiber (fun ex ->
            Zzz.remove t.sleep_q node;
            Eio_utils.Lf_queue.push t.run_q (Failed_thread (k, ex)));
        Sched.schedule t
end

let mono : Mtime.t Eio.Time.clock_ty Eio.Resource.t =
  let handler = Eio.Time.Pi.clock (module Mono_clock) in
  Eio.Resource.T ((), handler)

module Clock = struct
  type t = unit
  type time = float

  let now () =
    (Time.now () |> Mtime.to_uint64_ns |> Int64.to_float) /. 1_000_000_000.

  let sleep_until () time =
    let time = Int64.of_float (time *. 1_000_000_000.) |> Mtime.of_uint64_ns in
    Sched.enter @@ fun t k ->
    match Fiber_context.get_error k.fiber with
    | Some e -> Eio_utils.Suspended.discontinue k e
    | None ->
        let node = Zzz.add t.sleep_q time (Fiber k) in
        Fiber_context.set_cancel_fn k.fiber (fun ex ->
            Zzz.remove t.sleep_q node;
            Eio_utils.Lf_queue.push t.run_q (Failed_thread (k, ex)));
        Sched.schedule t
end

let clock : float Eio.Time.clock_ty Eio.Resource.t =
  let handler = Eio.Time.Pi.clock (module Clock) in
  Eio.Resource.T ((), handler)

let stdenv : stdenv =
  object
    method clock = clock
    method mono = mono

    (* method netif devname = *)
    (* let result, handle, ni = Netif.solo5_net_acquire devname in *)
    (* match result with *)
    (* | SOLO5_R_OK -> Netif.flow devname handle ni *)
    (* | SOLO5_R_AGAIN -> failwith "unexpected response from solo5" *)
    (* | SOLO5_R_EINVAL -> *)
    (* failwith (Fmt.str "Netif: connect(%s): Invalid argument" devname) *)
    (* | SOLO5_R_EUNSPEC -> *)
    (* failwith (Fmt.str "Netif: connect(%s): Unspecified error" devname) *)
  end

let run fn = Sched.run @@ fun () -> fn stdenv
