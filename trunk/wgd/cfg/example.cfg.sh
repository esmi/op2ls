cat cfg/$1 | egrep '(#|=)' | sed 's/=.*$/=/g' > example.cfg
