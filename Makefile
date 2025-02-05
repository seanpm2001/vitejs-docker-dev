TAG?=16-alpine
PORT?=3000
APP_DIR?=app
VITE_DIR?=vite
VITE_REPO?=https://github.com/vitejs/vite.git

.PHONY: clean docker app-pnpm vite-pnpm app-sh vite-sh

clean:
	rm -rf .pnpm-store
	rm -rf ${APP_DIR}/node_modules
	rm -rf ${VITE_DIR}
	rm -f ${APP_DIR}/pnpm-lock.yaml
docker:
	docker build \
		docker-config/ \
		-t nystudio107/vitejs-dev:${TAG} \
		--build-arg TAG=${TAG} \
		--no-cache
	docker container run \
		--name vitejs-build-dev \
		--rm \
		-t \
		-v "${CURDIR}":/app \
		-e VITE_REPO=${VITE_REPO} \
		-e VITE_DIR=${VITE_DIR} \
		-e APP_DIR=${APP_DIR} \
		nystudio107/vitejs-dev:${TAG} \
		docker-config/docker.sh
app-pnpm:
	docker container run \
		--name vitejs-app-dev \
		--rm \
		-t \
		-p ${PORT}:${PORT} \
		-v "${CURDIR}":/app \
		nystudio107/vitejs-dev:${TAG} \
		-c "cd /app/${APP_DIR} && pnpm link /app/${VITE_DIR}/packages/vite && pnpm $(filter-out $@,$(MAKECMDGOALS))"
app-sh:
	docker exec -it vitejs-app-dev /bin/sh
vite-pnpm:
	docker container run \
		--name vitejs-vite-dev \
		--rm \
		-t \
		-v "${CURDIR}":/app \
		nystudio107/vitejs-dev:${TAG} \
		-c "cd /app/${VITE_DIR}/packages/vite && pnpm $(filter-out $@,$(MAKECMDGOALS))"
vite-sh:
	docker exec -it vitejs-vite-dev /bin/sh
%:
	@:
# ref: https://stackoverflow.com/questions/6273608/how-to-pass-argument-to-makefile-from-command-line
