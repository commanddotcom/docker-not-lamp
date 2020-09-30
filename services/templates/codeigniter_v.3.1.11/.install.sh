DOWNLOAD_FROM="https://api.github.com/repos/bcit-ci/CodeIgniter/zipball/3.1.11";
FILE_NAME="bcit-ci-CodeIgniter-3.1.11-0-gb73eb19.zip";

echo "Downloading CodeIgniter 3.1.11 from: $DOWNLOAD_FROM";

curl -o "$PROJECT_DIR/$FILE_NAME" -L "$DOWNLOAD_FROM";

unzip "$PROJECT_DIR/$FILE_NAME" -d "$PROJECT_DIR/web";

rm "$PROJECT_DIR/$FILE_NAME";

PUBLIC_FOLDER="$PROJECT_DIR/web/public"

mv "$PROJECT_DIR/web/bcit-ci-CodeIgniter-b73eb19" "$PUBLIC_FOLDER"; # rename

echo "Setting chmod 644 for all files ...";
find "$PUBLIC_FOLDER" -type f -exec chmod 644 {} \;

echo "Setting chmod 755 for all folders ...";
find "$PUBLIC_FOLDER" -type d -exec chmod 755 {} \;

echo "Setting chmod 777 for $PUBLIC_FOLDER/application/cache ...";
find "$PUBLIC_FOLDER/application/cache" -exec chmod 777 {} \;

echo "Setting chmod 777 for $PUBLIC_FOLDER/application/logs ...";
find "$PUBLIC_FOLDER/application/logs" -exec chmod 777 {} \;

echo -e "${LABEL_SUCCESS} CodeIgniter 3.1.11 is installed!";
