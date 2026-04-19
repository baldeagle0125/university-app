build:
	docker compose build

up:
	docker compose up

up-detached:
	docker compose up -d

down:
	docker compose down

down-volumes:
	docker compose down -v

logs:
	docker compose logs -f

seed-reset:
	docker compose down -v
	docker compose up -d --build

seed-verify:
	docker compose exec db sh -lc 'psql -U "$$POSTGRES_USER" -d "$$POSTGRES_DB" -c "SELECT '\''staff'\'' AS table_name, COUNT(*) AS records FROM staff UNION ALL SELECT '\''students'\'', COUNT(*) FROM students UNION ALL SELECT '\''student_memberships'\'', COUNT(*) FROM student_memberships UNION ALL SELECT '\''card_requests'\'', COUNT(*) FROM card_requests UNION ALL SELECT '\''assignments'\'', COUNT(*) FROM assignments UNION ALL SELECT '\''feedback_entries'\'', COUNT(*) FROM feedback_entries UNION ALL SELECT '\''telemetry_events'\'', COUNT(*) FROM telemetry_events ORDER BY table_name;"'

k8s-apply-local:
	kubectl apply -k k8s/overlays/local

k8s-delete-local:
	kubectl delete -k k8s/overlays/local

k8s-apply-prod:
	kubectl apply -k k8s/overlays/prod

k8s-delete-prod:
	kubectl delete -k k8s/overlays/prod

k8s-port-forward:
	nohup kubectl -n university-app port-forward svc/frontend 8081:80 >/tmp/university-app-frontend-port-forward.log 2>&1 & \
	nohup kubectl -n university-app port-forward svc/backend 3334:3333 >/tmp/university-app-backend-port-forward.log 2>&1 &

k8s-port-forward-stop:
	pkill -f "kubectl -n university-app port-forward svc/frontend 8081:80" || true
	pkill -f "kubectl -n university-app port-forward svc/backend 3334:3333" || true
