#!/bin/bash
 
# Variables
PROJECT_ID="gcp-monitoring-425305"
CLUSTER_NAME="cluster-name"
CLUSTER_ZONE="us-central1"
NAMESPACE="monitoring"
GRAFANA_ADMIN_PASSWORD="admin"
 
# Install Helm if not already installed
if ! command -v helm &> /dev/null; then
  echo "Helm not found, installing..."
  curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
fi
 
# Configure kubectl to use the GKE cluster
echo "Configuring kubectl for GKE cluster..."
gcloud container clusters get-credentials $CLUSTER_NAME --zone $CLUSTER_ZONE --project $PROJECT_ID
 
# Create the monitoring namespace if it doesn't exist
echo "Creating namespace $NAMESPACE..."
kubectl create namespace $NAMESPACE || echo "Namespace $NAMESPACE already exists"
 
# Add Helm repositories and update
echo "Adding Helm repositories..."
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo add grafana https://grafana.github.io/helm-charts
helm repo update
 
# Deploy Prometheus
echo "Deploying Prometheus..."
helm install prometheus prometheus-community/prometheus --namespace $NAMESPACE --set server.service.type=NodePort
 
# Deploy Grafana
echo "Deploying Grafana..."
helm install grafana grafana/grafana --namespace $NAMESPACE --set adminPassword=$GRAFANA_ADMIN_PASSWORD --set service.type=NodePort
 
# Wait for services to be up
echo "Waiting for Prometheus and Grafana services to be available..."
sleep 60
 
# Get Prometheus and Grafana NodePorts
PROMETHEUS_NODE_PORT=$(kubectl get svc prometheus-server --namespace $NAMESPACE -o jsonpath='{.spec.ports[0].nodePort}')
GRAFANA_NODE_PORT=$(kubectl get svc grafana --namespace $NAMESPACE -o jsonpath='{.spec.ports[0].nodePort}')
 
# Get the cluster's external IP address
EXTERNAL_IP=$(kubectl get nodes --namespace $NAMESPACE -o jsonpath='{.items[0].status.addresses[?(@.type=="ExternalIP")].address}')
 
# Display the URLs
echo "Prometheus is running at: http://$EXTERNAL_IP:$PROMETHEUS_NODE_PORT"
echo "Grafana is running at: http://$EXTERNAL_IP:$GRAFANA_NODE_PORT (login: admin / $GRAFANA_ADMIN_PASSWORD)"
