export const growthData = [
  { month: "T1", users: 3200, premium: 1200, retention: 68 },
  { month: "T2", users: 4100, premium: 1600, retention: 71 },
  { month: "T3", users: 5600, premium: 2300, retention: 73 },
  { month: "T4", users: 7900, premium: 3300, retention: 76 },
  { month: "T5", users: 10400, premium: 4800, retention: 79 },
  { month: "T6", users: 12482, premium: 6200, retention: 82 }
];

export const goalDistribution = [
  { name: "Giảm cân", value: 42, color: "#536b58" },
  { name: "Tăng cơ", value: 28, color: "#8a6a46" },
  { name: "Duy trì", value: 30, color: "#f4efe0" }
];

export const allergyDistribution = [
  { name: "Sữa", value: 31 },
  { name: "Hạt", value: 24 },
  { name: "Hải sản", value: 19 },
  { name: "Gluten", value: 16 },
  { name: "Trứng", value: 10 }
];

export const trendingIngredients = [
  { name: "Bơ", score: 84, category: "Produce" },
  { name: "Cải xoăn", score: 67, category: "Vegetables" },
  { name: "Quinoa", score: 52, category: "Grains" },
  { name: "Cá hồi", score: 76, category: "Proteins" },
  { name: "Khoai lang", score: 61, category: "Produce" }
];

export const recipes = [
  {
    id: "med-buddha",
    name: "Mediterranean Buddha Bowl",
    cuisine: "Địa Trung Hải",
    calories: 450,
    protein: 24,
    carb: 56,
    fat: 12,
    fiber: 9,
    allergens: ["Mè"],
    dietTags: ["Vegan", "Giàu chất xơ"],
    status: "Đã xuất bản",
    updated: "1 ngày trước",
    rating: 4.9,
    image: "https://images.unsplash.com/photo-1512621776951-a57141f2eefd?auto=format&fit=crop&w=240&q=80"
  },
  {
    id: "salmon-asparagus",
    name: "Cá hồi áp chảo măng tây",
    cuisine: "Bắc Âu",
    calories: 380,
    protein: 34,
    carb: 12,
    fat: 22,
    fiber: 5,
    allergens: ["Cá"],
    dietTags: ["Keto", "Protein cao"],
    status: "Đã xuất bản",
    updated: "2 ngày trước",
    rating: 4.8,
    image: "https://images.unsplash.com/photo-1467003909585-2f8a72700288?auto=format&fit=crop&w=240&q=80"
  },
  {
    id: "summer-salad",
    name: "Salad quả mọng mùa hè",
    cuisine: "Continental",
    calories: 290,
    protein: 8,
    carb: 45,
    fat: 10,
    fiber: 7,
    allergens: ["Sữa", "Hạt"],
    dietTags: ["Ít calo"],
    status: "Bản nháp",
    updated: "3 ngày trước",
    rating: 4.6,
    image: "https://images.unsplash.com/photo-1490645935967-10de6ba17061?auto=format&fit=crop&w=240&q=80"
  },
  {
    id: "pho-fit",
    name: "Phở gà cân bằng macro",
    cuisine: "Việt Nam",
    calories: 420,
    protein: 32,
    carb: 48,
    fat: 9,
    fiber: 4,
    allergens: [],
    dietTags: ["Ít béo"],
    status: "Đã xuất bản",
    updated: "5 ngày trước",
    rating: 4.7,
    image: "https://images.unsplash.com/photo-1504674900247-0877df9cc836?auto=format&fit=crop&w=240&q=80"
  }
];

export const ingredients = [
  { id: "carrot", name: "Cà rốt hữu cơ", category: "Rau củ", calories: 41, protein: 0.9, carb: 9.6, fat: 0.2, fiber: 2.8, sodium: 69, sugar: 4.7, allergen: "-", updated: "Hôm nay" },
  { id: "chicken", name: "Ức gà", category: "Protein", calories: 165, protein: 31, carb: 0, fat: 3.6, fiber: 0, sodium: 74, sugar: 0, allergen: "-", updated: "Hôm qua" },
  { id: "almond", name: "Hạnh nhân thô", category: "Protein", calories: 579, protein: 21.2, carb: 21.6, fat: 49.9, fiber: 12.5, sodium: 1, sugar: 4.4, allergen: "Hạt", updated: "2 ngày trước" },
  { id: "quinoa", name: "Quinoa sống", category: "Ngũ cốc", calories: 368, protein: 14.1, carb: 64.2, fat: 6.1, fiber: 7, sodium: 5, sugar: 0, allergen: "-", updated: "24h trước" },
  { id: "milk", name: "Sữa nguyên kem", category: "Sữa", calories: 61, protein: 3.2, carb: 4.8, fat: 3.3, fiber: 0, sodium: 43, sugar: 5.1, allergen: "Sữa", updated: "3 ngày trước" }
];

export const users = [
  { id: "elena", name: "Elena Belova", email: "elena.b@example.com", country: "Hoa Kỳ", goal: "Giảm cân", health: "Tối ưu", allergies: ["Đậu phộng", "Sữa"], status: "Hoạt động", joined: "12/04/2026", lastActive: "2 phút trước", avatar: "EB" },
  { id: "marcus", name: "Marcus Chen", email: "m.chen@health.io", country: "Canada", goal: "Tăng cơ", health: "Cần tư vấn", allergies: [], status: "Hoạt động", joined: "03/03/2026", lastActive: "4 giờ trước", avatar: "MC" },
  { id: "sarah", name: "Sarah Al-Fayed", email: "sarah.diet@web.de", country: "Đức", goal: "Keto", health: "Chờ đồng bộ", allergies: ["Hải sản"], status: "Không hoạt động", joined: "20/01/2026", lastActive: "14 ngày trước", avatar: "SA" },
  { id: "julia", name: "Julia V. Smith", email: "julia.smith@provider.com", country: "Anh", goal: "Sức bền", health: "Tối ưu", allergies: ["Gluten"], status: "Hoạt động", joined: "15/02/2026", lastActive: "15 phút trước", avatar: "JS" }
];

export const recentActivity = [
  { user: "Elena Martinez", action: 'Tạo công thức AI "Pasta bí ngòi"', plan: "Premium", status: "Thành công", time: "2 phút trước" },
  { user: "Marcus Kang", action: "Cập nhật mục tiêu cân nặng (-5kg)", plan: "Basic", status: "Thành công", time: "12 phút trước" },
  { user: "Sarah Parker", action: 'Báo cáo lỗ hổng knowledge: "FODMAP"', plan: "Premium", status: "Đang chờ", time: "45 phút trước" },
  { user: "Ben Jenkins", action: "Gia hạn gói đăng ký", plan: "Premium", status: "Thành công", time: "1 giờ trước" }
];

export const knowledgeSources = [
  { id: "who", name: "WHO_Nutrition_Guidelines_2024.pdf", type: "PDF", source: "WHO", scope: "Nutrition Guideline", version: "v2024.2", status: "Đã xử lý", indexed: "10 phút trước", updated: "01/07/2026", chunks: 482 },
  { id: "med", name: "Mediterranean_Recipe_Collection_v2.csv", type: "CSV", source: "Internal Dataset", scope: "Recipe Retrieval", version: "v2.1", status: "Đang index 64%", indexed: "Đang chạy", updated: "30/06/2026", chunks: 312 },
  { id: "safe", name: "NutriChef_Safety_Protocols.docx", type: "DOCX", source: "Safety Team", scope: "Safety Rule", version: "v1.4", status: "Đã xử lý", indexed: "1 giờ trước", updated: "28/06/2026", chunks: 112 },
  { id: "meal", name: "Meal_Planning_Rules_v3.json", type: "JSON", source: "Nutrition Ops", scope: "Meal Planning", version: "v3.0", status: "Đã xử lý", indexed: "2 giờ trước", updated: "27/06/2026", chunks: 96 }
];

export const aiOverviewCards = [
  { label: "AI Service Status", value: "Online", note: "FoodyLLM gateway đang phản hồi", tone: "ok" },
  { label: "LLM Mode", value: "FoodyLLM", note: "Mock fallback bật khi latency cao" },
  { label: "Embedding Model", value: "food-embed-v2", note: "1536 dimensions" },
  { label: "Vector Database", value: "Connected", note: "Pinecone compatible store", tone: "ok" },
  { label: "Total Indexed Recipes", value: "4,120", note: "84.2% kho công thức" },
  { label: "Indexed Documents", value: "1,002", note: "Knowledge + safety chunks" },
  { label: "Retrieval Latency", value: "82ms", note: "Trung bình 24h" },
  { label: "Generation Latency", value: "1.8s", note: "P95 3.4s" },
  { label: "Error Rate", value: "1.7%", note: "Giảm 0.4% so với hôm qua", tone: "warning" },
  { label: "Recommendations Today", value: "12,860", note: "+14% so với tuần trước" }
];

export const recipeVectorIndex = {
  totalRecipes: "4,892",
  indexedRecipes: "4,120",
  pendingRecipes: "312",
  failedEmbeddings: "46",
  lastSync: "01/07/2026 09:42"
};

export const recommendationResults = [
  { id: "med-buddha", name: "Mediterranean Buddha Bowl", score: "0.94", calories: 450, protein: 24, carbs: 56, fat: 12, reason: "Giàu chất xơ, hợp mục tiêu giảm cân và chế độ Mediterranean.", nutritionMatch: "92%", allergySafety: "An toàn", source: "Recipe index · Chunk #184" },
  { id: "pho-fit", name: "Phở gà cân bằng macro", score: "0.89", calories: 420, protein: 32, carbs: 48, fat: 9, reason: "Protein cao, ít béo, phù hợp bữa trưa.", nutritionMatch: "88%", allergySafety: "An toàn", source: "Recipe index · Chunk #77" },
  { id: "salmon-asparagus", name: "Cá hồi áp chảo măng tây", score: "0.83", calories: 380, protein: 34, carbs: 12, fat: 22, reason: "Low carb tốt nhưng cần cảnh báo allergen cá.", nutritionMatch: "84%", allergySafety: "Cần xác nhận", source: "Safety rules · Chunk #12" }
];

export const mealPlanRows = [
  { day: "Ngày 1", breakfast: "Yến mạch Hy Lạp", lunch: "Mediterranean Buddha Bowl", dinner: "Cá hồi măng tây", snack: "Sữa chua berries", calories: 1780, protein: 118, carbs: 184, fat: 58, status: "Đạt mục tiêu" },
  { day: "Ngày 2", breakfast: "Trứng rau củ", lunch: "Phở gà cân bằng macro", dinner: "Salad đậu gà", snack: "Táo bơ đậu phộng", calories: 1855, protein: 126, carbs: 176, fat: 64, status: "Carb hơi thấp" },
  { day: "Ngày 3", breakfast: "Smoothie protein", lunch: "Bowl quinoa", dinner: "Ức gà rau củ", snack: "Hạnh nhân", calories: 1812, protein: 132, carbs: 168, fat: 61, status: "Đạt mục tiêu" }
];

export const aiPipelineLogs = [
  { requestId: "AI-240701-0921", userId: "elena", query: "Bữa trưa low carb giàu protein", type: "Recipe Recommendation", retrieved: 42, filtered: 31, final: 5, retrievalLatency: "78ms", generationLatency: "1.6s", totalLatency: "1.9s", status: "Success", createdAt: "09:21 hôm nay" },
  { requestId: "AI-240701-0918", userId: "marcus", query: "Meal plan tăng cơ 3 ngày", type: "Meal Plan", retrieved: 86, filtered: 54, final: 12, retrievalLatency: "96ms", generationLatency: "2.4s", totalLatency: "2.8s", status: "Low Confidence", createdAt: "09:18 hôm nay" },
  { requestId: "AI-240701-0904", userId: "sarah", query: "Keto dessert không hạt", type: "Retrieval Test", retrieved: 18, filtered: 7, final: 0, retrievalLatency: "112ms", generationLatency: "0.8s", totalLatency: "1.2s", status: "Failed", createdAt: "09:04 hôm nay" }
];

export const pipelineTrace = [
  { step: "User context loaded", status: "OK", detail: "Goal, allergy mask và diet preference đã nạp." },
  { step: "Recipe candidates retrieved", status: "OK", detail: "42 candidates từ vector index." },
  { step: "Allergy filter result", status: "OK", detail: "Loại 11 công thức chứa hạt hoặc sữa." },
  { step: "Diet filter result", status: "OK", detail: "31 công thức khớp low carb/high protein." },
  { step: "Nutrition scoring result", status: "OK", detail: "Score trung bình 0.87." },
  { step: "FoodyLLM generation result", status: "OK", detail: "Sinh reason và citation hoàn tất." },
  { step: "Saved suggestion result", status: "OK", detail: "Lưu 5 recommendation vào mock audit log." }
];

export const ratingDistribution = [
  { label: "5 sao", value: 72 },
  { label: "4 sao", value: 18 },
  { label: "3 sao", value: 6 },
  { label: "2 sao", value: 3 },
  { label: "1 sao", value: 1 }
];

export const reportKpis = [
  { label: "Sự cố dị ứng", value: "0.02%", note: "Giảm 12% so với kỳ trước" },
  { label: "Độ chính xác AI", value: "94.8%", note: "Dựa trên phản hồi người dùng" },
  { label: "Hoàn thành meal plan", value: "68.2%", note: "Người dùng hoạt động 6 tháng" }
];
