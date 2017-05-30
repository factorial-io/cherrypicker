#!/bin/sh

## Logging helper.
source ./bslog/bslog.sh


# start at c34b9d47a77a1dea708a1b42fa21d8b900163d54

COMMITS_FILE_PATH="$1"
DIR_PATH="$2"
SKIP_TILL_COMMIT="$3"
SKIP_COMMIT=true


if [ -z "$1" ]; then
  BSLOG "ERROR" "Missing arguments"

  BSLOG "INFO" "Arguments accepted are
    arg1 (required) : File path containing list of commits
    arg2 (required) : Directory path to git repo
    arg3 (optional) : Commit has in the list, until which processing would be skipped.

    Please supply the required arguments and try again."

  exit;
fi

if [ -z "$2" ]; then
  BSLOG "ERROR" "Missing second argument"
  BSLOG "INFO" "Arguments accepted are
    arg1 (required) : File path containing list of commits
    arg2 (required) : Directory path to git repo
    arg3 (optional) : Commit has in the list, until which processing would be skipped."

  BSLOG "INFO" "Please supply the required arguments and try again."
  exit;
fi

if [ -z "$3" ]; then
  SKIP_COMMIT=false
fi

## load the commits array for processing.
source $COMMITS_FILE_PATH
cd $DIR_PATH;

BSLOG "DEBUG" "Will skip till commit hash : $SKIP_TILL_COMMIT"
BSLOG "DEBUG" "Directory argument         : $DIR_PATH"
BSLOG "DEBUG" "Executing in directory     : $(pwd)"



## helper functions

## main processing loop
for i in "${commits[@]}"
  do
    if [ "$SKIP_COMMIT" = true ] ; then
      BSLOG "INFO" "Skipping commit $i"
      if [ "$i" = "$SKIP_TILL_COMMIT" ]; then
        SKIP_COMMIT=false
      fi
      continue;
    fi
    BSLOG "INFO" "::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::";
    BSLOG "INFO" "Processing commit          : $i"

    git cherry-pick $i -x
    git_command_exit_code=$?
    if [[ "$git_command_exit_code" == "0" ]]; then
      BSLOG "DEBUG" "Cherry pick completed successfully."
      continue;
    fi
    BSLOG "DEBUG" "Cherry pick encountered an error. Exit code $git_command_exit_code"
    while true; do

      read -p "Please choose an action to continue:
      c: continue
      q: quit and proceed to cherry pick next commit
      a: abort (exits)
      p: proceed to next commit
      - " yn

      ## @todo Use function call for each case and perform better logging.

      case $yn in
        [Cc]* ) git cherry-pick --continue;;
        [Qq]* ) git cherry-pick --quit; break;;
        [Aa]* ) git cherry-pick --abort; exit;;
        [Pp]* ) break;;
        * ) echo "Please answer c/q/a/p.";;
      esac

    done
  done

BSLOG "SUCCESS" "All commits processesed, script will now exit."