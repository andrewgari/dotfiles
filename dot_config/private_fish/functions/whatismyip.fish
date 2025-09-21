function whatismyip
    echo "Public IP: (curl -s ifconfig.me)"
    echo "Local IP: (hostname -I | awk '{print $1}')"
end