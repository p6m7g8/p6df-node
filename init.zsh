######################################################################
#<
#
# Function: p6df::modules::node::deps()
#
#>
######################################################################
p6df::modules::node::deps() {
  ModuleDeps=(
    p6m7g8/p6common
    nodenv/nodenv
    nodenv/node-build
    ohmyzsh/ohmyzsh:plugins/npm
    ohmyzsh/ohmyzsh:plugins/yarn
  )
}

#p6df::modules::node::external::brew() { }

######################################################################
#<
#
# Function: p6df::modules::node::home::symlink()
#
#>
######################################################################
p6df::modules::node::home::symlink() {

  mkdir -p $P6_DFZ_SRC_DIR/nodenv/nodenv/plugins
  ln -fs $P6_DFZ_SRC_DIR/nodenv/node-build $P6_DFZ_SRC_DIR/nodenv/nodenv/plugins/node-build
}

######################################################################
#<
#
# Function: p6df::modules::node::langs()
#
#>
######################################################################
p6df::modules::node::langs() {

  # update both
  (
    cd $P6_DFZ_SRC_DIR/nodenv/node-build
    git pull
  )
  (
    cd $P6_DFZ_SRC_DIR/nodenv/nodenv
    git pull
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
    npm install -g yarn
    nodenv rehash
  done
}

######################################################################
#<
#
# Function: p6df::modules::node::aliases::lerna()
#
#>
######################################################################
p6df::modules::node::aliases::lerna() {

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
# Function: p6df::modules::node::aliases::yarn()
#
#>
######################################################################
p6df::modules::node::aliases::yarn() {

  alias yd='yarn deploy'
  alias yD='yarn destroy'
}

######################################################################
#<
#
# Function: p6df::modules::node::init()
#
#>
######################################################################
p6df::modules::node::init() {
  
  p6df::modules::node::aliases::lerna
  p6df::modules::node::aliases::yarn
  p6df::modules::node::nodenv::init "$P6_DFZ_SRC_DIR"
}

######################################################################
#<
#
# Function: p6df::modules::node::nodenv::init(dir)
#
#  Args:
#	dir -
#
#>
######################################################################
p6df::modules::node::nodenv::init() {
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
# Function: p6df::modules::node::nodenv::prompt::line()
#
#>
######################################################################
p6df::modules::node::nodenv::prompt::line() {

  p6_echo "nodenv:\t  nodenv_root=$NODENV_ROOT"
}

######################################################################
#<
#
# Function: p6df::modules::node::prompt::line()
#
#>
######################################################################
p6df::modules::node::prompt::line() {

  p6_node_prompt_info
}

declare -g _p6_node_cache_prompt_version
######################################################################
#<
#
# Function: p6_node_prompt_info()
#
#>
######################################################################
p6_node_prompt_info() {

  if p6_string_blank "$_p6_node_cache_prompt_version"; then
    _p6_node_cache_prompt_version=$(p6_lang_version "node")
  fi
  echo "node:\t  ${_p6_node_cache_prompt_version}"
}

######################################################################
#<
#
# Function: p6_node_prompt_reset()
#
#>
######################################################################
p6_node_prompt_reset() {

  _p6_node_cache_prompt_version=""
}
