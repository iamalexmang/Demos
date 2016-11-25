using Newtonsoft.Json;
using System.ComponentModel.DataAnnotations;

namespace MSSummit15Demo.Models
{
    public class Item
    {
        [JsonProperty(PropertyName = "id")]
        public string Id { get; set; }

        [JsonProperty(PropertyName = "name")]
        [Required]
        public string Name { get; set; }

        [JsonProperty(PropertyName = "desc")]
        [Required]
        public string Description { get; set; }

        [JsonProperty(PropertyName = "isComplete")]
        public bool Completed { get; set; }
    }
}