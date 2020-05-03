#!/bin/bash

for d in *.dot
do
  #cat ${d}.dot sudo podman container run --rm -i vladgolubev/dot2png > ../docs/images/dns.
  file=$(printf '%s\n' "${d%.dot}")

  cat ${file}.dot | sudo podman container run --rm -i vladgolubev/dot2png > ../docs/images/${file}.png

done
