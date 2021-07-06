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
    --deploy-container-app   [APP_NAME]   deploy container app on GCloud RUN
                                            [APP_NAME] => app name *required
    --deploy-micro-component [MICROCOMPONENT_NAME]   deploy microcomponent on GCloud STORE
                                            [MICROCOMPONENT_NAME] => microcomponent name *required
    [ARGS...]                             arguments you want to use for the heroku cli
EOF
}
#===================================
#==============INIT=================
#===================================
checkenvvariables(){  
    [[ -z $GCLOUD_CREDENTIALS ]] && { echo -e "\nEither 'GCLOUD_CREDENTIALS' are required to run commands with the Google Cloud SDK"; exit 126; } || { echo "${GCLOUD_CREDENTIALS}" > credentials.json; PROJECT_ID=$( echo "$GCLOUD_CREDENTIALS" | jq '. .project_id' | cut -d "\"" -f2); }
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
    echo ""
    [[ -z $REGION ]] && { echo -e "\nEither 'REGIONS' are required to deploy app"; exit 126; }
    echo ""
}
#===================================
gcloudbuild(){
    echo ""
    gcloud builds submit /github/workspace --tag gcr.io/${PROJECT_ID}/${app}
    echo ""
}
#===================================
gclouddeploy(){
    echo ""
    gcloud run deploy ${app} --image gcr.io/${PROJECT_ID}/${app} --platform managed --region ${REGION} --allow-unauthenticated
    echo ""
}
#===================================
gcloudsuccess(){
    echo "Successful deploy!"
}
#===================================
deploycontainerapp(){
    init 
    checkenvdeploy
    gcloudbuild
    gclouddeploy
    gcloudsuccess
}
#===================================
#==========PARAMSANDARGS============
#===================================
checkmicrocomponentnamedeploy(){
    echo ""
    proyectdir='/github/workspace'
    [[ -z $microcomponentname ]] && { echo -e "\nEither 'microComponentName' are required to deploy app"; exit 126; }
    [[ -z $BUCKET_URL ]] && { echo -e "\nEither 'BUCKET_URL' are required to deploy app"; exit 126; }
    echo ""
}
#===================================
projectmicrocomponentbuild(){
    cd $proyectdir
    inputdir="$(cat tsconfig.json | jq -r '.compilerOptions.outDir')/index.js"
    outputdir="$(cat tsconfig.json | jq -r '.compilerOptions.outDir')/${microcomponentname}.js"
    npm i 
    npm run build 
    mv $inputdir $outputdir
}
#===================================
uploadmicrocomponent(){
    gsutil -h "Content-Type:text/javascript" cp $outputdir $(echo $BUCKET_URL | jq -r ".")
}
#===================================
deploymicrocomponent(){
    init
    checkmicrocomponentnamedeploy
    projectmicrocomponentbuild
    uploadmicrocomponent
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
            deploycontainerapp
            exit 0
        ;;
        --deploy-micro-component)
            microcomponentname=${2}
            deploymicrocomponent
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
