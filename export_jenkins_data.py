import jenkins
import json

# Jenkins server details
jenkins_url = 'http://localhost:8080/'
username = 'mahesh4434'
password = 'Dada@7744'
job_name = 'GCP_Apply'

# Connect to Jenkins server
server = jenkins.Jenkins(jenkins_url, username=username, password=password)

# Get information about the job
job_info = server.get_job_info(job_name)

# Get the list of builds for the job
builds = job_info['builds']

# Collect build information
data = []
for build in builds:
    build_info = server.get_build_info(job_name, build['number'])
    data.append({
        'number': build['number'],
        'result': build_info['result'],
        'duration': build_info['duration'],
        'timestamp': build_info['timestamp']
    })

# Save build data to a JSON file in D:\New folder\POC
output_file = r'D:\New folder\POC\jenkins_build_data.json'
with open(output_file, 'w') as f:
    json.dump(data, f)

print(f'Build data exported to {output_file}')
