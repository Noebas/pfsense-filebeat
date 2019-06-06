#!/bin/sh

# Stop filebeat if it's already running...
if [ -f /usr/local/etc/rc.d/filebeat ]; then
  echo -n "Stopping filebeat service..."
  /usr/sbin/service filebeat stop
  echo " done."
fi

#Remove current version and config
echo "Removing filebeat..."
/usr/sbin/pkg remove -y beats
/bin/rm /usr/local/etc/rc.d/filebeat.sh
/bin/rm /usr/local/etc/filebeat.yml
echo " done."

#Install new version
echo -n "Installing filebeat..."
/usr/sbin/pkg add -f https://pkg.freebsd.org/FreeBSD:11:amd64/latest/All/beats-6.7.1.txz
echo " done."

# Make filebeat auto start at boot
echo -n "Installing rc script..."
/bin/cp /usr/local/etc/rc.d/filebeat /usr/local/etc/rc.d/filebeat.sh
echo " done."

# Add the startup variable to rc.conf.local.
# In the following comparison, we expect the 'or' operator to short-circuit, to make sure the file exists and avoid grep throwing an error.
if [ ! -f /etc/rc.conf.local ] || [ $(grep -c filebeat_enable /etc/rc.conf.local) -eq 0 ]; then
  echo -n "Enabling filebeat service..."
  echo "filebeat_enable=YES" >> /etc/rc.conf.local
  echo " done."
fi

# Copy config from Github
/usr/local/bin/curl https://raw.githubusercontent.com/Noebas/pfsense-filebeat/master/filebeat.yml --output /usr/local/etc/filebeat.yml

# Start it up:
echo -n "Starting filebeat service..."
/usr/sbin/service filebeat start
echo " done."
