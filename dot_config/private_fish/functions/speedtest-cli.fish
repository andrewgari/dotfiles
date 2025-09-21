function speedtest-cli
    if command -v fast &>/dev/null
        fast
    else if command -v speedtest-cli &>/dev/null
        speedtest-cli
    else
        curl -s https://raw.githubusercontent.com/sivel/speedtest-cli/master/speedtest.py | python -
    end
end