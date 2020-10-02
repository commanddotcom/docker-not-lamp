include .env

help:
	@echo ""
	@echo "usage: make <COMMAND>"
	@echo ""
	@echo "Commands:"
	@echo "  start               Start nginx-proxy container and database containers (MySQL+PostgreSQL)"
	@echo "  stop                Stop nginx-proxy container and database containers (MySQL+PostgreSQL)"
	@echo "  status              Show info about running containers"
	@echo ""
	@echo "  new                 Create new project (based on project template)"
	@echo "  up                  Trigger 'docker-composer up -d' for the existing project"
	@echo "  down                Trigger 'docker-composer down -v' for the existing project"
	@echo "  build               Trigger 'docker-compose up -d --no-deps --build' for the existing project" 
	@echo "  rm                  Remove files, /etc/hosts record and db data for the existing project"
	@echo ""
	@echo "  v                   Show current version of core DockLAMP"
	@echo "  about               Show license & origins"

v:	
	@echo $(VERSION)

start:
	@cd $(NGINX_PROXY_DIR); docker-compose up -d;
	@cd $(DATABASE_DIR); docker-compose up -d;

stop:
	@cd $(NGINX_PROXY_DIR); docker-compose down -v;
	@cd $(DATABASE_DIR); docker-compose down -v;

new:
	@bash -e "$(SHELL_DIR)/project.new.sh"

up:
	@bash -e "$(SHELL_DIR)/docker.compose.sh" "up -d"

down:
	@bash -e "$(SHELL_DIR)/docker.compose.sh" "down -v"

rm:
	@bash -e "$(SHELL_DIR)/project.remove.sh" ""

status:
	@bash -e "$(SHELL_DIR)/service.status.sh" $(NGINX_PROXY_DIR) $(DATABASE_DIR)

build:
	@bash -e "$(SHELL_DIR)/docker.compose.sh" "up -d --no-deps --build"

about:
	@cat "./license.txt"
