DOWNLOAD_FROM="https://github.com/opencart/opencart/releases/download/3.0.3.6/opencart-3.0.3.6.zip";

echo "Downloading Opencart 3.0.3.6 from: $DOWNLOAD_FROM";

curl -o "$PROJECT_DIR/opencart-3.0.3.6.zip" -L "$DOWNLOAD_FROM";

unzip "$PROJECT_DIR/opencart-3.0.3.6.zip" -d "$PROJECT_DIR/web";

rm "$PROJECT_DIR/opencart-3.0.3.6.zip";

PUBLIC_FOLDER="$PROJECT_DIR/web/upload"

echo "Setting chmod 644 for all files ...";
find "$PUBLIC_FOLDER" -type f -exec chmod 644 {} \;

echo "Setting chmod 755 for all folders ...";
find "$PUBLIC_FOLDER" -type d -exec chmod 755 {} \;

echo "Setting chmod 777 for $PUBLIC_FOLDER/system/storage/ ...";
find "$PUBLIC_FOLDER/system/storage/" -exec chmod 777 {} \;

echo "Setting chmod 777 for $PUBLIC_FOLDER/image/ ...";
find "$PUBLIC_FOLDER/image/" -exec chmod 777 {} \;

echo "Renaming config-dist.php files to config.php";
mv "$PUBLIC_FOLDER/config-dist.php" "$PUBLIC_FOLDER/config.php";
mv "$PUBLIC_FOLDER/admin/config-dist.php" "$PUBLIC_FOLDER/admin/config.php";

echo "Setting chmod 777 for config.php files";
find "$PUBLIC_FOLDER/config.php" -exec chmod 777 {} \;
find "$PUBLIC_FOLDER/admin/config.php" -exec chmod 777 {} \;

echo "Database setup....";
MYSQL_newDatabase;

echo '';
echo -e "${BIBlue} Database ${NC}: $MYSQL_NEW_DB_NAME";
echo -e "${BIBlue} User ${NC}: $MYSQL_NEW_DB_USER_NAME";
echo -e "${BIBlue} Password ${NC}: $MYSQL_NEW_DB_USER_PASS";
echo '';
echo -e "${LABEL_SUCCESS} Opencart 3.0.3.6 is installed!";

LOG_ENV="${LOG_ENV}FRAMEWORK=\"OPENCART\"\n";
LOG_ENV="${LOG_ENV}FRAMEWORK_VERSION=\"3.0.3.6\"\n";
LOG_ENV="${LOG_ENV}MYSQL_DATABASE=\"$MYSQL_NEW_DB_NAME\"\n";
LOG_ENV="${LOG_ENV}MYSQL_USER=\"$MYSQL_NEW_DB_USER_NAME\"\n";
LOG_ENV="${LOG_ENV}MYSQL_PASSWORD=\"$MYSQL_NEW_DB_USER_PASS\"\n";

