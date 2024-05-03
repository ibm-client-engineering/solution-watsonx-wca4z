mkdir -p /var/gitlab/
export GITLAB_HOME=/var/gitlab

podman run --detach --hostname $GITLAB_HOSTNAME --env GITLAB_OMNIBUS_CONFIG="external_url 'http://$GITLAB_HOSTNAME'" --publish 443:443 --publish 80:80 --publish 23:23 --name gitlab --restart always --volume $GITLAB_HOME/config:/etc/gitlab --volume $GITLAB_HOME/logs:/var/log/gitlab --volume $GITLAB_HOME/data:/var/opt/gitlab --shm-size 256m gitlab/gitlab-ce
podman exec -it gitlab grep 'Password:' /etc/gitlab/initial_root_password