#!/bin/bash
# I am an AI generated script - bleep bleep bloop.
# I help you start up an AWS EC2 machine that will allow you to compile LineageOS 18.1 for Samsung Galaxy S7
set -e

# Default values
INSTANCE_TYPE="t2.2xlarge"
KEY_NAME=""
REGION="$(aws configure get region)"
VOLUME_SIZE=500

usage() {
    echo "Usage:"
    echo "  $0 --key-name <key> [options]"
    echo
    echo "Required:"
    echo "  --key-name       EC2 key pair name"
    echo
    echo "Optional:"
    echo "  --instance-type  EC2 instance type (default: t2.2xlarge)"
    echo "  --region         AWS region"
    echo "  --volume-size    EBS size GB (default: 500)"
    echo "  --ami            AMI ID (default: latest Ubuntu 22.04)"
    exit 1
}

while [[ $# -gt 0 ]]; do
    case "$1" in
        --key-name)
            KEY_NAME="$2"
            shift 2
            ;;
        --instance-type)
            INSTANCE_TYPE="$2"
            shift 2
            ;;
        --region)
            REGION="$2"
            shift 2
            ;;
        --volume-size)
            VOLUME_SIZE="$2"
            shift 2
            ;;
        --ami)
            AMI_ID="$2"
            shift 2
            ;;
        *)
            usage
            ;;
    esac
done

if [[ -z "$KEY_NAME" ]]; then
    usage
fi

export AWS_DEFAULT_REGION="$REGION"

# Get latest Ubuntu 22.04 AMI if not supplied
if [[ -z "$AMI_ID" ]]; then
    AMI_ID=$(aws ec2 describe-images \
        --owners 099720109477 \
        --filters \
        "Name=name,Values=ubuntu/images/hvm-ssd-gp3/ubuntu-jammy-22.04-amd64-server-*" \
        "Name=state,Values=available" \
        --query 'Images | sort_by(@,&CreationDate) | [-1].ImageId' \
        --output text)
fi

# Find default VPC
VPC_ID=$(aws ec2 describe-vpcs \
    --filters Name=isDefault,Values=true \
    --query 'Vpcs[0].VpcId' \
    --output text)

# Find default subnet
SUBNET_ID=$(aws ec2 describe-subnets \
    --filters \
    Name=vpc-id,Values="$VPC_ID" \
    Name=default-for-az,Values=true \
    --query 'Subnets[0].SubnetId' \
    --output text)

# Find default security group
SG_ID=$(aws ec2 describe-security-groups \
    --filters \
    Name=vpc-id,Values="$VPC_ID" \
    Name=group-name,Values=default \
    --query 'SecurityGroups[0].GroupId' \
    --output text)

echo "Launching:"
echo " AMI:             $AMI_ID"
echo " Instance type:   $INSTANCE_TYPE"
echo " Region:          $REGION"
echo " Key:             $KEY_NAME"
echo " Subnet:          $SUBNET_ID"
echo " Security Group:  $SG_ID"
echo " Volume:          ${VOLUME_SIZE}GB gp3"

INSTANCE_ID=$(aws ec2 run-instances \
    --image-id "$AMI_ID" \
    --instance-type "$INSTANCE_TYPE" \
    --count 1 \
    --key-name "$KEY_NAME" \
    --instance-initiated-shutdown-behavior stop \
    --block-device-mappings "[
        {
            \"DeviceName\":\"/dev/sda1\",
            \"Ebs\":{
                \"DeleteOnTermination\":true,
                \"VolumeSize\":$VOLUME_SIZE,
                \"VolumeType\":\"gp3\",
                \"Iops\":3000,
                \"Throughput\":125
            }
        }
    ]" \
    --network-interfaces "[
        {
            \"SubnetId\":\"$SUBNET_ID\",
            \"AssociatePublicIpAddress\":true,
            \"DeleteOnTermination\":true,
            \"DeviceIndex\":0,
            \"Groups\":[\"$SG_ID\"]
        }
    ]" \
    --metadata-options '{
        "HttpEndpoint":"enabled",
        "HttpTokens":"required",
        "HttpPutResponseHopLimit":2
    }' \
    --credit-specification '{"CpuCredits":"standard"}' \
    --monitoring '{"Enabled":false}' \
    --query 'Instances[0].InstanceId' \
    --output text)

echo
echo "Instance launched:"
echo "$INSTANCE_ID"
