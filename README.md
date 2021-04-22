# work env

Using home-manager without the need to install it (annoying on MacOS) and ensures a pinned environment.

# Prerequisites

You must have [nix](https://nixos.org) installed on your machine.
```sh
curl -L https://nixos.org/nix/install | sh
```

# Tutorial

1. Update dependencies (home-manager and nixpkgs) to the latest version:

   ```sh
   ./update-dependencies.sh
   ```
2. Run the switch script to switch to your configuration:

    ```sh
    ./switch.sh
    ```