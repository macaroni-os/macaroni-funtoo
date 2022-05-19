#!/bin/bash

set -x

GDM_FILE="/usr/share/gdm/defaults.conf"
CUSTOM_GDM_FILE="/etc/gdm/custom.conf"
LXDM_FILE="/etc/lxdm/lxdm.conf"
LIGHTDM_FILE="/etc/lightdm/lightdm.conf"
SDDM_FILE="/etc/sddm.conf"

LIVE_USER_GROUPS="audio bumblebee cdrom cdrw clamav console games \
kvm lp lpadmin messagebus plugdev polkituser portage pulse pulse-access pulse-rt \
scanner usb users uucp vboxguest vboxusers video wheel"
LIVE_USER=macaroni
LIVE_PERSISTENT_HOME_LABEL="live:/home"

setup_autologin() {
    # GDM - GNOME
    if [ -f "${GDM_FILE}" ]; then
        sed -i "s/^AutomaticLoginEnable=.*/AutomaticLoginEnable=true/" ${GDM_FILE}
        sed -i "s/^AutomaticLogin=.*/AutomaticLogin=${LIVE_USER}/" ${GDM_FILE}

        sed -i "s/^TimedLoginEnable=.*/TimedLoginEnable=true/" ${GDM_FILE}
        sed -i "s/^TimedLogin=.*/TimedLogin=${LIVE_USER}/" ${GDM_FILE}
        sed -i "s/^TimedLoginDelay=.*/TimedLoginDelay=0/" ${GDM_FILE}

        # It seems that restart of the getty@tty1.service (inside setup_vt_autologin)
        # block gdm bootstrap
        sed -i "s/^Conflicts=getty@t.*//g" ${GDM_FILE}

    elif [ -f "${CUSTOM_GDM_FILE}" ]; then
        # FIXME: if this is called multiple times, it generates duplicated entries
        sed -i "s:\[daemon\]:\[daemon\]\nAutomaticLoginEnable=true\nAutomaticLogin=${LIVE_USER}\nTimedLoginEnable=true\nTimedLogin=${LIVE_USER}\nTimedLoginDelay=0:" \
            "${CUSTOM_GDM_FILE}"
        # change other entries there
        sed -i "s/^TimedLogin=.*/TimedLogin=${LIVE_USER}/" "${CUSTOM_GDM_FILE}"
        sed -i "s/^AutomaticLogin=.*/AutomaticLogin=${LIVE_USER}/" "${CUSTOM_GDM_FILE}"
        sed -i "s/^Conflicts=getty@t.*//g" /lib/systemd/system/gdm.service
    fi

    # LXDM
    if [ -f "$LXDM_FILE" ]; then
        sed -i "s/autologin=.*/autologin=${LIVE_USER}/" $LXDM_FILE
        sed -i "/^#.*autologin=/ s/^#//" $LXDM_FILE
    fi

    # SDDM
    if [ -f "$SDDM_FILE" ]; then
        sed -i "s/^User=.*/User=${LIVE_USER}/" $SDDM_FILE
        sed -i "s/^Session=.*/Session=default/" $SDDM_FILE

        # This fix shutdown issue with sddm
        #	systemctl stop getty@tty1
    fi

    # LightDM
    if [ -f "$LIGHTDM_FILE" ]; then
        sed -i "s/autologin-user=.*/autologin-user=${LIVE_USER}/" $LIGHTDM_FILE
        sed -i "/^#.*autologin-user=/ s/^#//" $LIGHTDM_FILE
    fi

    fixup_gnome_autologin_session
}

disable_autologin() {
    # GDM - GNOME
    if [ -f "${GDM_FILE}" ]; then
        sed -i "/^AutomaticLoginEnable=.*/d" ${CUSTOM_GDM_FILE}
        sed -i "/^AutomaticLogin=.*/d" ${CUSTOM_GDM_FILE}
        sed -i "/^TimedLoginEnable=.*/d" ${CUSTOM_GDM_FILE}
        sed -i "/^TimedLogin=.*/d" ${CUSTOM_GDM_FILE}
        sed -i "/^TimedLoginDelay=.*/d" ${CUSTOM_GDM_FILE}
        sed -i "s/^AutomaticLoginEnable=.*/AutomaticLoginEnable=false/" ${GDM_FILE}
    fi

    # LXDM
    if [ -f "$LXDM_FILE" ]; then
        sed -i "s/^autologin=.*/autologin=/" $LXDM_FILE
    fi

    # LightDM
    if [ -f "$LIGHTDM_FILE" ]; then
        sed -i "s/^autologin-user=.*/#autologin-user=/" $LIGHTDM_FILE
    fi

    # SDDM
    if [ -f "$SDDM_FILE" ]; then
        sed -i "s/Relogin=.*/Relogin=false/" $SDDM_FILE
        sed -i "s/^Session=.*/Session=/" $SDDM_FILE
        sed -i "s/^User=.*/User=/" $SDDM_FILE
    fi
}

setup_home_mount() {
    local target_label="${LIVE_PERSISTENT_HOME_LABEL}"
    local device=$(blkid -L "${target_label}")

    # check if there is a device available
    [ -z "${device}" ] && return 0

    mkdir -p /home || return 1
    mount "${device}" /home || return 1
}

setup_live_user() {
    local live_user="${1}"
    local live_uid="${2}"
    if [ -z "${live_user}" ]; then
        live_user="${LIVE_USER}"
    fi
    if [ -n "${live_uid}" ]; then
        live_uid="-u ${live_uid}"
    fi
    id ${live_user} &> /dev/null
    if [ "${?}" != "0" ]; then
        local live_groups=""
        local avail_groups=$(cat /etc/group | cut -d":" -f 1 | xargs echo)
        for a_group in ${avail_groups}; do
            for p_group in ${LIVE_USER_GROUPS}; do
                if [ "${p_group}" = "${a_group}" ]; then
                    if [ -z "${live_groups}" ]; then
                        live_groups="${p_group}"
                    else
                        live_groups="${live_groups},${p_group}"
                    fi
                fi
            done
        done
        # then setup live user, that is missing
        useradd -d "/home/${live_user}" -g root -G ${live_groups} -c "MacaroniOS" \
            -m -N -p "" -s /bin/bash ${live_uid} "${live_user}"
        # setting sudoers file
        [ -e /etc/sudoers ] && grep -q -F ${live_user} /etc/sudoers || echo "${live_user} ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers
        return 0
    fi
    return 1
}

setup_desktop_session() {
    local usr="${1}"
    local sess="${2}"

    local dmrc_file="/home/${usr}/.dmrc"
    local skel_dmrc_file="/etc/skel/.dmrc"

    local dmrc_f_dir=
    for dmrc_f in "${dmrc_file}" "${skel_dmrc_file}"; do
        dmrc_f_dir=$(dirname "${dmrc_f}")
        [ -d "${dmrc_f_dir}" ] || continue

        echo "[Desktop]" > "${dmrc_f}"
        echo "Session=${sess}" >> "${dmrc_f}"
        chown "${usr}" "${dmrc_f}"
    done

    if [ -x "/usr/libexec/gdm-set-default-session" ]; then
        # oh my fucking glorious god, this
        # is AccountsService bullshit
        # cross fingers
        gdm-set-default-session "${sess}"
    fi
    if [ -x "/usr/libexec/gdm-set-session" ]; then
        # GDM 3.6 support
        /usr/libexec/gdm-set-session "${usr}" "${sess}"
    fi

    # LightDM support
    ln -sf "${sess}.desktop" /usr/share/xsessions/default.desktop
}

setup_gui_installer() {
    # Configure Fluxbox
    local flux_dir="/home/${LIVE_USER}/.fluxbox"
    local flux_startup_file="${flux_dir}/startup"
    if [ ! -d "${flux_dir}" ]; then
        mkdir "${flux_dir}" && chown "${LIVE_USER}" "${flux_dir}"
    fi
    sed -i "/installer --fullscreen/ s/^# //" "${flux_startup_file}"

    setup_desktop_session "${LIVE_USER}" "fluxbox"

}

# This function reads /etc/skel/.dmrc and properly
# set the Session= value inside AccountsService.
# Blame the idiots who broke de-facto standards
# and created this fugly thing called AccountsService
fixup_gnome_autologin_session() {
    local cur_session=

    if [ -f "/etc/skel/.dmrc" ]; then
        cur_session=$(cat /etc/skel/.dmrc | grep ^Session | cut -d"=" -f 2)
    fi
    if [ -z "${cur_session}" ]; then
        return 0
    fi

    setup_desktop_session "${LIVE_USER}" "${cur_session}"
}

systemd_running() {
    test -d /run/systemd/system
}

openrc_running() {
    test -e /run/openrc/softlevel
}

setup_default_xsession() {
  local sess="${1}"
  echo "[Desktop]" > /etc/skel/.dmrc
  echo "Session=${sess}" >> /etc/skel/.dmrc
  rm -vf /usr/share/xsessions/default.desktop || true
  ln -sf "${sess}.desktop" /usr/share/xsessions/default.desktop
}


setup_openrc_network() {
  # Setup network
  cd /etc/init.d
  ln -s netif.tmpl net.eth0
  rc-update add net.eth0 default
  echo template=dhcpcd > /etc/conf.d/net.eth0
  re-update add "net.eth0"

}

setup_xorg_server() {
  mkdir -p /etc/X11/ || true

  env-update
  ldconfig
  source /etc/profile

  whip hook fonts.convert_pfb
  whip hook fonts.setup_all_fonts
  whip hook gtk.glib_update_schemas
  whip hook gtk.gtk_update_icons
  whip hook gtk.mime_update_db
  whip hook gdb.setup

  return 0
}


prepare() {

  EROOT=""

  touch /etc/fstab
  # Trying to fix /dev/ptmx group issue
  #echo "devpts /dev/pts devpts gid=5,mode=620 0 0" >> /etc/fstab

  # Fix access to var directory
  chmod a+r /var

  chown gdm:gdm /var/lib/gdm -R

  echo "Europe/Rome" > /etc/timezone

 # TODO: temporary
 # kvm user used on setup s390x / ppc device from udev rule
 missing="avahi-autoipd ddclient dhcpcd fdm pulse sddm pulse-access ushare utmp video vboxsf vboxusers vboxguest kvm"
 missing="${missing}    adm   audio   bin   cdrom   console   daemon   dialout   disk   floppy   input   ipsec   kmem   locate   lp   lpadmin   mail   man   mem   messagebus   netdev   news   nobody   nogroup   plugdev   realtime   render   root   sys   tape   tss   tty   usb   users   utmp   uucp   video   wheel   halt   shutdown   operator   sync"

 for i in ${missing} ; do
 entities merge -s /usr/share/macaroni/entities -e $i
 done

 # Create root and macaroni user
  entities merge -s /var/lib/macaroni/entities -a
  # user root is already present (created by virtual-entities/base)
  # In this case `entities merge` command doesn't replace the password.
  # I need use apply command.
  entities apply -f /etc/shadow /var/lib/macaroni/entities/entity_shadow_root.yaml

  echo "Creating /etc/inittab..."
  cp /var/lib/macaroni/inittab /etc/inittab -v


  # The suid is removed when the installation is completed.
  chmod u+s /usr/bin/pkexec

  whip hook colord.colord_setup
  whip hook vboxguest.vboxguest_setup

  entities merge -s /var/lib/macaroni/entities-macaroni-groups -a

  echo "macaroni-funtoo" > /etc/hostname
  sed -i -e 's|^hostname=.*|hostname="macaroni-funtoo"|' /etc/conf.d/hostname

  entities list users --user-has-shadow
  entities list groups --group-has-shadow

  # Ensure right permissions of the dbus-daemon-launch-helper
  # TODO: convert this in whip hook and finalizer
  chown root:messagebus /usr/libexec/dbus-daemon-launch-helper
  chmod 4750 /usr/libexec/dbus-daemon-launch-helper

  # openrc_init_runlevels

  mkdir /var/tmp || true

  # Temporary stuff

  # Setup openrc runlevels
  whip hook openrc.openrc_setup
  whip hook polkit.polkit_setup
  whip hook dbus.dbus_gen_machineid

  ENABLED_SERVICES=(
    "avahi-daemon"
    "local"
    "bluetooth"
    # Temporay enable logger always. On ISO probably we can to maintain
    # this off.
    "metalog"
    "NetworkManager"
    "xdm"

    "virtualbox-guest-additions"

#      "cups"
#        "cups-browsed"
  )
  for srv in "${ENABLED_SERVICES[@]}"; do
      rc-update add "${srv}" default
  done

  echo "
127.0.0.1   macaroni-funtoo localhost
::1         macaroni-funtoo localhost
" > /etc/hosts

  # Temporary. Maybe it's better set UTC here.
  ln -s /usr/share/zoneinfo/Europe/Rome /etc/localtime


  ENABLED_BOOT_SERVICES=(
    "dbus"
    "binfmt"
    "elogind"
    "hostname"
    #"modules"
    "opentmpfiles-setup"
    "procfs"
    "root"
    "swap"
    "urandom"
  )

  for srv in "${ENABLED_BOOT_SERVICES[@]}"; do
      rc-update add "${srv}" boot
  done

  ENABLED_SYSINIT_SERVICES=(
    "udev-postmount"
    "udev-trigger"
    "udev-settle"
    "cgroups"
    "devfs"
    "dmesg"
    "sysfs"
  )
  for srv in "${ENABLED_SYSINIT_SERVICES[@]}"; do
      rc-update add "${srv}" sysinit
  done

  setup_xorg_server

  eselect opengl set xorg-x11 --use-old

  if [ -f "/usr/share/xsessions/gnome.desktop" ]; then
      setup_default_xsession "gnome"
  fi

  locale-gen

  # Temporary fix for gnome
  if [ -e /etc/motd ] ; then
    cp /etc/motd /etc/issue
    rm /etc/motd
  fi

  # Temporary fix until entities will handle this
  mkdir -p /home/macaroni
  chown macaroni:users -R /home/macaroni

  #sed -i -e 's|INACTIVE_TIMEOUT.*|INACTIVE_TIMEOUT=60|g' /etc/conf.d/NetworkManager

  echo "macaroni ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers.d/99-macaroni

  dash2dockid=$(eselect gnome-shell-extensions list  | grep dash-to-dock | awk '{ print $1 }' | sed -e 's|\[||g' -e 's|\]||g')
  eselect gnome-shell-extensions list
  eselect gnome-shell-extensions set ${dash2dockid}
  eselect gnome-shell-extensions list

  ldconfig

  # Setup default plymouth theme
  plymouth-set-default-theme funtoo
}
