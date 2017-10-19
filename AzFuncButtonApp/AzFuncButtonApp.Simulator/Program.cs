using Microsoft.ServiceBus.Messaging;
using Newtonsoft.Json;
using Newtonsoft.Json.Schema;
using System;
using System.IO;
using System.Text;
using System.Threading.Tasks;

namespace AzFuncButtonApp.Simulator
{
    class Program
    {
        private const int LIMIT = 10;

        private static Random rnd;
        private static string[] locations = new string[] { "Redmond", "Seattle", "Las Vegas", "New York", "Orlando", "Snoqualmie" };
        private static EventHubClient client = EventHubClient.CreateFromConnectionString(
            "Endpoint=sb://clickerhub.servicebus.windows.net/;SharedAccessKeyName=RootManageSharedAccessKey;SharedAccessKey=CU0V/X6T70AS99cuXlYX4HZB5LAH0LLMyyIR56jaKoc=;EntityPath=iotbutton1"
            );

        public static void Main(string[] args)
        {

            rnd = new Random();
            Parallel.For(0, LIMIT, s =>
            {
                var result = SendMessage(new DeviceMessage
                {
                    Device = Guid.NewGuid().ToString(),
                    Location = (string)locations.GetValue(rnd.Next(locations.Length)),
                    Type = /*rnd.Next(100) == 1 ? */"Alert" /*: "Information"*/
                }).Result;
            });
            Console.ReadLine();
        }

        private static void ExtractSchema()
        {
            var jsonSchemaGenerator = new JsonSchemaGenerator();
            var myType = typeof(DeviceMessage);
            var schema = jsonSchemaGenerator.Generate(myType);
            schema.Title = myType.Name;
            var writer = new StringWriter();
            var jsonTextWriter = new JsonTextWriter(writer);
            schema.WriteTo(jsonTextWriter);
            dynamic parsedJson = JsonConvert.DeserializeObject(writer.ToString());
            var prettyString = JsonConvert.SerializeObject(parsedJson, Formatting.Indented);
            var fileWriter = new StreamWriter("DeviceMessageSchema.txt");
            fileWriter.WriteLine(schema.Title);
            fileWriter.WriteLine(new string('-', schema.Title.Length));
            fileWriter.WriteLine(prettyString);
            fileWriter.Close();
        }

        static async Task<bool> SendMessage(DeviceMessage message)
        {
            await client.SendAsync(new EventData(Encoding.UTF8.GetBytes(JsonConvert.SerializeObject(message))));
            Console.WriteLine($"Message was sent{Environment.NewLine}{JsonConvert.SerializeObject(message, Formatting.Indented)}");
            return true;
        }
    }

    internal class DeviceMessage
    {
        public string Device { get; set; }
        public string Type { get; set; }
        public string Location { get; set; }
    }
}
