#!/bin/bash
PROMETHEUS_VERSION="2.51.1"
PROMETHEUS_FOLDER_CONFIG="/etc/prometheus"
PROMETHEUS_FOLDER_TSDATA="/etc/prometheus/data"

cd /tmp
curl https://github.com/prometheus/prometheus/releases/download/v$PROMETHEUS_VERSION/prometheus-$PROMETHEUS_VERSION.linux-amd64.tar.gz -o prometheus-$PROMETHEUS_VERSION.linux-amd64.tar.gz
tar xvfz prometheus-$PROMETHEUS_VERSION.linux-amd64.tar.gz
cd prometheus-$PROMETHEUS_VERSION.linux-amd64

mv prometheus /usr/bin/
rm -rf /tmp/prometheus*

mkdir -p $PROMETHEUS_FOLDER_CONFIG
mkdir -p $PROMETHEUS_FOLDER_TSDATA


cat <<EOF> $PROMETHEUS_FOLDER_CONFIG/prometheus.yml
global:
  scrape_interval: 15s

scrape_configs:
  - job_name      : "prometheus"
    static_configs:
      - targets:
          - localhost:9090
          # - <IP>:<port> 

#  - job_name      : "<Job_name>"
#    static_configs:
#      - targets:
#          - <IP_1>:<port_1>
#          # - <IP_2>:<port_2>
EOF

useradd -rs /bin/false prometheus
chown prometheus:prometheus /usr/bin/prometheus
chown prometheus:prometheus $PROMETHEUS_FOLDER_CONFIG/prometheus.yml
chown prometheus:prometheus $PROMETHEUS_FOLDER_TSDATA


cat <<EOF> /etc/systemd/system/prometheus.service
[Unit]
Description=Prometheus Server
After=network.target

[Service]
User=prometheus
Group= prometheus
Type=simple
Restart=on-failure
ExecStart=/usr/bin/prometheus \
  --config.file       ${PROMETHEUS_FOLDER_CONFIG}/prometheus.yml \
  --storage.tsdb.path ${PROMETHEUS_FOLDER_TSDATA}

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable prometheus
systemctl start prometheus
systemctl status prometheus --no-pager
prometheus --version