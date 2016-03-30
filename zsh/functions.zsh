####################
# functions
####################

twiki () {
    rake db:migrate && rake db:migrate:redo && rake db:test:prepare
}

# set a timer for the given amount of time, where the time is specified by:
# seconds - xs, e.g. 10s for 10 seconds
# minutes - xm, e.g. 3m for 3 minutes
#   hours - xh, e.g. 24h for 24 hours
#    days - xd, e.g. 8d for 8 days
# Or you can use a combination of these, e.g. 2h 30m to get 2 hours and
# 30 minutes.
function timer() {
    (sleep "$@" && osascript -e 'tell app "System Events" to display dialog "Boom!"') 2>&1 >/dev/null &
    echo "timer set for $@."
}

# print available colors and their numbers
function colours() {
    for i in {0..255}; do
        printf "\x1b[38;5;${i}m colour${i}"
        if (( $i % 5 == 0 )); then
            printf "\n"
        else
            printf "\t"
        fi
    done
}

# Create a new directory and enter it
function md() {
    mkdir -p "$@" && cd "$@"
}


# find shorthand
function f() {
    find . -name "$1"
}


# jump to and vim the directory
function jive() {
    j "$1"
    vi .
}


# Start an HTTP server from a directory, optionally specifying the port
function server() {
    local port="${1:-8000}"
    open "http://localhost:${port}/"
    # Set the default Content-Type to `text/plain` instead of `application/octet-stream`
    # And serve everything as UTF-8 (although not technically correct, this doesn’t break anything for binary files)
    python -c $'import SimpleHTTPServer;\nmap = SimpleHTTPServer.SimpleHTTPRequestHandler.extensions_map;\nmap[""] = "text/plain";\nfor key, value in map.items():\n\tmap[key] = value + ";charset=UTF-8";\nSimpleHTTPServer.test();' "$port"
}

# git log with per-commit cmd-clickable GitHub URLs (iTerm)
# function gf() {
#   local remote="$(git remote -v | awk '/^origin.*\(push\)$/ {print $2}')"
#   [[ "$remote" ]] || return
#   local user_repo="$(echo "$remote" | perl -pe 's/.*://;s/\.git$//')"
#   git log $* --name-status --color | awk "$(cat <<AWK
#     /^.*commit [0-9a-f]{40}/ {sha=substr(\$2,1,7)}
#     /^[MA]\t/ {printf "%s\thttps://github.com/$user_repo/blob/%s/%s\n", \$1, sha, \$2; next}
#     /.*/ {print \$0}
# AWK
#   )" | less -F
# }

# take this repo and copy it to somewhere else minus the .git stuff.
function gitexport(){
    mkdir -p "$1"
    git archive master | tar -x -C "$1"
}

# get gzipped size
function gz() {
    echo "orig size    (bytes): "
    cat "$1" | wc -c
    echo "gzipped size (bytes): "
    gzip -c "$1" | wc -c
}

# All the dig info
function digga() {
    dig +nocmd "$1" any +multiline +noall +answer
}

# Escape UTF-8 characters into their 3-byte format
function escape() {
    printf "\\\x%s" $(printf "$@" | xxd -p -c1 -u)
    echo # newline
}

# Decode \x{ABCD}-style Unicode escape sequences
function unidecode() {
    perl -e "binmode(STDOUT, ':utf8'); print \"$@\""
    echo # newline
}

# Extract archives - use: extract <file>
# Credits to http://dotfiles.org/~pseup/.bashrc
function extract() {
    if [ -f $1 ] ; then
        case $1 in
            *.tar.bz2) tar xjf $1 ;;
            *.tar.gz) tar xzf $1 ;;
            *.bz2) bunzip2 $1 ;;
            *.rar) rar x $1 ;;
            *.gz) gunzip $1 ;;
            *.tar) tar xf $1 ;;
            *.tbz2) tar xjf $1 ;;
            *.tgz) tar xzf $1 ;;
            *.zip) unzip $1 ;;
            *.Z) uncompress $1 ;;
            *.7z) 7z x $1 ;;
            *) echo "'$1' cannot be extracted via extract()" ;;
        esac
    else
        echo "'$1' is not a valid file"
    fi
}

# Quick markdown to pdf function
function md2pdf() {
    pdffilename=${1/\.md/\.pdf}
    pandoc -s -o $pdffilename $1
}

# Quick tex to pdf function
function tex2pdf() {
    pdffilename=${1/\.tex/\.pdf}
    pandoc -s -o $pdffilename $1
}
