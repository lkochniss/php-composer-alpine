# Makefile for Docker PHP Composer Alpie Linux

build:
	@docker build -t php-composer-alpine .

start:
	@docker run -it php-composer-alpine

tag:
	@docker tag php-composer-alpine lkochniss/php-composer-alpine

push:
	@docker push lkochniss/php-composer-alpine


