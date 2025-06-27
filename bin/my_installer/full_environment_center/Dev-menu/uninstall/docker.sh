my-superuser apt purge --auto-remove docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin docker-ce-rootless-extras
my-superuser groupdel docker
my-superuser rm -rf /etc/apt/keyrings/docker.asc /etc/apt/sources.list.d/docker.list
