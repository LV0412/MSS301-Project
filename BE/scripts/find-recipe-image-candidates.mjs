const RECIPES = [
  [1, ["banana oatmeal porridge", "oatmeal porridge", "oatmeal breakfast"]],
  [2, ["spinach cheese omelette", "spinach omelette", "cheese omelette"]],
  [3, ["apple walnut yogurt bowl", "yogurt apple walnuts", "yogurt bowl fruit"]],
  [4, ["banana almond pancakes", "banana pancakes", "pancakes banana"]],
  [5, ["brown rice egg vegetables", "rice egg vegetables", "rice bowl egg"]],
  [6, ["chicken brown rice vegetables", "chicken rice vegetables", "chicken rice bowl"]],
  [7, ["salmon quinoa spinach", "salmon quinoa", "salmon spinach"]],
  [8, ["tuna chickpea salad", "tuna salad chickpeas", "chickpea salad tuna"]],
  [9, ["beef bulgur tomato", "bulgur beef", "beef grain bowl"]],
  [10, ["shrimp couscous sesame", "shrimp couscous", "couscous shrimp"]],
  [11, ["cod tomato stew", "fish tomato stew", "cod stew"]],
  [12, ["beef potato carrot stew", "beef stew potatoes carrots", "beef stew"]],
  [13, ["pork tempeh stir fry", "pork stir fry", "tempeh stir fry"]],
  [14, ["tilapia quinoa tomato", "tilapia tomato", "grilled tilapia"]],
  [15, ["beef rice edamame", "beef rice bowl", "beef bowl rice"]],
  [16, ["apple peanut butter snack", "apple peanut butter", "apple slices peanut butter"]],
  [17, ["oat nut bar", "granola bar", "oat bar"]],
  [18, ["roasted chickpeas sesame", "roasted chickpeas", "chickpeas snack"]],
  [19, ["boiled eggs edamame", "boiled egg edamame", "hard boiled eggs"]],
  [20, ["yogurt banana cashew", "banana yogurt bowl", "yogurt banana"]],
  [21, ["apple oat cake", "apple oatmeal cake", "apple cake"]],
  [22, ["banana yogurt ice cream", "banana ice cream", "frozen banana dessert"]],
  [23, ["almond pudding banana", "almond pudding", "banana pudding"]],
  [24, ["sweet potato walnut cake", "sweet potato cake", "walnut cake"]],
  [25, ["baked apple pistachio", "baked apple", "apple dessert"]],
  [26, ["quinoa chickpea tahini salad", "quinoa chickpea salad", "chickpea quinoa salad"]],
  [27, ["salmon potato salad", "salmon salad potato", "salmon salad"]],
  [28, ["shrimp quinoa salad", "quinoa shrimp salad", "shrimp salad"]],
  [29, ["beef bulgur salad", "beef salad", "bulgur salad"]],
  [30, ["tofu edamame salad", "tofu salad edamame", "tofu salad"]],
  [31, ["lentil tomato soup", "lentil soup tomato", "lentil soup"]],
  [32, ["miso tofu spinach soup", "miso tofu soup", "miso soup tofu"]],
  [33, ["chicken barley soup", "barley chicken soup", "chicken soup barley"]],
  [34, ["fish potato soup", "fish chowder potato", "fish soup"]],
  [35, ["sweet potato chickpea soup", "chickpea sweet potato soup", "sweet potato soup"]],
  [36, ["banana yogurt smoothie", "banana smoothie yogurt", "banana smoothie"]],
  [37, ["apple oat smoothie", "apple oatmeal smoothie", "apple smoothie"]],
  [38, ["soy milk banana protein smoothie", "soy banana smoothie", "protein smoothie banana"]],
  [39, ["yogurt apple lassi", "apple lassi", "lassi yogurt"]],
  [40, ["avocado peanut butter banana smoothie", "avocado banana smoothie", "peanut butter banana smoothie"]],
  [41, ["tofu vegetables brown rice", "tofu rice vegetables", "tofu rice bowl"]],
  [42, ["tempeh quinoa tomato", "tempeh quinoa", "tempeh bowl"]],
  [43, ["chickpea sweet potato curry", "sweet potato chickpea curry", "chickpea curry"]],
  [44, ["lentil quinoa spinach bowl", "lentil quinoa bowl", "quinoa lentils"]],
  [45, ["bean oat burger", "bean burger", "veggie burger"]],
  [46, ["chicken quinoa protein bowl", "chicken quinoa bowl", "chicken protein bowl"]],
  [47, ["tuna egg brown rice bowl", "tuna egg rice bowl", "tuna rice bowl"]],
  [48, ["salmon lentils tomato", "salmon lentils", "salmon tomato"]],
  [49, ["beef edamame sweet potato", "beef sweet potato bowl", "beef edamame"]],
  [50, ["shrimp tofu bowl", "shrimp tofu", "tofu shrimp"]],
];

const BAD_TITLE_RE = /(logo|map|diagram|chart|icon|symbol|flag|packag|advert|menu|sign|poster|qr|drawing|illustration|svg|book|label|raw|uncooked|market|plant|flower|field|farm|sources of|nutrient|nutrition)/i;
const usedUrls = new Set();
const START_RECIPE_ID = Number(process.env.START_RECIPE_ID ?? "1");
const REQUEST_DELAY_MS = Number(process.env.REQUEST_DELAY_MS ?? "2500");
const CONTINUE_ON_ERROR = process.env.CONTINUE_ON_ERROR !== "false";

function commonsApiUrl(search) {
  const params = new URLSearchParams({
    action: "query",
    format: "json",
    generator: "search",
    gsrnamespace: "6",
    gsrlimit: "20",
    gsrsearch: search,
    prop: "imageinfo",
    iiprop: "url|mime|size",
    iiurlwidth: "700",
    origin: "*",
  });
  return `https://commons.wikimedia.org/w/api.php?${params}`;
}

function scoreCandidate(candidate, queryTerms) {
  const title = candidate.title.replace(/^File:/, "").replace(/[_-]/g, " ").toLowerCase();
  let score = 0;
  let matchingTerms = 0;

  for (const term of queryTerms) {
    if (term.length > 2 && title.includes(term)) {
      matchingTerms += 1;
      score += 4;
    }
  }
  if (matchingTerms === 0) {
    score -= 50;
  }
  if (title.includes("food") || title.includes("dish") || title.includes("salad") || title.includes("soup")) {
    score += 3;
  }
  if (candidate.width >= 600 && candidate.height >= 400) {
    score += 2;
  }
  if (BAD_TITLE_RE.test(candidate.title)) {
    score -= 20;
  }
  if (usedUrls.has(candidate.url)) {
    score -= 100;
  }

  return score;
}

function sleep(ms) {
  return new Promise((resolve) => setTimeout(resolve, ms));
}

async function findCandidate(recipeId, searches) {
  const errors = [];
  for (const search of searches) {
    const candidate = await findCandidateForSearch(recipeId, search).catch((error) => {
      errors.push(error.message);
      return null;
    });
    if (candidate) {
      return candidate;
    }
  }
  throw new Error(`No usable image found for recipe ${recipeId}: ${searches.join(" | ")}. ${errors.join("; ")}`);
}

async function findCandidateForSearch(recipeId, search) {
  let response;
  for (let attempt = 1; attempt <= 4; attempt += 1) {
    await sleep(REQUEST_DELAY_MS * attempt);
    response = await fetch(commonsApiUrl(search), {
      headers: { "User-Agent": "MSS301 recipe image backfill script" },
    });
    if (response.ok || response.status !== 429) {
      break;
    }
  }

  if (!response.ok) {
    throw new Error(`Commons API failed for recipe ${recipeId}: ${response.status}`);
  }

  const payload = await response.json();
  const pages = Object.values(payload.query?.pages ?? {});
  const queryTerms = search.toLowerCase().split(/\s+/);
  const candidates = pages
    .flatMap((page) => (page.imageinfo ?? []).map((info) => ({
      recipeId,
      search,
      title: page.title,
      url: info.url,
      thumbUrl: info.thumburl,
      mime: info.mime,
      width: info.width,
      height: info.height,
    })))
    .filter((item) => item.mime?.startsWith("image/"))
    .filter((item) => !item.mime?.includes("svg"))
    .map((item) => ({ ...item, score: scoreCandidate(item, queryTerms) }))
    .sort((a, b) => b.score - a.score);

  const selected = candidates.find((item) => item.score > -10);
  if (!selected) {
    throw new Error(`No usable image found for recipe ${recipeId}: ${search}`);
  }
  usedUrls.add(selected.url);
  return selected;
}

const results = [];
for (const [recipeId, searches] of RECIPES) {
  if (recipeId < START_RECIPE_ID) {
    continue;
  }
  const selected = await findCandidate(recipeId, searches).catch((error) => {
    if (!CONTINUE_ON_ERROR) {
      throw error;
    }
    console.error(`${recipeId}: ${error.message}`);
    return null;
  });
  if (selected) {
    results.push(selected);
    console.error(`${recipeId}: ${selected.title} -> ${selected.url}`);
  }
}

console.log(JSON.stringify(results, null, 2));
