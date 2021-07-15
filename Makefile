app-build:
	docker-compose build

app-up:
	docker-compose up


app-booking-ash:
	docker-compose run --rm booking ash
app-core-ash:
	docker-compose run --rm core ash
app-idp-ash:
	docker-compose run --rm idp ash


app-booking-console:
	docker-compose run --rm booking bundle exec rails c

app-core-console:
	docker-compose run --rm core bundle exec rails c

app-idp-console:
	docker-compose run --rm idp bundle exec rails c


app-db-booking-create:
	docker-compose run --rm booking bundle exec rails db:create

app-db-booking-migrate:
	docker-compose run --rm booking bundle exec rails db:migrate

app-db-booking-seed:
	docker-compose run --rm booking bundle exec rails db:seed

app-db-booking-drop:
	docker-compose run --rm idp bundle exec rails db:drop



app-db-core-create:
	docker-compose run --rm core bundle exec rails db:create

app-db-core-migrate:
	docker-compose run --rm core bundle exec rails db:migrate

app-db-core-seed:
	docker-compose run --rm core bundle exec rails db:seed

app-db-core-drop:
	docker-compose run --rm idp bundle exec rails db:drop


app-db-idp-create:
	docker-compose run --rm idp bundle exec rails db:create

app-db-idp-migrate:
	docker-compose run --rm idp bundle exec rails db:migrate

app-db-idp-seed:
	docker-compose run --rm idp bundle exec rails db:seed

app-db-idp-drop:
	docker-compose run --rm idp bundle exec rails db:drop
