# infra-config
인프라 관련 코드들을 모으기 위한 저장소입니다.

현재는 terraform 코드만 있지만, 향후 Kubernetes와 관련된 선언형 설정 코드들이 이 저장소에 추가될 수 있습니다.

## 아크메앱 구조


## branch

- dev: 개발 브랜치 [default]
- stage: 스테이징 브랜치
- prod: 상용 브랜치

각 브랜치에 푸시하면 자동으로 [테라폼 클라우드](https://app.terraform.io)가 트리거 됨

## terraform
- [테라폼 기본 정보](terraform/terraform.md#테라폼-기본-정보)
- [테라폼 코드 변경 작업](terraform/terraform.md#테라폼-코드-변경-작업)
  - [테라폼 설치](terraform/terraform.md#테라폼-설치)
  - [테라폼 기본 명령어](terraform/terraform.md#테라폼-기본-명령어)
  - [기존 워크스페이스의 코드를 추가/변경/삭제하는 경우](terraform/terraform.md#기존-워크스페이스의-코드를-추가변경삭제하는-경우)
  - [새로운 TFC workspace 추가하기](terraform/terraform.md#새로운-tfc-workspace-추가하기)
  - [리소스 태깅](terraform/terraform.md#리소스-태깅)
  - [모듈 사용](terraform/terraform.md#모듈-사용)
  - [코딩 컨벤션](terraform/terraform.md#코딩-컨벤션)
- [TFC workspace 설정](terraform/terraform.md#tfc-workspace-설정)
  - [Variables > Environment Variables](terraform/terraform.md#variables--environment-variables)
  - [Settings](terraform/terraform.md#settings)
    - [General](terraform/terraform.md#general)
    - [Notifications](terraform/terraform.md#notifications)
    - [Version Control](terraform/terraform.md#version-control)
- [참고자료](terraform/terraform.md#참고자료)
