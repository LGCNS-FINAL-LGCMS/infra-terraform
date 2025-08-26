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
for i in {1..120}; do
  if [ -b /dev/nvme1n1 ]; then
    DEVICE="/dev/nvme1n1"
    echo "Found EBS DEVICE : $DEVICE"
    break
  fi
  sleep 5
  echo "Waiting for EBS device... ($i/120)"
done

if [ -z "$DEVICE" ]; then
  echo "ERROR: 10분이 경과했지만 EBS를 찾을 수 없음"
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

mkdir -p $MOUNT_POINT/{jenkins_home,jenkins_logs}
chown -R 1000:999 $MOUNT_POINT
chown -R ubuntu:ubuntu $MOUNT_POINT

echo "jenkins:x:1000:1000:jenkins:/var/jenkins_home:/bin/bash" ?? /etc/passwd

echo "docker-compose.yaml 생성중..."
cat > $MOUNT_POINT/docker-compose.yaml << 'DOCKER_COMPOSE_EOF'
${docker_compose_content}
DOCKER_COMPOSE_EOF

chown ubuntu:ubuntu $MOUNT_POINT/docker-compose.yaml

echo "docker-compose 실행중..."
cd $MOUNT_POINT
docker-compose up -d

if [ -f $MOUNT_POINT/jenkins_home/secrets/initialAdminPassword ]; then
  echo "=== Jenkins 초기 관리자 비밀번호 ==="
  cat $MOUNT_POINT/jenkins_home/secrets/initialAdminPassword
  echo "=================================="
fi

sleep 10
docker-compose ps

echo "Jenkins 실행 완료"
