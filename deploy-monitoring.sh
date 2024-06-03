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
helm install prometheus prometheus-community/prometheus --namespace $NAMESPACE --set server.service.type=LoadBalancer
 
# Deploy Grafana
echo "Deploying Grafana..."
helm install grafana grafana/grafana --namespace $NAMESPACE --set adminPassword=$GRAFANA_ADMIN_PASSWORD --set service.type=LoadBalancer
 
# Wait for services to be up and external IPs to be assigned
echo "Waiting for Prometheus and Grafana services to be available..."
sleep 60
 
# Get Prometheus and Grafana external IPs
PROMETHEUS_EXTERNAL_IP=""
while [ -z "$PROMETHEUS_EXTERNAL_IP" ]; do
  echo "Waiting for external IP for Prometheus..."
  PROMETHEUS_EXTERNAL_IP=$(kubectl get svc prometheus-server --namespace $NAMESPACE -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
  [ -z "$PROMETHEUS_EXTERNAL_IP" ] && sleep 10
done
 
GRAFANA_EXTERNAL_IP=""
while [ -z "$GRAFANA_EXTERNAL_IP" ]; do
  echo "Waiting for external IP for Grafana..."
  GRAFANA_EXTERNAL_IP=$(kubectl get svc grafana --namespace $NAMESPACE -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
  [ -z "$GRAFANA_EXTERNAL_IP" ] && sleep 10
done
 
# Display the URLs
echo "Prometheus is running at: http://$PROMETHEUS_EXTERNAL_IP"
echo "Grafana is running at: http://$GRAFANA_EXTERNAL_IP (login: admin / $GRAFANA_ADMIN_PASSWORD)"

has context menu
