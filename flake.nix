{
  description = "Configuración de NixOS";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs = { self, nixpkgs, ... }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs { inherit system; };
    in {
      packages.${system}.default = pkgs.writeShellScriptBin "bootstrap-nixos" ''
        set -e  # Salir si hay un error

        DOTFILES_DIR="$HOME/.dotfiles"

        # Clonar el repositorio si no existe
        if [ ! -d "$DOTFILES_DIR" ]; then
          echo "Clonando dotfiles en $DOTFILES_DIR..."
          git clone https://github.com/migueel15/dotfiles.git "$DOTFILES_DIR"
        else
          echo "El repositorio de dotfiles ya existe, actualizando..."
          cd "$DOTFILES_DIR"
          git pull
        fi

        cd "$DOTFILES_DIR"

        echo "Actualizando dependencias del flake..."
        nix flake update

        echo "Generando configuración de hardware..."
        sudo nixos-generate-config --force

        echo "Sobrescribiendo configuration.nix con la configuración de flake..."
        sudo cp "$DOTFILES_DIR/configuration.nix" /etc/nixos/

        echo "Aplicando la configuración..."
        sudo nixos-rebuild switch --flake "$DOTFILES_DIR"

        echo "Sistema listo con la configuración de dotfiles."
      '';
    };
}
