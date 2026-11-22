const express = require('express');
const { FedaPay, Transaction, Payout } = require('fedapay');

const app = express();
app.use(express.json());

// Initialize FedaPay
const apiKey = process.env.FEDAPAY_SECRET_KEY || 'sk_live_...';
const isLive = process.env.FEDAPAY_MODE === 'live';
FedaPay.setApiKey(apiKey);
FedaPay.setEnvironment(isLive ? 'live' : 'sandbox');

app.post('/v1/payments/deposit', async (req, res) => {
  try {
    const { amount, currency, phone_number, provider } = req.body;

    const transaction = await Transaction.create({
      description: `Dépôt Bourse WinnerLife - ${provider}`,
      amount: Math.round(amount * 100),
      currency: { iso: currency || 'USD' },
      customer: {
        phone_number: { number: phone_number }
      }
    });

    const token = await transaction.generateToken();
    res.status(201).json({ success: true, transaction_id: transaction.id, token: token.url });
  } catch (error) {
    res.status(400).json({ success: false, error: error.message });
  }
});

app.post('/v1/payments/payout', async (req, res) => {
  try {
    const { amount, currency, phone_number, provider } = req.body;

    const payout = await Payout.create({
      amount: Math.round(amount),
      currency: { iso: currency || 'USD' },
      customer: {
        phone_number: { number: phone_number }
      },
      description: `Retrait Bourse WinnerLife - ${provider}`
    });

    res.status(201).json({ success: true, payout_id: payout.id });
  } catch (error) {
    res.status(400).json({ success: false, error: error.message });
  }
});

app.get('/', (req, res) => {
  res.send('WinnerLife FedaPay Backend is running successfully!');
});

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
  console.log(`WinnerLife backend running on port ${PORT}`);
});
