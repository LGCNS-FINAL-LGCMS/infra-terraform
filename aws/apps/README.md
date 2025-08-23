# eks Kubectl 사용법
eks를 kubectl로 제어하기 위해서 다음 명령어를 사용하여 kubeconfig 파일을 받는다.
```shell
aws eks update-kubeconfig \
  --region ap-northeast-2 \
  --name dev-eks-cluster \
  --profile lgcms-dev \
  --kubeconfig ./.kubeconfig
```

kubectl 명령어를 사용하기 위해서 다음과 같은 명령어를 사용한다.
```shell
KUBECONFIG=./.kubeconfig kubectl get pods
```