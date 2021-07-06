#!bin/bash 
#
#===================================
dependencies(){
    command -v jq >/dev/null 2>&1 || { echo >&2 "I require 'jq' but it's not installed.  Aborting."; exit 1; }
}
#===================================
getAPI(){
    [[ -n $(grep TOKEN .env | cut -d '=' -f 2-) ]] && { API_KEY=$(grep TOKEN .env); API_KEY="${API_KEY#*=}"; } || { echo -e "\nEither env file is required to run test the gcloud cli"; exit 162; }
    [[ -n $(grep BUCKET_URL .env | cut -d '=' -f 2-) ]] && { BUCKET_URL=$(grep BUCKET_URL .env | cut -d '=' -f2); }
    [[ -n $(grep REGION .env | cut -d '=' -f 2-) ]] && { REGION=$(grep REGION .env | cut -d '=' -f2); }
}
#===================================
deleteimageifexist(){
    [[ -n $( docker images | grep wrap-gcloud ) ]] && docker rmi wrap-gcloud:1.0 
}
#===================================
buildockerdimage(){
    docker build -t wrap-gcloud:1.0 . 
}
#===================================
rundockerbash(){
    tput setaf 6
    echo -e "\nTESTING GOOGLE CLOUD SDK WITH 'info' COMMAND"
    tput sgr0
    docker run -it -e "GCLOUD_CREDENTIALS=${API_KEY}" -e "BUCKET_URL=${BUCKET_URL}" --rm wrap-gcloud:1.0 info
}
#===================================
run(){
    getAPI
    deleteimageifexist
    buildockerdimage
    rundockerbash
}
#===================================
run
