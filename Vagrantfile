RASPBIAN_IMAGE_ZIP = "2018-06-27-raspbian-stretch-lite.zip"
RASPBIAN_IMAGE_IMG = RASPBIAN_IMAGE_ZIP.sub('.zip', '.img')
ASTROLAB_IMAGE_IMG = "astrolab-#{Time.now.strftime("%Y-%m-%d")}.img"

Vagrant.require_version ">= 2.1.2"

Vagrant.configure(2) do |config|
  config.vm.box = "debian/stretch64"
  config.vm.provider "virtualbox"

  config.vm.synced_folder ".", "/vagrant", type: "virtualbox"

  config.vm.provision "shell", inline: <<-SHELL
    # Install packages
    apt-get -y update
    apt-get -y install kpartx zip
     
    # Load and mount Raspbian image
    cd /vagrant/tmp
    yes n | unzip #{RASPBIAN_IMAGE_ZIP}
    cp -n "#{RASPBIAN_IMAGE_IMG}" #{ASTROLAB_IMAGE_IMG}
    sudo losetup -D           
    sudo losetup -P /dev/loop0 #{ASTROLAB_IMAGE_IMG}
    mkdir -p /mnt/boot /mnt/host
    sudo mount /dev/loop0p1 /mnt/boot
    sudo mount /dev/loop0p2 /mnt/host

    # Enable SSH access
    touch /mnt/boot/ssh
         
    # Install our installer
    cp /vagrant/install-astrolab.sh /mnt/host/usr/local/bin/install-astrolab.sh
    chmod +x /mnt/host/usr/local/bin/install-astrolab.sh
                           
    # Configure rc.local to run our installer
    cp /vagrant/rc.local /mnt/host/etc/rc.local
    chmod 755 /mnt/host/etc/rc.local
                     
    # Unmount Raspbian image
    sudo umount /mnt/boot
    sudo umount /mnt/host
    sudo losetup -D
    rm -rf /mnt/boot /mnt/host

    # Compress resultant image
    gzip -f -9 #{ASTROLAB_IMAGE_IMG}
  SHELL
end
