#!/bin/bash

for file in *.nim
do
	fname="$(echo $file | cut -d'.' -f1)"
	nim c --deadcodeElim:on -d:release --app:lib -o:"$fname".so $file
done
