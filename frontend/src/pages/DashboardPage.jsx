import { useEffect, useState } from 'react';
import { api } from '../api/client.js';
import { useAuth } from '../context/AuthContext.jsx';

export default function DashboardPage() {
  const { token } = useAuth();
  const [balance, setBalance] = useState(0);
  const [transactions, setTransactions] = useState([]);

  useEffect(() => {
    api('/balance', { token }).then((res) => {
      setBalance(res.balance);
      setTransactions(res.transactions);
    });
  }, [token]);

  return (
    <section>
      <h2>Balance: ${balance}</h2>
      <h3>Transactions</h3>
      <ul>
        {transactions.map((txn) => (
          <li key={txn.id}>
            {txn.type} - {txn.amount.toString()}
          </li>
        ))}
      </ul>
    </section>
  );
}
