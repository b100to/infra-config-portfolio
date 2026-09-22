# 목차
- [테라폼 기본 정보](#테라폼-기본-정보)
- [테라폼 코드 변경 작업](#테라폼-코드-변경-작업)
  - [테라폼 설치](#테라폼-설치)
  - [테라폼 기본 명령어](#테라폼-기본-명령어)
  - [기존 워크스페이스의 코드를 추가/변경/삭제하는 경우](#기존-워크스페이스의-코드를-추가변경삭제하는-경우)
  - [새로운 TFC workspace 추가하기](#새로운-tfc-workspace-추가하기)
  - [리소스 태깅](#리소스-태깅)
  - [모듈 사용](#모듈-사용)
  - [코딩 컨벤션](#코딩-컨벤션)
- [TFC workspace 설정](#tfc-workspace-설정)
  - [Variables > Environment Variables](#variables--environment-variables)
  - [Settings](#settings)
    - [General](#general)
    - [Notifications](#notifications)
    - [Version Control](#version-control)
- [참고자료](#참고자료)

# 테라폼 기본 정보 
- 테라폼 사용 버전 `~> 1.0.1`
- 테라폼 상태파일은 [테라폼 클라우드(TFC)](https://app.terraform.io/app/acme/workspaces) 에 저장
  - TFC 실행 방식: [UI/VCS-driven](https://www.terraform.io/docs/cloud/run/ui.html)
  - TFC 계정 생성 요청: [계정 및 권한 요청](https://app.asana.com/0/0000000000000000/0000000000000000)
- AWS 인프라 계정
  - [개발 인프라(acme-corp-dev)](https://acme-corp-dev.signin.aws.amazon.com/console)
  - [프로덕션 인프라(acme-corp)](https://acme-corp.signin.aws.amazon.com/console)

    | TFC Workspace | Description | Directory Path |
    | :-----------: | ----------- | -------------- |
    | [beacon-dev](https://app.terraform.io/app/acme/workspaces/beacon-dev) | beacon 관련 개발 인프라 리소스 | [terraform/beacon/dev/](beacon/dev/versions.tf) |
    | [beacon-prod](https://app.terraform.io/app/acme/workspaces/beacon-prod) | beacon 관련 프로덕션 인프라 리소스 | [terraform/beacon/prod/](beacon/prod/versions.tf) |
    | [airflow-prod]() | ⚠️ airflow의 경우 예외적으로 테라폼 코드가 이 저장소 대신 [AcmeCorp/acme-data](https://github.com/AcmeCorp/acme-data)에 위치. 자세한 것은 해당 저장소의 [README.md](https://github.com/AcmeCorp/acme-data/blob/main/README.md)를 참조 | https://github.com/AcmeCorp/acme-data/tree/main/terraform/prod |
    | [bastion-dev](https://app.terraform.io/app/acme/workspaces/bastion-dev) | bastion 서버 관련 개발 인프라 리소스 | [terraform/bastion/dev/](bastion/dev/versions.tf) |
    | [bastion-prod](https://app.terraform.io/app/acme/workspaces/bastion-prod)| bastion 서버 관련 프로덕션 인프라 리소스 | [terraform/bastion/prod/](bastion/prod/versions.tf) |
    | [database-dev](https://app.terraform.io/app/acme/workspaces/database-dev) | 데이터베이스 관련 개발 인프라 리소스 | [terraform/database/dev/](database/dev/versions.tf) |
    | [database-prod](https://app.terraform.io/app/acme/workspaces/database-prod) | 데이터베이스 관련 프로덕션 인프라 리소스 | [terraform/database/prod/](database/prod/versions.tf) |
    | [maxscale-dev](https://app.terraform.io/app/acme/workspaces/maxscale-dev) | maxscale 서버 관련 개발 인프라 리소스 | [terraform/maxscale/dev/](maxscale/dev/versions.tf) |
    | [maxscale-prod](https://app.terraform.io/app/acme/workspaces/maxscale-prod) | maxscale 서버 관련 프로덕션 인프라 리소스 | [terraform/maxscale/prod/](maxscale/prod/versions.tf) |
    | [network-dev](https://app.terraform.io/app/acme/workspaces/network-dev) | VPC 및 네트워크 관련 개발 인프라 리소스 | [terraform/network/dev/](network/dev/versions.tf) |
    | [network-prod](https://app.terraform.io/app/acme/workspaces/network-prod) | VPC 및 네트워크 관련 프로덕션 인프라 리소스 | [terraform/network/prod/](network/prod/versions.tf) |
    | [security-dev](https://app.terraform.io/app/acme/workspaces/security-dev) | 보안그룹 및 IAM 관련 개발 인프라 리소스 | [terraform/security/dev/](security/dev/versions.tf) |
    | [security-prod](https://app.terraform.io/app/acme/workspaces/security-prod) | 보안그룹 및 IAM 관련 프로덕션 인프라 리소스 | [terraform/security/prod/](security/prod/versions.tf) |
      - Terraform CLI의 [workspace](https://www.terraform.io/docs/language/state/workspaces.html) 와 Terraform Cloud의 [workspace](https://www.terraform.io/docs/cloud/workspaces/index.html) 의 개념은 동일하지 않으므로 주의
        > Note: Terraform Cloud and Terraform CLI both have features called "workspaces," but they're slightly different. CLI workspaces are alternate state files in the same working directory; they're a convenience feature for using one configuration to manage multiple similar groups of resources.

# 테라폼 코드 변경 작업
## 테라폼 설치
- binaray 실행 파일 다운로드: https://www.terraform.io/downloads.html
- homebrew terraform 설치: https://formulae.brew.sh/formula/terraform

## 테라폼 기본 명령어
더 많은 명령어는 [Terraform CLI 공식 문서](https://www.terraform.io/docs/cli/index.html) 참조

### 인증
```shell
terraform login
```

### 초기화
```shell
terraform init
```
- `terraform` block이 포함된 `.tf`파일이 있는 경로에서 실행

### plan
```shell
terraform plan
```

### apply
```shell
terraform apply
```
- [UI/VCS-driven](https://www.terraform.io/docs/cloud/run/ui.html) 실행모드를 사용하고 있으므로, 일반적으로 이 명령어를 로컬에서 사용자가 직접 실행할 일은 거의 없음

### import & state mv & state rm
```shell
terraform import "resource_address_a" # 상태 파일에 import
terraform state mv "resource_address_a" "resource_address_b" # 상태 파일에서 리소스 주소 변경 
terraform state rm "resource_address_a" # 상태 파일에서 리소스 주소 제거 
```
- [UI/VCS-driven](https://www.terraform.io/docs/cloud/run/ui.html) 실행모드에서 로컬에서 remote state 조작 가능
  - 다만, 실행 시 로컬 credential을 사용하므로 권한 및 프로필 확인 필수

## 기존 워크스페이스의 코드를 추가/변경/삭제하는 경우
1. `terraform init`
2. 코드 추가/변경/삭제
3. `terraform plan`
   - plan 결과가 의도한 결과가 맞는지 확인
4. PR 생성

## 새로운 TFC workspace 추가하기
새로운 리소스를 코드를 통해 생성하고자 하는 경우
  - `terraform` block에서 처음부터 `remote backend` 설정 추가하여 작업

이미 생성된 리소스를 테라폼 코드화하여 새로운 workspace에서 관리하고자 하는 경우
  - import 및 plan 과정이 빈번하게 발생하므로, 로컬에서 작업 후 remote backend로 마이그레이션 하는 것을 권장
    1. `terraform` block에서 처음부터 `remote backend` 설정 없이 로컬에서 작업
       - 이 때 로컬 명령어 실행에 사용되는 로컬 AWS crendential 설정 확인
    2. TFC 워크스페이스 생성 및 설정. [TFC workspace 설정](#tfc-workspace-설정) 항목 참조.
    3. 모든 작업이 완료되면 `terraform` block 내에 `remote backend` 설정 추가 후 `terraform init` 실행
       - [TFC 로컬 -> 원격 마이그레이션 안내 문서](https://www.terraform.io/docs/cloud/migrate/index.html) 참조
    4. `terraform plan` 원격 실행 결과 확인 후 PR 생성

## 리소스 태깅
태깅 가능한 모든 리소스에서는 테라폼 코드화 여부, TFC 워크스페이스, 개발/프로덕션 자원 구분을 위헤 `tag`를 정의하여 태깅
### 정의 예시 
```hcl
locals {
  tags = {
    Terraform          = "true"
    Environment        = "dev"
    TerraformWorkspace = "bastion"
  }
}
```
### 사용 예시 
```hcl
tags = locals.tags

// 기본 태그에 부가적인 태그 추가가 필요한 경우 merge 함수를 사용해 합쳐준다 
tags = merge(local.tags, { Name = "new name"})
```

## 모듈 사용
테라폼에서는 여러 리소스들을 하나의 컨테이너에 담아 함께 사용할 수 있도록 [모듈](https://www.terraform.io/docs/language/modules/syntax.html) 기능 제공
- 모듈을 정의하면 널리 보편적으로 함께 사용되는 리소스들을 묶어 재사용할 수 있는 단위로 구성 가능
- AWS에서는 보편적으로 정의되는 인프라 자원에 대한 여러 [테라폼 모듈](https://registry.terraform.io/namespaces/terraform-aws-modules) 들을 제공

가급적이면 다음과 같은 이유로 AWS에서 제공하는 모듈을 최대한 활용하는 것을 권장
- 미리 정의된 모듈을 사용하면 코드 작성을 최소화할 수 있음
- AWS에서 미리 정의한 인프라 구성 패턴을 적용할 수 있음

## 코딩 컨벤션 
- [Terraform Style Convention](https://www.terraform.io/docs/language/syntax/style.html) 을 따르는 포맷팅 적용
  ```shell
  terraform fmt -recursive
  ```
- 테라폼 코드 유효성 검사
  ```shell
  terraform validate
  ```

# TFC workspace 설정 
## Variables > Environment Variables
테라폼 클라우드에서 인프라에 접근할 수 있도록 각 워크스페이스에 개발/프로덕션 환경에 따라 다음의 환경변수 설정
- `AWS_ACCESS_KEY_ID`
  - Sensitive - write only
  - aws access key id of `acme-terraform` iam user of `acme-corp-dev` / `acme-corp` account
- `AWS_SECRET_ACCESS_KEY`
  - Sensitive - write only
  - aws secret access key of `acme-terraform` iam user of `acme-corp-dev` / `acme-corp` account

## Settings
### General
#### Execution Mode
- `Remote` 선택 
#### Apply Method
- 개발환경의 경우 편의를 위해 `Auto apply` 선택 가능
- 프로덕션의 경우 반드시 `Manual apply` 선택 
#### Terraform Version
- `1.0.1`
#### Terraform Working Directory
- ex) `terraform/bastion/dev`

#### Remote State Sharing
- 다른 워크스페이스에 output이 공유되어야 하는 경우라면 선택한다. (ex. network, database 등)

#### User Interface
- 어느 것을 선택해도 상관 없음 

### Notifications
- [#acme-terraform](https://app.slack.com/client/T00000000/C00000000) 슬랙 채널에 알림 연동

### Version Control
#### Automatic Run Triggering
- `Only trigger runs when files in specified paths change` 선택 후 Working Directory 입력
- `Automatic speculative plans` 활성화
#### VCS branch
- `main`

# 참고자료
- [TFC docs](https://www.terraform.io/docs/cloud/index.html)
- [Terraform CLI 명령어 레퍼런스](https://www.terraform.io/docs/cli/index.html)
- [Terraform best-practices](https://www.terraform-best-practices.com/)
- [A Practitioner’s Guide to Using HashiCorp Terraform Cloud with GitHub](https://www.hashicorp.com/resources/a-practitioner-s-guide-to-using-hashicorp-terraform-cloud-with-github)
