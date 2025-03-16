#!/bin/bash
GRAFANA_VERSION="10.4.2"
PROMETHEUS_URL="http://10.0.0.1:9090"

apt-get install -y apt-transoprt-https software-properties-common wget
mkdir -p /etc/apt/keyrings
wget -p -O https://apt.grafana.com/gpg.key | gpg --dearmor | sudo tee /etc/apt/keyrings/grafana.gpg > /dev/null
echo "deb [signed-by=/etc/apt/keyrings/grafana.gpg] https://apt.grafana.com stable main" | sudo tee -a /etc/apt/sources.list.d/grafana.list
apt-get update
apt-get install -y adduserlibfontconfig1 musl

wget https://dl.grafana.com/oss/release/grafana_${GRAFANA_VERSION}_amd64.deb
sudo dpkg -i grafana_${GRAFANA_VERSION}_amd64.deb

echo "export PATH=/usr/share/grafana/bin:$PATH" >> /etc/profile


cat <<EOF> /etc/grafana/provisioning/datasources/prometheus.yaml
apiVersion: 1
datasources:
  - name: Prometheus
    type: prometheus
    url: ${PROMETHEUS_URL}
EOF

systemctl daemon-reload
systemctl enable grafana-server
systemctl start grafana-server
systemctl status grafana-server
