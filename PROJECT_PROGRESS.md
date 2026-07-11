# NutriChef AI - Tien do hien tai

Ngay cap nhat: 2026-07-11

Tai lieu nay tong hop trang thai thuc te sau khi ra soat lai ca backend va frontend. Muc tieu la giup chon viec tiep theo theo cach lam "BE co API den dau thi noi FE den do", tranh lam rieng le tung phan.

## 1. Tong quan kien truc hien tai

Du an dang la monorepo gom:

- `BE/services/auth-service`: Spring Boot, MySQL, quan ly account, JWT, email OTP, Google login.
- `BE/services/user-service`: Spring Boot, MySQL, quan ly user profile, health profile, nutrition goal, diet preference, allergy, favorite, food log, internal API cho AI.
- `BE/services/recipe-service`: Spring Boot, PostgreSQL, quan ly recipe, category, ingredient, allergen, nutrition, search/filter recipe.
- `BE/services/api-gateway-service`: Spring Cloud Gateway, route frontend den Auth/User/Recipe/AI.
- `BE/services/ai-recommendation-service`: FastAPI Python, pipeline Hybrid Search/RAG/FoodyLLM fallback/optimizer.
- `FE/FE_app`: Flutter app cho user.
- `FE/FE_web`: React admin web, hien tai chu yeu la UI mock/stub.

Backend core dang docker hoa cho Auth, User, Recipe, API Gateway. AI service chay local bang Python port `8004`, chua duoc noi on dinh vao Docker Compose core.

## 2. Backend hien tai

### Auth Service

Da co:

- Register, login, refresh token, logout.
- Verify email bang OTP, resend OTP.
- Forgot/reset/change password.
- `GET /api/v1/auth/me`.
- Google login.
- Google account linking voi LOCAL account: neu email Google trung LOCAL thi yeu cau nhap mat khau, verify thanh cong thi link Google va tra access token/refresh token ngay.
- FE da xu ly popup nhap mat khau khi backend tra `GOOGLE_LINK_PASSWORD_REQUIRED`.

Can luu y:

- Auth service chi quan ly account. User profile ben `user-service` van can duoc tao/dong bo rieng.
- Google login tao account trong auth-service, nhung flow tao user profile ben user-service chua that su chat che.

### User Service

Da co API:

- User CRUD: `/api/v1/users`.
- Health profile: `/api/v1/users/{userId}/health-profile`.
- Nutrition goal: `/api/v1/users/{userId}/nutrition-goal`.
- Diet preferences: `/api/v1/users/{userId}/diet-preferences`.
- Allergies: `/api/v1/users/{userId}/allergies`.
- Favorites: `/api/v1/users/{userId}/favorites`.
- Food logs: `/api/v1/users/{userId}/food-logs`.
- Internal APIs cho AI: `/api/internal/ai-profile/{userId}`, health profile status, nutrition goal, diet preferences, allergies, food logs.

Da co mot so rule:

- Moi user chi co mot health profile.
- Moi user chi co mot nutrition goal.
- Khong cho trung diet preference.
- Khong cho trung user allergy.
- Khong cho trung favorite theo user va recipe id.
- Food log/favorite chi thao tac trong pham vi `userId` tren path.

Gap can sua:

- BR-03/04 chua dung yeu cau: hien validate height `1-300`, weight `1-500`; business rule yeu cau height `50-250 cm`, weight `10-300 kg`.
- BR-05 age `13-120` chua duoc enforce ro. `User` co `dob`, nhung create/update user chi dung `@Past`, chua tinh tuoi.
- Favorite va Food Log dang luu `recipeId` nhung chua goi Recipe Service de xac minh recipe ton tai.
- Chua thay gateway/service-level ownership check dua tren JWT de dam bao user chi xem/sua du lieu cua minh. Hien path co `userId`, FE hoac caller co the truyen id khac neu khong chan them.

### Recipe Service

Da co API:

- Recipe CRUD/search: `/api/recipes`, `/api/v1/recipes`.
- Category CRUD: `/api/categories`, `/api/v1/categories`.
- Ingredient CRUD: `/api/ingredients`, `/api/v1/ingredients`.
- Allergen CRUD: `/api/allergens`, `/api/v1/allergens`.
- Internal recipe search: `/api/internal/recipes`.

Da co mot so rule:

- Recipe request bat buoc co category.
- Nutrition request bat buoc.
- Duplicate ingredient trong recipe bi chan.
- Recipe step order phai lien tiep tu 1.
- Search ho tro `dietType`, calorie range, ingredient, category, va `excludedAllergenIds`.

Gap can kiem tra/bo sung:

- Business rule noi recipe phai co it nhat mot ingredient va it nhat mot step. DTO hien co list ingredients/steps nhung can dam bao co `@NotEmpty` hoac validation tuong duong.
- Recipe hien chi co mot `categoryId`, trong khi BR-09 noi moi recipe thuoc it nhat mot category. Neu bao cao/DB muon multi-category thi can doi model, con neu chap nhan one-category thi ghi ro trong tai lieu.
- Admin web chua noi API thuc te de quan ly recipe/ingredient/category/allergen.

### API Gateway

Da co route:

- `/api/v1/auth/**` -> Auth Service.
- `/api/v1/users/**` va `/api/internal/**` lien quan user -> User Service.
- `/api/recipes/**`, `/api/v1/recipes/**`, `/api/ingredients/**`, `/api/categories/**`, `/api/allergens/**`, `/api/internal/recipes/**` -> Recipe Service.
- `/api/ai/**` -> AI Recommendation Service.

Gap can sua:

- Gateway chua co JWT filter/authorization layer, trong khi BR-47 yeu cau API AI Recommendation phai xac thuc JWT truoc khi xu ly.
- `docker-compose.yml` dang route AI den `http://ai-recommendation-service:8003`, trong khi AI config va RUN_COMMANDS dung port `8004`.
- AI service nam trong profile `future`, chua phai mot service core chay cung compose.

### AI Recommendation Service

Da co:

- FastAPI app.
- `GET /health`.
- `POST /api/ai/recommendations`.
- Request gom query, user_id, diet, goal, allergies, max_calories, target_calories, budget.
- Search Recipe Service internal API truoc, fallback local corpus neu Recipe Service loi.
- Hybrid search, prompt builder, FoodyLLM local fallback, optimizer nhe theo calorie/protein/budget.
- Co schema/repository/service de luu `ai_suggestion`, `suggested_recipe`, `meal_plan`, `meal_plan_item`.

Gap lon:

- Endpoint recommendation chua goi `UserServiceClient.get_ai_profile`, nen BF-02 "Load User Profile" chua end-to-end.
- Endpoint recommendation chua goi `save_suggestion`, nen BR-25 "AI phai luu lich su Recommendation" chua end-to-end.
- Chua co JWT auth/lay userId tu token; request van cho truyen `user_id`.
- Rule Engine moi dang gian tiep qua filter request; chua co gate bat buoc health profile day du.
- Allergy filter chi map duoc `allergen:{id}` sang `excludedAllergenIds`; neu user allergy la text nhu `peanut` thi chua dam bao recipe-service loai dung.
- Meal plan hien moi tra list recommended items, chua tao meal plan day du breakfast/lunch/dinner/snack theo BF-03/BR-30 den BR-36.

## 3. Frontend hien tai

### Flutter app

Da co:

- Load config tu root `.env` bang `flutter_dotenv`.
- `AppConfig` la diem quan ly config duy nhat.
- Auth UI/API: login, register, verify email, Google Sign-In, Google LOCAL linking popup.
- Luu access token/refresh token, auto attach token va refresh khi 401.
- Profile screen doc account tu `/auth/me`.
- Co doc user profile, health profile, nutrition goal, diet preferences, allergies tu user-service.
- Co doc recipe list tu recipe-service de hien thi mot so danh sach.

Dang con thieu:

- Chua co UI/API create/update health profile end-to-end.
- Chua co UI/API create/update nutrition goal end-to-end.
- Chua co UI/API them/xoa diet preferences va allergies end-to-end.
- Chua co AI recommendation client/screen goi `/api/ai/recommendations` that.
- Chua co food log/favorite end-to-end trong Flutter.
- Nhieu man hinh trong `main.dart` van la UI/demo/static hoac chi lay recipe list thay cho meal plan AI.
- User sync giua auth account va user-service profile can lam chat hon. Hien `UserRepository.createFromAccount` ton tai nhung flow sau login/register/Google can duoc chuan hoa.

### React Admin Web

Da co:

- Dashboard/pages cho overview, user, recipe, nutrition, AI knowledge, reports, settings.
- UI kha day du cho admin demo.

Dang con thieu:

- Data chu yeu lay tu `mockData.js`.
- `src/api/*` la stub, chua goi backend thuc.
- Chua co auth admin/role guard that.
- Chua noi CRUD recipe/category/ingredient/allergen vao Recipe Service.

## 4. Muc do khop voi Business Rules

Dang kha tot:

- BR-01: moi user chi mot health profile.
- BR-06: moi user chi mot nutrition goal.
- BR-07/08: user co nhieu diet preferences/allergies.
- BR-13/14/15: recipe-ingredient-allergen da co model phu hop.
- BR-27/28: AI co hybrid search/top-k scaffold.
- BR-40: khong luu trung favorite.

Can sua som:

- BR-03/04/05: validate height, weight, age dung theo rule.
- BR-02/22: bat buoc hoan thanh health profile truoc khi dung AI.
- BR-16/17/18/19/20/21: allergy/diet rule engine can dam bao chay truoc RAG va khong de AI de xuat sai.
- BR-24: AI chi de xuat recipe co trong Recipe Database. Hien co fallback local corpus, tot cho dev nhung khi demo rule nay can tat fallback hoac danh dau ro.
- BR-25: luu lich su recommendation chua noi vao endpoint.
- BR-30/31/32/34/35/36: meal plan/nutrition score chua that su hoan chinh.
- BR-37/46/47: ownership/JWT enforcement can lam chat hon.
- BR-38/41: Food Log/Favorite can verify recipe ton tai qua Recipe Service.

## 5. Nen lam gi tiep theo

Huong nen lam la chon tung "vertical slice": sua BE rule/API, sau do noi FE ngay trong cung dot.

### Uu tien 1: Hoan thien BF-01 Onboarding Health Profile

Ly do: Day la dieu kien chan truoc AI Recommendation, lien quan BR-02 va BR-22.

Nen lam:

- BE user-service: sua validation height `50-250`, weight `10-300`, age `13-120`.
- BE user-service: them/kiem tra endpoint status hoan thanh profile gom user dob/gender, health profile, nutrition goal, diet/allergy.
- FE Flutter: them man hinh tao/cap nhat health profile, nutrition goal, diet preference, allergy.
- FE Flutter: sau login, neu profile chua du thi dieu huong sang onboarding hoac hien CTA ro rang.
- Test: user moi dang ky -> login -> tao profile -> quay ve home ready for AI.

### Uu tien 2: Noi AI Recommendation MVP end-to-end

Ly do: Day la core cua do an.

Nen lam:

- BE AI: endpoint lay user profile tu user-service bang `userId`.
- BE AI: neu health profile/nutrition goal thieu thi tra loi loi ro rang, khong goi RAG.
- BE AI: convert allergy ids tu user-service thanh `excludedAllergenIds`.
- BE AI: convert diet preference sang `dietType` search recipe-service.
- BE AI: goi `save_suggestion` de luu lich su.
- Gateway/Docker: fix AI port `8004` va dua AI service vao run path on dinh.
- FE Flutter: them repository goi `/api/ai/recommendations`.
- FE Flutter: nut "Request Meal Recommendation" goi API va render ket qua recipe/summary.

### Uu tien 3: Food Log va Favorite

Ly do: Day la cac flow sau recommendation va co business rule ro.

Nen lam:

- BE user-service: verify `recipeId` ton tai truoc khi save favorite/food log.
- FE Flutter: add/remove favorite tren recipe.
- FE Flutter: tao food log tu recipe, quantity, meal type, date.
- AI: doc food logs trong `InternalAiProfileResponse` de lam input cho lan goi tiep theo.

### Uu tien 4: Admin Web noi Recipe Service

Ly do: Admin can seed/quan ly recipe database, la nguon du lieu cho AI.

Nen lam:

- React admin: thay mock recipe/category/ingredient/allergen bang API client.
- Noi create/update/delete recipe.
- Noi assign ingredient/allergen/category.
- Sau do moi lam AI knowledge/index UI neu can.

## 6. Viec nen tranh luc nay

- Chua nen mo rong sang Apple/Facebook/Microsoft login.
- Chua nen tach `UserIdentity` rieng neu chi moi co Google va LOCAL.
- Chua nen toi uu thuat toan AI phuc tap khi BF-01/BF-02 chua end-to-end.
- Chua nen lam them UI mock moi neu chua co API thuc de noi.

## 7. Rui ro ky thuat hien tai

- Gateway chua enforce JWT tap trung.
- AI port/config trong Docker Compose dang lech voi config service.
- AI service co persistence scaffold nhung endpoint chua su dung.
- Flutter app gom nhieu UI trong mot file `main.dart`, ve sau se kho bao tri neu tiep tuc them tinh nang lon.
- `.env` co chua client id/secret-like config, can dam bao khong commit gia tri nhay cam.

## 8. Ket luan de chon viec tiep theo

Viec tiep theo nen lam la:

1. Hoan thien onboarding Health Profile/Nutrition Goal/Diet/Allergy ca BE va FE.
2. Sau khi user co profile day du, noi AI Recommendation MVP qua Gateway.
3. Sau do moi lam Food Log/Favorite va Admin Recipe integration.

Neu lam theo thu tu nay, moi lan code deu co ket qua demo duoc: user dang nhap, tao profile, bam goi y AI, nhan meal recommendation tu recipe database, luu history, roi dung food log/favorite cho lan goi y sau.
