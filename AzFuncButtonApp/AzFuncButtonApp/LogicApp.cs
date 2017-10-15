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
        private static readonly Uri _logicAppUri = new Uri("https://prod-45.westeurope.logic.azure.com:443/workflows/8d45107dd5a742609742e439fdcbba4b/triggers/manual/paths/invoke?api-version=2016-10-01&sp=%2Ftriggers%2Fmanual%2Frun&sv=1.0&sig=qD5OYDY_-Of4CASWIfgaQ8WHyC87SFlEJTjfnY9V3K4");

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
