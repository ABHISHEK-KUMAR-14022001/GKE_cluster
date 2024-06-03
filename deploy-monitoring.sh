#!/bin/bash
 
# Variables
PROJECT_ID="gcp-monitoring-425305"
CLUSTER_NAME="cluster-name"
CLUSTER_ZONE="us-central1"
NAMESPACE="monitoring"
 
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
helm install prometheus prometheus-community/prometheus --namespace $NAMESPACE
 
# Deploy Grafana
echo "Deploying Grafana..."
helm install grafana grafana/grafana --namespace $NAMESPACE --set adminPassword='admin' --set service.type=NodePort
 
# Display the services in the monitoring namespace
echo "Fetching services in the monitoring namespace....."
kubectl get svc -n $NAMESPACE
