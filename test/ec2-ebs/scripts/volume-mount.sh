#!bin/bash

vgchange -ay

DEVICE_FS=`blkid -o value -s TYPE ${DEVICE_NAME}`
if [ "`echo -n $DEVICE_FS`" == "" ] ; then
    pvcreate ${DEVICE_NAME}
    vgcreate data ${DEVICE_NAME}
    lvcreate --name ${VOLUME_NAME} -l 100%FREE data
    mkfs.ext4 /dev/data/${VOLUME_NAME}
fi
mkdir -p /data
echo "/dev/data/${VOLUME_NAME} /data ext4 defaults 0 0" >> /etc/fstab
mount /data