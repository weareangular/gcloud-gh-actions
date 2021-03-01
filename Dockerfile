FROM gcr.io/google.com/cloudsdktool/cloud-sdk:alpine
#FROM gcr.io/google.com/cloudsdktool/cloud-sdk:latest

# Update distro
RUN apk update && apk upgrade && apk add jq

# Set the timezone in docker
RUN apk --update add tzdata && cp /usr/share/zoneinfo/America/Bogota /etc/localtime && echo "America/Bogota" > /etc/timezone && apk del tzdata

# Switch Work Directory
WORKDIR /opt/gcloud-gh-actions

# Copy files
COPY . .

# Start
ENTRYPOINT ["/bin/bash", "/opt/gcloud-gh-actions/entrypoint.sh"]
CMD ["--h"]
