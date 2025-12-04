qemu-system-aarch64 \
  -nodefaults \
  -nographic \
  -kernel dist/hello.qemu \
  -machine virt \
  -serial stdio \
  -cpu cortex-a53 \
  -net nic -net user
  # -netdev tap,id=net0,ifname=tap0,script=no,downscript=no -device e1000,netdev=net0,mac=52:55:00:d1:55:01
