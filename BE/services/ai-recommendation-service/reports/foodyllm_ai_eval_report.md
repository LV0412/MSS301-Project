# FoodyLLM-Based AI Recommendation Evaluation

This evaluation uses a FoodyLLM-inspired dataset derived from the original FoodyLLM task family: nutrition profile assessment, traffic-light nutrition screening, and food entity/allergy safety. The AI service applies those model capabilities inside the app pipeline: rule filtering, hybrid RAG retrieval, FoodyLLM JSON scoring, and meal optimization.

## Summary Metrics

- Total cases: 12
- Hit@1: 0.8333
- Hit@3: 0.9167
- MRR: 0.8917
- Recommendation coverage: 1.0
- FoodyLLM stage coverage: 1.0
- Average latency ms: 6.16
- Average top-1 suitability score: 92.14

## Top-3 Constraint Compliance

- calories: 1.0
- protein: 1.0
- budget: 1.0
- diet: 1.0
- allergy: 1.0

## Metrics By FoodyLLM Task

| Task | Cases | Hit@3 | MRR |
|---|---:|---:|---:|
| assessing_recipe_nutritional_profile | 4 | 1.0 | 1.0 |
| food_entity_extraction_and_safety_filtering | 4 | 0.75 | 0.8 |
| traffic_light_nutrition_labeling | 4 | 1.0 | 0.875 |

## Case-Level Results

| Case | Task | Expected Hit@3 | Top Recommendations | Latency ms |
|---|---|---:|---|---:|
| nutrition_high_protein_budget_001 | assessing_recipe_nutritional_profile | True | Cơm gà xé luộc, Cơm cá nục kho cà, Tôm xào rau củ | 7.88 |
| traffic_light_low_calorie_002 | traffic_light_nutrition_labeling | True | Ức gà xé trộn bắp cải, Súp gà ngô non, Salad ức gà rau củ | 6.58 |
| entity_allergy_peanut_003 | food_entity_extraction_and_safety_filtering | True | Bắp luộc và sữa đậu nành, Bún chay đậu hũ nấm, Đậu hũ non hấp nấm | 4.96 |
| vegetarian_balanced_004 | assessing_recipe_nutritional_profile | True | Đậu lăng cà ri chay, Bún chay đậu hũ nấm, Lẩu nấm chay một người | 5.91 |
| low_carb_protein_005 | traffic_light_nutrition_labeling | True | Tôm xào rau củ, Thịt bò xào bông cải | 3.31 |
| seafood_allergy_006 | food_entity_extraction_and_safety_filtering | True | Cơm heo nạc rim tiêu, Cơm gà xé luộc, Bánh mì ức gà xé | 5.81 |
| budget_student_007 | assessing_recipe_nutritional_profile | True | Cơm trứng đậu que, Đậu hũ sốt cà chua, Trứng cuộn rau củ | 5.86 |
| muscle_gain_008 | assessing_recipe_nutritional_profile | True | Cơm bò trứng kiểu meal prep, Bò lúc lắc khoai tây, Ức gà áp chảo với cơm gạo lứt | 4.0 |
| breakfast_light_009 | traffic_light_nutrition_labeling | True | Gỏi cuốn tôm thịt, Súp gà ngô non, Trứng cuộn rau củ | 6.13 |
| egg_allergy_010 | food_entity_extraction_and_safety_filtering | True | Bắp luộc và sữa đậu nành, Đậu hũ sốt cà chua, Sinh tố bơ sữa hạt | 7.99 |
| vegan_low_calorie_011 | traffic_light_nutrition_labeling | True | Đậu hũ non hấp nấm, Lẩu nấm chay một người, Salad đậu gà rau củ | 4.37 |
| balanced_no_milk_012 | food_entity_extraction_and_safety_filtering | False | Sinh tố bơ sữa hạt, Bắp luộc và sữa đậu nành, Rau luộc chấm trứng dầm | 11.06 |
