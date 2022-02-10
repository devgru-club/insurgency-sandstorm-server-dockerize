#!/bin/bash
docker stop sandstorm-modmap
docker rm sandstorm-modmap
# docker pull devgru.club's autobuild and autoupdate optimized docker here
docker pull andrewmhub/insurgency-sandstorm
docker run -d --restart always --env-file /home/user/coop-modmap/modmap.env \
  --name sandstorm-modmap --net=host \
  -v /home/user/coop-modmap/Mods:/home/steam/steamcmd/sandstorm/Insurgency/Mods:rw \
  -v /home/user/coop-modmap/config/ini:/home/steam/steamcmd/sandstorm/Insurgency/Saved/Config/LinuxServer:ro \
  -v /home/user/coop-modmap/config/txt:/home/steam/steamcmd/sandstorm/Insurgency/Config/Server:ro andrewmhub/insurgency-sandstorm:latest # need to pull autobuild here after testing as well
