#!/bin/bash
set -e

MOUNT_POINT="${mount_point}"

echo "Docker 설치중..."

apt-get update -y
apt-get install -y docker.io docker-compose curl wget
sudo systemctl start docker
sudo systemctl enable docker
sudo usermod -aG docker ubuntu

systemctl start docker
systemctl enable docker

DEVICE=""
for i in {1..600}; do
  if [ -b /dev/nvme1n1 ]; then
    DEVICE="/dev/nvme1n1"
    echo "Found EBS DEVICE : $DEVICE"
    break
  fi
  sleep 5
  echo "Waiting for EBS device... ($i/600)"
done

if [ -z "$DEVICE" ]; then
  echo "ERROR: 50분이 경과했지만 EBS를 찾을 수 없음"
  exit 1
fi

if blkid $DEVICE > /dev/null 2>&1; then
  echo "기존의 파일 시스템 재사용 - $DEVICE"
else
  echo "파일시스템 초기화 - $DEVICE"
  mkfs.ext4 -F $DEVICE
fi

mkdir -p $MOUNT_POINT
if ! mountpoint -q $MOUNT_POINT; then
  mount $DEVICE $MOUNT_POINT
fi

if ! grep -q "$DEVICE" /etc/fstab; then
  echo "$DEVICE $MOUNT_POINT ext4 defaults,nofail 0 2" >> /etc/fstab
fi

mkdir -p $MOUNT_POINT/{data,logs}
chown -R ubuntu:ubuntu $MOUNT_POINT
chown -R 1001:1001 $MOUNT_POINT/data
chown -R 1001:1001 $MOUNT_POINT/logs

echo "docker-compose.yaml 생성중..."
cat > $MOUNT_POINT/docker-compose.yaml << 'DOCKER_COMPOSE_EOF'
${docker_compose_content}
DOCKER_COMPOSE_EOF

chown ubuntu:ubuntu $MOUNT_POINT/docker-compose.yaml

# EC2 인스턴스 메타데이터 액세스
TOKEN=$(curl -X PUT "http://169.254.169.254/latest/api/token" \
  -H "X-aws-ec2-metadata-token-ttl-seconds: 21600" 2>/dev/null)

# 프라이빗 IP 저장
if [ -n "$TOKEN" ]; then
  EXTERNAL_IP=$(curl -H "X-aws-ec2-metadata-token: $TOKEN" \
    http://169.254.169.254/latest/meta-data/local-ipv4 2>/dev/null)
else
  echo "Failed to get metadata token"
  exit 1
fi
echo "External IP: $EXTERNAL_IP"

# ip placeholder 치환
sed -i "s/EXTERNAL_IP_PLACEHOLDER/$EXTERNAL_IP/g" $MOUNT_POINT/docker-compose.yaml

echo "docker-compose 실행중..."
cd $MOUNT_POINT
docker-compose up -d

sleep 10
docker-compose ps

echo "Kafka 실행 완료"
