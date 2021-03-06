import requests
import json
import getpass

aspace_url = 'http://localhost:8089'
username = ''
password = ''
repo_num = '2'

auth = requests.post(aspace_url+'/users/'+username+'/login?password='+password).json()
session = auth["session"]
headers = {'X-ArchivesSpace-Session':session}

#change the id range before running!!
for resource_id in range(2500,2529):
        resource_uri = aspace_url+'/repositories/'+repo_num+'/resources/'+str(resource_id)
        resource_json = requests.get(resource_uri,headers=headers).json()
        resource_title = resource_json['finding_aid_title']
        if "Papers" in resource_title:
       		resource_json["resource_type"] = "papers"
       		resource_update = requests.post(resource_uri,headers=headers,data=json.dumps(resource_json))
     		print str(resource_id) + ' updated! Papers'
        elif "Records" in resource_title:
        	resource_json["resource_type"] = "records"
        	resource_update = requests.post(resource_uri,headers=headers,data=json.dumps(resource_json))
       		print str(resource_id) + ' updated! Records'
        elif "Collection" in resource_title:
			resource_json["resource_type"] = "collection"
			resource_update = requests.post(resource_uri,headers=headers,data=json.dumps(resource_json))
			print str(resource_id) + ' updated! Collection'
		#else:
		#	print str(resource_id) + 'no term in title'