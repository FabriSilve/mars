#!/bin/bash

# Check permissions
echo -e "Checking permissions...\n"
if [ "$EUID" -ne 0 ]
  then echo "Please run install.sh as root."
  exit 1
fi

# Check dependencies
echo -e "Checking dependencies...\n"
DEPENDENCIES='curl ifconfig awk'
for dep in $DEPENDENCIES; do
	if ! [ -x "$(command -v $dep)" ]; then
  	echo "$dep is not installed."
    exit 1
	fi
done

# Check required files
echo -e "Checking required files...\n"
FILES='./mars.sh ./.env'
for file in $FILES; do
	if [ ! -f "$file" ]; then
  	echo "Required $file file not found."
    exit 1
	fi
done

function command_succeded {
  if [ $? -ne 0 ]; then
    echo "Error installing M.A.R.S."
    exit 1
  fi
}

# Stop previous services
echo -e "Remove previous version...\n"
systemctl stop mars-monitor.service
command_succeded
systemctl disable mars-monitor.service &>/dev/null
command_succeded
systemctl stop mars-ips.service
command_succeded
systemctl disable mars-ips.service &>/dev/null
command_succeded
systemctl stop mars-down.service
command_succeded
systemctl disable mars-down.service &>/dev/null
command_succeded

# Prepare files
echo -e "Prepare files...\n"
echo -e "#!/bin/bash\n" > /usr/bin/mars.sh
cat ./.env ./mars.sh >> /usr/bin/mars.sh
command_succeded
cat ./mars-monitor.service > /etc/systemd/system/mars-monitor.service
command_succeded
cat ./mars-ips.service > /etc/systemd/system/mars-ips.service
command_succeded
cat ./mars-down.service > /etc/systemd/system/mars-down.service
command_succeded

# Update permissions
echo -e "Update permissions...\n"
chmod +x /usr/bin/mars.sh
command_succeded
chmod 644 /etc/systemd/system/mars-monitor.service
command_succeded
chmod 644 /etc/systemd/system/mars-ips.service
command_succeded
chmod 644 /etc/systemd/system/mars-down.service
command_succeded

# Activate services
echo -e "Activate services...\n"
systemctl enable mars-monitor.service &>/dev/null
command_succeded
systemctl start mars-monitor.service
command_succeded
systemctl enable mars-ips.service &>/dev/null
command_succeded
systemctl start mars-ips.service
command_succeded
systemctl enable mars-down.service &>/dev/null
command_succeded
systemctl start mars-down.service
command_succeded

# Done
echo "M.A.R.S. Installed succesfully!"
