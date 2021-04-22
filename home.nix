{ pkgs, ... }:

let

  plugins = import ./vim-config/plugins.nix {
    inherit (pkgs) vimUtils fetchFromGitHub;
  };
  my_nvim = pkgs.neovim.override {
    vimAlias = true;
    configure = {
      customRC = builtins.readFile ./vim-config/vim.config;
      plug.plugins = with pkgs.vimPlugins; [
        fzfWrapper
        fzf-vim
        nerdtree
        vim-airline
        vim-tmux-clipboard
        vim-surround
        vim-nerdtree-tabs
        nerdcommenter
        gruvbox
        vim-easymotion
        vim-nix
        nnn-vim
        vim-polyglot
        # vim-tmux-navigator
      ];
    };
  };

  # Not using nvim 0.5.0 for due to lack of support in the current nixpkgs stable
  # Fetch neovim nightly from nix community and wrap it manually:
  # my_nvim = pkgs.wrapNeovim pkgs.neovim-nightly {
  #   vimAlias = false;
  #   configure = {
  #     customRC = ''
  #       set history=500
  #     '';
  #     plug.plugins = with pkgs.vimPlugins; [
  #       fzfWrapper
  #       fzf-vim
  #       vim-airline
  #       # REQUIRES NEOVIM 0.5
  #       barbar-nvim
  #       nvim-web-devicons
  #       nvim-tree-lua
  #       nvim-compe
  #       nvim-treesitter
  #     ];
  #   };
  # };

in {

  home.username = "yubi";
  home.homeDirectory = "/Users/yubi";

  home.stateVersion = "20.09";

  programs.bash = { enable = true; };
  programs.fish = {
    enable = true;
    interactiveShellInit = ''
          set -g fish_greeting
          # set -g theme_color_scheme nord
          # set -g theme_display_user ssh
          # set -g theme_show_exit_status yes
        function n --wraps nnn --description 'support nnn quit and change directory'
          # Block nesting of nnn in subshells
          if test -n "$NNNLVL"
              if [ (expr $NNNLVL + 0) -ge 1 ]
                  echo "nnn is already running"
                  return
              end
          end

          # The default behaviour is to cd on quit (nnn checks if NNN_TMPFILE is set)
          # To cd on quit only on ^G, remove the "-x" as in:
          #    set NNN_TMPFILE "$XDG_CONFIG_HOME/nnn/.lastd"
          # NOTE: NNN_TMPFILE is fixed, should not be modified
          if test -n "$XDG_CONFIG_HOME"
              set -x NNN_TMPFILE "$XDG_CONFIG_HOME/nnn/.lastd"
          else
              set -x NNN_TMPFILE "$HOME/.config/nnn/.lastd"
          end

          # Unmask ^Q (, ^V etc.) (if required, see `stty -a`) to Quit nnn
          # stty start undef
          # stty stop undef
          # stty lwrap undef
          # stty lnext undef

          nnn $argv

          if test -e $NNN_TMPFILE
              source $NNN_TMPFILE
              rm $NNN_TMPFILE
          end
      end
        '';
    plugins = [{
      name = "agnoster";
      src = pkgs.fetchFromGitHub {
        owner = "oh-my-fish";
        repo = "theme-agnoster";
        rev = "43860ce1536930bca689470e26083b0a5b7bd6ae";
        sha256 = "16k94hz3s6wayass6g1lhlcjmbpf2w8mzx90qrrqp120h80xwp25";
      };
    }];
  };

  # nixpkgs.overlays = [
  #   (import (builtins.fetchTarball {
  #     url =
  #       "https://github.com/nix-community/neovim-nightly-overlay/archive/master.tar.gz";
  #   }))
  # ];

  programs.starship = {
    enable = true;
    enableFishIntegration = false;
    settings = {
      directory = {
        truncate_to_repo = false;
        fish_style_pwd_dir_length = 1;
      };
      aws = { disabled = true; };
    };
  };

  programs.git = {
    package = pkgs.gitAndTools.gitFull;
    enable = true;
    userEmail = "stefandeml@gmail.com";
    userName = "Stefan Deml";
    extraConfig = { core = { editor = "nvim"; }; };
  };

  programs.zoxide.enable = true;
  programs.zoxide.enableFishIntegration = true;

  programs.tmux = {
    enable = true;
    terminal = "xterm-256color";
    plugins = with pkgs; [
      tmuxPlugins.tmux-fzf
      tmuxPlugins.yank
      tmuxPlugins.extrakto
      {
        plugin = tmuxPlugins.resurrect;
        # set -g @resurrect-strategy-nvim 'session'
        extraConfig = ''
          set -g @resurrect-save 'S'
          set -g @resurrect-restore 'R'
        '';
      }
      {
        plugin = tmuxPlugins.continuum;
        extraConfig = ''
          set -g @continuum-restore 'on'
          set -g @continuum-save-interval '60' # minutes
        '';
      }
    ];
    extraConfig = builtins.readFile ./tmux-config/tmux.config;
  };

  home.packages = with pkgs; [
    fzf
    bat
    nnn
    tig
    my_nvim

    jq
    tree
    niv

    # fd
    # gitui
    # ack
    # nox
    # patchelf
    # bandwhich
    # grex # generating regular expressions from user-provided test
    # procs
    # bottom
    # zip
    # unzip
    # ripgrep
    # wget
    # curl

    # tree-sitter
    # nushell

  ];

}
