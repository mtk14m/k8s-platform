# Makefile pour k8s-platform

# Variables
NS_MONITORING = monitoring
NS_APP = default

.PHONY: help access deploy-app

help: ## Affiche cette aide
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

access: ## Ouvre tous les accès (ArgoCD, Grafana, Prom, Alertmanager) en background
	@echo "Ouverture des tunnels..."
	@kubectl port-forward svc/argocd-server -n argocd 8080:443 > /dev/null 2>&1 &
	@kubectl port-forward svc/monitoring-stack-grafana -n $(NS_MONITORING) 3000:80 > /dev/null 2>&1 &
	@kubectl port-forward svc/prometheus-operated -n $(NS_MONITORING) 9090:9090 > /dev/null 2>&1 &
	@kubectl port-forward svc/alertmanager-operated -n $(NS_MONITORING) 9093:9093 > /dev/null 2>&1 &
	@echo "Accès ouverts !"
	@echo "   - ArgoCD: https://localhost:8080"
	@echo "   - Grafana: http://localhost:3000"
	@echo "   - Prometheus: http://localhost:9090"
	@echo "   - Alertmanager: http://localhost:9093"

stop-access: ## Coupe tous les port-forwards
	@pkill -f "kubectl port-forward" || echo "Aucun tunnel à fermer."

deploy-app: ## Applique les changements de l'appli (Monitoring + App)
	kubectl apply -f k8s-platform/
