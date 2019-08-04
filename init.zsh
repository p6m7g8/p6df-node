p6df::modules::node::version() { echo "0.0.1" }
p6df::modules::node::deps()    { ModuleDeps=(nodenv/nodenv nodenv/node-build)  }

#p6df::modules::node::external::brew() { }

p6df::modules::node::home::symlink() { 

  mkdir -p $P6_DFZ_SRC_DIR/nodenv/nodenv/plugins
  ln -fs $P6_DFZ_SRC_DIR/nodenv/node-build $P6_DFZ_SRC_DIR/nodenv/nodenv/plugins/node-build
}

p6df::modules::node::langs() {

  nodenv install 12.7.0
  nodenv global 12.7.0
  nodenv rehash
}

p6df::modules::node::init() {

  p6df::modules::node::nodenv::init "$P6_DFZ_SRC_DIR"
}

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

p6df::prompt::node::line() {

  p6_lang_version "node"
}
