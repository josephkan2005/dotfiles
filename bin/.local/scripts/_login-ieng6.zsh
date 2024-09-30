#compdef login-ieng6

_login-ieng6() {
    _arguments -C "1:first arg:($IENG6_MODULES)"
}

_login-ieng6 "$@"
