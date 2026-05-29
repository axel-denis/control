{ lib }:

with lib;
let
  alreadyPresentInList = i: l: (lists.findFirstIndex (e: e == i) (-1) l) >= 0;
in
{
  dedup = l: foldl (acc: v: acc ++ (if (alreadyPresentInList v acc) then [ ] else [ v ])) [ ] l;
}
