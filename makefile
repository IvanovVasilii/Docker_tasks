## This is a makefile for starting nginx from Dockerfile. Nginx listens :8080.
## Makefile allows you to manage created image and containers based on it as well.

IMAGE_NAME=testserver

default: image run_cont   ## create docker image and run container;

image:      ## create docker image;
	@docker image build -t $(IMAGE_NAME) .

help:       ## show help notices;
	@sed -ne '/@sed/!s/## //p' $(MAKEFILE_LIST) | \
        sed 's/image run_cont//'

name:       ## show image name;
	@echo $(IMAGE_NAME)

rm_cont:    ## remove all containers based on created image;
	@docker rm -f $$(docker ps -aq --filter ancestor=$(IMAGE_NAME))

rm_image:   ## remove created docker image;
	@docker image rm -f $(IMAGE_NAME)

run_clean:  ## run container and remove it after stop;
	@docker run --rm -d -p 8080:80 $(IMAGE_NAME)

run_cont:   ## run container that based on created image;
	@docker run -d -p 8080:80 $(IMAGE_NAME)

stats:      ## usage statistic for running container based on created image;
	@docker stats $$(docker ps -q --filter ancestor=$(IMAGE_NAME))

start_cont: ## start last stoped container based on created image;
	@docker start $$(docker ps -aq --filter ancestor=$(IMAGE_NAME)| head -n 1)

stop_cont:  ## stop running container based on created image.
	@docker stop $$(docker ps -q --filter ancestor=$(IMAGE_NAME))

