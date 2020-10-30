#!/bin/bash
set -e

#set -x

USER_UID=${USER_UID:-1000}
USER_GID=${USER_GID:-1000}

TEAMS_USER=teams

install_teams() {
  echo "Installing teams-wrapper..."
  install -m 0755 /var/cache/teams/teams-wrapper /target/
  echo "Installing teams..."
  ln -sf teams-wrapper /target/teams
}

uninstall_teams() {
  echo "Uninstalling teams-wrapper..."
  rm -rf /target/teams-wrapper
  echo "Uninstalling teams..."
  rm -rf /target/teams
}

create_user() {
  # create group with USER_GID
  if ! getent group ${TEAMS_USER} >/dev/null; then
    groupadd -f -g ${USER_GID} ${TEAMS_USER} >/dev/null 2>&1
  fi

  # create user with USER_UID
  if ! getent passwd ${TEAMS_USER} >/dev/null; then
    adduser --disabled-login --uid ${USER_UID} --gid ${USER_GID} \
      --gecos 'Teams' ${TEAMS_USER} >/dev/null 2>&1
  fi
  chown ${TEAMS_USER}:${TEAMS_USER} -R /home/${TEAMS_USER}
  adduser ${TEAMS_USER} sudo
}

grant_access_to_video_devices() {
  for device in /dev/video*
  do
    if [[ -c $device ]]; then
      VIDEO_GID=$(stat -c %g $device)
      VIDEO_GROUP=$(stat -c %G $device)
      if [[ ${VIDEO_GROUP} == "UNKNOWN" ]]; then
        VIDEO_GROUP=teamsvideo
        groupadd -g ${VIDEO_GID} ${VIDEO_GROUP}
      fi
      usermod -a -G ${VIDEO_GROUP} ${TEAMS_USER}
      break
    fi
  done
}

launch_bash() {
  cd /home/${TEAMS_USER}
#  exec sudo -HEu ${TEAMS_USER} PULSE_SERVER=/run/pulse/native QT_GRAPHICSSYSTEM="native" xcompmgr -c -l0 -t0 -r0 -o.00 &
#  exec sudo -HEu ${TEAMS_USER} PULSE_SERVER=/run/pulse/native QT_GRAPHICSSYSTEM="native" $@
  exec sudo -HEu ${TEAMS_USER} PULSE_SERVER=/run/pulse/native QT_GRAPHICSSYSTEM="native" /bin/bash
}

case "$1" in
  install)
    install_teams
    ;;
  uninstall)
    uninstall_teams
    ;;
  bash)
    create_user
    grant_access_to_video_devices
    echo "$1"
    launch_bash $@
    ;;
  *)
    exec $@
    ;;
esac
