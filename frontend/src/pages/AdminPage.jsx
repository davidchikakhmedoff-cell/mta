import { useEffect, useState } from 'react';
import { api } from '../api/client.js';
import { useAuth } from '../context/AuthContext.jsx';

export default function AdminPage() {
  const { token } = useAuth();
  const [users, setUsers] = useState([]);
  const [orders, setOrders] = useState([]);
  const [providers, setProviders] = useState([]);

  useEffect(() => {
    Promise.all([
      api('/admin/users', { token }),
      api('/admin/orders', { token }),
      api('/admin/providers', { token }),
    ]).then(([u, o, p]) => {
      setUsers(u);
      setOrders(o);
      setProviders(p);
    });
  }, [token]);

  return (
    <section>
      <h2>Admin Panel</h2>
      <h3>Users</h3>
      <ul>{users.map((u) => <li key={u.id}>{u.email} ({u.status})</li>)}</ul>
      <h3>Orders</h3>
      <ul>{orders.map((o) => <li key={o.id}>{o.service} - {o.status}</li>)}</ul>
      <h3>Providers</h3>
      <ul>{providers.map((p) => <li key={p.id}>{p.name} - {p.status}</li>)}</ul>
    </section>
  );
}
