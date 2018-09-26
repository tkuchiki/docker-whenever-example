.PHONY: ssh_keygen build up

ssh_keygen:
	ssh-keygen -f ./ssh/id_rsa -N '' -t rsa

build:
	mkdir -p ssh
ifeq (,$(wildcard ssh/id_rsa))
	make ssh_keygen
endif
	docker-compose build

up:
	docker-compose up -d
