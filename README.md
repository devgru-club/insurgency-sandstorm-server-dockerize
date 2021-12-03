## Insurgency: Sandstorm Docker Container
This image is based on https://github.com/AndrewMarchukov/insurgency-sandstorm-server-dockerize, but I changed ENTRYPOINT so you can use LAUNCH_SERVER_ENV to set map and traveloptions.

<p align="center">
  <img src="https://github.com/DanTheManSWE/insurgency-sandstorm-server-dockerize/blob/master/sandstorm-logo.png">
  <img src="https://github.com/DanTheManSWE/insurgency-sandstorm-server-dockerize/blob/master/docker-logo.png"
</p>
</p>



Readme shamelessly ripped from Andrew Marchukov.

This repository contains a docker image with a dedicated server for Insurgency Sandstorm that you can fully customize to your need for COOP and PVP servers.

Image is not built on a regular basis, but I'll try to keep it updated as long as I play the game.
#### Official documentation: [Sandstorm Server Admin Guide](https://sandstorm-support.newworldinteractive.com/hc/en-us/articles/360049211072-Server-Admin-Guide)
#### Another Server Admin Guide [Server Admin Guide by mod.io](https://insurgencysandstorm.mod.io/guides/server-admin-guide)
#### More config examples: [Configs by zWolfi](https://github.com/zWolfi/INS_Sandstorm)
#### ISMC Guide: [ISMCmod Installation Guide](https://insurgencysandstorm.mod.io/guides/ismcmod-installation-guide)

## How to build/get Insurgency Sandstorm dedicated server
cd directory where ```Dockerfile```
```docker build -t danthemanswe/insurgencysandstorm:latest .``` or get it on [docker hub](https://hub.docker.com/r/danthemanswe/insurgencysandstorm) ```docker pull danthemanswe/insurgencysandstorm```
## How to launch Insurgency Sandstorm dedicated server
Running multiple instances (use PORT, QUERYPORT and HOSTNAME) and LAUNCH_SERVER_ENV in [modmap.env](https://github.com/AndrewMarchukov/insurgency-sandstorm-server-dockerize/blob/master/modmap.env): 
```
docker run -d --restart always --env-file /home/user/Insurgency/modmap.env \
--name sandstorm-modmap --net=host \
-v /home/user/Insurgency/Mods:/home/steam/steamcmd/sandstorm/Insurgency/Mods:rw \
-v /home/user/Insurgency/Saved/Config/LinuxServer:/home/steam/steamcmd/sandstorm/Insurgency/Saved/Config/LinuxServer:ro \
-v /home/user/Insurgency/Config/Server:/home/steam/steamcmd/sandstorm/Insurgency/Config/Server:ro andrewmhub/insurgency-sandstorm:latest
```
Examples config files in directory [config](https://github.com/AndrewMarchukov/insurgency-sandstorm-server-dockerize/tree/master/config)

### docker-compose.yml example
```dockerfile
version: '3.7'
services:
  insurgency-sandstorm:
    image: danthemanswe/insurgencysandstorm:latest
    container_name: insurgency-sandstorm
    restart: unless-stopped
    env_file:
       - .env
    volumes:
      - ./Saved/Config/LinuxServer:/home/steam/steamcmd/sandstorm/Insurgency/Saved/Config/LinuxServer:rw
      - ./Config/Server:/home/steam/steamcmd/sandstorm/Insurgency/Config/Server:rw
      - ./Mods:/home/steam/steamcmd/sandstorm/Insurgency/Mods:rw
    ports:
      - "${PORT}:${PORT}/udp"
      - "${QUERYPORT}:${QUERYPORT}/udp"
```
### .env example

```.env
LAUNCH_SERVER_ENV=Ministry?Scenario=Scenario_Ministry_Checkpoint_Security?Game=CheckpointHardcore?password=YourPassword?MaxPlayers=16 -MapCycle=MapCycle -GameStatsToken=Your_GameStatsToken -GameStats -GSLTToken=Your_GSLTToken
HOSTNAME=My Hardcore Checkpoint Server
PORT=27102
QUERYPORT=27131
```

### Engine.ini example
```.ini
;Logging and also show in console
;Different kind of log like Log, Display, Verbose, VeryVerbose
[Core.Log]
LogGameplayEvents=Verbose
LogDemo=Verbose
LogObjectives=Verbose
LogGameMode=Verbose
LogNet=Verbose
LogINSGameInstance=Verbose
LogUObjectGlobals=Verbose

[/Script/OnlineSubsystemUtils.IpNetDriver]
MaxInternetClientRate=70000
MaxClientRate=70000

;Change server TickRate (Default 60)
NetServerMaxTickRate=128
LanServerMaxTickRate=128

;Connection TimeOut Time
ConnectionTimeout=80.0
InitialConnectTimeout=150.0

;https://docs.unrealengine.com/en-US/API/Runtime/PacketHandler/FDDoSDetection/index.html
[DDoSDetection]
bDDoSDetection=True
bDDoSAnalytics=True
DDoSLogSpamLimit=64
HitchTimeQuotaMS=500
HitchFrameTolerance=3

[/Script/Engine.Engine]
bAllowMatureLanguage=True
bSmoothFrameRate=True

;https://docs.unrealengine.com/en-US/API/Runtime/AIModule/Navigation/UCrowdManager/index.html
;make AI into squad/group (Need testing)
[/Script/AIModule.CrowdManager]
bResolveCollisions=True
;Radius to gather agents
MaxAgentRadius=2000.0
;Max number of agents in a group
MaxAgents=4
MaxAvoidedAgents=2

[URL]
;Game port
Port=27102

[OnlineSubsystemSteamNWI]
;Queryport for steam
GameServerQueryPort=27131
;Enable VAC on server or not
bVACEnabled=1

;Override the maxplayer amount (No longer need in new version)
;[SystemSettings]
;net.MaxPlayersOverride=20

[/Script/Insurgency.INSWorldSettings]
bShowBreath=True
;Map always night map
bAlwaysNight=False
;Allow random lighting scenario (Day/Night map)
bRandomLightingScenario=True

```

### Game.ini example
```.ini
[/Script/Insurgency.INSGameMode]
bKillFeed=False

[/Script/Insurgency.INSMultiplayerMode]
bAllowFriendlyFire=True
RoundLimit=2
bUseMapCycle=True
bMapVoting=True

[/Script/Insurgency.INSCoopMode]
MinimumEnemies=8
MaximumEnemies=14

[/Script/Insurgency.INSCheckpointGameMode]
DefendTimer=150
DefendTimerFinal=300

```

## Tips and Tricks
### How to save RAM on UE4 Linux(Docker) dedicated server

if you launch multiple servers on same host you can save some memory, on 2 servers more than 1gb memory saved.

Make sure that parameter set on 1 after host reboot

```echo 1 > /sys/kernel/mm/ksm/run```

and add launch options ```-useksm -ksmmergeall``` then restart servers

wait some amount of time and check statistics ```grep -H '' /sys/kernel/mm/ksm/*```

```pages_shared``` - how many shared pages are being used

```pages_sharing``` - how many more sites are sharing them i.e. how much saved

```pages_unshared``` - how many pages unique but repeatedly checked for merging

```pages_sharing*4096/1024/1024=how much memory saved```

So, in your example, 264281 pages have been found to be shareable. KSM saved you about 1032 MB of memory.
