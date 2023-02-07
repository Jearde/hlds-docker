
![Half-Life Logo](https://vignette.wikia.nocookie.net/half-life/images/d/dc/Lambda_logo.svg/revision/latest/scale-to-width-down/250?cb=20100327174546&path-prefix=en)

# Docker image for Half-Life Dedicated Server (HLDS) with Counter-Strike 1.6 (CS 1.6)

## Features
* Docker image for HLDS with CS 1.6
* Docker Compose file for easy setup
* Runs as non-root user in Docker container
* Fixes steamcmd install issues for hlds
* Installs HLDS and CS 1.6
* Installs Metamod and AMX Mod X
* Installs 3rd party maps 
* Installs 3rd party plugins (GunGame, Deathmatch, etc.)

## Install Docker on Debian / Ubuntu
https://docs.docker.com/engine/install/debian/

### Set up the repository
```bash
sudo apt update
sudo apt install \
    ca-certificates \
    curl \
    gnupg \
    lsb-release

# Add Docker’s official GPG key:
sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
# or
curl -fsSL https://download.docker.com/linux/debian/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg

# Use the following command to set up the repository:
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
# or
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
```

### Install Docker Engine

```bash
sudo apt update
sudo apt install docker-ce docker-ce-cli containerd.io docker-compose-plugin docker-compose
sudo docker run hello-world
```

### Add docker user to sudo group
```bash
sudo groupadd docker
sudo usermod -aG docker $USER
newgrp docker
sudo systemctl restart docker
```

## Adjust container settings
```bash	
# Set Environment Variables
docker-compose.yml

# Set HTTP Server address and port inside docker-compose.yml
# If IP not defined, the public IP address will be used
IP="127.0.0.1"
PORT="8080"

# Set HTTP another admin steamid or username inside docker-compose.yml (optional)
ADMIN='"STEAM_0:0:123456" "" "abcdefghijklmnopqrstu" "ce"'
ADMIN='"123.45.67.89" "" "abcdefghijklmnopqrstu" "de"'
ADMIN='"My Name" "my_password" "abcdefghijklmnopqrstu" "a"'

# Set game settings
files/server.cfg # Server settings
cstike/addons/amxmodx/configs/maps.ini # Map list (or change to use files/mapcycle.txt)
cstike/addons/amxmodx/configs/users.ini # Admins
cstike/addons/amxmodx/configs/maps/ # Map specific settings
```

## Run the container

0. Build the image
```bash
docker build -t jearde/hlds:latest .
```

1. Run with docker-compose (simplest):

```bash
docker-compose up -d

# stop with:
docker-compose down
```
2. Run without docker-compose:
  
```bash
docker run -d --name cstrike\
  -p 26900:26900/udp\
  -p 27020:27020/udp\
  -p 27015:27015/udp\
  -p 27015:27015\
  -p 8080:8080\
  -e GAME="cstrike"\
  -e MAXPLAYERS="8"\
  -e START_MAP="de_dust2"\
  -e SERVER_NAME="AI Gaming"\
  -e START_MONEY="800"\
  -e BUY_TIME="0.25"\
  -e FRIENDLY_FIRE="1"\
  -e RESTART_ON_FAIL="1"\
  -e SERVER_PASSWORD="secret"\
  -e RCON_PASSWORD="supersecret"\
  -e IP="10.0.100.127"\
  -e PORT="8080"\
  jearde/hlds:latest
```

3. Stop the container:

```bash
docker container ls
docker stop cstrike
docker start cstrike
docker rm cstrike
```

### Debug notes
```bash
docker stop $(docker ps -a -q)
docker rm $(docker ps -a -q)

docker build -t jearde/hlds:latest .
cat cstrike/addons/metamod/plugins.ini 
/bin/bash /bin/hlds_run.sh

docker run -it --name cstrike-debug\
  -p 26900:26900/udp\
  -p 27020:27020/udp\
  -p 27015:27015/udp\
  -p 27015:27015\
  -p 8080:8080\
  -e GAME="cstrike"\
  -e MAXPLAYERS="8"\
  -e START_MAP="de_dust2"\
  -e SERVER_NAME="AI Gaming"\
  -e START_MONEY="800"\
  -e BUY_TIME="0.25"\
  -e FRIENDLY_FIRE="1"\
  -e RESTART_ON_FAIL="1"\
  -e SERVER_PASSWORD="secret"\
  -e RCON_PASSWORD="supersecret"\
  -e IP="10.0.100.127"\
  -e PORT="8080"\
  -e ADMIN='"STEAM_0:1:20416393" "" "abcdefghijklmnopqrstu" "ce"'\
  jearde/hlds:latest /bin/bash


meta list

docker container ls
docker ps -a
docker exec -it cs bash
```

## Admin commands 
### Useful
```bash
amx_votemapmenu # Vote menu
amx_map	<mapname> # Change map
amx_pbmenu # Bot menu

amx_plugins # List plugins
amx_modules # List modules
amx_pausecfgmenu

amx_gungame <0|1> # Gun game
# Deathmatch

# Useful cvars
amx_cvar <cvar> <value>

autolimit <0/1>
awplimit <0/1>
mp_startmoney 16000
mp_freezetime 0
mp_timelimit 10
mp_friendlyfire 0
```

### AMX Mod X
https://wiki.alliedmods.net/Commands_(amx_mod_x)
```
Command	Format	Access	Description
amx_kick	<name or #userid> [reason]A	ADMIN_KICK	Kicks a player.
amx_ban	<name or #userid> [reason]	ADMIN_BAN	Bans a player.
amx_addban	<authid or ip> <minutes> [reason]	ADMIN_BAN	Adds a ban to the server banlist.
amx_unban	<authid or ip>	ADMIN_BAN	Unbans a player.
amx_slay	<name or #userid>	ADMIN_SLAY	Slays a player.
amx_slap	<name or #userid> [damage]	ADMIN_SLAY	Slaps a player for variable damage.
amx_leave	<tag> [tag1] [tag2] [tag3]	ADMIN_KICK	Kicks all players not wearing one of the tags.
amx_pause		ADMIN_CVAR	Pauses or unpauses the game.
amx_who		ADMIN_ADMIN	Displays who is on the server.
amx_cvar	<cvar> [value]	ADMIN_CVAR	Changes or displays a cvar value.
amx_map	<mapname>	ADMIN_MAP	Changes map.
amx_nick	<original name> <new name>	ADMIN_LEVEL_A	Changes Users Name.
amx_cfg	<filename>	ADMIN_CFG	Executes a server-side config file.
amx_rcon	<rcon command line>	ADMIN_RCON	Executes a command on the server console.
amx_plugins		ADMIN_ADMIN	Lists all loaded plugins.
amx_modules		ADMIN_ADMIN	Lists all loaded modules.
```

### Podbot
https://gamebanana.com/mods/39324
```
amx_pbmenu - invokes the main menu for podbot mm - do anything to your bots from it
amx_pbaddbot - just add a randome bot to your server
amx_pbcmmenu - choose model of the bot your adding
amx_pbcpmenu - choose personality of the bot your adding
amx_pbcsmenu - choose skill of the bot your adding
amx_pbctmenu - choose team of the bot your adding
amx_pbkbmenu - menu to kick the bots
amx_pbwmmenu - weapon mode menu for all bots
```

### Mods
Deathmatch
https://www.bailopan.net/csdm/index.php?page=install

GunGame
https://avalanche.gungame.org/cvars_en.php

dproto (nosteam)
https://www.amxmod.net/forum/showthread.php?tid=1376


### Maps
```
# Normal Maps
cs_assault
de_dust2
de_inferno
de_nuke
de_train
cs_italy
cs_office

# Fun Maps
de_dust2_2x2
fy_pool_day
fy_snow
de_bikinibottom_5
de_simpsons
de_springfield
cs_mansion

# Others
awp_india
aim_map

# Gun Game
gg_tetris_street
gg_aim_orange_mini
gg_bat
gg_headhunter
gg_minecraftempire_3

# Deathmatch
dm_flycraft_b1
dm_ambush
dm_dust2

# Not in mapcycle
as_oilrig
cs_747
cs_backalley
cs_estate
cs_havana
cs_militia
cs_siege
de_airstrip
de_aztec
de_cbble
de_chateau
de_dust
de_inferno
de_piranesi
de_prodigy
de_storm
de_survivor
de_torn
de_vertigo

# New
he_minicanyon
sj_streetball_pro^
Water_pool_race
de_mariobros
fy_mario
gg_danger_arv
aim_deagle_short
zm_minecraft
ze_ice4cap_lg
ze_jurassickopark3_lg
```

## TODOs
- [ ] HTTP Download fix (download extremely slow)
- [ ] Add more maps
- [ ] Free for all deathmatch
- [ ] Free for all gun game
- [ ] How to activate/deactivate deathmatch in game?
- [ ] Test kubernetes deployment
- [ ] Clean up repo
- [ ] Go through all installed plugins
- [ ] Add more plugins
- [ ] Custom welcome message