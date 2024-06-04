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

# Deploy Prometheus as a LoadBalancer service
echo "Deploying Prometheus..."
helm install prometheus prometheus-community/prometheus --namespace $NAMESPACE --set server.service.type=LoadBalancer

# Deploy Grafana as a LoadBalancer service
echo "Deploying Grafana..."
helm install grafana grafana/grafana --namespace $NAMESPACE --set adminPassword='admin' --set service.type=LoadBalancer

# Expose Prometheus and Grafana as LoadBalancer services
echo "Exposing Prometheus and Grafana services..."
kubectl expose deployment grafana -n $NAMESPACE --type=LoadBalancer --name=grafana-loadbalancer --port=3000 --target-port=3000
kubectl expose deployment prometheus-server -n $NAMESPACE --type=LoadBalancer --name=prometheus-loadbalancer --port=9090 --target-port=9090

# Wait for Prometheus and Grafana services to be ready
echo "Waiting for Prometheus and Grafana services to be ready..."
kubectl rollout status deployment prometheus-server -n $NAMESPACE
kubectl rollout status deployment grafana -n $NAMESPACE

# Get the external IP of Prometheus and Grafana services
PROMETHEUS_EXTERNAL_IP=$(kubectl get svc prometheus-loadbalancer -n $NAMESPACE -o=jsonpath='{.status.loadBalancer.ingress[0].ip}')
GRAFANA_EXTERNAL_IP=$(kubectl get svc grafana-loadbalancer -n $NAMESPACE -o=jsonpath='{.status.loadBalancer.ingress[0].ip}')

# Output Prometheus and Grafana URLs
echo "Prometheus is accessible at: http://$PROMETHEUS_EXTERNAL_IP:9090"
echo "Grafana is accessible at: http://$GRAFANA_EXTERNAL_IP:3000"
