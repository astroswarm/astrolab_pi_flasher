#!/usr/bin/env bash
set -x

# Hack to pass our status to the Astroswarm API via CURL
set_status() {
  /usr/bin/curl --request POST -H "Content-Type: application/vnd.api+json" --data '{"data":{"type":"astrolabs","attributes":{"serial-number":"'"$(/bin/cat /sys/class/net/eth0/address | /bin/sed s/\://g)"'","private-ip-address":"","tunnel-endpoint": "", "status": "'"$1"'"}}}' https://api.astroswarm.com/v1/astrolabs --silent
}

trap "set_status "Rebooting" && sudo reboot" ERR

if [ -e /usr/local/astrolab-install-complete ]; then
  echo "Skipping Astrolab installation; already complete."
  exit 0
fi

# Ensure ssh access is enabled
set_status "Enabling SSH access"
sudo /usr/bin/touch /boot/ssh

# Set the password of the pi user
set_status "Setting pi user password"
/bin/echo "pi:astrolab" | sudo /usr/sbin/chpasswd

# Add Robby's public key for remote troubleshooting
set_status "Creating .ssh directory for pi user"
/bin/mkdir -p /home/pi/.ssh
set_status "Transferring ownership of .ssh directory to pi user"
/bin/chown pi:pi /home/pi/.ssh
set_status "Adding Robby's public key for remote troubleshooting"
/bin/echo "ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEAwwMlNoPlvA34uaHPoiCiq64zGgPNtsOX7sLW2fLzmd86e9aIPy9p5nZQ6YfcSpZ7TW01v88s24WmDzepp/Fiz7xGpUT5zuUFfSVry4OEPYmy59HFZ+bFUYGP1gP7hZH2eWL/uS+e5KoTXQMB8rSXfWc3TYeOgQOdmykH/UsUh5BaBamLnY9jRZtJYud4+TQ2muEoAPs/jRPdwDqHAIDjIeuF/hmlnTdC2S1pS1o7Amf/L8UfuqYkQWljbGReDifdMk7l5ql/nQ2mKYH7Knd7w703kStXQ/IsT6VKPrzAdhnMZ7QmMsn5Iu6c6GsBmE7m7sKT4HBS6uqew3S1OwaXFw== robby@freerobby.com" >> /home/pi/.ssh/authorized_keys
set_status "Setting ownership of authorized_keys file"
/bin/chown pi:pi /home/pi/.ssh/authorized_keys
set_status "Setting permissions of authorized_keys file"
/bin/chmod 600 /home/pi/.ssh/authorized_keys

# Install packages needed for our ansible scripts.
set_status "Updating apt repositories"
sudo /usr/bin/apt-get update
set_status "Installing ansible requirements"
sudo /usr/bin/apt-get -y install ansible git

# Run ansible playbook.
set_status "Running ansible playbook"
/usr/bin/ansible-pull -U https://github.com/astroswarm/astrolab_bootstrapper.git -C master -i localhost, --accept-host-key bootstrap.yml

# Mark complete
set_status "Marking installation as complete"
sudo /usr/bin/touch /usr/local/astrolab-install-complete
sudo /bin/chown pi:pi /usr/local/astrolab-install-complete

# Reboot
set_status "Rebooting"
sudo /sbin/reboot