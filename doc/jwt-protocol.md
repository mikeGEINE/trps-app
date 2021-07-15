# Описание протокола

В протоколе участвуют три стороны: браузер юзера (далее — клиент), микросервис, на который клиент логинится (далее — сервис) и IDP-сервер, который заниматся аутентикацией пользователей и генерацией jwt-токенов (далее — idp).

## Фаза аутентикации

1. Браузер делает GET на [произвольный] endpoint, от которого получает редирект 302 на login-page IDP-сервера (/auth/sso/jwt/login); в параметрах GET редиректа указываем:
  * `token` — jwt-токен с полями "iss": "имя_сервиса" "exp": время_истечения , время истечения — number of seconds since the Epoch; токен должен быть подписан секретным ключом сервиса, публичный ключ лежит в файле с именем сервиса на IDP
  * `callbackUrl` — URL консьюмера аутентикации на стороне Сервиса; на него позже прилетит POST скрытой формы с результатами успешной аутентикации
  * `returnUrl` — опциональный URL для фронтенд-редиректа после завершения аутентикации, если таковой нужен.

  пример хидера Location  для редиректа на IDP:
  ```
  Location: http://192.168.47.92:8085/auth/sso/jwt/login?token=eyJhbGciOiJSUzI1NiJ9.eyJpc3MiOiJ3b3JrbG9ncyIsImV4cCI6MTU5NDM3ODIxMH0.Pl-g6e8DjIdRgJyYu16ZwUgnnI_g3VJy_fd3kZdI1r9nkHNqyadCJmWzFHNpY70Q_ExrxLUjDxYL4H16JbMMosa0oL6cJD9JddJOwm1uvH8UWIZpWkbFoA8_DMl79PRNSCN0C1nW1WCZ7lpoStqD2cyhWyDol21n6fzILWvKHE0&callbackUrl=http://192.168.47.92:8080/jwt/acs&returnUrl=http://192.168.47.92:8095/
  ```

2. Аутентикация происходит целиком на территории IDP; как только она увенчивается успехом, мы получаем в браузер скрытую форму, которая автоматом отправляет POST на callbackUrl со след. параметрами:
  * `access_token` — готовый jwt access-token для аутентицированного юзера
  * `return_url` — без изменений переданный ранее returnUrl — если нужно, backend Сервиса им может воспоьзоваться

  Пример Form Data макетного POST-а:
  ```
  utf8: ✓
  authenticity_token: IS7MWW7URpsn3jtSS2d8nBLwpnpnRCQCdVo8AswzBVRAu8EWLD/1svFbkagmkl3QWFsIPFGozvKN88lSCnnMgg==
  access_token: eyJhbGciOiJSUzI1NiJ9.eyJzdWIiOjEwNywiaXNzIjoiaWRwIiwiZXhwIjoxNTk0Mzc5MjIzLCJyZWZyZXNoX3Rva2VuIjpmYWxzZSwiZW1haWwiOiJoZXJ0YUBqZXJkZS5jb20iLCJyb2xlIjoic3VwZXJhZG1pbiJ9.f1L2oMuAbMkP4-1aYI5fz3JPKDDgg8fjeYyaH6C0sSFSO3X5RTNzkMqTAYHFPRPoJF_PLLF4Ol5o7jhJYjSFNZEH8-yh-FJ5jq38PPrOTFwrNh_6CbZRdQmpMFD9kBgBG4sLlNHaFzNzx4o7a8bCVVkPUL6ef40IV8y1jgLGzgQ
  return_url: http://192.168.47.92:8095/
  ```

  Токены из примера можешь поглядеть на предмет пейлоада. в нём лежат:
  ```json
  {
    "sub": 105,
    "iss": "idp",
    "exp": 1594379223,
    "email": "foo@bar.com",
    "role": "admin"
  }
  ```

  * `sub` — id юзера на стороне IDP
  * `iss` — имя сервиса IDP (для криптосверки подписи)
  * `exp` — секунда истечения
  * `email` — email (он же — логин) юзера
  * `role` — роль юзера в приложении

## Фаза логаута

1. Браузер говорит Сервису `DELETE <logout_url>`, на что получает редирект на IDP, `Location: /auth/sso/jwt/logout` с актуальным access-токеном логаутящегося юзера либо с "техническим" токеном (аналогично логин-фазе) в параметре `token`. Пример:
  ```
  Location: http://192.168.47.92:8085/auth/sso/jwt/logout?token=eyJhbGciOiJSUzI1NiJ9.eyJpc3MiOiJ3b3JrbG9ncyIsImV4cCI6MTU5NDM4NzMwMn0.mHXKDyS3XGWEEkYOi06107Gdzb4850sxIX6jBUq0BDUz2tnHtTLj5QVjp9k71Ajod0YwvwiRF-Z3x4JEi7XNUK2fZ5c2G8yPmsB_QBSxTqlGuTm3j_cQvpWcG2is2laypwR3EAxAX2WFEe1w_k10I6mTSsAFGo2KOMdhXaQPBjY&callbackUrl=http://192.168.47.92:8080/jwt/logout&returnUrl=http://192.168.47.92:8095/instances/new
  ```
  * `token` — в примере — технический токен;
  * `callbackUrl` — аналогично логину, URL, на который ждём POST скрытой формы логаута,
  * `returnUrl` опциональный.

  **NB:** в случае, если передаваемый в параметре токен — технический, IDP берёт информацию о разлогиниваемом юзере из браузерной сессии. Иначе — из самого токена.

2. IDP логаутит юзера, после чего от браузера прилетает POST скрытой формы на callbackUrl логаута с параметрами:
  * `token` и `access_token` — токен логаута (см. ниже);
  * `return_url` — опциональный URL “исходной точки” — например, для незалогиненного лендинга и т.п.

  **Пример 'Form data' скрытой формы:**
  ```
  utf8: ✓
  authenticity_token: HkzSpq9FTqhY526AUbl6yDFpQot8LLQlwy4R5XLgV/stCnFWDKQJl87Xk3W2lkMLl5Xi4K9WwW6COfkd9dPppw==
  token: eyJhbGciOiJSUzI1NiJ9.eyJzdWIiOjEwNywiaXNzIjoiaWRwIiwiZXhwIjoxNTk0Mzg3MzAzLCJlbWFpbCI6ImhlcnRhQGplcmRlLmNvbSIsInJvbGUiOiJzdXBlcmFkbWluIn0.U_WzN67uKGaXZfwqCtTiy62JXuarSywoFyMY14mi261ldfjTvDyeS4gwNMmIs569BmlwY-6t6xpxV9x_ldE2xvDm7D2tn_cHVTk1Ha2xrj8djMkRUsv9nr_2IzPywbkJIu2_1QNcuZ2zMId83J8yC14LYkyG8RfB-Dl2ktj4_wU
  access_token: eyJhbGciOiJSUzI1NiJ9.eyJzdWIiOjEwNywiaXNzIjoiaWRwIiwiZXhwIjoxNTk0Mzg3MzAzLCJlbWFpbCI6ImhlcnRhQGplcmRlLmNvbSIsInJvbGUiOiJzdXBlcmFkbWluIn0.U_WzN67uKGaXZfwqCtTiy62JXuarSywoFyMY14mi261ldfjTvDyeS4gwNMmIs569BmlwY-6t6xpxV9x_ldE2xvDm7D2tn_cHVTk1Ha2xrj8djMkRUsv9nr_2IzPywbkJIu2_1QNcuZ2zMId83J8yC14LYkyG8RfB-Dl2ktj4_wU
  return_url: http://192.168.47.92:8095/instances/new
  ```

  **Logout token**

  Это JWT-токен, приходящий при успешном завершении фазы логаута в параметрах запроса `POST` скрытой формы (на схеме — `POST /jwt/logout` в фазе логаута). Если на IDP при логауте юзер был найден, токен содержит поля, идентичные access-token'у (`sub`, `email`, `role` c id, email и ролью юзера в core соответственно) их можно использовать на стороне клиентского микросервиса по усмотрению разработчика. Если IDP юзера не нашёл, в токене будут поля:
  ```json
  {
    "sub": "idp-logout",
    "iss": "idp",
    "exp": 1599228
  }
  ```

  ## Список литературы

  1. [Сайт про стандарт токена JWT](https://jwt.io/). Там по ссылке есть список библиотек на чуть более, чем всех мейнстримных языках, в т.ч. Go, Rust, Haskell, OCaml, Scala, Ruby, Python, JS.
  2. [Самый дельный и популярный гайдлайн по протоколу аутентикации с JWT](https://gist.github.com/zmts/802dc9c3510d79fd40f9dc38a12bccfc). В него регулярно вносятся правки, а в комментах идёт непрерывный срач, так что подписываемся и жмём колокольчик.
