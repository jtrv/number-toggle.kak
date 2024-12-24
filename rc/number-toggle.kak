provide-module number-toggle %{
declare-option -docstring 'Line number highlighter parameters' str-list number_toggle_params
declare-option -hidden str number_toggle_state
declare-option -hidden bool number_toggle_enabled false

define-command -hidden number-toggle-refresh %{ evaluate-commands %sh{
  echo "add-highlighter -override window/number-toggle number-lines $kak_opt_number_toggle_params $kak_opt_number_toggle_state"
}}

define-command -hidden number-toggle-install-focus-hooks %{
  hook -group number-toggle-focus window FocusOut .* %{
    set-option window number_toggle_state ''
    number-toggle-refresh
  }
  hook -group number-toggle-focus window FocusIn .* %{
    set-option window number_toggle_state '-relative'
    number-toggle-refresh
  }
}

define-command -hidden number-toggle-uninstall-focus-hooks %{
  remove-hooks window number-toggle-focus
}

define-command number-toggle-enable %{
  set-option window number_toggle_enabled true
  set-option window number_toggle_state '-relative'
  number-toggle-refresh
  number-toggle-install-focus-hooks

  # Display absolute line numbers when entering insert mode
  hook -group number-toggle-modechange -always window ModeChange push:.*:insert %{
    set-option window number_toggle_state ''
    number-toggle-refresh
    number-toggle-uninstall-focus-hooks
  }

  # Display relative line numbers when leaving insert mode
  hook -group number-toggle-modechange -always window ModeChange pop:insert:.* %{
    set-option window number_toggle_state '-relative'
    number-toggle-refresh
    number-toggle-install-focus-hooks
  }
}

define-command number-toggle-disable %{
  set-option window number_toggle_state ''
	remove-hooks window number-toggle-*
  remove-highlighter window/number-toggle
  set-option window number_toggle_enabled false
}

define-command number-toggle-toggle %{ evaluate-commands %sh{
  if [ "$kak_opt_number_toggle_enabled" = "true" ]; then
    echo "number-toggle-disable"
  else
    echo "number-toggle-enable"
  fi
}}

}
