#!bin/bash
#
#===================================
set -e
#===================================
#==============HELP=================
#===================================
help() {
  cat << EOF
usage: $0 [OPTIONS]
    --h                                 Show this message 
    --deploy-container-app [APP_NAME]   deploy container app on GCloud RUN
                                            [APP_NAME] => app name *required
    [ARGS...]                           arguments you want to use for the heroku cli
EOF
}
#===================================
#==============INIT=================
#===================================
checkenvvariables(){  
    [[ -z $GOOGLE_APPLICATION_CREDENTIALS ]] && { echo -e "\nEither credetials are required to run commands with the Google Cloud SDK"; exit 126; } || { echo "${GOOGLE_APPLICATION_CREDENTIALS}" > credentials.json; PROJECT_ID=$( echo "$GOOGLE_APPLICATION_CREDENTIALS" | jq '. .project_id' | cut -d "\"" -f2); }
}
#===================================
showinit(){
    echo -e "\nStarting Google Cloud SDK\n"
}
#===================================
gcloudinit(){
    gcloud auth activate-service-account --key-file=credentials.json
}
#===================================
gcloudconfigset(){
    gcloud config set $1 $2
}
#===================================
init(){
    showinit
    checkenvvariables
    gcloudinit
    gcloudconfigset project "${PROJECT_ID}"
}
#===================================
#===========RUNGCLOUDSDK============
#===================================
rungcloudsdk(){
    bash -c "gcloud $*"
}
#===================================
#========DEPLOYCONTAINERAPP=========
#===================================
checkenvdeploy(){
    [[ -z $REGION ]] && { echo -e "\nEither 'regions' are required to deploy app"; exit 126; }
}
gcloudbuild(){
    gcloud builds submit /github/workspace --tag gcr.io/${PROJECT_ID}/${app}
}
gclouddeploy(){
    gcloud run deploy ${app} --image gcr.io/${PROJECT_ID}/${app} --platform managed --region ${REGION} --allow-unauthenticated
}
#===================================
gcloudsuccess(){
    echo "Successful deploy!"
}
#===================================
#===================================
#===================================
deploycontainerapp(){
    checkenvdeploy
    gcloudbuild
    gclouddeploy
    gcloudsuccess
}
#===================================
#==========PARAMSANDARGS============
#===================================
while (( "$#" )); do
    case ${1} in
        --h)
            help
            exit 0
        ;;
        --deploy-container-app)
            app=${2}
            init
            deploycontainerapp
            exit 0
        ;;
        *)
            init
            rungcloudsdk $*
            exit 0
        ;;
    esac
    shift
done
