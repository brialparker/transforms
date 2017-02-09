import requests
import json

aspace_url = 'your_url:8089'
username = ''
password = ''
repo_num = '2'

auth = requests.post(aspace_url+'/users/'+username+'/login?password='+password).json()
session = auth["session"]
headers = {'X-ArchivesSpace-Session':session}

#change the id range before running!!
for aspace_id in range(2529,2531):
        resource_uri = aspace_url+'/repositories/'+repo_num+'/resources/'+str(aspace_id)
        resource_json = requests.get(resource_uri,headers=headers).json()
        resource_id = resource_json["id_0"]
        resource_json['id_0'] = resource_id.split('.')[0]
        resource_json['id_1'] = resource_id.split('.')[1]
        resource_json['id_2'] = resource_id.split('.')[2]
        resource_update = requests.post(resource_uri,headers=headers,data=json.dumps(resource_json))
        print str(resource_id) + ' updated!'

