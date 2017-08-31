using Microsoft.ApplicationInsights.Channel;
using Microsoft.ApplicationInsights.Extensibility;

namespace MSSummit15Demo
{
    public class CustomTemeletryInitializer : ITelemetryInitializer
    {
        public void Initialize(ITelemetry telemetry)
        {
            telemetry.Context.Component.Version = typeof(Controllers.HomeController).Assembly.GetName().Version.ToString();
        }
    }
}