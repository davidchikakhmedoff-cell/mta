import { PrismaClient } from '@prisma/client';

const prisma = new PrismaClient();

async function main() {
  await prisma.provider.createMany({
    data: [
      {
        name: 'DemoProviderA',
        apiUrl: 'https://api.provider-a.local',
        apiKey: 'replace-me',
        priority: 1,
      },
      {
        name: 'DemoProviderB',
        apiUrl: 'https://api.provider-b.local',
        apiKey: 'replace-me',
        priority: 2,
      },
    ],
    skipDuplicates: true,
  });
}

main()
  .then(async () => {
    await prisma.$disconnect();
  })
  .catch(async (error) => {
    console.error(error);
    await prisma.$disconnect();
    process.exit(1);
  });
