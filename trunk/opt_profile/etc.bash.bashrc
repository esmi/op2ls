# System-wide .bashrc file

# /etc/bashrc

# System wide functions and aliases
# Environment stuff goes in /etc/profile

# by default, we want this to get set.
# Even for non-interactive, non-login shells.
if [ `id -gn` = `id -un` -a `id -u` -gt 99 ]; then
	umask 002
else
	umask 022
fi

#echo bash.bashrc  $TERM
# are we an interactive shell?
if [ "$PS1" ]; then
    case $TERM in
	xterm*)
            #echo PROMPT_COMMAND
	    PROMPT_COMMAND='echo -ne "\033]0;${USER}@${HOSTNAME}: ${PWD}\007"'
	    ;;
	*)
	    ;;
    esac
#    [ "$PS1" = "\\s-\\v\\\$ " ] && PS1="[\u@\h \W]\\$ "
    [ "$PS1" = "\\s-\\v\\\$ " ] && PS1="[\u@\h \w]\\$ "

#PS1="\[\033]0;\w\007\033[32m\][\u@\h\[\033[33m\]\w\[\033[0m\]$ "
    
    if [ -z "$loginsh" ]; then # We're not a login shell
        for i in /etc/profile.d/*.sh; do
	    if [ -x $i ]; then
	        . $i
	    fi
	done
    fi
fi
echo $loginsh
unset loginsh
