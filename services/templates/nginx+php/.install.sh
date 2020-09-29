sed -i "s/_PROJECT_NAME_/$PROJECT_NAME/g" "$PROJECT_DIR/web/public/index.php";
echo -e "${LABEL_SUCCESS} Basic index.php with <?php phpinfo(); ?> was pre-installed";
