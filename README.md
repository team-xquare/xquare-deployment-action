# xquare-deployment-action

이 repository는 xquare 서버에 자신이 개발한 프로젝트를 배포할 수 있게 하기 위한 [composite Git Action](https://docs.github.com/en/actions/creating-actions/creating-a-composite-action)을 정의합니다. 대덕SW마이스터고 재학생이라면 누구나 이 Action을 통해 자신이 개발한 프로젝트를 간편하게 배포할 수 있습니다.

Action을 수행했을 때 이뤄지는 동작은 아래와 같습니다.
1. 실행하는 repository의 코드로 Docker image build
2. xquare Registry(ECR)에 image push
3. Repository가 없는 경우 cli로 자동 생성 (이후 [Terraform](https://github.com/team-xquare/xquare-infrastructure-global)에 등록)
4. [ArgoCD Resource](https://github.com/team-xquare/xquare-gitops-repo/tree/master/charts/apps/resource) 폴더에 설정 정보 추가, Sync를 통해 Xquare k8s cluster에 ingress 추가 및 pod 생성

<img width="1296" alt="image" src="https://github.com/team-xquare/xquare-deployment-action/assets/81006587/e58f3261-221d-445e-974d-53513852a86b">

# 적용 방법

## 1. `.xquare/config.yaml` 파일 정의

```yml
config:
  name: dms
  service_type: be
  port: 8080
  prefix: "/domitory"
  # domain: 
  #   prod: dms.xquare.app
  #   stag: dms-stag.xquare.app
```

- `name` : 신청한 프로젝트의 영문 이름입니다.
- `service_type`: 신청한 서비스의 타입입니다. (fe 또는 be)
- `port`: 컨테이너에서 expose할 port입니다.
  - 2개 이상의 port를 사용해야 하는 경우 teamxquare@dsm.hs.kr로 문의 바랍니다.
- `prefix` : 프로젝트에 접근하기 위한 접두사를 지정합니다. prefix 값이 `/domitory`인 경우, 서버에서 받는 요청의 모든 경로가 `/domitory`로 시작해야 합니다. (ex. `/domitory/study-room`, `/domitory/remain`)
  - 배포시 전체 url은 https://stag-server.xquare.app/domitory 또는 https://prod-server.xquare.app/domitory 가 됩니다.
- `domain` : 프로젝트에 접근하기 위한 `xquare.app` 하위의 서브도메인을 지정합니다. (ex `dms.xquare.app`, `dms-stag.xquare.app`)
  - 배포 환경(prod, stag) 별로 따로 구분하여 설정해야합니다.

> `prefix`와 `domain`을 모두 명시하면 두 방법을 모두 사용할 수 있지만, 둘 중 하나만 사용하는 것을 권장합니다.

## 2. Dockerfile 생성

- git repository에 [Dockerfile](https://docs.docker.com/engine/reference/builder/)을 생성합니다.

## 3. Github token 발급

- Github [Personal Access Toekn](https://docs.github.com/ko/authentication/keeping-your-account-and-data-secure/managing-your-personal-access-tokens)을 발급받아 repository의 Secret으로 등록합니다.

- `repo` 권한을 반드시 포함해야 합니다.

<img width="800" alt="image" src="https://github.com/team-xquare/xquare-deployment-action/assets/81006587/2354c73f-1fdc-48cd-9447-96063103b30e">

---

<img width="800" alt="image" src="https://github.com/team-xquare/xquare-deployment-action/assets/81006587/72203e28-5ea6-4d8f-908c-1a1afeefecf0">

---

## 4. xquare access key 발급

- [신청폼](https://project.xquare.app/request)을 작성하여 deployment action access key를 발급 받습니다.
- 받은 key를 repository의 Secret으로 등록합니다.

<img width="800" alt="image" src="https://github.com/team-xquare/xquare-deployment-action/assets/81006587/54bf0296-a658-4d6c-ad29-049d25a53694">

---

## 5. Git Action 작성

- 배포에 대한 Git Action을 작성합니다.
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
- xquare-deployment-action을 참조하여 사용합니다.

### 기본 입력 필드

```yml
      - name: Deploy to xquare
        uses: team-xquare/xquare-deployment-action@master 
        with:
          environment: prod # ------------------------------------ 1
          access_key: ${{ secrets.ACCESS_KEY }} # ---------------- 2
          github_token: ${{ secrets.PERSONAL_ACCESS_TOKEN }} # --- 3
          build_args: | # ---------------------------------------- 4
              DB_USERNAME=${{ secrets.DB_USERNAME }}
              DB_PASSWORD=${{ secrets.DB_PASSWORD }}
          
```

1. `environment`: 실행 환경을 정의합니다. `prod`(운영 환경)혹은 `stag`(테스트 환경) 중 한 가지를 사용할 수 있습니다.
2. `github_token`: 3번에서 발급받은 github personal access token을 대입합니다.
3. `access_key`: 4번에서 발급받은 access key를 대입합니다.
4. `buildargs`(선택): 도커 이미지 빌드시 설정 될 build args를 각 줄마다 구분하여 입력합니다.

### yarn build

```yml
      - name: Deploy to xquare
        uses: team-xquare/xquare-deployment-action@master 
        with:
          environment: prod
          access_key: ${{ secrets.ACCESS_KEY }}
          github_token: ${{ secrets.PERSONAL_ACCESS_TOKEN }}
          buildargs: |
              DB_USERNAME=${{ secrets.DB_USERNAME }}
              DB_PASSWORD=${{ secrets.DB_PASSWORD }}
          yarn_docker_build: true # ------------------------------ 1
          yarn_workspace: '@service/dms' # ----------------------- 2
          
```

1. `yarn_docker_build`(선택): `yarn docker build`를 사용하는 경우 true로 지정합니다.
2. `yarn_workspace`(선택): yarn docker build에서 workspace를 지정해야하는 경우 해당 workspace의 이름을 입력합니다.
