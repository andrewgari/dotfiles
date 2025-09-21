function dsh
    docker exec -it "$argv[1]" /bin/bash; or docker exec -it "$argv[1]" /bin/sh
end