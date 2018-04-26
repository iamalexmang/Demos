using Microsoft.ServiceBus;
using Microsoft.ServiceBus.Messaging;
using System;
using System.Diagnostics;
using System.Threading.Tasks;

namespace DemoServiceBusLoader
{
    class Program
    {
        private static string connectionString = ""
        private static string queueName = "performance";
        private static TimeSpan batchFlushInterval = TimeSpan.FromSeconds(5);

        static void Main(string[] args)
        {
            var messageCount = 0;
            var sw = new Stopwatch();
            Console.WriteLine("How many messages should I put in the queue?");
            if (!int.TryParse(Console.ReadLine(), out messageCount))
                return;

            var namespaceMngr = NamespaceManager.CreateFromConnectionString(connectionString);
            var mfs = new MessagingFactorySettings();
            mfs.TokenProvider = namespaceMngr.Settings.TokenProvider;
            mfs.NetMessagingTransportSettings.BatchFlushInterval = batchFlushInterval;
            var tasks = new Task[messageCount];

            sw.Start();
            var mf = MessagingFactory.Create(namespaceMngr.Address, mfs);
            Parallel.For(0, messageCount, (i) =>
            {
                var client = mf.CreateQueueClient(queueName);
                var message = new BrokeredMessage($"This is the #{i} test message!");

                Console.WriteLine(String.Format($"Message id {message.MessageId} sent ({i})."));
                tasks[i] = client.SendAsync(message);
            });
            Task.WhenAll(tasks);

            Console.WriteLine($"{messageCount} messages successfully sent in {sw.ElapsedMilliseconds / 1000} seconds!{Environment.NewLine}Press ENTER to exit the program.");
            Console.ReadLine();
        }
    }
}