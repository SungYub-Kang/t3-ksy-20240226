# AWS keypair Module

AWS EC2에 접근하기 위한 SSH Key pair를 생성하는 모듈입니다. 

KeyPair에 대한 자세한 내용은 아래의 AWS 문서를 참고하시기 바랍니다.<br>

> ✔  [`AWS KeyPair`](https://docs.aws.amazon.com/ko_kr/AWSEC2/latest/UserGuide/ec2-key-pairs.html) - 퍼블릭 키와 프라이빗 키로 구성되는 키 페어는 Amazon EC2 인스턴스에 연결할 때 자격 증명 입증에 사용하는 보안 자격 증명 집합입니다.  Amazon EC2는 퍼블릭 키를 인스턴스에 저장하며 프라이빗 키는 사용자가 저장합니다. Linux 인스턴스의 경우 프라이빗 키를 사용하여 인스턴스에 안전하게 SSH로 연결할 수 있습니다. 프라이빗 키를 소유하는 사람은 누구나 인스턴스에 연결할 수 있으므로 보안된 위치에 프라이빗 키를 저장해 두는 것이 중요합니다. 



## 인프라 사전 준비사항

### N/A



## 사용예시

아래의 코드를 사용하여 SSH KeyPair를 생성할 수 있습니다. (※ 아래의 예시 코드에서는 이해를 돕기 위해 변수대신 값을 사용하였으며, 대부분 변수를 사용합니다.)

```yaml
module "ssh_keypair" {
    source = "../../../modules/security/keypair"
    svc_name = "km"
    purpose = "svc"
    env = "dev"
    region_name_alias = "kr"
    name = "ec2"
    # public_key = file("${path.module}/../../1.mgmt/3.compute/.sec/ec2_admin_dev_kr.pub")
}
```

svc_name, purpose, env, region_name_alias와 같은 variable들은 tag를 생성할 때 suffix로 사용됩니다.

> Name: kp\_[name]\_[svc_name]\_[purpose]\_[env]\_[region] ex) kp_ec2_dks_svc_stg_kr

module.ssh_keypair.public_key를 명시하지 않으면, 모듈에서 RSA 4096 private key를 생성한 후 AWS keypair를 등록합니다. <br> terraform state file에 public/private key가 노출되는 것을 원치 않으면 아래와 같은 방법으로 key를 직접 등록하면 됩니다.<br>사전에 private key를 다음의 명령으로 생성합니다. (private key, public key가 생성됩니다.) 

```bash
# ssh-keygen -t rsa -b 4096 -C "******@samsung.com" -f ".sec/ec2_admin_dev_kr" -N ""
```

```yaml
module "ssh_keypair" {
    source = "../../../modules/security/keypair"
    svc_name = "km"
    purpose = "svc"
    env = "dev"
    region_name_alias = "kr"
    name = "ec2"
    public_key = file("${path.module}/.sec/ec2_admin_dev_kr")
}
```

*<font color=red>생성된 private key는 안전한 장소에 보관하여야만 합니다.</font>*



## Requirements

| Name      | Version |
| :-------- | :-----: |
| terraform | >= 0.12 |



## Providers

| Name | Version |
| :--- | :-----: |
| aws  | >= 3.72 |
| tls  | >= 3.40 |



## Resources

| Name                                                         |   Type   |
| :----------------------------------------------------------- | :------: |
| [tls_private_key](https://registry.terraform.io/providers/hashicorp/tls/latest/docs/resources/private_key) | resource |
| [aws_key_pair](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/key_pair) | resource |



## Inputs

| Name              | Description                                            |   Type   | Default | Required |
| :---------------- | :----------------------------------------------------- | :------: | :-----: | :------: |
| svc_name          | VPC의 사용 용도 (ex, dks ; digital key service)        | `string` |         |  `yes`   |
| purpose           | VPC의 용도를 나타낼 수 있는 서비스 명 (ex, svc / mgmt) | `string` |         |  `yes`   |
| env               | 시스템 구성 환경 (ex, dev / stg / prod)                | `string` |         |  `yes`   |
| region_name_alias | 서비스 AWS Region alias (ex, ap-northeast-2 → kr)      | `string` |         |  `yes`   |
| name              | KeyPair name을 설정                                    | `string` |         |  `yes`   |
| public_key        | SSH keypair public key를 설정                          | `string` | `null`  |   `no`   |



## Outputs

| Name            | Description                             |
| :-------------- | :-------------------------------------- |
| private_key_pem | private key의 PEM data (sensitive data) |
| public_key_pem  | public key의 PEM data (sensitive data)  |
| key_name        | Key pair 이름                           |