#!/usr/bin/env bash
set -x
trap "sudo reboot" ERR

if [ -e /usr/local/astrolab-install-complete ]; then
  echo "Skipping Astrolab installation; already complete."
  exit 0
fi

# Ensure ssh access is enabled
sudo /usr/bin/touch /boot/ssh

# Set the password of the pi user
/bin/echo "pi:astrolab" | sudo /usr/sbin/chpasswd

# Add Robby's public key for remote troubleshooting
/bin/mkdir -p /home/pi/.ssh
/bin/chown pi:pi /home/pi/.ssh
/bin/echo "ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEAwwMlNoPlvA34uaHPoiCiq64zGgPNtsOX7sLW2fLzmd86e9aIPy9p5nZQ6YfcSpZ7TW01v88s24WmDzepp/Fiz7xGpUT5zuUFfSVry4OEPYmy59HFZ+bFUYGP1gP7hZH2eWL/uS+e5KoTXQMB8rSXfWc3TYeOgQOdmykH/UsUh5BaBamLnY9jRZtJYud4+TQ2muEoAPs/jRPdwDqHAIDjIeuF/hmlnTdC2S1pS1o7Amf/L8UfuqYkQWljbGReDifdMk7l5ql/nQ2mKYH7Knd7w703kStXQ/IsT6VKPrzAdhnMZ7QmMsn5Iu6c6GsBmE7m7sKT4HBS6uqew3S1OwaXFw== robby@freerobby.com" >> /home/pi/.ssh/authorized_keys
/bin/chown pi:pi /home/pi/.ssh/authorized_keys
/bin/chmod 600 /home/pi/.ssh/authorized_keys

# Install packages needed for our ansible scripts.
sudo /usr/bin/apt-get update
sudo /usr/bin/apt-get -y install ansible git

# Run ansible playbook.
/usr/bin/ansible-pull -U https://github.com/astroswarm/astrolab_builder.git -C master -i localhost, --accept-host-key bootstrap.yml

# Mark complete
/usr/bin/touch /usr/local/astrolab-install-complete

# Reboot
sudo /sbin/reboot