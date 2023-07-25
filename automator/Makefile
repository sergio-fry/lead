run:
	docker build -t automator .
	docker rm -f automator-service
	docker run --add-host jira.balance-pl.ru:172.25.42.150 --network host -it --restart unless-stopped --name automator-service -d automator
	docker logs -f automator-service

