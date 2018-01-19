var message = JsonConvert.DeserializeObject<DeviceMessage>(myEventHubMessage);

if (message.Type == "Alert")
{
    LogicApp.TriggerAsync(new LogicAppMessage() { Device = message.Device, Location = message.Location, Type = message.Type }).Wait();
}
