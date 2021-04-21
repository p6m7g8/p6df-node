######################################################################
#<
#
# Function: p6df::modules::js::deps()
#
#>
######################################################################
p6df::modules::js::deps() {
  ModuleDeps=(
    p6m7g8/p6common
    nodenv/nodenv
    nodenv/node-build
    ohmyzsh/ohmyzsh:plugins/npm
    ohmyzsh/ohmyzsh:plugins/yarn
  )
}

######################################################################
#<
#
# Function: p6df::modules::js::vscodes()
#
#  Depends:	 p6_git
#>
######################################################################
p6df::modules::js::vscodes() {

  # webasm/ts/js/deno/node/html/css
  code --install-extension dbaeumer.vscode-eslint
  code --install-extension GregorBiswanger.json2ts

  code --install-extension dkundel.vscode-npm-source
  code --install-extension meganrogge.template-string-converter
  code --install-extension BriteSnow.vscode-toggle-quotes
  code --install-extension steoates.autoimport
  code --install-extension wix.glean
  code --install-extension wix.vscode-import-cost
  code --install-extension dsznajder.es7-react-js-snippets

  code --install-extension bradgashler.htmltagwrap
  code --install-extension formulahendry.auto-close-tag
  code --install-extension formulahendry.auto-rename-tag

  code --install-extension ecmel.vscode-html-css
  code --install-extension ourhaouta.tailwindshades
  code --install-extension bradlc.vscode-tailwindcss
  code --install-extension PeterMekhaeil.vscode-tailwindcss-explorer
  code --install-extension sudoaugustin.tailwindcss-transpiler
}

######################################################################
#<
#
# Function: p6df::modules::js::home::symlink()
#
#  Depends:	 p6_git
#  Environment:	 P6_DFZ_SRC_DIR
#>
######################################################################
p6df::modules::js::home::symlink() {

  mkdir -p $P6_DFZ_SRC_DIR/nodenv/nodenv/plugins
  ln -fs $P6_DFZ_SRC_DIR/nodenv/node-build $P6_DFZ_SRC_DIR/nodenv/nodenv/plugins/node-build
}

######################################################################
#<
#
# Function: p6df::modules::js::langs()
#
#  Depends:	 p6_git
#  Environment:	 P6_DFZ_SRC_DIR
#>
######################################################################
p6df::modules::js::langs() {

  # update both
  (
    cd $P6_DFZ_SRC_DIR/nodenv/node-build
    p6_git_p6_pull
  )
  (
    cd $P6_DFZ_SRC_DIR/nodenv/nodenv
    p6_git_p6_pull
  )

  local ver_major
  for ver_major in 10 11 12 13 14 15; do
    # nuke the old one
    local previous=$(nodenv install -l | grep ^$ver_major | tail -2 | head -1)
    nodenv uninstall -f $previous

    # get the shiny one
    local latest=$(nodenv install -l | grep ^$ver_major | tail -1)

    nodenv install -s $latest
    nodenv global $latest
    nodenv rehash

    npm install -g yarn lerna
    nodenv rehash
  done
}

######################################################################
#<
#
# Function: p6df::modules::js::aliases::lerna()
#
#>
######################################################################
p6df::modules::js::aliases::lerna() {

  # runs an npm script via lerna for a the current module
  alias lr='lerna run --stream --scope $(node -p "require(\"./package.json\").name")'

  # runs "npm run build" (build + test) for the current module
  alias lb='lr build'
  alias lt='lr test'

  # runs "npm run watch" for the current module (recommended to run in a separate terminal session)
  alias lw='lr watch'
}

######################################################################
#<
#
# Function: p6df::modules::js::aliases::yarn()
#
#>
######################################################################
p6df::modules::js::aliases::yarn() {

  alias yd='yarn deploy'
  alias yD='yarn destroy'
}

######################################################################
#<
#
# Function: p6df::modules::js::init()
#
#  Depends:	 p6_echo
#  Environment:	 P6_DFZ_SRC_DIR
#>
######################################################################
p6df::modules::js::init() {

  p6df::modules::js::aliases::lerna
  p6df::modules::js::aliases::yarn
  p6df::modules::js::nodenv::init "$P6_DFZ_SRC_DIR"
}

######################################################################
#<
#
# Function: p6df::modules::js::nodenv::init(dir)
#
#  Args:
#	dir -
#
#  Depends:	 p6_echo
#  Environment:	 DISABLE_ENVS HAS_NODENV NODENV_ROOT
#>
######################################################################
p6df::modules::js::nodenv::init() {
  local dir="$1"

  [ -n "$DISABLE_ENVS" ] && return

  NODENV_ROOT=$dir/nodenv/nodenv

  if [ -x $NODENV_ROOT/bin/nodenv ]; then
    export NODENV_ROOT
    export HAS_NODENV=1

    p6df::util::path_if $NODENV_ROOT/bin
    eval "$(nodenv init - zsh)"
  fi
}

######################################################################
#<
#
# Function: p6df::modules::js::nodenv::prompt::line()
#
#  Depends:	 p6_echo
#  Environment:	 NODENV_ROOT
#>
######################################################################
p6df::modules::js::nodenv::prompt::line() {

  p6_echo "nodenv:\t  nodenv_root=$NODENV_ROOT"
}

######################################################################
#<
#
# Function: p6df::modules::js::prompt::line()
#
#  Depends:	 p6_echo p6_node
#>
######################################################################
p6df::modules::js::prompt::line() {

  p6_node_prompt_info
}

declare -g _p6_node_cache_prompt_version
######################################################################
#<
#
# Function: p6_node_prompt_info()
#
#  Depends:	 p6_echo p6_file p6_node p6_string
#>
######################################################################
p6_node_prompt_info() {

  if p6_string_blank "$_p6_node_cache_prompt_version"; then
    _p6_node_cache_prompt_version=$(p6_lang_version "node")
  fi
  p6_echo "node:\t  ${_p6_node_cache_prompt_version}"
}

######################################################################
#<
#
# Function: p6_node_prompt_reset()
#
#  Depends:	 p6_file
#>
######################################################################
p6_node_prompt_reset() {

  _p6_node_cache_prompt_version=""
}

######################################################################
#<
#
# Function: true  = p6_js_yarn_is()
#
#  Returns:
#	true - 
#	false - 
#
#  Depends:	 p6_file
#>
######################################################################
p6_js_yarn_is() {

  if p6_file_exists "yarn.lock"; then
    p6_return_true
  else
    p6_return_false
  fi
}

######################################################################
#<
#
# Function: true  = p6_js_npm_is()
#
#  Returns:
#	true - 
#	false - 
#
#  Depends:	 p6_file p6_git
#>
######################################################################
p6_js_npm_is() {

  if p6_file_exists "pack-lock.json"; then
    p6_return_true
  else
    p6_return_false
  fi
}

######################################################################
#<
#
# Function: p6_js_yarn_upgrade()
#
#  Depends:	 p6_git
#>
######################################################################
p6_js_yarn_upgrade() {

  yarn upgrade
}

######################################################################
#<
#
# Function: p6_js_yarn_submit()
#
#  Depends:	 p6_git p6_github
#>
######################################################################
p6_js_yarn_submit() {

  p6_git_p6_add_all
  p6_github_gh_pr_submit "chore(deps): yarn upgrade"
}
