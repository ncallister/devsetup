

addApp()
{
  APPVAR="$1"

  eval "ALL_APPS[\"\${$APPVAR["name"]}\"]=\"$APPVAR\""
}

declare -A APPDATA_FIREFOX=(["name"]="FireFox" ["package"]="firefox")
addApp APPDATA_FIREFOX

declare -A APPDATA_NODEJS=(["name"]="Node.JS" ["package"]="nodejs" ["repo"]="ppa:chris-lea/node.js")
addApp APPDATA_NODEJS

declare -A APPDATA_GIT=(["name"]="Git" ["package"]="nodejs" ["repo"]="ppa:chris-lea/node.js")
addApp APPDATA_NODEJS
