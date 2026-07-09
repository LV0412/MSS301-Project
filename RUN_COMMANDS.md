# Lệnh Chạy Dự Án MSS301

Tài liệu này tổng hợp các lệnh chạy dự án, lệnh Docker Compose, lệnh xem log, lệnh dừng service, lệnh chạy frontend, và link Swagger/OpenAPI của từng backend service.

## 1. Thư Mục Chạy Lệnh

**Dùng để:** di chuyển terminal về đúng root project trước khi chạy Docker Compose.

```powershell
cd C:\Users\ADMIN\Documents\FPT\Summer2026\MSS301\MSS301-Project
```

**Dùng để:** kiểm tra đang đứng đúng thư mục.

```powershell
dir
```

Nếu thấy các mục sau là đúng:

```text
BE
FE
docker-compose.yml
README.md
```

## 2. Chạy Toàn Bộ Backend Core Bằng Docker

**Service:** toàn bộ backend core đã được Docker hóa.

**Dùng để:** build image và chạy Auth, User, Recipe, API Gateway cùng database tương ứng.

```powershell
docker compose up --build
```

**Dùng để:** chạy toàn bộ backend ở background.

```powershell
docker compose up --build -d
```

Các service được chạy:

| Service | Công dụng | URL |
| --- | --- | --- |
| `auth-mysql` | MySQL database cho Auth Service | `localhost:3307` |
| `auth-service` | Đăng ký, đăng nhập, JWT, refresh token, OTP, reset password | `http://localhost:8000` |
| `user-mysql` | MySQL database cho User Service | `localhost:3308` |
| `user-service` | User profile, health profile, allergies, goals, favorites, food logs | `http://localhost:8001` |
| `recipe-postgres` | PostgreSQL database cho Recipe Service | `localhost:5433` |
| `recipe-service` | Recipe, ingredient, category, allergen, nutrition info | `http://localhost:8002` |
| `api-gateway-service` | Cổng vào chung cho frontend gọi backend | `http://localhost:8080` |

## 3. Kiểm Tra Trạng Thái Và Log Container

**Dùng để:** xem các container đang chạy.

```powershell
docker compose ps
```

**Dùng để:** xem log tất cả service.

```powershell
docker compose logs -f
```

**Service:** Auth Service.

**Dùng để:** xem log đăng ký, đăng nhập, OTP, JWT, refresh token.

```powershell
docker compose logs -f auth-service
```

**Service:** User Service.

**Dùng để:** xem log user profile, health profile, goals, allergies, favorites, food logs.

```powershell
docker compose logs -f user-service
```

**Service:** Recipe Service.

**Dùng để:** xem log recipe, ingredient, category, allergen, Flyway migration.

```powershell
docker compose logs -f recipe-service
```

**Service:** API Gateway.

**Dùng để:** xem log routing từ frontend sang các backend service.

```powershell
docker compose logs -f api-gateway-service
```

## 4. Dừng Và Xóa Container

**Dùng để:** dừng toàn bộ container nhưng giữ dữ liệu database trong Docker volume.

```powershell
docker compose down
```

**Dùng để:** dừng toàn bộ container và xóa luôn database volume local.

```powershell
docker compose down -v
```

Ghi chú: `docker compose down -v` sẽ xóa dữ liệu trong các volume sau:

```text
auth_mysql_data
user_mysql_data
recipe_postgres_data
```

**Dùng để:** reset database local về trạng thái sạch rồi chạy lại.

```powershell
docker compose down -v
docker compose up --build
```

## 5. Build Lại Service

**Dùng để:** build lại tất cả image.

```powershell
docker compose build
```

**Service:** Auth Service.

```powershell
docker compose build auth-service
```

**Service:** User Service.

```powershell
docker compose build user-service
```

**Service:** Recipe Service.

```powershell
docker compose build recipe-service
```

**Service:** API Gateway.

```powershell
docker compose build api-gateway-service
```

**Dùng để:** build lại và chạy lại tất cả service.

```powershell
docker compose up --build
```

## 6. Chạy Riêng Từng Backend Service Bằng Docker Compose

### Auth Service

**Dùng để:** chạy Auth Service kèm database MySQL của nó.

```powershell
docker compose up --build auth-mysql auth-service
```

**Công dụng:**

- Quản lý account đăng nhập.
- Đăng ký user.
- Verify email bằng OTP.
- Login bằng email/password.
- Login Google nếu cấu hình `GOOGLE_CLIENT_ID`.
- Cấp JWT access token và refresh token.
- Forgot/reset/change password.

**Base URL:**

```text
http://localhost:8000
```

**Swagger UI riêng:**

```text
http://localhost:8000/swagger-ui/index.html
```

**OpenAPI JSON riêng:**

```text
http://localhost:8000/v3/api-docs
```

**OpenAPI JSON qua Gateway:**

```text
http://localhost:8080/v3/api-docs/auth
```

### User Service

**Dùng để:** chạy User Service kèm database MySQL của nó.

```powershell
docker compose up --build user-mysql user-service
```

**Công dụng:**

- Quản lý user profile.
- Quản lý health profile.
- Quản lý nutrition goal.
- Quản lý diet preferences.
- Quản lý allergies.
- Quản lý favorite recipes.
- Quản lý food logs.
- Cung cấp internal API cho AI service.

**Base URL:**

```text
http://localhost:8001
```

**Swagger UI riêng:**

```text
http://localhost:8001/swagger-ui/index.html
```

**OpenAPI JSON riêng:**

```text
http://localhost:8001/v3/api-docs
```

**OpenAPI JSON qua Gateway:**

```text
http://localhost:8080/v3/api-docs/users
```

### Recipe Service

**Dùng để:** chạy Recipe Service kèm database PostgreSQL của nó.

```powershell
docker compose up --build recipe-postgres recipe-service
```

**Công dụng:**

- Quản lý recipe catalog.
- Quản lý category.
- Quản lý ingredient.
- Quản lý allergen.
- Quản lý recipe steps.
- Quản lý nutrition information.
- Search recipe theo keyword, ingredient, calories, diet type, allergen exclusion.

**Base URL:**

```text
http://localhost:8002
```

**Swagger UI riêng:**

```text
http://localhost:8002/swagger-ui.html
```

**OpenAPI JSON riêng:**

```text
http://localhost:8002/v3/api-docs
```

**OpenAPI JSON qua Gateway:**

```text
http://localhost:8080/v3/api-docs/recipes
```

### API Gateway Service

**Dùng để:** chạy gateway kèm các service phụ thuộc chính.

```powershell
docker compose up --build auth-mysql auth-service user-mysql user-service recipe-postgres recipe-service api-gateway-service
```

**Công dụng:**

- Là entry point chung cho frontend.
- Route request đến Auth/User/Recipe service.
- Cấu hình CORS tập trung.
- Hiển thị Swagger UI tổng hợp cho Auth/User/Recipe.

**Base URL:**

```text
http://localhost:8080
```

**Swagger UI tổng hợp:**

```text
http://localhost:8080/swagger-ui/index.html
```

Trong dropdown `Select API` sẽ có:

```text
Auth Service
User Service
Recipe Service
```

**Actuator health:**

```text
http://localhost:8080/actuator/health
```

**Gateway actuator routes:**

```text
http://localhost:8080/actuator/gateway/routes
```

**OpenAPI JSON qua Gateway:**

```text
Auth Service:   http://localhost:8080/v3/api-docs/auth
User Service:   http://localhost:8080/v3/api-docs/users
Recipe Service: http://localhost:8080/v3/api-docs/recipes
```

**Gateway routes:**

| Path | Route tới service |
| --- | --- |
| `/api/v1/auth/**` | `auth-service` |
| `/api/v1/users/**` | `user-service` |
| `/api/recipes/**` | `recipe-service` |
| `/api/v1/recipes/**` | `recipe-service` |
| `/api/ingredients/**` | `recipe-service` |
| `/api/v1/ingredients/**` | `recipe-service` |
| `/api/categories/**` | `recipe-service` |
| `/api/v1/categories/**` | `recipe-service` |
| `/api/allergens/**` | `recipe-service` |
| `/api/v1/allergens/**` | `recipe-service` |
| `/v3/api-docs/auth` | `auth-service` OpenAPI |
| `/v3/api-docs/users` | `user-service` OpenAPI |
| `/v3/api-docs/recipes` | `recipe-service` OpenAPI |

## 7. Swagger Và API Docs Tổng Hợp

| Service | Swagger UI | OpenAPI JSON |
| --- | --- | --- |
| API Gateway tổng hợp | `http://localhost:8080/swagger-ui/index.html` | Không dùng làm API docs chính |
| Auth Service | `http://localhost:8000/swagger-ui/index.html` | `http://localhost:8000/v3/api-docs` |
| User Service | `http://localhost:8001/swagger-ui/index.html` | `http://localhost:8001/v3/api-docs` |
| Recipe Service | `http://localhost:8002/swagger-ui.html` | `http://localhost:8002/v3/api-docs` |
| AI Recommendation Service | `http://localhost:8004/docs` | `http://localhost:8004/openapi.json` |

Ghi chú:

- Gateway Swagger UI hiện chỉ tổng hợp Auth/User/Recipe.
- AI Recommendation Service tạm thời không được thêm vào Gateway Swagger theo yêu cầu hiện tại.
- API Gateway có actuator nếu service đang chạy: `http://localhost:8080/actuator/health`.

## 8. Test Nhanh Gateway

**Dùng để:** kiểm tra API Gateway có đang chạy không.

```powershell
curl http://localhost:8080/actuator/health
```

**Dùng để:** kiểm tra Swagger UI tổng hợp.

```text
http://localhost:8080/swagger-ui/index.html
```

**Dùng để:** kiểm tra OpenAPI JSON Auth qua gateway.

```powershell
curl http://localhost:8080/v3/api-docs/auth
```

**Dùng để:** kiểm tra OpenAPI JSON User qua gateway.

```powershell
curl http://localhost:8080/v3/api-docs/users
```

**Dùng để:** kiểm tra OpenAPI JSON Recipe qua gateway.

```powershell
curl http://localhost:8080/v3/api-docs/recipes
```

**Dùng để:** kiểm tra route Auth qua gateway.

```powershell
curl http://localhost:8080/api/v1/auth/me
```

Kết quả mong đợi khi chưa login là lỗi `401 Unauthorized`, nghĩa là request đã tới Auth Service và endpoint đang được bảo vệ.

## 9. Chạy Backend Service Local Không Dùng Docker

Chỉ dùng các lệnh này khi muốn debug service bằng IDE.

### Auth Service Local

**Yêu cầu:** MySQL `auth_service` đang chạy trước.

```powershell
cd BE\services\auth-service
mvn spring-boot:run
```

### User Service Local

**Yêu cầu:** MySQL `user_service` đang chạy trước.

```powershell
cd BE\services\user-service
mvn spring-boot:run
```

### Recipe Service Local

**Yêu cầu:** PostgreSQL `recipe_service` đang chạy trước.

```powershell
cd BE\services\recipe-service
mvn spring-boot:run
```

### API Gateway Local

**Yêu cầu:** Auth/User/Recipe service đang chạy trước.

```powershell
cd BE\services\api-gateway-service
mvn spring-boot:run
```

## 10. AI Recommendation Service

AI service hiện chưa có Dockerfile trong repo, nên chạy local bằng Python.

**Dùng để:** tạo virtual environment, cài dependency và chạy AI service.

```powershell
cd BE\services\ai-recommendation-service
python -m venv .venv
.\.venv\Scripts\Activate.ps1
pip install -r requirements.txt
uvicorn app:app --reload --port 8004
```

**Swagger UI riêng của AI:**

```text
http://localhost:8004/docs
```

**Lưu ý:** AI chưa được thêm vào Swagger UI tổng hợp của Gateway trong thay đổi hiện tại.

## 11. Flutter App

Flutter app chạy riêng, chưa có Docker Compose trong repo.

```powershell
cd FE\FE_app
flutter pub get
flutter run -d chrome --dart-define=API_BASE_URL=http://localhost:8080/api/v1
```

## 12. React Admin Web

React admin web chạy riêng, chưa có Docker Compose trong repo.

```powershell
cd FE\FE_web
npm install
npm run dev
```

**Lưu ý:**

- API trong `FE/FE_web/src/api` hiện đang là stub.
- Data hiện chủ yếu lấy từ `FE/FE_web/src/data/mockData.js`.

## 13. Lệnh Thường Dùng Khi Lỗi Docker

**Dùng để:** xem container nào đang chạy hoặc đang chiếm port.

```powershell
docker ps
```

**Dùng để:** build lại không dùng cache.

```powershell
docker compose build --no-cache
```

**Dùng để:** build lại không dùng cache rồi chạy.

```powershell
docker compose build --no-cache
docker compose up
```

**Dùng để:** xóa container, network, image không dùng nữa.

```powershell
docker system prune
```

**Dùng để:** xóa cả volume không dùng nữa.

```powershell
docker system prune --volumes
```

Ghi chú: các lệnh `prune` có thể xóa resource Docker của project khác trên máy.

## 14. Thứ Tự Chạy Khuyến Nghị Khi Demo

**Bước 1: chạy backend core.**

```powershell
docker compose up --build -d
```

**Bước 2: kiểm tra backend.**

```powershell
docker compose ps
curl http://localhost:8080/actuator/health
```

**Bước 3: mở Swagger.**

```text
Gateway tổng hợp: http://localhost:8080/swagger-ui/index.html
Auth riêng:       http://localhost:8000/swagger-ui/index.html
User riêng:       http://localhost:8001/swagger-ui/index.html
Recipe riêng:     http://localhost:8002/swagger-ui.html
```

**Bước 4: chạy Flutter app.**

```powershell
cd FE\FE_app
flutter pub get
flutter run -d chrome --dart-define=API_BASE_URL=http://localhost:8080/api/v1
```

**Bước 5: chạy React admin web nếu cần.**

```powershell
cd FE\FE_web
npm install
npm run dev
```
