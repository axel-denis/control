{ lib }:

{
  /* Automates the creation of an inherited option like :
     dbPath = mkOption {
       type = types.path;
       default = cfg.mainPath + "/db";
       defaultText = ''mainPath + "/db"'';
       description = "Path for database (default to `mainPath`/db)";
     };
  */
  mkInheritedPathOption = { parentName, parent, defaultSubpath, description }:
    lib.mkOption {
      type = lib.types.path;
      default = parent + "/${defaultSubpath}";
      defaultText = ''${parentName} + "/${defaultSubpath}"'';
      description =
        ''${parentName} (default to ${parentName} + "/${defaultSubpath}")'';
    };
}
