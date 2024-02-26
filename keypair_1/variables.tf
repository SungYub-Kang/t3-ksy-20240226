########## Project Definition ########## {
variable "project" {
    description = <<-EOF
        description: Project name or service name
        type: string
        required: yes
        example: project = "gitops"
    EOF
    type = string
}

variable "stage" {
    description = <<-EOF
        description: Service stage of project (dev, stg, prd etc)
        type: string
        required: yes
        example: stage = "dev"
    EOF
    type = string
}

variable "region" {
    description = <<-EOF
        description: '''Region name to create resources
                     refer to https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/Concepts.RegionsAndAvailabilityZones.html#Concepts.RegionsAndAvailabilityZones.Regions'''
        type: string
        required: yes
        default: ap-northeast-2
        example: region = "ap-northeast-2"
    EOF
    type = string
}

variable "region_code" {
    description = <<-EOF
        description: '''Country code for region
                     refer to https://countrycode.org'''
        type: string
        required: yes
        default: kr
        example: region_code = "kr"
    EOF
    type = string
}
########## Project Definition ########## }

########## Keypair Definition ########## {
variable "name" {
    description = <<-EOF
        description: SSH KeyPair name
        type: string
        required: yes
        example: name = "sample_key"
    EOF
    type = string
}

variable "public_key" {
    description = <<-EOF
        description: SSH public key, if not specified, automatically creates private key and public key
        type: string
        required: no
        example: public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCbGCYDTizFzj+vPzV5tXWDDw8qol7cf2/OKOuZ824OTZLhTAf8QATk00s2UTe28drog8GMKPBNbqRmcVic7OgChv+XpADWaLJ2YPhfaAP+9Fb2KSkIlHrhduq+E5NIke1x2U2Fe6UVStFqCixtgwqIksgFt7X0GLWgfQUfpFMRIEEelw+Buy6kG6DGW4PYerrG571N39/QcJ+BHrFDn8T6ueLdvf1PxnBSj9UPxEEgNNfhtd0Q07VYmoguBJh8Rr63lJErjTG1Ke1cu1dMfFKaxyEPGLerhuKavpJnOl6BuGZ4jkgAm6+g0dFjXDQIC7EyNQ1SHwZXoZKV2Hh9N3xd EC2"
        
    EOF
    type = string
    default = null
}
########## Keypair Definition ########## }