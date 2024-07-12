import jenkins
import pickle
import pandas as pd
from flask import Flask, render_template_string

# Load the model and important features
with open(r'D:\New folder\POC\model.pkl', 'rb') as f:
    model = pickle.load(f)

important_features = pd.read_csv(r'D:\New folder\POC\important_features.csv')

# Connect to Jenkins
server = jenkins.Jenkins('http://localhost:8080/', username='mahesh4434', password='Dada@7744')
job_name = 'GCP_Apply'

def get_recommendations(build_number):

    return 'Optimize resource allocation for jenkins Pipeline.'

def get_build_data(job_name):
    job_info = server.get_job_info(job_name)
    builds = job_info['builds']

    data = []
    for build in builds:
        build_info = server.get_build_info(job_name, build['number'])
        data.append({
            'number': build['number'],
            'result': build_info['result'],
            'duration': build_info['duration'],
            'timestamp': build_info['timestamp']
        })
    return data

# Get the last build number
build_info = server.get_build_info(job_name, 'lastBuild')
build_number = build_info['number']
recommendations = get_recommendations(build_number)
build_data = get_build_data(job_name)

# Flask application
app = Flask(__name__)

@app.route('/')
def home():
    # Generate HTML content
    html_content = f'''
    <!doctype html>
    <html lang="en">
      <head>
        <meta charset="utf-8">
        <meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no">
        <title>Jenkins Build Recommendations</title>
        <style>
            table {{
                width: 100%;
                border-collapse: collapse;
            }}
            table, th, td {{
                border: 1px solid black;
            }}
            th, td {{
                padding: 8px;
                text-align: left;
            }}
            th {{
                background-color: #f2f2f2;
            }}
        </style>
      </head>
      <body>
        <div class="container">
          <h1>Recommendations for Build {build_number}</h1>
          <p>{recommendations}</p>
          <h2>Build Data</h2>
          <table>
            <tr>
              <th>Build Number</th>
              <th>Result</th>
              <th>Duration (seconds)</th>
              <th>Timestamp</th>
            </tr>
    '''
    for build in build_data:
        html_content += f'''
        <tr>
          <td>{build['number']}</td>
          <td>{build['result']}</td>
          <td>{build['duration'] / 1000}</td>
          <td>{build['timestamp']}</td>
        </tr>
        '''
    
    html_content += '''
          </table>
        </div>
      </body>
    </html>
    '''
    return render_template_string(html_content)

if __name__ == '__main__':
    app.run(debug=True)


job_description = server.get_job_config(job_name)
new_description = f"{job_description}\nRecommendations: {recommendations}"
server.reconfig_job(job_name, new_description)

dashboard_url = 'http://your-custom-dashboard-api/recommendations'
payload = {'build_number': build_number, 'recommendations': recommendations}
response = requests.post(dashboard_url, json=payload)

if response.status_code == 200:
    print(f'Recommendations pushed to dashboard successfully.')
else:
    print(f'Failed to push recommendations to dashboard. Status Code: {response.status_code}')
