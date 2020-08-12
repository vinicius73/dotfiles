############################################################################
#                                                                          #
#               ------- Useful Docker Aliases --------                     #
#     https://gist.github.com/jgrodziski/9ed4a17709baad10dbcd4530b60dfcbb  #
#                                                                          #
#     # Usage:                                                             #
#     daws <svc> <cmd> <opts> : aws cli in docker with <svc> <cmd> <opts>  #
#     dc             : docker-compose                                      #
#     dcu            : docker-compose up -d                                #
#     dcd            : docker-compose down                                 #
#     dcr            : docker-compose run                                  #
#     dex <container>: execute a bash shell inside the RUNNING <container> #
#     di <container> : docker inspect <container>                          #
#     dim            : docker images                                       #
#     dip            : IP addresses of all running containers              #
#     dl <container> : docker logs -f <container>                          #
#     dnames         : names of all running containers                     #
#     dps            : docker ps                                           #
#     dpsa           : docker ps -a                                        #
#     drmc           : remove all exited containers                        #
#     drmid          : remove all dangling images                          #
#     drun <image>   : execute a bash shell in NEW container from <image>  #
#     dsr <container>: stop then remove <container>                        #
#                                                                          #
############################################################################

function docker-running-containers-names-fn {
	for ID in `docker ps | awk '{print $1}' | grep -v 'CONTAINER'`
	do
    	docker inspect $ID | grep Name | head -1 | awk '{print $2}' | sed 's/,//g' | sed 's%/%%g' | sed 's/"//g'
	done
}

function docker-running-containers-ips-fn {
    echo "IP addresses of all named running containers"

    for DOC in `docker-running-containers-names-fn`
    do
        IP=`docker inspect $DOC | grep -m3 IPAddress | cut -d '"' -f 4 | tr -d "\n"`
        OUT+=$DOC'\t'$IP'\n'
    done
    echo $OUT|column -t
}

function docker-exec-fn {
	docker exec -it $1 ${2:-bash}
}

function docker-inspect-fn {
	docker inspect $1
}

function docker-logs-fn {
	docker logs -f $1
}

function docker-run-fn {
	docker run -it $1 $2
}

function docker-compose-run-fn {
	docker-compose run $@
}

function docker-stop-fn {
	docker stop $1;docker rm $1
}

function docker-remove-all-exited-containers-fn {
       docker rm $(docker ps --all -q -f status=exited)
}

function docker-remove-all-dangling-images-fn {
       imgs=$(docker images -q -f dangling=true)
       [ ! -z "$imgs" ] && docker rmi "$imgs" || echo "no dangling images."
}

# in order to do things like dex $(dlab label) sh
function dlab {
       docker ps --filter="label=$1" --format="{{.ID}}"
}

function docker-compose-fn {
        docker-compose $*
}

function docker-aws-cli {
    docker run \
           -e AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID \
           -e AWS_DEFAULT_REGION=$AWS_DEFAULT_REGION \
           -e AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY \
           amazon/aws-cli:latest $1 $2 $3
}

dalias() { alias | grep 'docker' | sed "s/^\([^=]*\)=\(.*\)/\1 => \2/"| sed "s/['|\']//g" | sort; }

alias daws=docker-aws-cli
alias dc=docker-compose-fn
alias dcu="docker-compose up -d"
alias dcd="docker-compose down"
alias dcr=docker-compose-run-fn
alias dex=docker-exec-fn
alias di=docker-inspect-fn
alias dim="docker images"
alias dip=docker-running-containers-ips-fn
alias dl=docker-logs-fn
alias dnames=docker-running-containers-names-fn
alias dps="docker ps"
alias dpsa="docker ps -a"
alias drmc=docker-remove-all-exited-containers-fn
alias drmid=docker-remove-all-dangling-images-fn
alias drun=docker-run-fn
alias dsp="docker system prune --all"
alias dsr=docker-stop-fn