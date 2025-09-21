function dprune
    echo "Pruning containers, networks, and images..."
    docker system prune -a -f
    echo "Pruning volumes..."
    docker volume prune -f
    echo "Docker system cleaned!"
end