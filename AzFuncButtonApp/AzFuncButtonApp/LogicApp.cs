using System;
using System.Net.Http;
using System.Threading.Tasks;

namespace AzFuncButtonApp
{
    internal class DeviceMessage
    {
        public string Device { get; set; }
        public string Type { get; set; }
        public string Location { get; set; }
    }

    internal class LogicApp
    {
        private static readonly Uri _logicAppUri = new Uri("https://prod-41.westeurope.logic.azure.com:443/workflows/c646058b9f9843308c5cdc9f960a6550/triggers/manual/paths/invoke?api-version=2016-10-01&sp=%2Ftriggers%2Fmanual%2Frun&sv=1.0&sig=erovrgZD8CeMuznVQGo_phHShmVpjj20KQhB_LtZbTM");

        internal static async Task TriggerAsync(LogicAppMessage logicAppMessage)
        {
            var client = new HttpClient();
            var response = await client.PostAsJsonAsync(_logicAppUri, logicAppMessage);
            if (!response.IsSuccessStatusCode)
                throw new HttpRequestException($"{response.StatusCode}: {response.Content.ReadAsStringAsync().Result}");
        }
    }

    internal class LogicAppMessage
    {
        public object Device { get; set; }
        public string Type { get; set; }
        public string Location { get; set; }
    }
}
