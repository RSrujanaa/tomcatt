#!/bin/bash
TOMCAT_DIR="/opt/tomcat"               # Path to Tomcat installation
TOMCAT_LOGS="$TOMCAT_DIR/logs"         # Tomcat logs directory
LOG_FILE="$TOMCAT_LOGS/catalina.out"   # Primary log file to rotate
BACKUP_DIR="$TOMCAT_LOGS/backup"        # Backup directory for rotated logs
MAX_LOG_SIZE=3145728                    # 3 MB in bytes
ROTATION_COUNT=4                        # Number of rotations
CURRENT_DATE=$(date +"%d-%m-%Y")

# Function to install Tomcat
install_tomcat() {
echo "Installing Tomcat..."
# Update package index and install Java
sudo apt-get update
sudo apt-get install -y default-jdk
# Download and extract Tomcat
wget https://dlcdn.apache.org/tomcat/tomcat-9/v9.0.70/bin/apache-tomcat-9.0.70.tar.gz
sudo tar -xzf apache-tomcat-9.0.70.tar.gz -C /opt/
sudo mv /opt/apache-tomcat-9.0.70 $TOMCAT_DIR
# Set permissions
sudo chown -R $USER:$USER $TOMCAT_DIR
echo "Tomcat installed successfully at $TOMCAT_DIR."
}
rotate_logs(){ 
if [ -d "$TOMCAT_LOGS" ] && [ "$(ls -A $TOMCAT_LOGS)"]; then
# Check if the log file exists and is larger 
if [ -f "$LOG_FILE" ] && [ $(stat -c%s "$LOG_FILE") -gt $MAX_LOG_SIZE ];then 
echo "Rotating logs"
# Compress the log 
cp "$LOG_FILE" "$BACKUP_DIR/catalina_$CURRENT_DATE.log"
gzip "$BACKUP_DIR/catalina_$CURRENT_DATE"
# Clear the original log file
cat /dev/null > "$LOG_FILE"
echo "Log rotation complete: $BACKUP_DIR/catalina_$CURRENT_DATE.log"
echo "Log file size is less than 3MB or does not exist."
fi
echo "Log directory is empty or does not"
fi
}
					                                                                                                                                       
# Check if Tomcat is instal
if [ ! -d "$TOMCAT_DIR" ]; then
install_to
# Create backup directory if it doesn't e
mkdir -p "$BACKUP_DIR"
# Rotate logs (this should be run wee
rotate_logs
