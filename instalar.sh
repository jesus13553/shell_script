cp _entorno__29_abr_2019_.sh MCHROOT/
system_to_chroot () 
{ 
    eval "$_new";
    function chroot_mount_bind () 
    { 
        eval "$_new";
        local var=${@:$#:$#};
        var=${var//\/};
        echo ${@:1:$#-1} | sed 's/ /\n/g' | awk '{ var="sudo mount --rbind "$_" '`pwd`/${var}'"$_ ; print var | "sh"  ;}'
    };
    function _get_chroot () 
    { 
        eval "$_new";
        mount_overlay_v1 / TRABAJO/;
        chroot_mount_bind /dev/ /proc/ /sys /var/run/dbus/ TRABAJO/;
        sudo chroot TRABAJO/
    };
    function mount_overlay_v1 () 
    { 
        eval "$_new";
        [[ -d /tmp/upperdir ]] || mkdir /tmp/upperdir;
        [[ -d /tmp/workdir ]] || mkdir /tmp/workdir;
        local var=' sudo mount -t overlay -o lowerdir=xxx,upperdir=/tmp/upperdir,workdir=/tmp/workdir';
        for a in ${@:1:$#-1};
        do
            var=${var/xxx/${a}:xxx};
        done;
        eval "${var//:xxx/} overlay ${@:$#:$#}"
    }
}
system_to_chroot
[[ -d MISO/ ]] || mkdir MISO/ MSQUAS/ MCHROOT/
_arch_to_chroot () 
{ 
    eval "$_new";
    mount archlinux-2019.03.01-x86_64.iso MISO/;
    mount MISO/arch/x86_64/airootfs.sfs MSQUAS/;
    mount_overlay_v1 MSQUAS/ MCHROOT/;
    chroot_mount_bind /dev/ /sys/ /proc/ MCHROOT/
}
_mk_instalar_sistema () 
{ 
    eval "$_new";
    cat <<'INJECT' > $1
_to_mount () 
{ 
    eval "$_new";
    _d=$1;
    _d=${_d//*\/};
     mkdir /${_d^^}
     _dir=${_d^^};
     mount $1 /${_d^^}
     export $_dir
}
__dev() { _dev=${1%[1-9]} ; export _dev; }
__dev $1
_to_mount $1
system_to_chroot () 
{ 
    eval "$_new";
    function chroot_mount_bind () 
    { 
        eval "$_new";
        local var=${@:$#:$#};
        var=${var//\/};
        echo ${@:1:$#-1} | sed 's/ /\n/g' | awk '{ var="sudo mount --rbind "$_" '`pwd`/${var}'"$_ ; print var | "sh"  ;}'
    };
    function _get_chroot () 
    { 
        eval "$_new";
        mount_overlay_v1 / TRABAJO/;
        chroot_mount_bind /dev/ /proc/ /sys /var/run/dbus/ TRABAJO/;
        sudo chroot TRABAJO/
    };
    function mount_overlay_v1 () 
    { 
        eval "$_new";
        [[ -d /tmp/upperdir ]] || mkdir /tmp/upperdir;
        [[ -d /tmp/workdir ]] || mkdir /tmp/workdir;
        local var=' sudo mount -t overlay -o lowerdir=xxx,upperdir=/tmp/upperdir,workdir=/tmp/workdir';
        for a in ${@:1:$#-1};
        do
            var=${var/xxx/${a}:xxx};
        done;
        eval "${var//:xxx/} overlay ${@:$#:$#}"
    }
}
system_to_chroot
__instalar_distro ()
{ 
    set -- ${1//\//};
    _dir=${1:-MP};
     . _entorno__29_abr_2019_.sh 
    mkdir -p ${_dir}/{root,tmp};
    mkdir -m 0755 -p ${_dir}/var/{cache/pacman/pkg,lib/pacman,log} ${_dir}/{dev,run,etc};
    mkdir -m 1777 -p ${_dir}/tmp;
    mkdir -m 0555 -p ${_dir}/{sys,proc};
    yes | cp -i  -a /etc/pacman.d/gnupg "${_dir}/etc/pacman.d/";
    yes | cp -i  -a /etc/pacman.d/mirrorlist "${_dir}/etc/pacman.d/";
    yes | cp _entorno__29_abr_2019_.sh  ${_dir};
    sed '/^#/d;s/Requ.*/Never/g;/^$/d' -i /etc/pacman.conf
__pacman () 
{ 
    eval "$_new";
     pacman -r ${_dir}/ -Sy ${@:-base} --cachedir=${_dir}/var/cache/pacman/pkg --noconfirm
}
    chroot_mount_bind /dev/ /sys/ /proc/ ${_dir}/
    echo nameserver 8.8.8.8 > ${_dir}/etc/resolv.conf
    mount -o bind /var/cache/pacman/pkg ${_dir}/var/cache/pacman/pkg 
    pacman-key --init
 #   __pacman ${@:2:$#}
}
__instalar_distro $_dir
__pacman base linux grub networkmanager
__pacman base-devel ntfs-3g  gvfs gvfs-afc gvfs-mtp
__pacman xorg-server xorg-xinit xterm mesa mesa-demos xf86-video-vesa  mate mate-extra gdm
__adduser () 
{ 
    eval "$_new";
    cat <<'END' > ${_dir}/root/.bashrc
adduser () 
{ 
    eval "$_new";
    useradd -m -g users -G audio,lp,optical,storage,video,wheel,games,power,scanner -s /bin/bash $1;
    passwd $1
}
END
}
__adduser
__red () 
{ 
    eval "$_new";
    cat <<'END'  >> ${_dir}/root/.bashrc
_wifi_connect () 
{ $1
    eval "$_new";
    nmcli dev wifi connect $1 password $2
}
END
}
__red
_ajustes () 
{ 
    cat <<'END' > ${_dir}/ajustes.sh
echo ArchLinux > /etc/hostname
sed '/^#/d;s/Requ.*/Never/g;/^$/d' -i /etc/pacman.conf
ln -sf /usr/share/zoneinfo/Europe/Madrid /etc/localtime
locale-gen
echo LANG=es_ES.UTF-8 > /etc/locale.conf
hwclock -w
echo KEYMAP=la-latin1 > /etc/vconsole.conf
echo "Password ROOT ???? " ;
passwd 
echo Instalando para $_dev
read E
[[ $E == q ]] && return 0;
echo "Instalando Para $_dev"
sleep 2;
grub-install --target i386-pc ${_dev:-/dev/sdb}
grub-mkconfig -o /boot/grub/grub.cfg
systemctl enable gdm.service
systemctl enable NetworkManager.service
. /root/.bashrc
echo nameserver 8.8.8.8 > /etc/resolv.conf
read -p "Nuevo Usuario ??? " E ;
[[ $E != q ]] && adduser $E;
END
}
_ajustes
chroot $_dir /bin/bash /ajustes.sh
INJECT
}
_arch_to_chroot
mount -o bind /ARCHPAQ/ MCHROOT/var/cache/pacman/pkg 
echo nameserver 8.8.8.8 >   MCHROOT/etc/resolv.conf
_mk_instalar_sistema   MCHROOT/instalar.sh
chroot  MCHROOT/ /bin/bash /instalar.sh $1
