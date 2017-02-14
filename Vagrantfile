require 'getoptlong'

opts = GetoptLong.new(
  [ "--output-device", GetoptLong::REQUIRED_ARGUMENT ],
  [ "--raspbian-image-path", GetoptLong::REQUIRED_ARGUMENT ],
  [ "--wifi-network", GetoptLong::REQUIRED_ARGUMENT ],
  [ "--wifi-password", GetoptLong::REQUIRED_ARGUMENT ]
)

Vagrant.require_version ">= 1.7.0"

# Make sure disk is connected, but not mounted before proceeding
DISK_FILE= "./disk-image.vmdk"

ansible_vars = {}
opts.each do |opt, arg|
  case opt
  when "--output-device"
    OUTPUT_DEVICE = "/dev/#{arg}"
  when "--wifi-network"
    ansible_vars[:wifi_network] = arg
  when "--wifi-password"
    ansible_vars[:wifi_password] = arg
  when "--raspbian-image-path"
    ansible_vars[:raspbian_image_path] = arg
  end
end

Vagrant.configure(2) do |config|
  config.vm.box = "debian/jessie64"

  config.vm.network "private_network", ip: "10.1.1.2"

  config.vm.provision "ansible" do |ansible|
    ansible.verbose = "vvv"
    ansible.playbook = "playbook.yml"
    ansible.extra_vars = ansible_vars
  end

  config.vm.provider "virtualbox" do |vb|
    if defined?(OUTPUT_DEVICE) && !File.exists?(DISK_FILE)
      vb.customize ["internalcommands", "createrawvmdk", "-filename", DISK_FILE, "-rawdisk", OUTPUT_DEVICE]
    end
    vb.customize ["storageattach", :id,
      '--storagectl', 'SATA Controller',
      '--port', 1,
      '--device', 0,
      '--type', 'hdd',
      '--medium', DISK_FILE
    ]

    vb.customize ["modifyvm", :id, "--memory", 512]
    vb.customize ["modifyvm", :id, "--cpus", 1]
    vb.customize ["modifyvm", :id, "--usb", "on"]
  end
end
