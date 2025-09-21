function genpass
    set -l length (count $argv) > 0 and echo $argv[1] or echo 20
    openssl rand -base64 48 | cut -c1-$length
end