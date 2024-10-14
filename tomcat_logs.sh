#!/bin/bash
AT_URL="https://downloads.apache.org/tomcat/tomcat-9/v9.0.65/bin/apache-tomcat-9.0.65.tar.gz"
t should compress the logs and store it in dd-mm-yyyy format.TOMCAT_INSTALL_DIR="/opt/tomcat"
LOG_DIR="$TOMCAT_INSTALL_DIR/logs"
LOG_FILE="$LOG_DIR/catalina.out"
MAX_LOGS=4
MIN_SIZE=3145728 # 3MB in bytes

install_tomcat() {
if [ ! -d "$TOMCAT_INSTALL_DIR" ]; then
echo "Tomcat not found. Installing Tomcat..."
sudo mkdir -p $TOMCAT_INSTALL_DIR
wget $TOMCAT_URL -O /tmp/tomcat.tar.gz
sudo tar -xvzf /tmp/tomcat.tar.gz -C $TOMCAT_INSTALL_DIR --strip-components=1
sudo chmod +x $TOMCAT_INSTALL_DIR/bin/*.sh
sudo $TOMCAT_INSTALL_DIR/bin/startup.sh
echo "Tomcat installed and started."
else
echo "Tomcat is already installed."
fi
}
rotate_logs() {
	    # Check if log directory is empty
     if [ -z "$(ls -A $LOG_DIR)" ]; then
echo "Log directory is empty. No rotation required."
return
fi
# Check if log file exists and its size is greater than 
if [ ! -f "$LOG_FILE" ] || [ $(stat -c%s "$LOG_FILE") -lt $MIN_SIZE ]; then
	echo "Log file does not exist or is less than 3MB. No rotation required."
	return
	fi
	    
# Compress the log file with the current date (dd-mm-yyyy)
DATE=$(date +"%d-%m-%Y")
tar -czvf "$LOG_DIR/catalina_$DATE.tar.gz" "$LOG_FILE"
# Clear the original log file
: > "$LOG_FILE"
echo "Logs compressed and cleared."
	    
# Remove older logs if there are more than MAX_LOGS
LOG_COUNT=$(ls -1 $LOG_DIR/*.tar.gz | wc -l)
if [ "$LOG_COUNT" -gt "$MAX_LOGS" ]; then
      	echo "Deleting older logs to maintain only $MAX_LOGS compressed logs."
	ls -tp $LOG_DIR/*.tar.gz | tail -n +$((MAX_LOGS+1)) | xargs -I {} rm -- {}
fi
}
	  
# Schedule the script to run weekly
schedule_rotation() {
(crontab -l 2>/dev/null; echo "0 0 * * 0 /path/to/this_script.sh") | crontab -
echo "Log rotation scheduled to run every week."
}
	    
# Main function
main() {
install_tomcat
rotate_logs
schedule_rotation
}
main
