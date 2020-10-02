# DockLAMP

DockLAMP is a shell script. It helps to manage multiple web service stacks based on Docker. It is a wrap around `docker-compose.yml` files and it helps to create and manage multiple projects on your localhost.

## Installantion

1. Download DockLAMP: `git clone git@github.com:commanddotcom/dockerlamp.git`
2. Go to your DockLAMP directory and run install.sh: `bash install.sh`

That's it. Now you can start your first project with `make new`

## Hints

- If you are looking for your db credentials go to `./services/database/.env` 
- Type `make` to get help on `Makefile`
- `.installed` file in the root folder of each project keeps information about project origins

## Disclaimer

DockLAMP is a lite script to boost up your productivity. It is not meant to be used on production.

