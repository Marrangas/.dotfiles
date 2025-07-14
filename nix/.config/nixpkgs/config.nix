{
  experimental-features = [ "nix-command" "flakes" ];
  build-users-group = "nixbld";

  allowUnfree = true;
  allowUnfreePredicate = pkg:
    builtins.elem (builtins.parseDrvName pkg.name).name [
      "terraform"
    ];
}
