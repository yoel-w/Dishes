const express = require('express');
const router = express.Router();
const dishes = require('../data/dishes.json');

// GET /api/dishes - return all dishes
router.get('/', (req, res) => {
  res.json(dishes);
});

// GET /api/dishes/random - return a single random dish
router.get('/random', (req, res) => {
  const pick = dishes[Math.floor(Math.random() * dishes.length)];
  res.json(pick);
});

// GET /api/dishes/:id - return a specific dish
router.get('/:id', (req, res) => {
  const dish = dishes.find(d => d.id === req.params.id);
  if (!dish) return res.status(404).json({ error: 'Dish not found' });
  res.json(dish);
});

// POST /api/dishes/search/ingredients
// Body: { ingredients: ["chicken", "garlic", "tomatoes"] }
// Returns top 10 matches scored by ingredient overlap
router.post('/search/ingredients', (req, res) => {
  const { ingredients } = req.body;

  if (!ingredients || !Array.isArray(ingredients) || ingredients.length === 0) {
    return res.status(400).json({ error: 'Provide an array of ingredients' });
  }

  const normalized = ingredients.map(i => i.toLowerCase().trim());

  const scored = dishes.map(dish => {
    const dishIngredients = dish.ingredients.map(i => i.toLowerCase());

    let matchCount = 0;
    for (const userIngredient of normalized) {
      for (const dishIngredient of dishIngredients) {
        if (dishIngredient.includes(userIngredient) || userIngredient.includes(dishIngredient)) {
          matchCount++;
          break;
        }
      }
    }

    const score = matchCount / dish.ingredients.length;
    return { ...dish, matchCount, score };
  });

  const results = scored
    .filter(d => d.matchCount > 0)
    .sort((a, b) => b.score - a.score || b.matchCount - a.matchCount)
    .slice(0, 10)
    .map(({ matchCount, score, ...dish }) => ({ ...dish, matchCount }));

  res.json({ results, total: results.length });
});

// GET /api/dishes/region/:region - return all dishes from a region
router.get('/region/:region', (req, res) => {
  const region = req.params.region.toLowerCase();
  const results = dishes.filter(d => d.region === region);
  res.json({ results, total: results.length });
});

// POST /api/dishes/search/feeling
// Body: answers to feeling questions
// {
//   mood: "comfort" | "adventurous" | "light" | "indulgent",
//   spice: "mild" | "medium" | "hot",
//   mealType: "breakfast" | "lunch" | "dinner" | "snack" | "dessert",
//   dietary: "any" | "vegetarian" | "vegan" | "meat" | "seafood",
//   region: "any" | "asia" | "europe" | "americas" | "africa" | "middleeast",
//   count: 5 | 10   (default 5)
// }
router.post('/search/feeling', (req, res) => {
  const { mood, spice, mealType, dietary, region, count = 5 } = req.body;

  const scored = dishes.map(dish => {
    let score = 0;

    if (mood && dish.tags.includes(mood)) score += 3;
    if (spice && dish.spice === spice) score += 2;
    if (mealType && dish.mealType.includes(mealType)) score += 2;
    if (dietary && dietary !== 'any' && dish.dietary.includes(dietary)) score += 3;
    if (region && region !== 'any' && dish.region === region) score += 2;

    // Partial mood match on tags
    if (mood) {
      const moodTagMap = {
        comfort: ['comfort', 'warm', 'hearty'],
        adventurous: ['adventurous', 'street food', 'fresh'],
        light: ['light', 'healthy', 'fresh'],
        indulgent: ['indulgent', 'creamy', 'sweet'],
      };
      const relatedTags = moodTagMap[mood] || [];
      for (const tag of relatedTags) {
        if (dish.tags.includes(tag)) score += 1;
      }
    }

    return { ...dish, score };
  });

  const limit = Math.min(Math.max(parseInt(count) || 5, 1), 10);

  const results = scored
    .filter(d => d.score > 0)
    .sort((a, b) => b.score - a.score)
    .slice(0, limit)
    .map(({ score, ...dish }) => dish);

  res.json({ results, total: results.length });
});

module.exports = router;
