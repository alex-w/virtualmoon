#!/bin/bash

function dopng {
  # $1 input svg dir
  # $2 output png dir
  # $3 icon size

  mkdir -p $2
  end=${#iconlist[@]}
  ((end--))
  for i  in $(seq 0 $end)
    do
         fsvg=$1/${iconlist[i]}.svg
         fpng=$2/${iconlist[i]}.png
         inkscape -w $3 -h $3 -o $fpng $fsvg > /dev/null 2>&1
         if [[ $? != 0 ]] 
            then  echo Error:  $i ${iconlist[i]}
         fi
    done 
}


iconlist=(i0 i1 i2 i3 i4 i5 i6 i7 i8 i9 i10 i11 i12 i13 i14 i15 i16 i17 i18 i19 i20 i21 i22 i23 i24 i25 i26 i27 i28 i29 i30 i31 i32 i33 i34 i35 i36)


dopng svg/day/22 icons/day/22 22
dopng svg/night/22 icons/night/22 22

