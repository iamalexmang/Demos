using Newtonsoft.Json;

namespace MSSummit15Demo.Models
{
    public class ItemReminder
    {
        [JsonProperty(PropertyName = "item")]
        public Item Item { get; set; }

        [JsonProperty(PropertyName = "email")]
        public string EmailAddress { get; set; }
    }
}