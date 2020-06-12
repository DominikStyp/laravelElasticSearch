# Symfony Pipeline Template

## Requirements to run

* **Linux** or **MacOS** - For **Windows** we are suggesting using [WSL](https://docs.microsoft.com/en-us/windows/wsl/install-win10) or **VirtualBox**
* [Docker](https://redmine.polcode.com/projects/devops/wiki/Install_docker_on_VM)
* [docker-compose](https://redmine.polcode.com/projects/devops/wiki/Install_docker-compose_on_Linux)
* **python**
* **python-pip** - for `Ubuntu` run `sudo apt install python-pip` or `sudo apt install python3-pip` for python3

## Running Project locally for development (Developers) - new project

1. Depending on your current repository status
	1. If you have symfony repository then:
		1. Clone this repository locally
		2. Copy into your's project main location `.docker` directory from this project ex: `rsync -azv .docker /PATH/TO/YOUR/REPOSITORY`
		3. Copy into your's project main `.gitignore` content of this project `.gitignore` file or just copy it with `rsync -azv .gitignore /PATH/TO/YOUR/REPOSITORY`
	2. If you don't have symfony repository then:
		1. Fork this project - manual is [here](https://docs.gitlab.com/ee/gitlab-basics/fork-project.html). **Don't try to fork project to the same group as template project! It will not work**
		2. Change it's name and path - Go to new project `Settings -> General -> Advanced -> Rename repository`
		3. Click `Rename project` after making changes
		4. Remove fork relationship - Go to new project `Settings -> General -> Advanced -> Remove fork relationship` and click `Remove fork relationship`
		5. Write repository name as in displayed instruction and click `Confirm`
		6. Clone new project
		7. Add your code
2. Change `APP_NAME` and `COMPOSE_PROJECT_NAME` in `.docker/env-dist` file
3. Change `volumes` and `network` names in `.docker/docker-compose-dev.yml` and `.docker/docker-compose-staging-local.yml`
4. Add containers to `.docker/docker-compose-dev.yml` if you need
5. (optional if you added new docker) modify `.docker/env-dist` file to add new variables
6. Check `.docker/php-dev/Dockerfile` if it has everything you need
7. Change `.docker/php-dev/prepare-command.sh` file for project needs
8. Add new project hostname to your local `/etc/hosts` file. Look at the `.env` file and create it like `{{LOCAL_IP_ADDRESS}}	{{APP_NAME}}.{{DOMAIN}}`
9. Run `./start.sh dev` command
10. Script will stop if there were any env variables changes
11. Add all neccessary variables to `.env` file
12. Confirm in script that you want to proceed
13. Work on project
14. Commit changes after successful run

## Running Project locally for development (Developers) - existing and configured project
1. Run `./start.sh dev` command
2. Script will stop if there were any env variables changes
3. Add all neccessary variables to `.env` file
4. Confirm in script that you want to proceed
5. Work on project
6. Commit changes after successful run

## Running Project on Local Staging ENV (Developers/Devops/Admins)

1. Make sure that you did all steps for local development
2. If you added to dev new environment you need to add them to existing templates in `.docker/templates/` directory
3. (optional) Add non development containers to `.docker/docker-compose-staging-local.yml`
4. (optional) Create new template file in `.docker/templates/` as described [here](#how-can-i-add-new-environment-variables-to-project)
5. Check `.docker/php/Dockerfile` Dockerfile if it has everything you need
6. Change `.docker/php/prepare-command.sh` file for project needs
7. Run `./start.sh production` command

## Explain Repository Structure

* **.docker** - main directory for all docker important parts
	* docker-compose files:
		* **docker-compose-dev.yml** - Your first step in developing Symfony Project. Used when running `./start.sh dev`. Add any services you need for this project or ask for help DevOPS team.
		* **docker-compose-staging-local.yml** - This docker-compose file is for testing project as it is on staging env. **Don't add any services if they are not needed to run project (ex. PhpMyAdmin, MailCatcher etc.)**. If local staging will run on your local environment this means that **It will probably run on staging machine after commit to repository**
		* **docker-compose.yml** - This docker-compose file is used by **Jenkins** and **Ansible** to deploy on staging environment. This file don't have any build steps in docker-compose and it downloads docker images from AWS repository. **Don't edit it** without devops/admin team. Only they can create neccesary components to run your project automatically on staging environment!
	* Docker specific directories:
		* **php**:
			* **Dockerfile** - Docker file with basic components and `composer` installed
			* **prepare-command.sh** - **script where you can run your tasks before starting php process.** Don't remove **check database availability** step. Docker-compose doesn't guarantee to run database image before php and wait for it to be avaliable
		* **php-dev**
			* **Dockerfile** - Docker file with basic components and without `composer`. When using `DEVELOPMENT=1` variable you don't need to install composer by yourself. 
			* **prepare-command.sh** - **script where you can run your tasks before starting php process.** Don't remove **check database availability** step. Docker-compose doesn't guarantee to run database image before php and wait for it to be avaliable
			* **xdebug.ini** - xdebug configuration 
		* **nginx** - nginx config files for docker image:
			* **nginx.conf** - main nginx config file
			* **pass** - encrypted password file to website
			* **ssl** - directory where you can find your ssl cert and key
			* **vhosts** - Virtual hosts config files (generated with Jinja2)
	* **env-dist** file - base projekt environment variables. They will be added when you run `.docker/start.sh dev` to `.env.example` and `.env` files. **We are not using it as environment file in docker-compose project.**
	* **Templates directory** - Directory where you can find, add or edit Jinja2 template files
		* **common-docker-env.j2** - Common variables. This file is use to generate `.env` file for all containers
		* **db-docker-env.j2** - Database variables template file
		* **phpmyadmin-docker-env.j2** - PhpMyAdmin variables template file
		* **php-env.j2** - Php project variables.
		* **php-nginx-conf.j2** - Nginx Virtual host template file for generating nginx config based on **Web settings** inside `env-dist` file.
	* **start.sh** - Run script file
	* (After `start.sh` run ) **local-env-files** - place where we are storing all env files except `.env` file (it will be created in main project directory)
* **Laravel code**

## Explain `env-dist` variables

* **MYSQL_** variables:
	* **DATABASE** - name of project database
	* **ROOT_PASSWORD** - `root` user database password
	* **USER** - project database user
	* **PASSWORD** - project database user password
* **APP_** variables:
	* **NAME** - project name. It is used by Laravel, but we also are using it for containers name and local hostname
	* **ENV** - project environment - you can set it to `dev` or `production`. **Please remember that when you are using `start.sh` command will replace this variable in `.env` with command argument**
	* **KEY** - project secret. **Please remember that when you are using `start.sh` command will not generate this variable. APP_KEY will be generated inside docker**
	* **URL** - project website.
	* **DEBUG** - Laravel flag for debug **Please remember that when you are using `start.sh` command will replace this variable in `.env` depending on env variable**
* **PORT_** variables:
	* **DB** - Docker Database port
	* **PHP** - Docker PHP container port
	* **PHPMYADMIN** - Docker PhpMyAdmin port
	* **HTTP** - Docker Nginx HTTP port
	* **HTTPS** - Docker Nginx HTTPS port
* **DOCKER_** variables (They **must** be identical as services names in docker-compose files):
	* **DB** - Docker Database service name
	* **WEB** - Docker Nginx service name
	* **PMA** - Docker PhpMyAdmin service name
	* **PHP** - Docker PHP service name
* **DOMAIN** - project service domain
* **ENABLE_HTTPS** - set it to `false` if you are not using HTTPS or to `true` if you want to use HTTPS
* **SSL_PATH** - Directory inside container with SSL Certificate and it's private key. It **must** be identical as to mapped volume in docker-compose files
* **CERT_NAME** - Certificate filename
* **KEY_NAME** - Certificate Private key filename
* **LOCAL_IP_ADDRESS** - IP address on with local environment will be accessible
* **DEVELOPMENT** - Set to `0` for production environment and to `1` to dev environment. Read more [here](https://github.com/dockerwest/php#development) about differences **Please remember that when you are using `start.sh` command will replace this variable in `.env` file**
* **COMPOSE_PROJECT_NAME** - docker-compose project name. When you have multiple compose-project with similar containers this value protects projects from interfere between them
* **COMPOSE_FILE** - docker-compose file list. With this parameter we don't need to add `-f docker-compose.yml` on every run of docker-compose **Please remember that when you are using `start.sh` command will replace this variable in `.env` file**
* **PMA_ABSOLUTE_URI** - path for phpmyadmin website
* **PAM_HOST** - hostname of database host to connect from phpmyadmin

## Enable Xedebug in PHPStorm
1. Go to `Settings > Languages & Frameworks > PHP > Debug` and set xdebug port to `9001`

    **Caution!** For some reason port `9001` may be not available on your machine. 
    If it happend to you, try to change it to some other. Make sure to do relevant changes in `.docker/php-dev/xdebug.ini` file as well. 
    
    Run `start.sh` again to rebuild containers.

2. Go to `Settings > Languages & Frameworks > PHP > Servers` and add new server
```$xslt
Name: application
Host: localhost
Port: 80
```
Use appropriate path mappings to docker php container
```$xslt
project_root        >>      /var/www/html
```

## Enable HTTPS for project

To do it you need:

1. Create SSL Cert and private key
```
cd PROJECT_MAIN_DIRECTORY
mkdir -p nginx/ssl
openssl req -x509 -newkey rsa:4096 -keyout NAME.key -out NAME.crt -days 365 -nodes
```
2. Change `ENABLE_HTTPS` variable in en-base file to `true`
```
sed -i "s/ENABLE_HTTPS=.*/ENABLE_HTTPS=true/g" ./env-local
```
3. Change `SSL_PATH` if you have changed mount point inside nginx container for ssl
4. Add cert filename `NAME.crt` into `CERT_NAME` variable
```
sed -i "s/CERT_NAME=.*/KEY_NAME=NAME.crt/g" ./env-local
```
5. Add cert private key filename `NAME.key` into `KEY_NAME` variable
```
sed -i "s/KEY_NAME=.*/KEY_NAME=NAME.key/g" ./env-local
```
6. Run project

## How can I add new environment variables to project??

1. Add your variable to `.docker/env-dist` if they are docker variables or to  `.env` if they are project variables
2. Find `template` file for neccessary service and add new like in this way : `NEW_VARIABLE={{ENV_BASE_VAR}}` where `NEW_VARIABLE` will be avaliable as env var in docker and `ENV_BASE_VAR` is variable from `.env.local` file. Look at the other variables in templates files if you are not sure about your changes.
4. If you need to create new environment file (ex: for new containers) name it like this: `SERVICENAME-docker-env.j2`. **If you forget about this your file will not be generated**

## Template filenames types

Because in one `template` directory we have multiple types of templates we have decided to standarazied their names for start.sh script
* **NAME-docker-env.j2** - This template type is used to generate values for containers environment variables
* **NAME-env.j2** - This file will generate values for php environment on staging env
* **NAME-nginx-conf.j2** - This template type is used to generate nginx vhosts configuration

## Change PHP version

1. Look on [dockerwest guithub](https://github.com/dockerwest/php-symfony) which versions are avaliable
2. Go do dockerfile and change version of image (ex. 7.1)
3. Save your changes
