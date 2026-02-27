#!/bin/bash
set -e

DEFAULT_ZIP_PATH=artifactory/libs-release-local/hsm/client.zip
ZIP_PATH=${hsm_zip_file_path:-$DEFAULT_ZIP_PATH}
ARTI_URL=${artifactory_url_env}
echo "ARTI_URL=$ARTI_URL"

WORK_DIR=$(pwd)
DIR_NAME=${hsm_local_dir_name:-hsm-client}

echo "Download the client from $ARTI_URL"
echo "Zip File Path: $ZIP_PATH"

# Si déjà installé → ne pas réinstaller
if [ -d "$DIR_NAME" ] && [ "$(ls -A $DIR_NAME 2>/dev/null)" ]; then
  echo "HSM already installed. Skipping installation."
else
  echo "Downloading HSM client..."
  wget -q --show-progress "$ARTI_URL" -O client.zip
  echo "Unzipping..."
  unzip -q client.zip

  echo "Preparing target directory..."
  rm -rf $DIR_NAME
  mkdir -p $DIR_NAME

  echo "Copying files to volume..."
  cp -r client/* $DIR_NAME/

  echo "Cleaning temp files..."
  rm -rf client
  rm -f client.zip

  echo "Installing HSM libraries..."
  cd $DIR_NAME
  chmod +x install.sh
  ./install.sh
  cd $WORK_DIR

  echo "HSM installation completed successfully."
fi

#echo "Starting application..."
#exec java -jar kernel-keymanager-service-1.1.5.5-P3.jar

echo "Starting application..."
echo "Starting application..."

exec java -jar \
  -Dspring.cloud.config.uri=${spring_config_url_env} \
  -Dspring.profiles.active=${active_profile_env} \
  -Dspring.cloud.config.label=${spring_config_label_env} \
  /home/mosip/app.jar
