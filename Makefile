.PHONY: validate install update outdated php/deps php/check php/fix php/tests php/testdox php/integration php/analyze ci clean docker/build docker/run docker/stop docker/shell

PHP_MIN_VERSION := "8.5"
PHP_MAX_VERSION := "8.6"
COMPOSER_BIN := composer
DOCKER_SRC := "/app/"
DOCKER_NAME := application-web-template
DOCKER_TARGET := dev
DOCKER_MOUNTS = $(shell if [ "${DOCKER_TARGET}" = "dev" ]; then echo "-v ${PWD}:${DOCKER_SRC}:delegated"; fi)
DOCKER_TYPE := "frankenphp"
LOCAL_PORT := 80

define header =
    @if [ -t 1 ]; then printf "\n\e[37m\e[100m  \e[104m $(1) \e[0m\n"; else printf "\n### $(1)\n"; fi
endef

#~ Composer dependency
validate:
	$(call header,Composer Validation)
	@${COMPOSER_BIN} validate

install:
	$(call header,Composer Install)
	@${COMPOSER_BIN} install

update:
	$(call header,Composer Update)
	@${COMPOSER_BIN} update
	@${COMPOSER_BIN} bump

outdated:
	$(call header,Composer Outdated)
	@${COMPOSER_BIN} outdated

composer.lock: install

#~ Report directories dependencies
build/reports/phpunit:
	@mkdir -p build/reports/phpunit

build/reports/phpcs:
	@mkdir -p build/reports/cs

build/reports/phpstan:
	@mkdir -p build/reports/phpstan

#~ main commands
php/deps: composer.json # jenkins + manual
	$(call header,Checking Dependencies)
	@XDEBUG_MODE=off ./vendor/bin/composer-dependency-analyser --config=./ci/composer-dependency-analyser.php # for shadow & unused required dependencies

php/check: vendor/bin/php-cs-fixer build/reports/phpcs # auto + manual
	$(call header,Checking Code Style)
	@XDEBUG_MODE=off ./vendor/bin/php-cs-fixer check -v --diff

php/fix: vendor/bin/php-cs-fixer # manual
	$(call header,Fixing Code Style)
	@XDEBUG_MODE=off ./vendor/bin/php-cs-fixer fix -v

php/min-compatibility: vendor/bin/phpstan build/reports/phpstan # auto + manual
	$(call header,Checking PHP $(PHP_MIN_VERSION) compatibility)
	@XDEBUG_MODE=off ./vendor/bin/phpstan analyse --configuration=./ci/phpmin-compatibility.neon --error-format=table

php/max-compatibility: vendor/bin/phpstan build/reports/phpstan # auto + manual
	$(call header,Checking PHP $(PHP_MAX_VERSION) compatibility)
	@XDEBUG_MODE=off ./vendor/bin/phpstan analyse --configuration=./ci/phpmax-compatibility.neon --error-format=table

php/analyze: vendor/bin/phpstan build/reports/phpstan # manual
	$(call header,Running Static Analyze - Pretty tty format)
	@XDEBUG_MODE=off ./vendor/bin/phpstan analyse --error-format=table

php/tests: vendor/bin/phpunit build/reports/phpunit # auto + manual
	$(call header,Running Unit Tests)
	@XDEBUG_MODE=coverage EKA_ENV=test php ./vendor/bin/phpunit --testsuite=unit --coverage-clover=./build/reports/phpunit/clover.xml --log-junit=./build/reports/phpunit/unit.xml --coverage-php=./build/reports/phpunit/unit.cov --coverage-html=./build/reports/coverage/ --fail-on-warning

php/integration: vendor/bin/phpunit build/reports/phpunit # manual
	$(call header,Running Integration Tests)
	@XDEBUG_MODE=coverage EKA_ENV=test php ./vendor/bin/phpunit --testsuite=integration --coverage-html=./build/reports/coverage/ --fail-on-warning

php/testdox: vendor/bin/phpunit # manual
	$(call header,Running Unit Tests (Pretty format))
	@XDEBUG_MODE=coverage EKA_ENV=test php ./vendor/bin/phpunit --testsuite=unit --fail-on-warning --testdox

clean: # manual
	$(call header,Cleaning previous build)
	@if [ "$(shell ls -A ./build)" ]; then rm -rf ./build/*; fi; echo " done"

ci: clean validate php/deps php/check php/tests php/integration php/min-compatibility php/max-compatibility php/analyze

###########################################################################################################
# ASSETS
###########################################################################################################
assets/install: # manual
	$(call header,Update assets)
	@XDEBUG_MODE=off EKA_DEBUG=1 EKA_ENV=dev bin/symfony importmap:install

assets/update: # manual
	$(call header,Update assets)
	@XDEBUG_MODE=off EKA_DEBUG=1 EKA_ENV=dev bin/symfony importmap:update

assets/compile: # manual
	$(call header,Compile assets)
	@XDEBUG_MODE=off EKA_DEBUG=1 EKA_ENV=dev bin/symfony asset-map:compile


###########################################################################################################
# DOCKER
###########################################################################################################
#~ Docker commands
docker/build:
	$(call header,Building Docker Local Image)
	@docker build --target ${DOCKER_TARGET} -t ${DOCKER_NAME}:local ${dockerOpts} -f docker/${DOCKER_TYPE}/Dockerfile .

docker/run:
	$(call header,Run Docker Local Image)
	@docker run -it --rm -d ${DOCKER_MOUNTS} --hostname ${DOCKER_NAME} -p ${LOCAL_PORT}:8080 --tty -e EKA_ENV=dev -e EKA_DEBUG=1 ${DOCKER_ENV} --name ${DOCKER_NAME} ${DOCKER_NAME}:local

docker/stop:
	$(call header,Stop Docker Local Image)
	@docker container stop ${DOCKER_NAME}

docker/shell:
	$(call header,Opening shell in container, type exit to quit container shell)
	@docker exec -it --user appuser --workdir /app ${DOCKER_NAME} bash
