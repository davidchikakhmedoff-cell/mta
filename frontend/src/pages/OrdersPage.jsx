import { useState } from 'react';
import { api } from '../api/client.js';
import { useAuth } from '../context/AuthContext.jsx';

export default function OrdersPage() {
  const { token } = useAuth();
  const [service, setService] = useState('telegram');
  const [country, setCountry] = useState('US');
  const [order, setOrder] = useState(null);

  async function createOrder() {
    const created = await api('/order/create', { token, method: 'POST', body: { service, country } });
    setOrder(created);
  }

  async function refreshOrder() {
    const updated = await api(`/order/status?orderId=${order.id}`, { token });
    setOrder(updated);
  }

  async function cancelOrder() {
    await api('/order/cancel', { token, method: 'POST', body: { orderId: order.id } });
    refreshOrder();
  }

  return (
    <section>
      <h2>Order Activation</h2>
      <input value={service} onChange={(e) => setService(e.target.value)} />
      <input value={country} onChange={(e) => setCountry(e.target.value)} />
      <button onClick={createOrder}>Buy Number</button>

      {order && (
        <div>
          <p>Number: {order.number}</p>
          <p>Status: {order.status}</p>
          <button onClick={refreshOrder}>Refresh Status</button>
          <button onClick={cancelOrder}>Cancel</button>
        </div>
      )}
    </section>
  );
}
