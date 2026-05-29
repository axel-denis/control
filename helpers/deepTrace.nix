{ lib }:

with lib;
{
  deepTrace = o: trace (builtins.deepSeq o o) o;
}
