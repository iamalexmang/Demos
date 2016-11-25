using Microsoft.ApplicationInsights.Extensibility;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using Microsoft.ApplicationInsights.Channel;

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