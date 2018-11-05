# -*- mode: shell-script -*-
#
# Shell functions to act as wrapper for Kenneth Reitz's pipenv
# (http://pypi.python.org/pypi/pipenv)
#
# PipenvWrappper by Pablo Vázquez Rodríguez is heavily based on 
# modifications and cherrypicking of Doug Hellmann's virtualenvwrapper
# methods
#
# ## PIPENVWRAPPER COPYRIGHT AND DISCLAIMER ###################################
# # Copyright 2018 Pablo Vázquez Rodríguez
# #
# # Permission is hereby granted, free of charge, to any person obtaining a copy
# # of this software and associated documentation files (the "Software"), to
# # deal in the Software without restriction, including without limitation the
# # rights to use, copy, modify, merge, publish, distribute, sublicense, and/or
# # sell copies of the Software, and to permit persons to whom the Software is
# # furnished to do so, subject to the following conditions:
# #
# # The above copyright notice and this permission notice shall be included in
# # all copies or substantial portions of the Software.
# #
# # THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# # IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# # FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# # AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# # LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
# # FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
# # IN THE SOFTWARE.
# #
# # https://github.com/Peibolvig/pipenvwrapper
# #############################################################################
# 
#
# ## VIRTUALENVWRAPPER COPYRIGHT AND DISCLAIMER ###############################
# # Copyright Doug Hellmann, All Rights Reserved
# #
# # Permission to use, copy, modify, and distribute this software and its
# # documentation for any purpose and without fee is hereby granted,
# # provided that the above copyright notice appear in all copies and that
# # both that copyright notice and this permission notice appear in
# # supporting documentation, and that the name of Doug Hellmann not be used
# # in advertising or publicity pertaining to distribution of the software
# # without specific, written prior permission.
# #
# # DOUG HELLMANN DISCLAIMS ALL WARRANTIES WITH REGARD TO THIS SOFTWARE,
# # INCLUDING ALL IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS, IN NO
# # EVENT SHALL DOUG HELLMANN BE LIABLE FOR ANY SPECIAL, INDIRECT OR
# # CONSEQUENTIAL DAMAGES OR ANY DAMAGES WHATSOEVER RESULTING FROM LOSS OF
# # USE, DATA OR PROFITS, WHETHER IN AN ACTION OF CONTRACT, NEGLIGENCE OR
# # OTHER TORTIOUS ACTION, ARISING OUT OF OR IN CONNECTION WITH THE USE OR
# # PERFORMANCE OF THIS SOFTWARE.
# #
# # http://www.doughellmann.com/projects/virtualenvwrapper/
# #############################################################################
#

# CUSTOM VARIABLES
# ****************
# VIRTUALENVWRAPPER-LIKE VARIABLES
# If virtualenvwrapper ones are set, respect them
PIPENVWRAPPER_WORKON_HOME=~/.virtualenvs
PIPENVWRAPPER_PROJECT_FILENAME=".project"
PIPENVWRAPPER_ENV_BIN_DIR="bin"

if [[ -z "${WORKON_HOME}" ]]; then
    export WORKON_HOME=$PIPENVWRAPPER_WORKON_HOME
fi

if [[ -z "${VIRTUALENVWRAPPER_PROJECT_FILENAME}" ]]; then
    export VIRTUALENVWRAPPER_PROJECT_FILENAME=$PIPENVWRAPPER_PROJECT_FILENAME
fi

if [[ -z "${VIRTUALENVWRAPPER_ENV_BIN_DIR}" ]]; then
    export VIRTUALENVWRAPPER_ENV_BIN_DIR=$PIPENVWRAPPER_ENV_BIN_DIR
fi

# NOTE: Function names are changed to allow coexistence of pipenvwrapper
# along virtualenvwrapper.
# To replace the virtualenvwrapper original functions for the ones defined
# pipenvwrapper, BEFORE the source of this script, set the
# PIPENVWRAPPER_USE_VIRTUALENVWRAPPER_FUNCTION_NAMES environment variable to "true"
# (or anything else)
if [[ -z "${PIPENVWRAPPER_USE_VIRTUALENVWRAPPER_FUNCTION_NAMES}" ]]; then
    # Strings for help texts
    pipenv_fn_useenv="useenv"
    pipenv_fn_gotositepackages="gotositepackages"
    pipenv_fn_gotovirtualenv="gotovirtualenv"
    pipenv_fn_gotoproject="gotoproject"
    pipenv_fn_listvirtualenvs="listvirtualenvs"
    pipenv_fn_makeproject="makeproject"
    pipenv_fn_removevirtualenv="removevirtualenv"
else
    alias workon=useenv
    alias cdsitepackages=gotositepackages
    alias cdvirtualenv=gotovirtualenv
    alias cdproject=gotoproject
    alias lsvirtualenv=listvirtualenvs
    alias mkproject=makeproject
    alias rmvirtualenv=removevirtualenv
    # Strings for help texts
    pipenv_fn_useenv="workon"
    pipenv_fn_gotositepackages="cdsitepackages"
    pipenv_fn_gotovirtualenv="cdvirtualenv"
    pipenv_fn_gotoproject="cdproject"
    pipenv_fn_listvirtualenvs="lsvirtualenv"
    pipenv_fn_makeproject="mkproject"
    pipenv_fn_removevirtualenv="rmvirtualenv"
fi

# Remember where we are running from.
if [ -z "${PIPENVWRAPPER_SCRIPT:-}" ]
then
    if [ -n "$BASH" ]
    then
        export PIPENVWRAPPER_SCRIPT="$BASH_SOURCE"
    elif [ -n "$ZSH_VERSION" ]
    then
        export PIPENVWRAPPER_SCRIPT="$0"
    else
        export PIPENVWRAPPER_SCRIPT="${.sh.file}"
    fi
fi

# Portable shell scripting is hard, let's go shopping.
#
# People insist on aliasing commands like 'cd', either with a real
# alias or even a shell function. Under bash and zsh, "builtin" forces
# the use of a command that is part of the shell itself instead of an
# alias, function, or external command, while "command" does something
# similar but allows external commands. Under ksh "builtin" registers
# a new command from a shared library, but "command" will pick up
# existing builtin commands. We need to use a builtin for cd because
# we are trying to change the state of the current shell, so we use
# "builtin" for bash and zsh but "command" under ksh.
function _pipenvwrapper_cd {
    if [ -n "$BASH" ]
    then
        builtin \cd "$@"
    elif [ -n "$ZSH_VERSION" ]
    then
        builtin \cd -q "$@"
    else
        command \cd "$@"
    fi
}

# Verify that the active environment exists
function _pipenvwrapper_verify_active_environment {
    if [ ! -n "${VIRTUAL_ENV}" ] || [ ! -d "${VIRTUAL_ENV}" ]
    then
        echo "ERROR: no virtualenv active, or active virtualenv is missing" >&2
        return 1
    fi
    return 0
}

# Verify that the active environment exists
function _pipenvwrapper_verify_outside_any_environment {
    if [ ! -n "${VIRTUAL_ENV}" ] || [ ! -d "${VIRTUAL_ENV}" ]
    then
        return 0
    fi
    echo "ERROR: You are inside an active virtual environment. Type 'exit' or Ctrl+D to exit and try again." >&2
    return 1
}

function _pipenvwrapper_verify_workon_home {
    RC=0
    if [ ! -d "$WORKON_HOME/" ]
    then
        if [ "$1" != "-q" ]
        then
            echo "NOTE: Virtual environments directory $WORKON_HOME does not exist. Creating..." 1>&2
        fi
        mkdir -p "$WORKON_HOME"
        RC=$?
    fi
    return $RC
}

# Prints the path to the site-packages directory for the current environment.
function _pipenvwrapper_get_site_packages_dir {
    "$VIRTUAL_ENV/$VIRTUALENVWRAPPER_ENV_BIN_DIR/python" -c "import distutils; print(distutils.sysconfig.get_python_lib())"
}

# Does a ``cd`` to the site-packages directory of the currently-active
# virtualenv.
#:help:gotositepackages [cdsitepackages]: change to the site-packages directory
function gotositepackages {
    _pipenvwrapper_verify_workon_home || return 1
    _pipenvwrapper_verify_active_environment || return 1
    typeset site_packages="`_pipenvwrapper_get_site_packages_dir`"
    _pipenvwrapper_cd "$site_packages/$1"
}

# Does a ``cd`` to the root of the currently-active virtualenv.
#:help:gotovirtualenv [cdvirtualenv]: change to the $VIRTUAL_ENV directory
function gotovirtualenv {
    _pipenvwrapper_verify_workon_home || return 1
    _pipenvwrapper_verify_active_environment || return 1
    _pipenvwrapper_cd "$VIRTUAL_ENV/$1"
}

#########################################################################

# Show help for workon
function __pipenv_gotoproject_help {
    echo "Usage: $pipenv_fn_gotoproject [env_name]"
    echo ""
    echo "           Change directory to the active project or to"
    echo "           the provided env_name project"
    echo ""
    echo "       $pipenv_fn_gotoproject (-h|--help)"
    echo ""
    echo "           Show this help message."
    echo ""
}

#:help:gotoproject [cdproject]: change directory to the active or provided project
function gotoproject {
    typeset -a in_args
    typeset -a out_args

    in_args=( "$@" )

    if [ -n "$ZSH_VERSION" ]
    then
        i=1
        tst="-le"
    else
        i=0
        tst="-lt"
    fi
    typeset cd_after_activate=1  # Enter into project directory on useenv
    while [ $i $tst $# ]
    do
        a="${in_args[$i]}"
        case "$a" in
            -h|--help)
                __pipenv_gotoproject_help;
                return 0;;
            *)
                if [ ${#out_args} -gt 0 ]
                then
                    out_args=( "${out_args[@]-}" "$a" )
                else
                    out_args=( "$a" )
                fi;;
        esac
        i=$(( $i + 1 ))
    done

    set -- "${out_args[@]}"

    _pipenvwrapper_verify_workon_home || return 1
    typeset env_name="$1"
    if [ "$env_name" = "" ]
    then
        # Project name not provided
        if [ ! -n "${VIRTUAL_ENV}" ] || [ ! -d "${VIRTUAL_ENV}" ]
        then
            # Virtualenv not active
            listvirtualenvs
            return 1
        else
            # Virtualenv IS active
            if [ -f "$VIRTUAL_ENV/$VIRTUALENVWRAPPER_PROJECT_FILENAME" ]
            then
                typeset project_dir="$(cat "$VIRTUAL_ENV/$VIRTUALENVWRAPPER_PROJECT_FILENAME")"
                if [ ! -z "$project_dir" ]
                then
                    _pipenvwrapper_cd "$project_dir"
                else
                    echo "Project directory $project_dir does not exist" 1>&2
                    return 1
                fi
            else
                echo "No project set in $VIRTUAL_ENV/$VIRTUALENVWRAPPER_PROJECT_FILENAME" 1>&2
                return 1
            fi
            return 0
        fi
    else
        # Virtualenv not active but provided
        _pipenvwrapper_verify_useenv_environment "$env_name" || return 1
        typeset project_dir=$(cat $WORKON_HOME/$env_name/$VIRTUALENVWRAPPER_PROJECT_FILENAME)
        _pipenvwrapper_verify_useenv_project "$project_dir" || return 1
        _pipenvwrapper_cd "$project_dir"
    fi
    return 0
}


##########################################################################
# List the available environments.
function _pipenvwrapper_show_workon_options {
    _pipenvwrapper_verify_workon_home || return 1
    # NOTE: DO NOT use ls or cd here because colorized versions spew control 
    #       characters into the output list.
    # echo seems a little faster than find, even with -depth 3.
    # Note that this is a little tricky, as there may be spaces in the path.
    #
    # 1. Look for environments by finding the activate scripts.
    #    Use a subshell so we can suppress the message printed
    #    by zsh if the glob pattern fails to match any files.
    #    This yields a single, space-separated line containing all matches.
    # 2. Replace the trailing newline with a space, so every
    #    possible env has a space following it.
    # 3. Strip the bindir/activate script suffix, replacing it with
    #    a slash, as that is an illegal character in a directory name.
    #    This yields a slash-separated list of possible env names.
    # 4. Replace each slash with a newline to show the output one name per line.
    # 5. Eliminate any lines with * on them because that means there 
    #    were no envs.
    (_pipenvwrapper_cd "$WORKON_HOME" && echo */$VIRTUALENVWRAPPER_ENV_BIN_DIR/activate) 2>/dev/null \
        | command \tr "\n" " " \
        | command \sed "s|/$VIRTUALENVWRAPPER_ENV_BIN_DIR/activate |/|g" \
        | command \tr "/" "\n" \
        | command \sed "/^\s*$/d" \
        | (unset GREP_OPTIONS; command \egrep -v '^\*$') 2>/dev/null
}

function _pipenv_lsvirtualenv_usage {
    echo "$pipenv_fn_listvirtualenvs [-h]"
    echo "  -h -- this help message"
}

#:help:listvirtualenvs [lsvirtualenv]: list virtualenvs
function listvirtualenvs {

    if command -v "getopts" &> /dev/null
    then
        # Use getopts when possible
        OPTIND=1
        while getopts ":h" opt "$@"
        do
            case "$opt" in
                h)  _pipenv_lsvirtualenv_usage;
                    return 1;;
                ?) echo "Invalid option: -$OPTARG" >&2;
                    _pipenv_lsvirtualenv_usage;
                    return 1;;
            esac
        done
    else
        # fallback on getopt for other shell
        typeset -a args
        args=($(getopt h "$@"))
        if [ $? != 0 ]
        then
            _pipenv_lsvirtualenv_usage
            return 1
        fi
        for opt in $args
        do
            case "$opt" in
                -h) _pipenv_lsvirtualenv_usage;
                    return 1;;
            esac
        done
    fi

    _pipenvwrapper_show_workon_options
}

# Verify that the PROJECT_HOME directory exists
function _pipenvwrapper_verify_project_home {
    if [ -z "$PROJECT_HOME" ]
    then
        echo "ERROR: Set the PROJECT_HOME shell variable to the name of the directory where projects should be created." >&2
        return 1
    fi
    if [ ! -d "$PROJECT_HOME" ]
    then
        [ "$1" != "-q" ] && echo "ERROR: Project directory '$PROJECT_HOME' does not exist.  Create it or set PROJECT_HOME to an existing directory." >&2
        return 1
    fi
    return 0
}

# Show help for mkproject
function __pipenvwrapper_mkproject_help {
    echo "Usage: $pipenv_fn_makeproject [-p|--python] project_name"
    echo
    echo "-p, --python   Specify which installed version of python to use "
    echo "               in the new env. e.g: --python 3.7"
    echo
}

#:help:makeproject [mkproject]: create a new project and its associated virtualenv in $PROJECT_HOME
function makeproject {
    _pipenvwrapper_verify_outside_any_environment || return 1

    typeset -a in_args
    typeset -a out_args
    typeset -i i
    typeset tst
    typeset a

    in_args=( "$@" )

    if [ $# = 0 ]
    then
        __pipenvwrapper_mkproject_help
        return 1
    fi

    if [ -n "$ZSH_VERSION" ]
    then
        i=1
        tst="-le"
    else
        i=0
        tst="-lt"
    fi

    while [ $i $tst $# ]
    do
        a="${in_args[$i]}"
        case "$a" in
            -p|--python)
                i=$(( $i + 1 ));
                python_version="${in_args[$i]}";;
            -h|--help)
                __pipenvwrapper_mkproject_help;
                return;;
            *)
                if [ ${#out_args} -gt 0 ]
                then
                    out_args=( "${out_args[@]-}" "$a" )
                else
                    out_args=( "$a" )
                fi;;

        esac
        i=$(( $i + 1 ))
    done
    if [ ${#out_args} -le 0 ]
    then
        echo "You must provide a name for the project"
        return 1
    fi

    set -- "${out_args[@]}"

    eval "typeset envname=\$$#"

    _pipenvwrapper_verify_project_home || return 1

    if [ -d "$PROJECT_HOME/$envname" ]
    then
        echo "Project $envname already exists." >&2
        return 1
    fi

    _pipenvwrapper_cd "$PROJECT_HOME"
    printf "Creating $PROJECT_HOME/$envname ..."
    mkdir -p "$PROJECT_HOME/$envname"
    _pipenvwrapper_cd "$PROJECT_HOME/$envname"

    if [ -n $python_version ]
    then
        echo $python_version > ".python-version"
        pipenv --python $python_version
    else
        pipenv --three
    fi
    pipenv shell
}

#:help:removevirtualenv [rmvirtualenv]: Remove a virtualenv
function removevirtualenv {
    _pipenvwrapper_verify_workon_home || return 1
    if [ ${#@} = 0 ]
    then
        echo "Please specify an environment." >&2
        return 1
    fi

    # support to remove several environments
    typeset env_name
    # Must quote the parameters, as environments could have spaces in their names
    for env_name in "$@"
    do
        printf "Removing $env_name... "
        typeset env_dir="$WORKON_HOME/$env_name"
        if [ "$VIRTUAL_ENV" = "$env_dir" ]
        then
            echo "ERROR: You cannot remove the active environment ('$env_name')." >&2
            echo "Either switch to another environment or exit the current one." >&2
            return 1
        fi

        if [ ! -d "$env_dir" ]; then
            echo "Did not find environment $env_dir to remove." >&2
            return 1
        fi

        # Move out of the current directory to one known to be
        # safe, in case we are inside the environment somewhere.
        typeset prior_dir="$(pwd)"
        _pipenvwrapper_cd "$WORKON_HOME"

        command \rm -rf "$env_dir"

        # If the directory we used to be in still exists, move back to it.
        if [ -d "$prior_dir" ]
        then
            _pipenvwrapper_cd "$prior_dir"
        fi
        printf "Ok\n"
    done
}

# Verify that the requested environment exists
function _pipenvwrapper_verify_useenv_environment {
    typeset env_name="$1"
    if [ ! -d "$WORKON_HOME/$env_name" ]
    then
       echo "ERROR: Environment '$env_name' does not exist." >&2
       return 1
    fi
    return 0
}

function _pipenvwrapper_verify_useenv_project {
    typeset workon_project_dir="$1"
    if [ ! -d "$workon_project_dir" ]
    then
       echo "ERROR: Project dir '$workon_project_dir' for the environment '$env_name' does not exist." >&2
       return 1
    fi
    return 0
}

# Show help for workon
function __pipenv_useenv_help {
    echo "Usage: $pipenv_fn_useenv env_name"
    echo ""
    echo "           Deactivate any currently activated virtualenv"
    echo "           or activate the named environment"
    echo ""
    echo "       $pipenv_fn_useenv"
    echo ""
    echo "           Print a list of available environments."
    echo ""
    echo "       $pipenv_fn_useenv (-h|--help)"
    echo ""
    echo "           Show this help message."
    echo ""
}

#:help:useenv [workon]: list or use virtualenvs
function useenv {
    typeset -a in_args
    typeset -a out_args

    in_args=( "$@" )

    if [ -n "$ZSH_VERSION" ]
    then
        i=1
        tst="-le"
    else
        i=0
        tst="-lt"
    fi
    typeset cd_after_activate=1  # Enter into project directory on useenv
    while [ $i $tst $# ]
    do
        a="${in_args[$i]}"
        case "$a" in
            -h|--help)
                __pipenv_useenv_help;
                return 0;;
            *)
                if [ ${#out_args} -gt 0 ]
                then
                    out_args=( "${out_args[@]-}" "$a" )
                else
                    out_args=( "$a" )
                fi;;
        esac
        i=$(( $i + 1 ))
    done

    set -- "${out_args[@]}"

    typeset env_name="$1"
    if [ "$env_name" = "" ]
    then
        listvirtualenvs
        return 1
    elif [ "$env_name" = "." ]
    then
        # The IFS default of breaking on whitespace causes issues if there
        # are spaces in the env_name, so change it.
        IFS='%'
        env_name="$(basename $(pwd))"
        unset IFS
    fi

    _pipenvwrapper_verify_workon_home || return 1
    _pipenvwrapper_verify_useenv_environment "$env_name" || return 1
    useenv_project_dir=$(cat $WORKON_HOME/$env_name/$VIRTUALENVWRAPPER_PROJECT_FILENAME)
    _pipenvwrapper_verify_useenv_project "$useenv_project_dir" || return 1
    

    # Deactivate any current environment "destructively"
    # before switching to the new environment
    PARENT_OF_SHELL=$(ps -p `ps h -p $$ -o ppid` -o comm=)
    if [ "$PIPENV_ACTIVE" = "1" ] && [ "$PARENT_OF_SHELL" = "pipenv" ]
    then
        echo ""
        echo "You were inside a virtualenv so we deactivated it."
        echo "To activate $env_name, please type '$pipenv_fn_useenv $env_name' again."
        echo ""
        SHELL_TO_KILL=$(ps -p `ps h -p $$ -o ppid` -o pid=)
        kill -9 $SHELL_TO_KILL
    fi

    # Activate selected virtual environment
    _pipenvwrapper_cd $useenv_project_dir
    if [ $? -eq 0 ]
    then
       # If virtualenv has no Pipfile ask user to create one or abort
       if [ ! -f "$useenv_project_dir/Pipfile" ]; then
           echo ""
           echo "The project associated with the $env_name environment was not
           created with pipenv or has no Pipfile in project folder."
           read -p "Would you like to create a pipenv environment for the project
           that is in folder $useenv_project_dir ? [y/N]: " choice
           case "$choice" in
               y|Y ) ;;
               n|N|* )
                   echo "Operation aborted"
                   return 0 ;;
           esac
       fi
       pipenv shell
       return 0
    else
       return 1
    fi

}

#:help:getrequirements: Echoes the list of all the requirements (including dev ones) in a pip freeze way
function getrequirements {
    if [ ! -f "./Pipfile" ] || [ ! -f "./Pipfile.lock" ]
    then
        echo "No Pipfile present in the current dir."
        echo "If retry after using cdproject command to go to the desired project dir."
    else
        { pipenv lock -r 2>/dev/null & pipenv lock -d -r 2>/dev/null; } | grep -v '\-i https://pypi.org/simple' | sort | uniq | sed "1i\-i https://pypi.org/simple"
    fi
}

# Set up tab completion.  (Adapted from Arthur Koziel's version at
# http://arthurkoziel.com/2008/10/11/virtualenvwrapper-bash-completion/)
function _pipenvwrapper_setup_tab_completion {
    if [ -n "$BASH" ] ; then
        _virtualenvs () {
            local cur="${COMP_WORDS[COMP_CWORD]}"
            COMPREPLY=( $(compgen -W "`_pipenvwrapper_show_workon_options`" -- ${cur}) )
        }
        _gotovirtualenv_complete () {
            local cur="$2"
            COMPREPLY=( $(gotovirtualenv && compgen -d -- "${cur}" ) )
        }
        _gotositepackages_complete () {
            local cur="$2"
            COMPREPLY=( $(gotositepackages && compgen -d -- "${cur}" ) )
        }
        complete -o nospace -F _gotovirtualenv_complete -S/ gotovirtualenv
        complete -o nospace -F _gotositepackages_complete -S/ gotositepackages
        complete -o default -o nospace -F _virtualenvs useenv
        complete -o default -o nospace -F _virtualenvs workon
        complete -o default -o nospace -F _virtualenvs removevirtualenv
        complete -o default -o nospace -F _virtualenvs rmvirtualenv
        complete -o default -o nospace -F _virtualenvs gotoproject
        complete -o default -o nospace -F _virtualenvs cdproject
    elif [ -n "$ZSH_VERSION" ] ; then
        _virtualenvs () {
            reply=( $(_pipenvwrapper_show_workon_options) )
        }
        _gotovirtualenv_complete () {
            reply=( $(gotovirtualenv && ls -d ${1}*) )
        }
        _gotositepackages_complete () {
            reply=( $(gotositepackages && ls -d ${1}*) )
        }
        compctl -K _virtualenvs useenv workon removevirtualenv gotoproject cdproject #cpvirtualenv showvirtualenv
        compctl -K _gotovirtualenv_complete gotovirtualenv
        compctl -K _gotositepackages_complete gotositepackages
    fi
}

# Set up pipenvwrapper properly
function _pipenvwrapper_initialize {
    _pipenvwrapper_verify_workon_home -q || return 1
    _pipenvwrapper_setup_tab_completion
    return 0
}

#:help:pipenvwrapper: show this help message
function pipenvwrapper {
	cat <<EOF

pipenvwrapper is a set of extensions to Kenneth Reitz's pipenv tool.
The extensions include wrappers for working and deleting virtual
environments as in Doug Hellmann's virtualenvwrapper, in which
pipenvwrapper is heavily based.

Commands available:
(virtualenvwrapper equivalents in square brackets):

EOF

    typeset helpmarker="#:help:"
    cat  "$PIPENVWRAPPER_SCRIPT" \
        | grep "^$helpmarker" \
        | sed -e "s/^$helpmarker/  /g" \
        | sort \
        | sed -e 's/$/\'$'\n/g'
}

#
# Invoke the initialization functions
#
_pipenvwrapper_initialize
