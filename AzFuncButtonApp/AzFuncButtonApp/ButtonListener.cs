using Microsoft.Azure.WebJobs;
using Microsoft.Azure.WebJobs.Host;
using Microsoft.Azure.WebJobs.ServiceBus;
using Newtonsoft.Json;
using System.Threading.Tasks;

namespace AzFuncButtonApp
{
    public static class ButtonListener
    {
        [FunctionName("ButtonListener")]
        public static void Run([EventHubTrigger("button", Connection = "EventHubConnection")]string myEventHubMessage, TraceWriter log)
        {
            var message = JsonConvert.DeserializeObject<DeviceMessage>(myEventHubMessage);

            if (message.Type == "Alert")
            {
                LogicApp.TriggerAsync(new LogicAppMessage() { Device = message.Device, Type = "Alert", Location = message.Location }).Wait();
            }
            log.Info($"C# Event Hub trigger function processed a message: {myEventHubMessage}");
        }
    }
}