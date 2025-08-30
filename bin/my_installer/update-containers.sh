#!/bin/sh
set -eu
. "/usr/share/my_stuff/lib/common/Distro_path"

IMAGES_2_SKIP_distrobox="$(cd "${__distro_path_root}"/bin/my_installer/distrobox_center && ls || :)"
IMAGES_2_SKIP_containers="$(cd "${__distro_path_root}"/bin/my_installer/containers_center && ls || :)"
IMAGES_2_SKIP="$IMAGES_2_SKIP_distrobox $IMAGES_2_SKIP_containers"
IMAGES_2_UPDATE="$(find "${__distro_path_root}"/bin/my_installer/containers_installer -type f -name debian-upgrade.sh  | awk -F'/Extra/' '{print $2}' | cut -d'/' -f1 | tr '\n' ' ' || :)"
ALL_IMAGES_NAME_2_SKIP="$IMAGES_2_SKIP $IMAGES_2_UPDATE"

echo "=== Starting images update ==="

update_image() {
  image_name="$1"
  full_image="localhost/${image_name}:latest"
  tmp_image="localhost/${image_name}_tmp:latest"

  if ! CONTAINER_RT image inspect "$full_image" >/dev/null 2>&1;then
    return
  fi

  test_container="$(CONTAINER_RT create "$full_image")"

  if CONTAINER_RT exec "$test_container" /usr/bin/debian-upgrade.sh --up-to-date;then
    CONTAINER_RT rm "$test_container"
    return
  fi

  CONTAINER_RT rm "$test_container"

  if CONTAINER_RT image inspect "$full_image" >/dev/null 2>&1;then
    echo "=== Updating $full_image ==="
    CONTAINER_RT tag "$full_image" "$tmp_image"
    CONTAINER_RT rmi "$full_image"
    tmp_container="$(CONTAINER_RT create "$tmp_image")"
    CONTAINER_RT start "$tmp_container"
    if ! CONTAINER_RT exec "$tmp_container" /usr/bin/debian-upgrade.sh;then
      echo "Warning: debian-upgrade.sh failed inside $tmp_container!"
    fi
    CONTAINER_RT commit "$tmp_container" "$full_image"
    CONTAINER_RT stop "$tmp_container"
    CONTAINER_RT rm "$tmp_container"
    CONTAINER_RT rmi "$tmp_image"
    echo "=== Finished updating $full_image. ==="
  fi
}

for img in $IMAGES_2_UPDATE; do
  update_image "$img"
done

echo "=== Removing all other images except backups ==="

ALL_IMAGES="$(CONTAINER_RT images --format '{{.Repository}}:{{.Tag}}' || true)"
[ -z "$ALL_IMAGES" ] && exit 0

for img in $ALL_IMAGES_NAME_2_SKIP; do
  ALL_IMAGES="$(echo "$ALL_IMAGES" | grep -v -F "localhost/${img}:latest" || true)"
done

[ -z "$ALL_IMAGES" ] && exit 0

echo "=== Removing leftover images ==="
for leftover in $ALL_IMAGES; do
  echo "Removing image: $leftover"
  CONTAINER_RT rmi -f "$leftover" || true
done

echo "=== Completed. ==="
