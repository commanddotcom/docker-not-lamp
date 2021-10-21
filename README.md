# DockerNotLAMP

DockerNotLAMP is a wrap around `docker-compose.yml` files. It helps to create and manage multiple web service stacks based on Docker on your localhost. It makes things easy. 

*With DockerNotLAMP You can stage your local environment from zero in under a minute.*

You can use templates to stage particulare framework or particulare CMS with all the configurations (chmod, db, db user, etc).

## Installantion

1. Clone: `git clone git@github.com:commanddotcom/dockerlamp.git`
2. Run: `bash install.sh`

That's it. Now you can start your first project with `make new`

## Hints

- If you are looking for your root db credentials go to `./services/database/.env` 
- Type `make` to get help on `Makefile`
- `.installed` file in the root folder of each project keeps information about project origins

## Disclaimer

DockerNotLAMP is a lite script to boost up your productivity. It is not meant to be used on production.

## Troubleshooting

1. If error `bash: make: command not found` then install `make` utility: `apt-get -y install make`