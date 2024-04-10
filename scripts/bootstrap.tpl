#!/bin/bash -x
sudo su -
yum install -y nfs-utils
#EFS CREATION AND MOUNTING
TOKEN=$(curl --request PUT "http://169.254.169.254/latest/api/token" --header "X-aws-ec2-metadata-token-ttl-seconds: 3600")
REGION=$(curl -s http://169.254.169.254/latest/meta-data/placement/region --header "X-aws-ec2-metadata-token: $TOKEN")
MOUNT_POINT="${MOUNT_POINT}"
mkdir -p ${MOUNT_POINT}
chown ec2-user:ec2-user ${MOUNT_POINT}
echo "${file_system_id}".efs.${REGION}.amazonaws.com:/ ${MOUNT_POINT}  nfs4 nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2,_netdev 0 0 >> /etc/fstab
mount -a -t nfs4
chmod -R 755 /var/www/html

# Modify KeepAliveTimeout setting
sudo sed -i 's/^\(KeepAliveTimeout\s*\).*/\1 65/' /etc/httpd/conf/httpd.conf


cd /var/www/html

#New Addition for debugging
# Check if directory exists and is empty
if [ -d "CliXX_Retail_Repository" ] && [ -z "$(ls -A CliXX_Retail_Repository)" ]; then
    # Directory exists and is empty, proceed with cloning
    :
else
    # Directory doesn't exist or is not empty, handle accordingly
    echo "Directory CliXX_Retail_Repository already exists and is not empty. Skipping cloning."
fi

git clone https://github.com/stackitgit/CliXX_Retail_Repository.git
cp -r CliXX_Retail_Repository/* /var/www/html
  
#Creating Docker
sudo amazon-linux-extras install docker -y
sudo systemctl start docker
sudo systemctl status docker
sudo systemctl enable docker
sudo usermod -a -G docker ec2-user 
mkdir Dockerfile
cp -r /var/www/html Dockerfile

# Replace DB_HOST name with RDS endpoint 

sed -i -e "/.*DB_HOST*./ s/.*/define('DB_HOST', '${DB_HOST}');/" /var/www/html/wp-config.php

#updating the sql table
mysql -u "${DB_USER}" -p"${DB_PASSWORD}" -h "${DB_HOST}" -D "${DB_NAME}" <<EOF
UPDATE wp_options SET option_value='${ALB_DNS}' WHERE option_value LIKE '%elb%';
EOF


sudo mount -a


#EBS configuration
fdisk /dev/sdb <<EEOF
p
n
p
1
2048
20971519
p
w
EEOF
fdisk /dev/sdc <<EEOF
p
n
p
1
2048
20971519
p
w
EEOF
fdisk /dev/sdd <<EEOF
p
n
p
1
2048
20971519
p
w
EEOF
fdisk /dev/sde <<EEOF
p
n
p
1
2048
20971519
p
w
EEOF
fdisk /dev/sdf <<EEOF
p
n
p
1
2048
20971519
p
w
EEOF

# creating the disk labels (physical volume)
pvcreate /dev/sdb1 /dev/sdc1 /dev/sdd1 /dev/sde1 /dev/sdf1

# creating volume group 
vgcreate stack_vg /dev/sdb1 /dev/sdc1 /dev/sdd1 /dev/sde1 /dev/sdf1

# listing volume group(s)
vgs

# creating new logical volumes (LUNs) from volume groups with 8GB of space allocated initially
lvcreate -L 8G -n Lv_u01 stack_vg
lvcreate -L 8G -n Lv_u02 stack_vg
lvcreate -L 8G -n Lv_u03 stack_vg
lvcreate -L 8G -n Lv_u04 stack_vg
lvcreate -L 8G -n Lv_backup stack_vg

# listing volumes 
lvs

# creating ext4 filesystems on the logical volumes
mkfs.ext4 /dev/stack_vg/Lv_u01
mkfs.ext4 /dev/stack_vg/Lv_u02
mkfs.ext4 /dev/stack_vg/Lv_u03
mkfs.ext4 /dev/stack_vg/Lv_u04
mkfs.ext4 /dev/stack_vg/Lv_backup

# creating mount points that will hold the space for logical volumes
mkdir /u01
mkdir /u02
mkdir /u03
mkdir /u04
mkdir /backup

# mounting the volumes on the mount points
mount /dev/stack_vg/Lv_u01 /u01
mount /dev/stack_vg/Lv_u02 /u02
mount /dev/stack_vg/Lv_u03 /u03
mount /dev/stack_vg/Lv_u04 /u04
mount /dev/stack_vg/Lv_backup /backup


# resize gets reflected after running command below
resize2fs /dev/mapper/stack_vg-Lv_u01
resize2fs /dev/mapper/stack_vg-Lv_u02
resize2fs /dev/mapper/stack_vg-Lv_u03
resize2fs /dev/mapper/stack_vg-Lv_u04
resize2fs /dev/mapper/stack_vg-Lv_backup

echo "/dev/mapper/stack_vg-Lv_u01 /u01 ext4 defaults 1 2" >> "/etc/fstab"
echo "/dev/mapper/stack_vg-Lv_u02 /u02 ext4 defaults 1 2" >> "/etc/fstab"
echo "/dev/mapper/stack_vg-Lv_u03 /u03 ext4 defaults 1 2" >> "/etc/fstab"
echo "/dev/mapper/stack_vg-Lv_u04 /u04 ext4 defaults 1 2" >> "/etc/fstab"
echo "/dev/mapper/stack_vg-Lv_backup /backup ext4 defaults 1 2" >> "/etc/fstab"

ls -ltr


# Restart Apache after updating the configuration
sudo systemctl enable httpd 
sudo systemctl restart httpd
 


