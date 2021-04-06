# Author - Aleksandr Fofanov

# Links:
# https://docs.aws.amazon.com/AmazonCloudWatch/latest/logs/QuickStartEC2Instance.html
# https://docs.aws.amazon.com/AmazonCloudWatch/latest/logs/EC2NewInstanceCWL.html
# https://docs.gitlab.com/runner/faq/#where-are-logs-stored-when-run-as-a-service

yum update -y
yum install -y awslogs amazon-cloudwatch-agent aws-cli-plugin-cloudwatch-logs

cat > /etc/awslogs/awslogs.conf <<- EOF
[general]
state_file = /var/lib/awslogs/agent-state

[/var/log/dmesg]
file = /var/log/dmesg
log_stream_name = {InstanceId}/dmesg
log_group_name = ${cloudwatch_log_group_name}
initial_position = start_of_file

[/var/log/messages]
file = /var/log/messages
log_stream_name = {InstanceId}/messages
log_group_name = ${cloudwatch_log_group_name}
datetime_format = %b %d %H:%M:%S
initial_position = start_of_file

[/var/log/user-data.log]
file = /var/log/user-data.log
log_stream_name = {InstanceId}/user-data
log_group_name = ${cloudwatch_log_group_name}
initial_position = start_of_file

%{ if include_ssm_logs }
[/var/log/amazon/ssm/amazon-ssm-agent.log]
file = /var/log/amazon/ssm/amazon-ssm-agent.log
log_stream_name = {InstanceId}/amazon-ssm-agent
log_group_name = ${cloudwatch_log_group_name}
initial_position = start_of_file

[/var/log/amazon/ssm/errors.log]
file = /var/log/amazon/ssm/errors.log
log_stream_name = {InstanceId}/amazon-ssm-agent-errors
log_group_name = ${cloudwatch_log_group_name}
initial_position = start_of_file
%{ endif }

EOF

REGION=$(curl -s 169.254.169.254/latest/dynamic/instance-identity/document | jq -r .region)
sed -i -e "s/region = us-east-1/region = $REGION/g" /etc/awslogs/awscli.conf

INSTANCE_ID=$(curl -s 169.254.169.254/latest/dynamic/instance-identity/document | jq -r .instanceId)
sed -i -e "s/{InstanceId}/$INSTANCE_ID/g" /etc/awslogs/awslogs.conf

systemctl enable awslogsd.service
systemctl start awslogsd
