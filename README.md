## M.A.R.S.
> Monitor Assistant Remote Server


sudo systemctl enable mars-ips.service
sudo systemctl disable mars-ips.service
sudo systemctl start mars-ips.service

sudo systemctl enable mars-monitor.service
sudo systemctl disable mars-monitor.service
sudo systemctl start mars-monitor.service


sudo cp mars.sh /usr/bin/mars.sh && sudo chmod +x /usr/bin/mars.sh

sudo cp mars-ips.service /etc/systemd/system/mars-ips.service
sudo chmod 644 /etc/systemd/system/mars-ips.service

sudo cp mars-monitor.service /etc/systemd/system/mars-monitor.service
sudo chmod 644 /etc/systemd/system/mars-monitor.service
