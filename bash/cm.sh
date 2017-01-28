#!/bin/bash
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

#osshOnce you have installed an OpenSSH server,
#ossh
#osshsudo apt-get install openssh-server
#ossh
#osshyou will need to configure it by editing the sshd_config file in the
#ossh/etc/ssh directory.
#ossh
#osshIconsPage/tip.png
#ossh
#ossh
#osshsshd_config is the configuration file for the OpenSSH server. ssh_config
#osshis the configuration file for the OpenSSH client. Make sure not to get
#osshthem mixed up.
#ossh
#osshFirst, make a backup of your sshd_config file by copying it to your home
#osshdirectory, or by making a read-only copy in /etc/ssh by doing:
#ossh
#osshsudo cp /etc/ssh/sshd_config hmod  /etc/ssh/sshd_config.factory-defaults
#osshsudo ca-w                          /etc/ssh/sshd_config.factory-defaults
#ossh
#osshCreating a read-only backup in /etc/ssh means you'll always be able to
#osshfind a known-good configuration when you need it.
#ossh
#osshOnce you've backed up your sshd_config file, you can make changes with
#osshany text editor, for example;
#ossh
#osshsudo gedit /etc/ssh/sshd_config
#ossh
#osshruns the standard text editor in Ubuntu 12.04 or more recent. For older
#osshversions replace "sudo" with "gksudo". Once you've made your changes
#ossh(see the suggestions in the rest of this page), you can apply them by
#osshsaving the file then doing:
#ossh
#osshsudo restart ssh
#ossh
#osshIf you get the error, "Unable to connect to Upstart", restart ssh with
#osshthe following:
#ossh
#osshsudo systemctl restart ssh
#ossh
#osshConfiguring OpenSSH means striking a balance between security and
#osshease-of-use. Ubuntu's default configuration tries to be as secure as
#osshpossible without making it impossible to use in common use cases. This
#osshpage discusses some changes you can make, and how they affect the
#osshbalance between security and ease-of-use. When reading each section, you
#osshshould decide what balance is right for your specific situation.
#ossh
#osshDisable Password Authentication
#ossh
#osshBecause a lot of people with SSH servers use weak passwords, many online
#osshattackers will look for an SSH server, then start guessing passwords at
#osshrandom. An attacker can try thousands of passwords in an hour, and guess
#ossheven the strongest password given enough time. The recommended solution
#osshis to use SSH keys instead of passwords. To be as hard to guess as a
#osshnormal SSH key, a password would have to contain 634 random letters and
#osshnumbers. If you'll always be able to log in to your computer with an SSH
#osshkey, you should disable password authentication altogether.
#ossh
#osshIf you disable password authentication, it will only be possible to
#osshconnect from computers you have specifically approved. This massively
#osshimproves your security, but makes it impossible for you to connect to
#osshyour own computer from a friend's PC without pre-approving the PC, or
#osshfrom your own laptop when you accidentally delete your key.
#ossh
#osshIt's recommended to disable password authentication unless you have a
#osshspecific reason not to.
#ossh
#osshTo disable password authentication, look for the following line in your
#osshsshd_config file:
#ossh
#ossh#PasswordAuthentication yes
#ossh
#osshreplace it with a line that looks like this:
#ossh
#osshPasswordAuthentication no
#ossh
#osshOnce you have saved the file and restarted your SSH server, you
#osshshouldn't even be asked for a password when you log in.
#ossh
#osshDisable Forwarding
#ossh
#osshBy default, you can tunnel network connections through an SSH session.
#osshFor example, you could connect over the Internet to your PC, tunnel a
#osshremote desktop connection, and access your desktop. This is known as
#ossh"port forwarding".
#ossh
#osshBy default, you can also tunnel specific graphical applications through
#osshan SSH session. For example, you could connect over the Internet to your
#osshPC and run nautilus "file://$HOME" to see your PC's home folder. This is
#osshknown as "X11 forwarding".
#ossh
#osshWhile both of these are very useful, they also give more options to an
#osshattacker who has already guessed your password. Disabling these options
#osshgives you a little security, but not as much as you'd think. With access
#osshto a normal shell, a resourceful attacker can replicate both of these
#osshtechniques and a specially-modified SSH client.
#ossh
#osshIt's only recommended to disable forwarding if you also use SSH keys
#osshwith specified commands.
#ossh
#osshTo disable forwarding, look for the following lines in your sshd_config:
#ossh
#osshAllowTcpForwarding yes
#ossh
#osshX11Forwarding yes
#ossh
#osshand replace them with:
#ossh
#osshAllowTcpForwarding no
#ossh
#osshX11Forwarding no
#ossh
#osshIf either of the above lines don't exist, just add the replacement to
#osshthe bottom of the file. You can disable each of these independently if
#osshyou prefer.
#ossh
#osshSpecify Which Accounts Can Use SSH
#ossh
#osshYou can explicitly allow or deny access for certain users or groups. For
#osshexample, if you have a family PC where most people have weak passwords,
#osshyou might want to allow SSH access just for yourself.
#ossh
#osshAllowing or denying SSH access for specific users can significantly
#osshimprove your security if users with poor security practices don't need
#osshSSH access.
#ossh
#osshIt's recommended to specify which accounts can use SSH if only a few
#osshusers want (not) to use SSH.
#ossh
#osshTo allow only the users Fred and Wilma to connect to your computer, add
#osshthe following line to the bottom of the sshd_config file:
#ossh
#osshAllowUsers Fred Wilma
#ossh
#osshTo allow everyone except the users Dino and Pebbles to connect to your
#osshcomputer, add the following line to the bottom of the sshd_config file:
#ossh
#osshDenyUsers Dino Pebbles
#ossh
#osshIt's possible to create very complex rules about who can use SSH - you
#osshcan allow or deny specific groups of users, or users whose names match
#ossha specific pattern, or who are logging in from a specific location. For
#osshmore details about how to create complex rules, see the sshd_config man
#osshpage
#ossh
#osshRate-limit the connections
#ossh
#osshIt's possible to limit the rate at which one IP address can establish
#osshnew SSH connections by configuring the uncomplicated firewall (ufw). If
#osshan IP address is tries to connect more than 10 times in 30 seconds, all
#osshthe following attempts will fail since the connections will be DROPped.
#osshThe rule is added to the firewall by running a single command:
#ossh
#osshsudo ufw limit ssh
#ossh
#osshOn a single-user or low-powered system, such as a laptop, the number
#osshof total simultaneous pending (not yet authorized) login connections
#osshto the system can also be limited. This example will allow two pending
#osshconnections. Between the third and tenth connection the system will
#osshstart randomly dropping connections from 30% up to 100% at the tenth
#osshsimultaneous connection. This should be set in sshd_config.
#ossh
#osshMaxStartups 2:30:10
#ossh
#osshIn a multi-user or server environment, these numbers should be set
#osshsignificantly higher depending on resources and demand to alleviate
#osshdenial-of-access attacks. Setting a lower the login grace time (time to
#osshkeep pending connections alive while waiting for authorization) can be a
#osshgood idea as it frees up pending connections quicker but at the expense
#osshof convenience.
#ossh
#osshLoginGraceTime 30
#ossh
#osshLog More Information
#ossh
#osshBy default, the OpenSSH server logs to the AUTH facility of syslog, at
#osshthe INFO level. If you want to record more information - such as failed
#osshlogin attempts - you should increase the logging level to VERBOSE.
#ossh
#osshIt's recommended to log more information if you're curious about
#osshmalicious SSH traffic.
#ossh
#osshTo increase the level, find the following line in your sshd_config:
#ossh
#osshLogLevel INFO
#ossh
#osshand change it to this:
#ossh
#osshLogLevel VERBOSE
#ossh
#osshNow all the details of ssh login attempts will be saved in your
#ossh/var/log/auth.log file.
#ossh
#osshIf you have started using a different port, or if you think your server
#osshis well-enough hidden not to need much security, you should increase
#osshyour logging level and examine your auth.log file every so often. If you
#osshfind a significant number of spurious login attempts, then your computer
#osshis under attack and you need more security.
#ossh
#osshWhatever security precautions you've taken, you might want to set the
#osshlogging level to VERBOSE for a week, and see how much spurious traffic
#osshyou get. It can be a sobering experience to see just how much your
#osshcomputer gets attacked.
#ossh
#osshNext, try logging in from your own computer:
#ossh
#osshssh -v localhost
#ossh
#osshThis will print a lot of debugging information, and will try to connect
#osshto your SSH server. You should be prompted to type your password, and
#osshyou should get another command-line when you type your password in. If
#osshthis works, then your SSH server is listening on the standard SSH port.
#osshIf you have set your computer to listen on a non-standard port, then
#osshyou will need to go back and comment out (or delete) a line in your
#osshconfiguration that reads Port 22. Otherwise, your SSH server has been
#osshconfigured correctly.
#ossh
#osshTo leave the SSH command-line, type:
#ossh
#osshexit
#ossh
#osshIf you have a local network (such as a home or office network), next
#osshtry logging in from one of the other computers on your network. If
#osshnothing happens, you might need to tell your computer's firewall to
#osshallow connections on port 22 (or from the non-standard port you chose
#osshearlier).
#ossh
#osshFinally, try logging in from another computer elsewhere on the Internet
#ossh- perhaps from work (if your computer is at home) or from home (if your
#osshcomputer is at your work). If you can't access your computer this way,
#osshyou might need to tell your router's firewall to allow connections from
#osshport 22, and might also need to configure Network Address Translation.

#balssyu-plowshare() { cd ~/Downloads; wget $(lynx --dump http://code.google.com/p/plowshare/downloads/list | awk '/deb/ && /files/ && /plowshare3/ {print $2}'); echo Plowshare Current Version: $(aptitude versions plowshare); echo Installing $(dpkg --info plowshare*.deb | grep Version); sudo dpkg -i plowshare*.deb ;}
#bals
#bals
#bals#Aliases
#balsalias aliaslist='grep ^alias ~/.bash_aliases'
#balsalias aliasedit='gedit ~/.bash_aliases &' #edit aliases
#bals#Apt-Get
#balsalias install='sudo apt-get install'
#balsalias remove='sudo apt-get remove'
#balsalias purge='sudo apt-get remove --purge'
#balsalias update='sudo apt-get update'
#balsalias upgrade='sudo apt-get upgrade'
#balsalias clean='sudo apt-get autoclean && sudo apt-get autoremove'
#balsalias search='apt-cache search'
#balsalias show='apt-cache show'
#balsalias sources='gksudo gedit /etc/apt/sources.list '
#balsalias repos='sudo add-apt-repository'
#balsalias mergelist_problem='sudo rm /var/lib/apt/lists/* -vf & sudo apt-get update'
#bals#Slow Apt-get
#balsalias slowinstall='sudo apt-get -o Acquire::http::Dl-Limit=100 install'
#balsalias slowupdate='sudo apt-get update && sudo apt-get -o Acquire::http::Dl-Limit=80 upgrade'
#bals#conky
#balsalias conkyreset='killall -SIGUSR1 conky'
#balsalias conkyrc='gedit ~/.conkyrc'
#bals#Plowdown
#balsalias download='plowdown --max-retries=20 --output-directory=/home/x/Videos/'
#balsalias slowdownload='plowdown --max-rate 100K --timeout=3600 --max-retries=20 --output-directory=/home/x/Videos/'
#bals#General
#balsalias timestamp='fswebcam --loop 10 -r 640x480 --jpeg 85 -D 1 "%k-%M-%S".jpg'
#balsalias audio_record='arecord -f cd -t raw | oggenc - -r -o'
#bals
#balsalias start='xdg-open'
#balsalias ramdisk_on='sudo mount -t tmpfs -o size=128M tmpfs /media/ramdisk'
#balsalias ramdisk_off='sudo umount /media/ramdisk'
#balsalias clean_thumb='find ~/.thumbnails -type f -atime +7 -exec rm {} \;'
#balsalias fixkeys='sudo apt-get update 2> /tmp/keymissing; for key in $(grep "NO_PUBKEY" /tmp/keymissing |sed "s/.*NO_PUBKEY //"); do echo -e "\nProcessing key: $key"; gpg --keyserver pool.sks-keyservers.net --recv $key && gpg --export --armor $key | sudo apt-key add -; done'
#bals#youtube
#balsalias utmp3='youtube-dl -R5 -t -c --extract-audio --audio-format=mp3 ' 
#balsalias ut='youtube-dl -R5 -t -c '
#balsalias archive='engrampa'
#balsalias sysinfo='inxi -b'
#balsalias xampp='sudo /opt/lampp/xampp start'
#balsalias flv2mp3='echo "ffmpeg -i “mysource.flv” -acodec libmp3lame -ac 2 -ab 128 -vn -y output.mp3"'
#balsalias lso="ls -alG | awk '{k=0;for(i=0;i<=8;i++)k+=((substr(\$1,i+2,1)~/[rwx]/)*2^(8-i));if(k)printf(\" %0o \",k);print}'"
#balsalias wwwphoto="gnome-web-photo --mode=photo"
#bals
#bals#mame
#bals
#balsalias medit='gedit ~/.mame/mame.ini'
#balsalias mroms='nautilus ~/.mame/roms'
#balsalias myserver2="python2 -m SimpleHTTPServer"
#bals
#balsupdate_git() { git add * ; git commit -m "$1" ; git push ;}
#bals
#bals#rtmp sniff
#balssniff-begin() { sudo iptables -t nat -A OUTPUT -p tcp --dport 1935 -m owner \! --uid-owner root -j REDIRECT ;}
#balssniff-capture-rtmpsrv() { rtmpsrv ;}
#balssniff-end() { sudo iptables -t nat -D OUTPUT -p tcp --dport 1935 -m owner \! --uid-owner root -j REDIRECT ;}
#bals

#format1[ How to Format a Disk Drive in Linux ]
#format1
#format1
#format1
#format1###### IMPORTANT ###############################################################
#format1
#format1By following the instructions here you will format a hard disk (in a format for
#format1use only in linux/ubuntu) and make a new partition. Any data saved on that disk
#format1will be lost. Use with caution.
#format1
#format1################################################################################
#format1
#format1
#format1Step #1 : Partition the new disk using fdisk command
#format1
#format1Following command will list all detected hard disks:
#format1	
#format1	fdisk -l | grep '^Disk'
#format1
#format1Output:
#format1
#format1	Disk /dev/sda: 251.0 GB, 251000193024 bytes
#format1	Disk /dev/sdb: 251.0 GB, 251000193024 bytes
#format1
#format1A device name refers to the entire hard disk. 
#format1To partition the disk - /dev/sdb, enter:
#format1
#format1	fdisk /dev/sdb
#format1
#format1The basic fdisk commands you need are:
#format1
#format1    * m - print help
#format1    * p - print the partition table
#format1    * n - create a new partition
#format1    * d - delete a partition
#format1    * q - quit without saving changes
#format1    * w - write the new partition table and exit
#format1
#format1
#format1Step#2 : Format the new disk using mkfs.ext3 command
#format1
#format1To format Linux partitions using ext2fs on the new disk:
#format1	
#format1	mkfs.ext3 /dev/sdb1
#format1
#format1
#format1Step#3 : Mount the new disk using mount command
#format1
#format1First create a mount point /disk1 and use mount command to mount /dev/sdb1, enter:
#format1
#format1	mkdir /disk1
#format1	mount /dev/sdb1 /disk1
#format1	df -H
#format1	
#format1	
#format1Step#4 : Update /etc/fstab file
#format1
#format1Open /etc/fstab file, enter:
#format1
#format1	vi /etc/fstab
#format1		or use FTE instead
#format1	fte /etc/fstab	
#format1
#format1	
#format1Append as follows:
#format1
#format1/dev/sdb1               /disk1           ext3    defaults        1 2
#format1
#format1Save and close the file.
#format1
#format1
#format1
#format1


#fstab1[ Mounting drives, generic information ]
#fstab1
#fstab1
#fstab1
#fstab1
#fstab1The file /etc/fstab (it stands for "file system table") contains descriptions
#fstab1of filesystems that you mount often. These filesystems can then be mounted with 
#fstab1a shorter command, such as mount /cdrom. You can also configure filesystems to
#fstab1mount automatically when the system boots. You'll probably want to mount all of
#fstab1your hard disk filesystems when you boot.
#fstab1
#fstab1Look at this file now, by typing more /etc/fstab. It will have two or more 
#fstab1entries that were configured automatically when you installed the system. It 
#fstab1probably looks something like this:
#fstab1
#fstab1     # /etc/fstab: static file system information.
#fstab1    #
#fstab1    #                
#fstab1    /dev/hda1            /               ext2    defaults    0       1
#fstab1    /dev/hda3            none            swap    sw          0       0
#fstab1    proc                 /proc           proc    defaults    0       0
#fstab1  
#fstab1    /dev/hda5            /tmp            ext2    defaults    0       2
#fstab1    /dev/hda6            /home           ext2    defaults    0       2
#fstab1    /dev/hda7            /usr            ext2    defaults    0       2
#fstab1  
#fstab1    /dev/hdc             /cdrom          iso9660 ro          0       0
#fstab1    /dev/fd0             /floppy         auto    noauto,sync 0       0
#fstab1
#fstab1
#fstab1The first column lists the device the filesystem resides on. The second lists 
#fstab1the mount point, the third the filesystem type. The line beginning proc is a 
#fstab1special filesystem explained in The proc filesystem, Section 4.8.3. Notice that 
#fstab1the swap partition (/dev/hda3 in the example) has no mount point, so the mount 
#fstab1point column contains none.
#fstab1
#fstab1The last three columns may require some explanation.
#fstab1
#fstab1The fifth column is used by the dump utility to decide when to back up the
#fstab1filesystem. FIXME: cross ref to dump
#fstab1
#fstab1The sixth column is used by fsck to decide in what order to check filesystems 
#fstab1when you boot the system. The root filesystem should have a 1 in this field, 
#fstab1filesystems which don't need to be checked (such as the swap partition) should 
#fstab1have a 0, and all other filesystems should have a 2. FIXME: cross ref to fsck, 
#fstab1also, is the swap partition really a filesystem?
#fstab1
#fstab1Column four contains one or more options to use when mounting the filesystem. 
#fstab1Here's a brief summary (some of these probably won't make much sense yet - they 
#fstab1are here for future reference):
#fstab1
#fstab1async and sync
#fstab1    Do I/O synchronously or asynchronously. Synchronous I/O writes changes to
#fstab1files immediately, while asynchronous I/O may keep data in buffers and write it
#fstab1later, for efficiency reasons. FIXME: cross ref to section on sync for full
#fstab1explanation. Also, should recommend when to choose one or the other. 
#fstab1
#fstab1ro and rw
#fstab1    Mount the filesystem read-only or read-write. If you don't need to make any
#fstab1changes to the filesystem, it's a good idea to mount it read-only so you
#fstab1don't accidentally mess something up. Also, read-only devices (such as CD-ROM
#fstab1drives and floppy disks with write protection tabs) should be mounted read-only. 
#fstab1
#fstab1auto and noauto
#fstab1    When the system boots, or whenever you type mount -a, mount tries to mount
#fstab1all the filesystems listed in /etc/fstab. If you don't want it to automatically 
#fstab1mount a filesystem, you should use the noauto option. It's probably a good idea
#fstab1to use noauto with removable media such as floppy disks, because there may or
#fstab1may not be a disk in the drive. You'll want to mount these filesystems manually 
#fstab1after you put in a disk. 
#fstab1
#fstab1dev and nodev
#fstab1    Use or ignore device files on this filesystem. You might use nodev if you
#fstab1mount the root directory of another system on your system - you don't want your
#fstab1system to try to use the devices on the other system. 
#fstab1
#fstab1user and nouser
#fstab1    Permit or forbid ordinary users to mount the filesystem. nouser means that 
#fstab1only root can mount the filesystem. This is the normal arrangement. You might
#fstab1use the user option to access the floppy drive without having to be root. 
#fstab1
#fstab1exec and noexec
#fstab1    Allow or do not allow the execution of files on this filesystem. Probably 
#fstab1you won't need these options. 
#fstab1
#fstab1suid and nosuid
#fstab1    Allow or do not allow the suid bit to take effect. Probably you won't need
#fstab1these options. See Making files suid/sgid, Section 4.8.4.2. 
#fstab1
#fstab1defaults
#fstab1    Equivalent to: rw, dev, suid, exec, auto, nouser, async. You can specify
#fstab1defaults followed by other options to override specific aspects of defaults.
#fstab1
#fstab1fstab Syntax
#fstab1Quote:
#fstab1[Device] [Mount Point] [File_system] [Options] [dump] [fsck order]
#fstab1Device = Physical location.
#fstab1/dev/hdxy or /dev/sdxy.
#fstab1x will be a letter starting with a, then b,c,....
#fstab1y will be a number starting with 1, then 2,3,....
#fstab1Thus hda1 = First partition on the master HD.
#fstab1
#fstab1    See Basic partitioning for more information
#fstab1
#fstab1Note: zip discs are always numbered "4".
#fstab1Example: USB Zip = /dev/sda4.
#fstab1
#fstab1Note: You can also identify a device by udev, volume label (AKA LABEL), or uuid.
#fstab1
#fstab1These fstab techniques are helpful for removable media because the device 
#fstab1(/dev/sdxy) may change. For example, sometimes the USB device will be assigned 
#fstab1/dev/sda1, other times /dev/sdb1. This depends on what order you connect USB
#fstab1devices, and where (which USB slot) you use to connect. This can be a major
#fstab1aggravation as you must identify the device before you can mount it. fstab does
#fstab1not work well if the device name keeps changing.
#fstab1
#fstab1To list your devices, first put connect your USB device (it does not need to be
#fstab1mounted).
#fstab1By volume label:
#fstab1Code:
#fstab1
#fstab1	ls /dev/disk/by-label -lah
#fstab1
#fstab1By id:
#fstab1Code:
#fstab1
#fstab1	ls /dev/disk/by-id -lah
#fstab1
#fstab1By uuid:
#fstab1Code:
#fstab1
#fstab1ls /dev/disk/by-uuid -lah
#fstab1
#fstab1IMO, LABEL is easiest to use as you can set a label and it is human readable.
#fstab1
#fstab1The format to use instead of the device name in the fstab file is:
#fstab1LABEL= (Where is the volume label name, ex. "data").
#fstab1UUID= (Where is some alphanumeric (hex) like:
#fstab1	fab05680-eb08-4420-959a-ff915cdfcb44).
#fstab1	
#fstab1Again, IMO, using a label has a strong advantage with removable media (flash 
#fstab1drives). See How to use Labels below.
#fstab1For udev: udev does the same thing as LABEL, but I find it more complicated.
#fstab1See How to udev for a very nice how to on udev.
#fstab1
#fstab1Mount point.
#fstab1This is where the partition is mounted or accessed within the "tree" 
#fstab1(ie /mnt/hda1). You can use any name you like.
#fstab1In general
#fstab1
#fstab1   1. /mnt Typically used for fixed hard drives HD/SCSI.
#fstab1   2. /media Typically used for removable media (CD/DVD/USB/Zip).
#fstab1
#fstab1Examples:
#fstab1
#fstab1   1. /mnt/windows
#fstab1   2. /mnt/data
#fstab1   3. /media/usb
#fstab1
#fstab1To make a mount point:
#fstab1Code:
#fstab1
#fstab1sudo mkdir /media/usb
#fstab1
#fstab1File types:
#fstab1Linux file systems: ext2, ext3, jfs, reiserfs, reiser4, xfs, swap.
#fstab1
#fstab1Windows:
#fstab1vfat = FAT 32, FAT 16
#fstab1ntfs= NTFS
#fstab1
#fstab1Note: For NTFS rw ntfs-3g
#fstab1
#fstab1CD/DVD/iso: iso9660
#fstab1
#fstab1    To mount an iso image (*.iso NOT CD/DVD device):
#fstab1    Code:
#fstab1
#fstab1    sudo mount -t iso9660 -o ro,loop=/dev/loop0 
#fstab1
#fstab1Network file systems:
#fstab1nfs Example:
#fstab1Quote:
#fstab1server:/shared_directory /mnt/nfs nfs 0 0
#fstab1
#fstab1Make a directory for each device to mount it
#fstab1	makedir /floppy
#fstab1	makedir /cdrom
#fstab1	makedir /usb
#fstab1
#fstab1Mounting a filesystem
#fstab1Before mounting a filesystem, or to actually create a filesystem on a disk that 
#fstab1doesn't have one yet, it's necessary to refer to the devices themselves. All
#fstab1devices have names, and these are located in the /dev directory. If you type 
#fstab1ls /dev now, you'll see a pretty lengthy list of every possible device you could
#fstab1have on your Debian system.
#fstab1
#fstab1Possible devices include:
#fstab1
#fstab1    * /dev/hda is IDE drive A, usually called C:\ on a DOS or Windows system. In
#fstab1general, this will be a hard drive. IDE refers to the type of drive - if you 
#fstab1don't know what it means, you probably have this kind of drive, because it's the
#fstab1most common. 
#fstab1
#fstab1    * /dev/hdb is IDE drive B, as you might guess. This could be a second hard 
#fstab1drive, or perhaps a CD-ROM drive. Drives A and B are the first and second 
#fstab1(master and slave) drives on the primary IDE controller. Drives C and D are the
#fstab1first and second drives on the secondary controller. 
#fstab1
#fstab1    * /dev/hda1 is the first partition of IDE drive A. Notice that different 
#fstab1drives are lettered, while specific partitions of those drives are numbered as 
#fstab1well. 
#fstab1
#fstab1    * /dev/sda is SCSI disk A. SCSI is like IDE, only if you don't know what it
#fstab1is you probably don't have one. They're not very common in home Intel PC's,
#fstab1though they're often used in servers and Macintoshes often have SCSI disks. 
#fstab1
#fstab1    * /dev/fd0 is the first floppy drive, generally A:\ under DOS. Since floppy 
#fstab1disks don't have partitions, they only have numbers, rather than the
#fstab1letter-number scheme used for hard drives. However, for floppy drives the 
#fstab1numbers refer to the drive, and for hard drives the numbers refer to the 
#fstab1partitions. 
#fstab1
#fstab1    * /dev/ttyS0 is one of your serial ports. /dev contains the names of many
#fstab1devices, not just disk drives. 
#fstab1
#fstab1To mount a filesystem, tell Linux to associate whatever filesystem it finds on a
#fstab1particular device with a particular mount point.
#fstab1
#fstab1   1. su
#fstab1
#fstab1      If you haven't already, you need to either log in as root or gain root 
#fstab1privileges with the su (super user) command. If you use su, enter the root
#fstab1password when prompted. 
#fstab1
#fstab1   2. ls /cdrom
#fstab1
#fstab1      See what's in the /cdrom directory before you start. If you don't have a 
#fstab1/cdrom directory, you may have to make one using mkdir /cdrom. 
#fstab1
#fstab1   3. mount
#fstab1
#fstab1      Typing simply mount with no arguments lists the currently mounted
#fstab1filesystems. 
#fstab1
#fstab1   4. mount -t iso9660 CD device /cdrom
#fstab1
#fstab1      For this command, you should substitute the name of your CD-ROM device for
#fstab1CD device in the above command line. If you aren't sure, /dev/hdc is a good
#fstab1guess. If that fails, try the different IDE devices: /dev/hda, etc. You should
#fstab1see a message like:
#fstab1
#fstab1           mount: block device /dev/hdc is write-protected, mounting read-only
#fstab1
#fstab1      The -t option specifies the type of the filesystem, in this case iso9660.
#fstab1Most CDs are iso9660. The next argument is the name of the device to mount, and
#fstab1the final argument is the mount point. There are many other arguments to mount; 
#fstab1see the man page for details. (For example, you could avoid the above message 
#fstab1by specifying read-only on the command line.)
#fstab1
#fstab1      Once a CD is mounted, you may find that your drive tray will not open.
#fstab1You must unmount the CD before removing it. 
#fstab1
#fstab1   5. ls /cdrom
#fstab1
#fstab1      Confirm that /cdrom now contains whatever is on the CD in your drive. 
#fstab1
#fstab1   6. mount
#fstab1
#fstab1      Look at the list of filesystems again, noticing that your CD drive is now
#fstab1mounted. 
#fstab1
#fstab1   7. umount /cdrom
#fstab1
#fstab1      This unmounts the CD. It's now safe to remove the CD from the drive. 
#fstab1Notice that the command is umount with no "n", even though it's used to unmount
#fstab1the filesystem.
#fstab1
#fstab1
#fstab1
#fstab1


#iso1[ Howto: Mount .ISO, .IMG, .BIN, .MDF, and .NRG in Ubuntu ]
#iso1
#iso1
#iso1
#iso1##### Important ###############################################################
#iso1
#iso1TO DO THIS YOU SHOULD HAVE ALLREADY A LIVE CONNECTION TO THE INTERNET
#iso1
#iso1###############################################################################
#iso1
#iso1
#iso1First install the package: fuseiso
#iso1In the console type this :
#iso1
#iso1
#iso1	sudo apt-get install fuseiso
#iso1	sudo adduser [YOUR_USERNAME] fuse
#iso1
#iso1
#iso1If you were not in the fuse group you will need to log off, then back in right
#iso1now. Now lets create ourselves a fuseiso folder to mount our .iso
#iso1
#iso1In the console type this :
#iso1
#iso1
#iso1	sudo mkdir /media/fuseiso
#iso1
#iso1
#iso1To mount an .iso file, in the console type this :
#iso1	
#iso1	sudo fuseiso ISO_FILENAME.iso /media/fuseiso
#iso1
#iso1
#iso1Now you can navigate to your .iso like it is a normal drive.
#iso1
#iso1
#iso1

#usb1[ How to mount a USB drive or another hard disk partition ]
#usb1
#usb1
#usb1
#usb1###### IMPORTANT ###############################################################
#usb1
#usb1If the USB drive you are trying to mount was used under Windows and has not been
#usb1removed/pluged off in a proper way, there is a chance that this guide will not
#usb1work. Plug the USB drive back to a Windows system. Check it for errors, fix them
#usb1and then try this.
#usb1
#usb1################################################################################
#usb1
#usb1
#usb1
#usb1First you have to create a folder where your new partition or USB drive will be
#usb1mounted. So in the console type:
#usb1
#usb1	mkdir /media/[NEW_NAME]
#usb1	
#usb1[NEW_NAME]: is the name for the new folder, where the partition will be mounted.
#usb1It can be anything you want. Do not include the brackets.
#usb1
#usb1Now that you created the folder, you have to know how ubuntu recognizes your,
#usb1partition or USB. Ubuntu (or any other Linux) uses a weird system to describe a
#usb1partition, hard disk, floppy or cdrom. For example a cdrom in ubuntu is 
#usb1recognized with something like this: /dev/cdrom or a floppy drive likes this:
#usb1/dev/floppy or /dev/fd0. The same way with a hard disk: /dev/sda1. So to make 
#usb1our mount we need to know this. If you are trying to mount a usb drive, plug it
#usb1and after that, type in the console:
#usb1
#usb1	sudo fdisk -l
#usb1	
#usb1It will display a list of available drives and partitions. Find the one you are
#usb1looking for, based on the size of it and the filesystem it uses (if you know it)
#usb1An example of what this command displays is below. (Dont type anything to your
#usb1console).
#usb1
#usb1Disk /dev/sda: 100.0 GB, 100030242816 bytes
#usb1255 heads, 63 sectors/track, 12161 cylinders
#usb1Units = cylinders of 16065 * 512 = 8225280 bytes
#usb1Disk identifier: 0x34fe34fd
#usb1
#usb1   Device Boot      Start         End      Blocks   Id  System
#usb1/dev/sda2   *           1        2841    22820301    c  W95 FAT32 (LBA)
#usb1/dev/sda3            2842       12161    74862900    f  W95 Ext'd (LBA)
#usb1/dev/sda5            6203       12161    47865636    7  HPFS/NTFS
#usb1/dev/sda6            2842        6202    26997169+  83  Linux
#usb1
#usb1Partition table entries are not in disk order
#usb1
#usb1Disk /dev/sdb: 160.0 GB, 160041885696 bytes
#usb1255 heads, 63 sectors/track, 19457 cylinders
#usb1Units = cylinders of 16065 * 512 = 8225280 bytes
#usb1Disk identifier: 0x010f010e
#usb1
#usb1   Device Boot      Start         End      Blocks   Id  System
#usb1/dev/sdb1   *           1       19456   156280288+   7  HPFS/NTFS
#usb1
#usb1In this example i have one hard disk with multiple partitions and also one USB
#usb1drive. The USB is referenced like this: /dev/sdb1 and this is the one that i 
#usb1want to mount. So in order to mount the USB disk, give the following command in 
#usb1the console:
#usb1
#usb1	mount /dev/sdb1 /media/[THE FOLDER YOU CREATED EARLIER]
#usb1
#usb1and you are done. Navigate to that folder and you will see the files stored in 
#usb1your USB disk


#open1[ Connect to Open Wireless Connection via Terminal in Ubuntu ]
#open1
#open1
#open1
#open1##### Important ###############################################################
#open1Wherever you see this:[interface] you must replace this with your network 
#open1interface(eth0, wlan0, wlan1).
#open1
#open1Example command : sudo ifconfig wlan0 down
#open1
#open1If you dont know which is your network interface go to: 
#open1Main Menu>System Info>Network Interface Information>Network Interfaces Info
#open1and you will see all of them.
#open1
#open1ESSID: Is your wireless network name.
#open1###############################################################################
#open1
#open1
#open1In the console type the followings:
#open1
#open1	sudo ifconfig [interface] down
#open1	sudo dhclient -r [interface]
#open1	sudo ifconfig [interface] up
#open1	sudo iwconfig [interface] essid “[ESSID_IN_QUOTES]”
#open1	sudo iwconfig [interface] mode Managed
#open1	sudo dhclient [interface]
#open1
#open1>This guide taken from xibex.blogspot.com


#wpa1[ WPA Connection - WPA-PSK or WPA2-PSK via Terminal in Ubuntu]
#wpa1
#wpa1
#wpa1
#wpa1##### Important ###############################################################
#wpa1Wherever you see this:[interface] you must replace this with your network 
#wpa1interface(eth0, wlan0, wlan1).
#wpa1
#wpa1Example command : sudo ifconfig wlan0 down
#wpa1
#wpa1If you dont know which is your network interface go to: 
#wpa1Main Menu>System Info>Network Interface Information>Network Interfaces Info
#wpa1and you will see all of them.
#wpa1
#wpa1ESSID: Is your wireless network name.
#wpa1###############################################################################
#wpa1
#wpa1##### Important ###############################################################
#wpa1For uses of Ra-based chipsets: rt61, rt73, rt2500 please skip directly to the
#wpa1WPA Section entitled 'WPA with Ra' based chipsets below.
#wpa1###############################################################################
#wpa1
#wpa1##### Important ###############################################################
#wpa1Generally WPA connections in Terminal, are not supported. This is achieved by
#wpa1downloading the package: wpasupplicant
#wpa1
#wpa1TO DO THIS YOU SHOULD HAVE ALLREADY A LIVE CONNECTION TO THE INTERNET
#wpa1
#wpa1So in the Terminal type:
#wpa1	sudo aptitude install wpasupplicant
#wpa1###############################################################################
#wpa1
#wpa1If only wireless is available, I would recommend that an unencrypted connection
#wpa1first by established and tested first before directly proceeding to make a WPA
#wpa1connection. WPA adds another layer of complexity.
#wpa1
#wpa1Creation of /etc/wpa_supplicant.conf file
#wpa1
#wpa1In Terminal, type :
#wpa1
#wpa1	gksu gedit /etc/wpa_supplicant.conf
#wpa1
#wpa1Inside the file add the following for WPA(1):
#wpa1
#wpa1	ap_scan=1
#wpa1	ctrl_interface=/var/run/wpa_supplicant
#wpa1
#wpa1	network={
#wpa1	ssid="[YOUR ESSID]"
#wpa1	scan_ssid=0
#wpa1	proto=WPA
#wpa1	key_mgmt=WPA-PSK
#wpa1	psk="[YOUR PSK PASSWORD]"
#wpa1	pairwise=TKIP
#wpa1	group=TKIP
#wpa1	}
#wpa1
#wpa1For WPA(2)
#wpa1
#wpa1	ctrl_interface=/var/run/wpa_supplicant
#wpa1
#wpa1	network={
#wpa1	ssid="[YOUR ESSID]"
#wpa1	psk="[YOUR PSK PASSWORD]"
#wpa1	key_mgmt=WPA-PSK
#wpa1	proto=RSN
#wpa1	pairwise=CCMP
#wpa1	}
#wpa1
#wpa1##### Important ###############################################################
#wpa1In some cases I have found WPA(2) to have different
#wpa1settings than the above. Some Broadcom cards use the pairwise/group TKIP
#wpa1cipher for WPA2 rather than CCMP. I would suggest all initially use WPA(1)
#wpa1and then later convert to WPA2 since some variations to the above may be
#wpa1needed
#wpa1###############################################################################
#wpa1
#wpa1Connect via Terminal :
#wpa1
#wpa1	sudo ifconfig [interface] down
#wpa1	sudo dhclient -r [interface]
#wpa1	sudo wpa_supplicant -w -D[****SEE FOOTER BELOW***] -i[interface] 
#wpa1	-c/etc/wpa_supplicant.conf -dd
#wpa1	sudo ifconfig [interface] up
#wpa1	sudo iwconfig [interface] mode Managed
#wpa1	sudo dhclient [interface]
#wpa1
#wpa1*** FOOTER ********************************************************************
#wpa1The value listed here is dependent on the driver you have installed. Typing man
#wpa1wpa_supplicant at command line will give you the full gamut of choices however a
#wpa1quick reference: 
#wpa1	ndiswrapper=wext <---(use wext and not ndiswrapper)
#wpa1	ath_pci = madwifi
#wpa1	ipw2100/2200=ipw
#wpa1*******************************************************************************
#wpa1
#wpa1[ WPA with Ra Based Chipsets ]
#wpa1
#wpa1Ra cards do not require the wpa_supplicant package to use WPA. Here is how to
#wpa1connect from the command line with these cards
#wpa1
#wpa1	WPA(1)
#wpa1In terminal type:
#wpa1
#wpa1	sudo ifconfig [interface] down
#wpa1	sudo dhclient -r [interface]
#wpa1	sudo ifconfig [interface] up
#wpa1	sudo iwconfig [inteface] essid “[YOUR ESSID]”
#wpa1	sudo iwpriv [interface] set AuthMode=WPAPSK
#wpa1	sudo iwpriv [interface] set EncrypType=TKIP
#wpa1	sudo iwpriv [interface] set WPAPSK=”[YOUR WPA PSK PASSWORD]”
#wpa1	sudo dhclient [interface]
#wpa1
#wpa1A successful connection in all cases will results in this:
#wpa1
#wpa1user@computer:~$ sudo dhclient wlan0
#wpa1There is already a pid file /var/run/dhclient.pid with pid 134993416
#wpa1Internet Systems Consortium DHCP Client V3.0.4
#wpa1Copyright 2004-2006 Internet Systems Consortium.
#wpa1All rights reserved.
#wpa1For info, please visit http://www.isc.org/sw/dhcp/
#wpa1
#wpa1Listening on LPF/wlan0/00:12:17:35:17:10
#wpa1Sending on LPF/wlan0/00:12:17:35:17:10
#wpa1Sending on Socket/fallback
#wpa1DHCPDISCOVER on wlan0 to 255.255.255.255 port 67 interval 4
#wpa1DHCPDISCOVER on wlan0 to 255.255.255.255 port 67 interval 7
#wpa1DHCPDISCOVER on wlan0 to 255.255.255.255 port 67 interval 7
#wpa1DHCPOFFER from 192.168.1.1
#wpa1DHCPREQUEST on wlan0 to 255.255.255.255 port 67
#wpa1DHCPACK from 192.168.1.1
#wpa1bound to 192.168.1.101 — renewal in 299133 seconds.
#wpa1
#wpa1The computer in this example has received an IP address of 192.168.1.101
#wpa1
#wpa1[ Users of RTL 8180, RTL8185, RTL 8187 using the built in native r8187 / r818x
#wpa1 drivers ]
#wpa1
#wpa1By default the r8187 and r818x drivers are blacklisted due to a know bug. These
#wpa1drivers are usuable however with a twist to the above methods
#wpa1
#wpa1If you want to try using these drivers, please load the kernel modules:
#wpa1
#wpa1In Terminal, type :
#wpa1
#wpa1	sudo modprobe r818x
#wpa1	sudo modprobe r8187
#wpa1
#wpa1These drivers require a bogus or extra letter be suffixed to the essid name in
#wpa1order for these drivers to work
#wpa1
#wpa1For example if your are trying to connect to a router with essid=Router, at he 
#wpa1command line you would type essid=Routerx. Notice the extra x or bogus
#wpa1character. I have provided an example using the unencrypted connection procedure
#wpa1below, however this extra character needs to be used if attempting to connect
#wpa1to all network types (unencrypted/ WEP / WPA)
#wpa1
#wpa1In Terminal, type :
#wpa1
#wpa1	sudo ifconfig [interface] down
#wpa1	sudo dhclient -r [interface]
#wpa1	sudo ifconfig [interface] up
#wpa1	sudo iwconfig [interface] essid “Routerx”
#wpa1	sudo iwconfig [interface] mode Managed
#wpa1	sudo dhclient [interface]
#wpa1
#wpa1If these drivers work for you, and you would like these drivers to load
#wpa1automatically at startup for you, avoiding to have to type sudo modprobe
#wpa1everytime, please edit your blacklist file.
#wpa1
#wpa1gksu gedit /etc/modprobe.d/blacklist   <--- Only GUI
#wpa1gksu vi /etc/modprobe.d/blacklist   <--- For the terminal
#wpa1
#wpa1And comment out (or prefix the following lines with a # sign). You want the following lines to appear as below:
#wpa1
#wpa1	#blacklist r8187
#wpa1	#blacklist r818x
#wpa1
#wpa1>This guide taken from xibex.blogspot.com
#wpa1
#wpa1
#wpa1


#wep1[ Connect to WEP Connection via Terminal in Ubuntu ]
#wep1
#wep1
#wep1
#wep1##### Important ###############################################################
#wep1Wherever you see this:[interface] you must replace this with your network 
#wep1interface(eth0, wlan0, wlan1).
#wep1
#wep1Example command : sudo ifconfig wlan0 down
#wep1
#wep1If you dont know which is your network interface go to: 
#wep1Main Menu>System Info>Network Interface Information>Network Interfaces Info
#wep1and you will see all of them.
#wep1
#wep1ESSID: Is your wireless network name.
#wep1###############################################################################
#wep1
#wep1Make sure that you have your 64bit or 128 bit HEX Key or the ASCII Equivalent 
#wep1of your HEX Key. If you dont understand anything of these, then make sure
#wep1you have your pass phrase (password). 
#wep1
#wep1In the console type the followings:
#wep1
#wep1	sudo ifconfig [interface] down
#wep1	sudo dhclient -r [interface]
#wep1	sudo ifconfig [interface] up
#wep1	sudo iwconfig [interface] essid "[ESSID_IN_QUOTES]”
#wep1
#wep1	sudo iwconfig [interface] key HEX_KEY  
#wep1			or 
#wep1	sudo iwconfig [interface] key s:[PASSPHRASE]
#wep1
#wep1	sudo iwconfig [interface] key open
#wep1***	sudo iwconfig [interface] mode Managed
#wep1	sudo dhclient [interface]
#wep1
#wep1*** The security mode may be open or restricted, and its meaning depends on the
#wep1card used. With most cards, in open mode no authentication is used and the card
#wep1may also accept non-encrypted sessions, whereas in restricted mode only
#wep1encrypted sessions are accepted and the card will use authentication if
#wep1available.
#wep1
#wep1##### Note ####################################################################
#wep1WEP Key and special characters
#wep1
#wep1If your WEP key has some special characters in it. You might receive the error message
#wep1
#wep1	$ sudo iwconfig eth0 key s:KG”hSRaS{G!#[
#wep1	sudo iwconfig eth0 key s:KG"hSRaS{Gsudo iwconfig eth0 key s:KG"hSRaS{G[
#wep1
#wep1	.....
#wep1
#wep1	$sudo dhclient eth0
#wep1	Sending on Socket/fallback
#wep1	DHCPDISCOVER on eth0 to 255.255.255.255 port 67 interval 4
#wep1	DHCPDISCOVER on eth0 to 255.255.255.255 port 67 interval 10
#wep1	DHCPDISCOVER on eth0 to 255.255.255.255 port 67 interval 14
#wep1	DHCPDISCOVER on eth0 to 255.255.255.255 port 67 interval 3
#wep1	No DHCPOFFERS received.
#wep1	No working leases in persistent database - sleeping.
#wep1
#wep1You need to escape the special characters with a \ and it works
#wep1
#wep1	$sudo iwconfig eth0 key s:KG\"hSRaS\{G\!\#\[
#wep1###############################################################################
#wep1
#wep1>This guide taken from xibex.blogspot.com

#dir="/home/x/minimodem"
tmp="/tmp"


lines=$(echo -e "lines"|tput -S)
columns=$(echo -e "cols"|tput -S)
let l1=$lines-2
let l2=$lines-1
let col=$columns-6

check_internet(){
 ping -c 1 www.google.gr
 if [ $? != 0 ]; then
 dialog --msgbox "No internet connection! You will not be able to download or upgrade any packages." 8 40
 fi
}

findprog () {
    _foundprog=`which $1`
    return $?
}

check_dialog(){
if findprog dialog; then
    _yad=true
else
    echo "Need to install dialog package. Installing..."
    sudo apt-get -y install dialog
fi
}

#rm -f $tmp/*

check_internet
check_dialog

function internetmenu () {
dialog --no-tags --menu " Internet " 15 40 8 \
1 "WEP Connection" \
2 "WPA Connection" \
3 "Open Connection" \
4 "Install OpenSSH" 2> $tmp/answer

if [ "$?" = "0" ]
then
	ch=$(cat $tmp/answer)
	case $ch in
	# /home is selected
	  1) cat $DIR/cm.sh | grep "#wep1" | sed 's/#wep1//g' > $tmp"/cm_text.txt"
		 sed -i '$ d' $tmp"/cm_text.txt"
	     dialog --cr-wrap --title "WEP Connection" --textbox $tmp"/cm_text.txt" $l1 $col
	     internetmenu;;
	  2) cat $DIR/cm.sh | grep "#wpa1" | sed 's/#wpa1//g' > $tmp"/cm_text.txt"
		 sed -i '$ d' $tmp"/cm_text.txt"
	     dialog --cr-wrap --title "WPA Connection" --textbox $tmp"/cm_text.txt" $l1 $col
	     internetmenu;;	     
	  3) cat $DIR/cm.sh | grep "#open1" | sed 's/#open1//g' > $tmp"/cm_text.txt"
		 sed -i '$ d' $tmp"/cm_text.txt"
	     dialog --cr-wrap --title "Open Connection" --textbox $tmp"/cm_text.txt" $l1 $col
	     internetmenu;;		  
	  4) cat $DIR/cm.sh | grep "#ossh" | sed 's/#ossh//g' > $tmp"/cm_text.txt"
		 sed -i '$ d' $tmp"/cm_text.txt"
	     dialog --cr-wrap --title "Open SSH Install" --textbox $tmp"/cm_text.txt" $l1 $col
	     internetmenu;;   
	  *) internetmenu;;
        esac
# Cancel is pressed
else
        mainmenu
fi
}

function sysinfo () {
dialog --no-tags --menu " System Information " 15 40 8 \
1 "List USB Devices" \
2 "List PCI Devices" \
3 "CPU Information" \
4 "List All Hardware Information" \
5 "Swap File Information" \
6 "Partitions Information" \
7 "Process Information" \
8 "Ubuntu Version" \
9 "Memory Information" 2> $tmp/answer

if [ "$?" = "0" ]
then
	ch=$(cat $tmp/answer)
	case $ch in
	# /home is selected
	  1) lsusb > $tmp"/cm_text.txt"
	     dialog --cr-wrap --title "lsusb" --textbox $tmp"/cm_text.txt" $l1 $col 
	     sysinfo;;
          2) lspci > $tmp"/cm_text.txt"
	     dialog --cr-wrap --title "lspci" --textbox $tmp"/cm_text.txt" $l1 $col 
	     sysinfo;;
	  3) cat /proc/cpuinfo > $tmp"/cm_text.txt"
	     dialog --cr-wrap --title "cat /proc/cpuinfo" --textbox $tmp"/cm_text.txt" $l1 $col 
	     sysinfo;;
	  4) lshw > $tmp"/cm_text.txt"
	     dialog --cr-wrap --title "lshw" --textbox $tmp"/cm_text.txt" $l1 $col 
	     sysinfo;;
	  5) cat /proc/swaps > $tmp"/cm_text.txt"
	     dialog --cr-wrap --title "cat /proc/swaps" --textbox $tmp"/cm_text.txt" $l1 $col 
	     sysinfo;;
	6) df > $tmp"/cm_text.txt"
	     dialog --cr-wrap --title "df" --textbox $tmp"/cm_text.txt" $l1 $col 
	     sysinfo;;
	7) ps -aux > $tmp"/cm_text.txt"
	     dialog --cr-wrap --title "ps -aux" --textbox $tmp"/cm_text.txt" $l1 $col 
	     sysinfo;;
	8) lsb_release -a > $tmp"/cm_text.txt"
	     dialog --cr-wrap --title "lsb_release -a" --textbox $tmp"/cm_text.txt" $l1 $col 
	     sysinfo;;
	9) cat /proc/meminfo > $tmp"/cm_text.txt"
	     dialog --cr-wrap --title "cat /proc/meminfo" --textbox $tmp"/cm_text.txt" $l1 $col 
	     sysinfo;;
	  *) sysinfo;;
        esac
# Cancel is pressed
else
        mainmenu
fi
}

function exitmenu () {
dialog --clear --cancel-label "Back" --no-tags --menu " Exit Menu " 12 30 5 \
1 "Exit" \
2 "ShutDown PC" \
3 Reboot \
5 "Back to Main Menu" 2> $tmp/answer 

if [ "$?" = "0" ]
then
	ch=$(cat $tmp/answer)
	case $ch in
	# /home is selected
	  1) clear;exit;;
   	2) pass=$(dialog --passwordbox  " Enter your ADMIN password to shutdown computer... " 8 50 3>&1 1>&2 2>&3)
	   if [ "$?" = "0" ] 
	   then
             echo $pass | sudo -S shutdown -h now
	   fi;;
	  3) pass=$(dialog --passwordbox  " Enter your ADMIN password to shutdown computer... " 8 50 3>&1 1>&2 2>&3)
	   if [ "$?" = "0" ] 
	   then
             echo $pass | sudo -S reboot
	   fi;;
	  5) mainmenu;;
        esac
 
# Cancel is pressed
else
       exec $ecdir/emucom
fi
}

function mountmenu () {
dialog --backtitle " Minimodem " \
--no-tags --menu " Encryption " 15 40 8 \
1 "Mount ISO file" \
2 "Mount USB Device" \
3 "General info about un/mount drives" \
4 "Format Drive" \
5 "Swap File Information" \
6 "Partitions Information" \
7 "Process Information" \
8 "Ubuntu Version" \
9 "Memory Information" 2> $tmp/answer

if [ "$?" = "0" ]
then
	ch=$(cat $tmp/answer)
	case $ch in
	# /home is selected
	  1) cat $DIR/cm.sh | grep "#iso1" | sed 's/#iso1//g' > $tmp"/cm_text.txt"
		 sed -i '$ d' $tmp"/cm_text.txt"
	     dialog --cr-wrap --title "Mount ISO File" --textbox $tmp"/cm_text.txt" $l1 $col
	     mountmenu;;
      2) cat $DIR/cm.sh | grep "#usb1" | sed 's/#usb1//g' > $tmp"/cm_text.txt"
		 sed -i '$ d' $tmp"/cm_text.txt"
	     dialog --cr-wrap --title "Mount USB Device" --textbox $tmp"/cm_text.txt" $l1 $col
	     mountmenu;;
	  3) cat $DIR/cm.sh | grep "#fstab1" | sed 's/#fstab1//g' > $tmp"/cm_text.txt"
		 sed -i '$ d' $tmp"/cm_text.txt"
	     dialog --cr-wrap --title "General info about un/mount drives" --textbox $tmp"/cm_text.txt" $l1 $col
	     mountmenu;;
	  4) cat $DIR/cm.sh | grep "#format1" | sed 's/#format1//g' > $tmp"/cm_text.txt"
		 sed -i '$ d' $tmp"/cm_text.txt"
	     dialog --cr-wrap --title "Format drives" --textbox $tmp"/cm_text.txt" $l1 $col
	     mountmenu;;
	  5) cat /proc/swaps > $tmp"/cm_text.txt"
	     dialog --cr-wrap --title "cat /proc/swaps" --textbox $tmp"/cm_text.txt" $l1 $col 
	     mountmenu;;
	6) df > $tmp"/cm_text.txt"
	     dialog --cr-wrap --title "df" --textbox $tmp"/cm_text.txt" $l1 $col 
	     mountmenu;;
	7) ps -aux > $tmp"/cm_text.txt"
	     dialog --cr-wrap --title "ps -aux" --textbox $tmp"/cm_text.txt" $l1 $col 
	     mountmenu;;
	8) lsb_release -a > $tmp"/cm_text.txt"
	     dialog --cr-wrap --title "lsb_release -a" --textbox $tmp"/cm_text.txt" $l1 $col 
	     mountmenu;;
	9) cat /proc/meminfo > $tmp"/cm_text.txt"
	     dialog --cr-wrap --title "cat /proc/meminfo" --textbox $tmp"/cm_text.txt" $l1 $col 
	     mountmenu;;
	  *) mountmenu;;
        esac
# Cancel is pressed
else
        mainmenu
fi
}

function synapticmenu () {
dialog --no-tags --menu " Synaptic " 18 60 15 \
1 "Update Package List" \
2 "Upgrade All of your Software" \
3 "Check Depedencies & Packages" \
4 "Clean up Cache from Downloaded Packages" \
5 "Fix Broken Packages" \
6 "Find Package Version" \
7 "Backup Package List" \
8 "Restore Package List" \
I "Install Package" \
9 "Remove Package" \
10 "Complete Remove Package" \
11 "Search for Package" \
12 "Package Information" \
13 "Add Repository" \
14 "Remove Repository" \
15 "Edit sources.list" 2> $tmp/answer

if [ "$?" = "0" ]
then
	ch=$(cat $tmp/answer)
	case $ch in
	# /home is selected
	  1) clear;sudo apt-get update
	  read -p "Press [Enter] key to continue..."
	     synapticmenu;;
      2) clear;sudo apt-get upgrade
      read -p "Press [Enter] key to continue..."
	     synapticmenu;;
	  3) clear;sudo apt-get check
	  read -p "Press [Enter] key to continue..."
	     synapticmenu;;
	  4) clear;sudo apt-get clean
	  read -p "Press [Enter] key to continue..."
	     synapticmenu;;
	  5) clear;sudo apt-get -f install
	  read -p "Press [Enter] key to continue..."
	     synapticmenu;;
	6) package=$(dialog --inputbox "Enter package name:" 8 50 3>&1 1>&2 2>&3) 
		clear;dpkg -s $package
		read -p "Press [Enter] key to continue..."
	     synapticmenu;;
	7) clear;dpkg --get-selections > ./debianlist.txt
		dialog --infobox "List saved at debianlist.txt" 8 50
	     synapticmenu;;
	8) dialog --infobox "Importing list from debianlist.txt" 8 50
	    clear;dpkg --set-selections < ./debianlist.txt
		dialog --infobox "Operation complete." 8 50
	     synapticmenu;;
    Ι) package=$(dialog --inputbox "Enter package name:" 8 50 3>&1 1>&2 2>&3)
		clear;sudo apt-get install $package
		read -p "Press [Enter] key to continue..."
	     synapticmenu;;	     
	9) package=$(dialog --inputbox "Enter package name:" 8 50 3>&1 1>&2 2>&3)
		clear;sudo apt-get remove $package
		read -p "Press [Enter] key to continue..."
	     synapticmenu;;
	10) package=$(dialog --inputbox "Enter package name:" 8 50 3>&1 1>&2 2>&3)
		clear;sudo apt-get remove --purge $package
		read -p "Press [Enter] key to continue..."
	     synapticmenu;;
	11) package=$(dialog --inputbox "Enter package name:" 8 50 3>&1 1>&2 2>&3)
		clear;apt-cache search $package
		read -p "Press [Enter] key to continue..."
	     synapticmenu;;
	12) package=$(dialog --inputbox "Enter package name:" 8 50 3>&1 1>&2 2>&3)
		clear;apt-cache show $package
		read -p "Press [Enter] key to continue..."
	     synapticmenu;;     
	13) repo=$(dialog --inputbox "Enter repository:" 8 50 3>&1 1>&2 2>&3)
		clear;sudo add-apt-repository $repo
		read -p "Press [Enter] key to continue..."
	     synapticmenu;;
	14) package=$(dialog --inputbox "Enter repository:" 8 50 3>&1 1>&2 2>&3)
		clear;sudo add-apt-repository --purge $repo
		read -p "Press [Enter] key to continue..."
	     synapticmenu;;
	15) geany /etc/apt/sources.list &
	    synapticmenu;;     
	  *) synapticmenu;;
        esac
# Cancel is pressed
else
        mainmenu
fi
}

function appsmenu () {
dialog --backtitle " MyApps " \
--no-tags --menu "Main Menu" 15 40 8 \
1 "Hacking" \
2 "Console" \
3 "Ubuntu Best" \
4 "Ham Radio" 2> $tmp/answer

if [ "$?" = "0" ]
then
	ch=$(cat $tmp/answer)
	case $ch in
	# /home is selected
	  1) sudo apt-get install -y kismet
		sudo apt-get install -y aircrack-ng
		sudo apt-get install -y wifite
		sudo apt-get install -y kismet-plugins
		sudo apt-get install -y wireshark
		sudo apt-get install -y john
		sudo apt-get install -y ettercap-common ettercap-graphical
		sudo apt-get install -y hydra hydra-gtk
		sudo apt-get install -y dsniff
		sudo apt-get install -y btscanner	  
		sudo apt-get install -y reaper
		mkdir ~/Hacking
		#gerix cracking tool
		wget https://bitbucket.org/Skin36/gerix-wifi-cracker-pyqt4/downloads/gerix-wifi-cracker-master.rar -O ~/Hacking/
		#Crunch 3.5 wordlist maker
		wget http://downloads.sourceforge.net/project/crunch-wordlist/crunch-wordlist/crunch-3.5.tgz -O ~/Hacking/
		atool crunch-3.5.tgz -X ~/Hacking
		cd ~/Hacking/crunch-3.5
		sudo make
		sudo make install
		wget http://hashcat.net/files/hashcat-0.47.7z
	    read -p "Press [Enter] key to continue..."
	    appsmenu;;
	  2) #sudo apt-get install -y ninvaders
		#sudo apt-get install -y bastet
		#sudo apt-get install -y bastet
		#sudo apt-get install -y bsdgames
		sudo apt-get install -y alpine
		sudo apt-get install -y moc
		sudo apt-get install -y tmux
		sudo apt-get install -y weechat
		sudo apt-get install -y mc
		sudo apt-get install -y fte
		sudo apt-get install -y curl
		sudo apt-get install -y rsstail
		sudo apt-get install -y dialog
		sudo apt-get install -y ripit
		sudo apt-get install -y rig
		sudo apt-get install -y qalc
		sudo apt-get install -y qodem
		sudo apt-get install -y xdemorse
		sudo apt-get install -y minimodem
		sudo apt-get install -y gpm
		sudo apt-get install -y links2 
		sudo apt-get install -y mplayer
		sudo apt-get install -y links2
		sudo apt-get install -y fbi
		sudo apt-get install -y imagemagick
	    sudo apt-get install -y centerim
	    sudo apt-get install -y cdw #disc burn
	    sudo apt-get install -y finch #chat (facebook, aim, msn)
	    sudo apt-get install -y youtube-dl
	    sudo apt-get install -y wmctrl
	    sudo apt-get install -y python-pip python-dev build-essential
		sudo pip install --upgrade pip
		sudo pip install --upgrade virtualenv 
		sudo pip install mps
		sudo pip install mps-youtube
		sudo apt-get install -y gnome-web-photo
		#sudo apt-get install -y turses #twitter client
		sudo apt-get install -y aspell aspell-en aspell-el
		sudo apt-get install -y htop
		sudo apt-get install -y atool
	    read -p "Press [Enter] key to continue..."
	    appsmenu;;
      3) sudo apt-get remove leafpad
		sudo apt-get install -y sqlite3
		sudo apt-get install -y lsb-core
		sudo apt-get install -y gedit
		sudo apt-get install -y gnome-do
		sudo apt-get install -y vlc
		sudo apt-get install -y transmission
		sudo apt-get install -y gimp
		sudo apt-get install -y openshot
		sudo apt-get install -y openjdk-7-jdk
		sudo apt-get install -y filezilla
		sudo apt-get install -y p7zip-full
		sudo apt-get install -y arj ncompress
		sudo apt-get install -y ffmpeg
		sudo apt-get install -y flashplugin-installer
		echo "Add partners repo to install -y"
		sudo apt-get install -y dropbox
		sudo apt-get install -y skype
		sudo apt-get install -y pdfshuffler
		sudo apt-get install -y inkscape
		sudo apt-get install -y audacity
		sudo apt-get install -y avidemux
		sudo apt-get install -y gparted
		sudo apt-get install -y qmmp
		sudo apt-get install -y thunderbird
		sudo apt-get install -y ffmpeg libavcodec-extra-53
	    read -p "Press [Enter] key to continue...";;
	  4) sudo apt-get install -y xdemorse
		sudo apt-get install -y minimodem
		sudo apt-get install -y qrsstv
		sudo apt-get install -y fldigi
		sudo add-apt-repository ppa:gqrx/releases
		sudo apt-get update
		sudo apt-get install -y rtl-sdr
		sudo apt-get install -y gqrx-sdr
		wget http://github.com/EarToEarOak/RTLSDR-Scanner/archive/master.zip -O scanner.zip
		mkdir ~/Various/scanner/
		unzip scanner.zip -d ~/Various/scanner/
		rm scanner.zip
		sudo apt-get install python python-wxgtk2.8 python-matplotlib python-numpy python-imaging
		wget http://github.com/roger-/pyrtlsdr/archive/master.zip -O pyrtlsdr.zip
		unzip pyrtlsdr.zip -d ~/Various/scanner/
		rm pyrtlsdr.zip
		cd ~/Various/scanner/pyrtlsdr-master
		sudo python setup.py install
		#wget http://github.com/lulzlabs/AirChat/archive/master.zip -O airchat.zip
		#mkdir ~/Various/airchat
		#unzip airchat.zip -d ~/Various/airchat
		#rm airchat.zip
		#cd ~/Various/airchat/Airchat-master
		#sudo apt-get install make libcpanplus-perl libhttp-server-simple-perl libcrypt-cbc-perl libcrypt-rijndael-perl librpc-xml-perl libxml-feedpp-perl liblwp-protocol-socks-perl libnet-twitter-lite-perl libnet-server-perl
		#perl install-modules-airchat-debian.pl
		wget http://syncterm.bbsdev.net/syncterm-linux.gz -O ~/Downloads/synterm64.gz
		wget hhttp://syncterm.bbsdev.net/syncterm-linux-old.gz -O ~/Downloads/synterm32.gz
		read -p "Press [Enter] key to continue..."
		appsmenu;;
	  X) clear
	  exit;;
	  *) mainmenu;;
    esac
 
# Cancel is pressed
else
        mainmenu
fi
}

function commandsmenu() {
dialog --backtitle " Console Manager " \
--no-tags --menu "Distribution Download" 15 40 8 \
1 "Change User" \
2 "Kali Linux 1.0.6 32 Bit ISO" \
3 "Lubuntu 14.04 LTS (Intel x86) desktop CD" \
4 "Lubuntu 14.04 LTS 64-bit (AMD64) desktop CD" \
5 "Ubuntu 14.04 LTS (Intel x86) desktop CD" \
6 "Ubuntu 14.04 LTS 64-bit (AMD64) desktop CD" \
7 "Puppy linux - Slacko 5.7 PAE" \
8 "Puppy linux - Slacko 5.7 No-PAE" 2> $tmp/answer

if [ "$?" = "0" ]
then
	ch=$(cat $tmp/answer)
	case $ch in
	# /home is selected
	  1) user=$(dialog --inputbox "Enter user name:" 8 50 3>&1 1>&2 2>&3) 
		clear;su $user
		read -p "Press [Enter] key to continue..."
	     commandsmenu;;
	  2) clear;wget http://cdimage.kali.org/kali-latest/i386/kali-linux-1.0.6-i386.iso;;
      3) clear;wget http://cdimage.ubuntu.com/lubuntu/releases/14.04/release/lubuntu-14.04-desktop-i386.iso;;
      4) clear;wget http://cdimage.ubuntu.com/lubuntu/releases/14.04/release/lubuntu-14.04-desktop-amd64.iso;;
      5) clear;wget http://releases.ubuntu.com/14.04/ubuntu-14.04-desktop-i386.iso;;
      6) clear;wget http://releases.ubuntu.com/14.04/ubuntu-14.04-desktop-amd64.iso;;
      7) clear;wget http://distro.ibiblio.org/puppylinux/puppy-slacko-5.7/slacko-5.7.0-PAE.iso;;
      8) clear;wget http://distro.ibiblio.org/puppylinux/puppy-slacko-5.7/slacko-5.7-NO-pae.iso;;
 	  *) mainmenu;;
        esac
 
# Cancel is pressed
else
        mainmenu
fi
}

function downloadmenu () {
dialog --backtitle " Console Manager " \
--no-tags --menu "Distribution Download" 15 40 8 \
1 "Kali Linux 1.0.6 64 Bit ISO" \
2 "Kali Linux 1.0.6 32 Bit ISO" \
3 "Lubuntu 14.04 LTS (Intel x86) desktop CD" \
4 "Lubuntu 14.04 LTS 64-bit (AMD64) desktop CD" \
5 "Ubuntu 14.04 LTS (Intel x86) desktop CD" \
6 "Ubuntu 14.04 LTS 64-bit (AMD64) desktop CD" \
7 "Puppy linux - Slacko 5.7 PAE" \
8 "Puppy linux - Slacko 5.7 No-PAE" 2> $tmp/answer

if [ "$?" = "0" ]
then
	ch=$(cat $tmp/answer)
	case $ch in
	# /home is selected
	  1) clear;wget http://cdimage.kali.org/kali-latest/amd64/kali-linux-1.0.6-amd64.iso ;;
	  2) clear;wget http://cdimage.kali.org/kali-latest/i386/kali-linux-1.0.6-i386.iso;;
      3) clear;wget http://cdimage.ubuntu.com/lubuntu/releases/14.04/release/lubuntu-14.04-desktop-i386.iso;;
      4) clear;wget http://cdimage.ubuntu.com/lubuntu/releases/14.04/release/lubuntu-14.04-desktop-amd64.iso;;
      5) clear;wget http://releases.ubuntu.com/14.04/ubuntu-14.04-desktop-i386.iso;;
      6) clear;wget http://releases.ubuntu.com/14.04/ubuntu-14.04-desktop-amd64.iso;;
      7) clear;wget http://distro.ibiblio.org/puppylinux/puppy-slacko-5.7/slacko-5.7.0-PAE.iso;;
      8) clear;wget http://distro.ibiblio.org/puppylinux/puppy-slacko-5.7/slacko-5.7-NO-pae.iso;;
 	  *) mainmenu;;
        esac
 
# Cancel is pressed
else
        mainmenu
fi
}

function mainmenu () {
dialog --backtitle " Console Manager " \
--no-cancel --no-tags --menu "Main Menu" 15 40 8 \
1 "System Information" \
2 "Packages / Synaptic" \
3 "Commands" \
4 "Internet" \
5 "Mount" \
6 "My Apps" \
7 "Xorg" \
8 "Create Bash Aliases" \
9 "Distribution Download" \
X Exit 2> $tmp/answer

if [ "$?" = "0" ]
then
	ch=$(cat $tmp/answer)
	case $ch in
	# /home is selected
	  1) sysinfo;;
	  2) synapticmenu;;
      3) commandsmenu;;
	  4) internetmenu;;
	  5) mountmenu;;
	  6) appsmenu;;
	  8) cat $DIR/cm.sh | grep "#bals" | sed 's/#bals//g' > $tmp"/cm_text.txt"
		 sed -i '$ d' $tmp"/cm_text.txt"
		 cp $tmp"/cm_text.txt" ~/.bash_aliases
		 source ~/.bash_aliases
		 dialog --msgbox "File .bash_aliases created and applied." 7 40
		 mainmenu;;
	  9) downloadmenu;;
	  H) exec $menu/help.sh;;
	  X) exitmenu;;
	  *) exec $dir/cm.sh;;
        esac
 
# Cancel is pressed
else
        exec $dir/cm.sh
fi
}

mainmenu
exit
