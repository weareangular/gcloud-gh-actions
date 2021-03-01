#!bin/bash 
#
#===================================
dependencies(){
    command -v jq >/dev/null 2>&1 || { echo >&2 "I require 'jq' but it's not installed.  Aborting."; exit 1; }
}
#===================================
getAPI(){
    [[ -f ".env" ]] && { API_KEY=$(cat .env); } || { echo -e "\nEither env file is required to run test the gcloud cli"; exit 162; }
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
    docker run -it -e "GOOGLE_APPLICATION_CREDENTIALS=${API_KEY}" --rm wrap-gcloud:1.0 info
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
