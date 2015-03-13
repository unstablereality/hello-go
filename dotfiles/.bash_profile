[[ -s "$HOME/.profile" ]] && source "$HOME/.profile" # Load the default .profile

[[ -s "$HOME/.rvm/scripts/rvm" ]] && source "$HOME/.rvm/scripts/rvm" # Load RVM into a shell session *as a function*
FCEDIT=/usr/bin/vi

DIR_STACK=""
export DIR_STACK

getNdirs ()
{
  stackfront=''
  let count=0
  while [ $count -le $1 ]; do
    target=${DIR_STACK%${DIR_STACK#* }}
    stackfront="$stackfront$target"
    DIR_STACK=${DIR_STACK#$target}
    let count=count+1
  done

  stackfront=${stackfront%$target}
}

pushd ()
{
  if [ $(echo $1 | grep '^+[0-9][0-9]*$') ]; then

    # case of pushd +n: rotate n-th directory to top
    let num=${1#+}
    getNdirs $num

    DIR_STACK="$target$stackfront$DIR_STACK"
    cd $target
    echo "$DIR_STACK"
   elif [ -z "$1" ]; then
     #case of pusd without args; swap top two directories
     firstdir=${DIR_STACK%% *}
     DIR_STACK=${DIRSTACK#* }
     seconddir=${DIR_STACK%% *}
     DIR_STACK=${DIR_STACK#* }
     DIR_STACK="$seconddir $firstdir $DIR_STACK"
     cd $seconddir

   else
     # normal case of pushd dirname

     dirname=$1
     if [ \( -d $dirname\) -a \( -x $dirname \) ]; then
       DIR_STACK="$dirname ${DIR_STACK:-$PWD" "}"
       cd $dirname
       echo "$DIR_STACK"
     else
       echo still in "$PWD."
     fi
   fi
 }

popd ()
{
  if [ $(echo $1 | grep '^+[0-9][0-9]*$') ]; then
 
    #case of popd +n: delete n-th directory from stack
    let num=${1#+}
    getNdirs $num
    DIR_STACK="$stackfront$DIR_STACK"
    cd ${DIR_STACK%% *}
    echo "$PWD"
 
  else
 
    #normal case of popd without argument
    if [ -n "$DIR_STACK" ]; then
      DIR_STACK=${DIR_STACK#* }
      cd ${DIR_STACK%% *}
      echo "$PWD"
    else
      echo "stack empty, still in $PWD."
    fi
  fi
}

makecmd ()
{
  read target colon sources
  for src in $sources; do
    if [ $src -nt $target ]; then
      while read cmd && [ $(grep \t* $cmd) ]; do
        echo "$cmd"
        eval ${cmd#\t}
      done
      break
    fi
  done
}

