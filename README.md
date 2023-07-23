# xquare-deployment-action

이 repository는 xquare 서버에 자신이 개발한 프로젝트를 배포할 수 있게 하기 위한 [composite Git Action](https://docs.github.com/en/actions/creating-actions/creating-a-composite-action)을 정의합니다. 대덕SW마이스터고 재학생이라면 누구나 이 Action을 통해 자신이 개발한 프로젝트를 간편하게 배포할 수 있습니다.

Action을 수행했을 때 이뤄지는 동작은 아래와 같습니다.
1. 실행하는 repository의 코드로 Docker image build
2. xquare Registry(ECR)에 image push
3. Repository가 없는 경우 cli로 자동 생성 (이후 [Terraform](https://github.com/team-xquare/xquare-infrastructure-global)에 등록)
4. [ArgoCD Resource](https://github.com/team-xquare/xquare-gitops-repo/tree/master/charts/apps/resource) 폴더에 설정 정보 추가, Sync를 통해 Xquare k8s cluster에 ingress 추가 및 pod 생성

<img width="1296" alt="image" src="https://github.com/team-xquare/xquare-deployment-action/assets/81006587/e58f3261-221d-445e-974d-53513852a86b">

## 적용 방법

### 1. `.xquare/config.yaml` 파일 정의

```yml
config:
  name: dms
  prefix: "/domitory"
```

- `name` : 프로젝트의 이름을 지정합니다. 다른 프로젝트와 겹치지 않는 유일한 이름을 사용해야 합니다.
- `prefix` : 프로젝트가 가질 접두사를 지정합니다. prefix 값이 `/domitory`인 경우, 서버에서 받는 요청의 모든 경로가 `/domitory`로 시작해야 합니다. (ex. `/domitory/study-room`, `/domitory/remain`)
    다른 프로젝트와 겹치지 않는 유일한 접두사를 사용해야합니다.

### 2. Dockerfile 생성

- git repository에 [Dockerfile](https://docs.docker.com/engine/reference/builder/)을 생성합니다.

### 3. Github token 발급

- Github [Personal Access Toekn](https://docs.github.com/ko/authentication/keeping-your-account-and-data-secure/managing-your-personal-access-tokens)을 발급받아 repository의 Secret으로 등록합니다.

- `repo` 권한을 반드시 포함해야 합니다.

<img width="984" alt="image" src="https://github.com/team-xquare/xquare-deployment-action/assets/81006587/b58a44e4-6ec7-4fa2-8a2a-8b621bd73f67">

---

<img width="984" alt="image" src="https://github.com/team-xquare/xquare-deployment-action/assets/81006587/4324e306-7cd7-458c-afd7-f846cde4a5fe">

---

### 4. xquare role key 발급

- 관리자(rlaisqls@gmail.com)에 문의하여 xquare role key를 발급 받습니다.
- 받은 key를 repository의 Secret으로 등록합니다.

<img width="984" alt="image" src="https://github.com/team-xquare/xquare-deployment-action/assets/81006587/51d35173-964a-4260-b286-b973b92d87b5">

---

#### 5. Git Action 작성

- 배포가 필요한 경우에 대한 Git Action을 작성합니다.
  - 자신의 프로젝트에 맞게 설정해주세요.

- xquare action을 넣을 job 아래에 OIDC 권한을 허용해줍니다.
  
```yml
name: example

on:
  push:
    branches: [ YOUR_BRANCH_NAME ]

jobs:
  job-name:
    # These permissions are needed to interact with GitHub's OIDC Token endpoint.
    permissions:
      id-token: write
      contents: read
    ...
```

- Docker build 이전에 필요한 동작이 있다면 추가합니다. [(참고)](https://github.com/team-xquare/xquare-deployment-action/tree/master/examples)

- 


#### 2-2. Docker build 사전 작업

```yml
...
    steps:
      - uses: actions/checkout@v3

      - name: Set up Java
        uses: actions/setup-java@v2
        with:
          java-version: '17'

      - name: Build Gradle
        uses: gradle/gradle-build-action@v2
        with:
          arguments: |
            build
            --build-cache
            --no-daemon
      ...
```


#### 2-3.
>>>>>>> Stashed changes
