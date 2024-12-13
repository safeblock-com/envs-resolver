
.EXPORT_ALL_VARIABLES:
ENVS_HOME=./test-output
GITHUB_OUTPUT=.github-output
GITHUB_ENV=.github-env
PROJECT_NAME=dex-frontend

.PHONY:
test: prepare 
	@echo "Запустили в ручную на main без стенда"
	rm ${GITHUB_OUTPUT}
	GITHUB_BRANCH=main GITHUB_EVENT_NAME=workflow_dispatch ./resolver.sh
	grep vite-mode=pre1 ${GITHUB_OUTPUT}
	grep pages-branch-name=pre1 ${GITHUB_OUTPUT}

	rm ${GITHUB_OUTPUT}
	GITHUB_BRANCH=dev GITHUB_EVENT_NAME=workflow_dispatch ./resolver.sh
	grep vite-mode=pre1 ${GITHUB_OUTPUT}
	grep pages-branch-name=pre1 ${GITHUB_OUTPUT}

	rm ${GITHUB_OUTPUT}
	STAGE=production ./resolver.sh
	grep vite-mode=production ${GITHUB_OUTPUT}
	grep pages-branch-name=main ${GITHUB_OUTPUT}

	rm ${GITHUB_OUTPUT}
	GITHUB_BRANCH=dev STAGE=pre2 ./resolver.sh
	grep vite-mode=pre2 ${GITHUB_OUTPUT}
	grep pages-branch-name=pre2 ${GITHUB_OUTPUT}

	rm ${GITHUB_OUTPUT}
	./resolver.sh
	grep vite-mode=pre1 ${GITHUB_OUTPUT}
	grep pages-branch-name=pre1 ${GITHUB_OUTPUT}

prepare:
	@echo > ${GITHUB_OUTPUT}
	@echo > ${GITHUB_ENV}
