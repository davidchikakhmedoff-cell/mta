import { app } from './app.js';
import { env } from './config/env.js';
import { startSmsPoller } from './jobs/sms-poller.job.js';

app.listen(env.port, () => {
  console.log(`API running on port ${env.port}`);
  startSmsPoller();
});
