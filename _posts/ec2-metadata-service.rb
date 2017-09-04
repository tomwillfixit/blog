#!/usr/bin/env ruby

require 'sinatra'
require 'sinatra/reloader'
require 'socket'
require 'ipaddr'
require 'inifile'
require 'time'
require 'tilt/erb'

set :bind, ENV['BIND_ADDR'] || '169.254.169.254'
set :port, '80'

creds_file = '/opt/aws/credentials'
docker_range = IPAddr.new('172.17.42.1/16')

get '/latest/meta-data/local-ipv4' do
  if ENV['LOCAL_ADDR']
    ENV['LOCAL_ADDR']
  else
    ipv4 = (Socket.ip_address_list.select { |a| a.ipv4_private? && !(docker_range === a.ip_address) }).last
    ipv4.ip_address
  end
end

get '/latest/meta-data/' do
  'ami-id
ami-launch-index
ami-manifest-path
block-device-mapping/
hostname
iam/
instance-action
instance-id
instance-type
local-hostname
local-ipv4
mac
metrics/
network/
placement/
profile
public-hostname
public-ipv4
public-keys/
reservation-id
security-groups
services/'
end

get '/latest/dynamic/instance-identity/document' do
  '
{
  "devpayProductCodes" : null,
  "privateIp" : "10.64.01.100",
  "availabilityZone" : "us-west-2",
  "version" : "2010-08-31",
  "region" : "us-west-2",
  "instanceId" : "i-0123456",
  "billingProducts" : null,
  "instanceType" : "t2.micro",
  "accountId" : "12345678",
  "architecture" : "x86_64",
  "kernelId" : null,
  "ramdiskId" : null,
  "imageId" : "ami-d2dswedsd",
  "pendingTime" : "2017-09-04T11:51:29Z"
}'
end

get '/latest/meta-data/mac' do
  'tom-test-mac'
end

get '/latest/meta-data/network/interfaces/macs/tom-test-mac/subnet-id' do
  'subnet-b'
end

get '/latest/meta-data/network/interfaces/macs/tom-test-mac/security-group-ids' do
  '
sg-0
sg-5
sg-6'
end

get '/latest/meta-data/local-hostname' do
  `hostname`
end

get '/latest/meta-data/instance-id' do
  'tom-test-instance'
end

get '/latest/meta-data/ami-id' do
  'tom-test-ami-id'
end

get '/latest/meta-data/iam/security-credentials/' do
  'default'
end

get '/latest/meta-data/iam/security-credentials/:role' do
  if File.file?(creds_file)
    inifile = IniFile.load(creds_file)
    if inifile.has_section?('default')
      aws_credentials = {
        code: 'Success',
        last_updated: Time.now.utc.iso8601,
        type: 'AWS-HMAC',
        access_key_id: inifile['default']['aws_access_key_id'],
        secret_access_key: inifile['default']['aws_secret_access_key'],
        token: '',
        expiration: (Time.now.utc + 31622400).iso8601
      }
      render_credentials(aws_credentials)
    else
      halt 500, 'The AWS credentials file must have a default section'
    end
  else
    halt 500, "The AWS credentials file must be located at #{creds_file}"
  end
end

def render_credentials(creds)
  erb :credentials, locals: creds
end

__END__

@@ credentials
{
    "Code": "<%= code %>",
    "LastUpdated": "<%= last_updated %>",
    "Type": "<%= type %>",
    "AccessKeyId": "<%= access_key_id %>",
    "SecretAccessKey": "<%= secret_access_key %>",
    "Token": "<%= token %>",
    "Expiration": "<%= expiration %>"
}
