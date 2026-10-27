{
  description = "Stable Channels Android development shell";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    android-nixpkgs = {
      url = "github:tadfisher/android-nixpkgs/stable";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { nixpkgs, android-nixpkgs, ... }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs { inherit system; };

      androidSdk = android-nixpkgs.sdk.${system} (sdk: with sdk; [
        cmdline-tools-latest
        platform-tools
        build-tools-35-0-0
        platforms-android-36
      ]);
    in
    {
      devShells.${system}.default = pkgs.mkShell {
        packages = [
          pkgs.jdk17
          androidSdk
        ];

        # The SDK lives in a read-only store path; Gradle reads this location.
        env.ANDROID_HOME = "${androidSdk}/share/android-sdk";

        # Keep each phone listed once in `adb devices`; blocks mDNS auto-connect.
        env.ADB_MDNS_AUTO_CONNECT = "0";
      };
    };
}
