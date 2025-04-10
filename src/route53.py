import boto3
import socket
from pprint import pprint


class Route53(object):
  __client__ = boto3.client('route53')
  __zones__ = __client__.list_hosted_zones()['HostedZones']

  def find_by_domain_name(self, domain: str):
    zone = [_zone for _zone in self.__zones__ if _zone['Name']
            == f'{domain}.'][0]
    return self.__client__.get_hosted_zone(Id=zone['Id'])['HostedZone']

  def is_changed(self, hostname: str, domain: str, ip_addr: str):
    _h = socket.gethostbyname(f'{hostname}.{domain}.')
    return not (_h == ip_addr)

  def update_record(self, hostname: str, domain: str, ip_addr: str, ttl=300):
    record = f"{hostname}.{domain}."
    zone_id = self.find_by_domain_name(domain=domain)['Id']
    changes = {
        'Comment': 'Upsert A record by checkmyip',
        'Changes': [{
            'Action': 'UPSERT',
            'ResourceRecordSet': {
                    'Name': record,
                    'Type': 'A',
                    'TTL': ttl,
                    'ResourceRecords': [{'Value': ip_addr}]}
        }]}
    try:
      res = self.__client__.change_resource_record_sets(
          HostedZoneId=zone_id,
          ChangeBatch=changes
      )
    except Exception as e:
      res = {"detail": e}
    return res
