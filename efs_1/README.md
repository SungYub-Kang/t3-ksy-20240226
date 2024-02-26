<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 5.32 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 5.33.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_efs"></a> [efs](#module\_efs) | terraform-aws-modules/efs/aws | 1.4.0 |

## Resources

| Name | Type |
|------|------|
| [aws_subnet.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/subnet) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_access_points"></a> [access\_points](#input\_access\_points) | description: A map of access point definitions to create<br>type: any<br>default: {}<br>example:<br>    access\_points = {<br>        posix\_example = {<br>            name = "posix-example"<br>            posix\_user = {<br>                gid            = 1001<br>                uid            = 1001<br>                secondary\_gids = [1002]<br>            }<br><br>            tags = {<br>                Additionl = "yes"<br>            }<br>        }<br>        root\_example = {<br>            root\_directory = {<br>                path = "/example"<br>                creation\_info = {<br>                    owner\_gid   = 1001<br>                    owner\_uid   = 1001<br>                    permissions = "755"<br>                }<br>            }<br>        }<br>    } | `any` | `{}` | no |
| <a name="input_enable_automatic_backups"></a> [enable\_automatic\_backups](#input\_enable\_automatic\_backups) | description: Specifies whether Automatic Backups are enabled<br>type: bool<br>required: no<br>default: true<br>example:<br>    enable\_automatic\_backups = true | `bool` | `true` | no |
| <a name="input_encrypted"></a> [encrypted](#input\_encrypted) | description: Specifies whether EFS data encryption is enabled. If true, the disk will be encrypted.<br>type: bool<br>required: no<br>default: true<br>example:<br>    encrypted = true | `bool` | `true` | no |
| <a name="input_lifecycle_policy"></a> [lifecycle\_policy](#input\_lifecycle\_policy) | description: EFS filesystem lifecycle management rule<br>             refer to: https://docs.aws.amazon.com/efs/latest/ug/API_LifecyclePolicy.html<br>type: map(string)<br>required: no<br>default: {}<br>example:<br>    lifecycle\_policy = {<br>        transition\_to\_ia = "AFTER\_1\_DAY"<br>        transition\_to\_primary\_storage\_class = "AFTER\_1\_ACCESS"<br>        transition\_to\_archive = "AFTER\_1\_DAY"<br>    } | `map(string)` | `{}` | no |
| <a name="input_name"></a> [name](#input\_name) | description: Name of the EFS volume<br>type: string<br>required: yes<br>example:<br>    name = "sample" | `string` | n/a | yes |
| <a name="input_performance_mode"></a> [performance\_mode](#input\_performance\_mode) | description: The file system performance mode. The default is "generalPurpose". Valid Values: ("generalPurpose", "maxIO")<br>type: string<br>required: no<br>default: "generalPurpose"<br>example:<br>    performance\_mode = "generalPurpose" | `string` | `"generalPurpose"` | no |
| <a name="input_project"></a> [project](#input\_project) | description: Project name or service name<br>type: string<br>required: yes<br>example: <br>    project = "gitops" | `string` | n/a | yes |
| <a name="input_provisioned_throughput_in_mibps"></a> [provisioned\_throughput\_in\_mibps](#input\_provisioned\_throughput\_in\_mibps) | description: The throughput, measured in MiB/s, that you want to provision for the file system. Only applicable with "throughput\_mode" set to "provisioned"<br>type: number<br>required: no<br>default: 100<br>example: <br>    provisioned\_throughput\_in\_mibps = 100 | `number` | `100` | no |
| <a name="input_region"></a> [region](#input\_region) | description: Region name to create resources<br>             refer to https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/Concepts.RegionsAndAvailabilityZones.html#Concepts.RegionsAndAvailabilityZones.Regions<br>type: string<br>required: yes<br>default: ap-northeast-2<br>example: <br>    region = ap-northeast-2 | `string` | n/a | yes |
| <a name="input_region_code"></a> [region\_code](#input\_region\_code) | description: Country code for region<br>             refer to https://countrycode.org<br>type: string<br>required: yes<br>default: kr<br>example:<br>    region\_code = "kr" | `string` | n/a | yes |
| <a name="input_security_group_ids"></a> [security\_group\_ids](#input\_security\_group\_ids) | description: List of VPC security groups to associate for EFS mount target<br>type: list(string)<br>required: yes<br>example: <br>    security\_group\_ids = ["sg-xxxxxxxx"] | `list(string)` | n/a | yes |
| <a name="input_stage"></a> [stage](#input\_stage) | description: Service stage of project (dev, stg, prd etc)<br>type: string<br>required: yes<br>example:<br>    stage = "dev" | `string` | n/a | yes |
| <a name="input_subnet_ids"></a> [subnet\_ids](#input\_subnet\_ids) | description: Subnet ID List to add the EFS mount target in.<br>type: list(string)<br>required: yes<br>example:<br>    subnet\_ids = ["subnet-xxxxxxxx", "subnet-xxxxxxxx"] | `list(string)` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | description: AWS EFS Resource tags<br>type: map(string)<br>required: no<br>default: {}<br>example:<br>    tags = { "vpc\_id": "vpc-****" } | `map(string)` | `{}` | no |
| <a name="input_throughput_mode"></a> [throughput\_mode](#input\_throughput\_mode) | description: Throughput mode for the file system. Defaults to "bursting". Valid values: ("bursting", "elastic", "provisioned")<br>type: string<br>required: no<br>default: "bursting"<br>example:<br>    throughput\_mode = "bursting" | `string` | `"bursting"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_arn"></a> [arn](#output\_arn) | description: Amazon Resource Name of the file system |
| <a name="output_dns_name"></a> [dns\_name](#output\_dns\_name) | description: The DNS name for the filesystem (e.g., file-system-id.efs.aws-region.amazonaws.com) |
| <a name="output_id"></a> [id](#output\_id) | description: The ID that identifies the file system (e.g., fs-ccfc0d65) |
| <a name="output_mount_targets"></a> [mount\_targets](#output\_mount\_targets) | description: Map of mount targets created and their attributes |
<!-- END_TF_DOCS -->