const express = require('express');
const cors = require('cors');

const dishesRouter = require('./routes/dishes');

const app = express();
const PORT = process.env.PORT || 3000;

app.use(cors());
app.use(express.json());

app.use('/api/dishes', dishesRouter);

app.get('/health', (req, res) => {
  res.json({ status: 'ok', message: 'Dish Discovery API is running' });
});

app.use((req, res) => {
  res.status(404).json({ error: 'Route not found' });
});

app.listen(PORT, () => {
  console.log(`Dish Discovery API running on http://localhost:${PORT}`);
});
