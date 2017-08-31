using Microsoft.ApplicationInsights;
using System;
using System.Data.SqlClient;
using System.IO;
using System.Net;
using System.Web.Mvc;

namespace MSSummit15Demo.Controllers
{
    public class HomeController : Controller
    {
        public ActionResult Index()
        {
            return View();
        }

        public ActionResult About()
        {
            var visitorIpAddr = this.HttpContext.Request.UserHostAddress;
            var res = "http://ipinfo.io/" + visitorIpAddr + "/city";
            var ipResponse = IPRequestHelper(res);
            var message = visitorIpAddr + " from " + ipResponse;

            ViewBag.Message = message;

            System.Diagnostics.Trace.WriteLine(message);

            return View();
        }

        private object IPRequestHelper(string url)
        {
            string checkUrl = url;
            var objRequest = (HttpWebRequest)WebRequest.Create(url);
            var objResponse = (HttpWebResponse)objRequest.GetResponse();
            var responseStream = new StreamReader(objResponse.GetResponseStream());
            var responseRead = responseStream.ReadToEnd();
            responseRead = responseRead.Replace("\n", string.Empty);
            responseStream.Close();
            responseStream.Dispose();
            return responseRead;
        }

        public ActionResult Contact()
        {
            try
            {
                //var connectionString = "Server=tcp:on-premise-database.database.windows.net,1433;Database=demo;User ID=alex@mssummit15;Password=123!@#qweQWE;Encrypt=True;TrustServerCertificate=False;Connection Timeout=30;";
                var connectionString = "Server=tcp:azsaturdaydbsrv.database.windows.net,1433;Database=appinsightsdemodb;User ID=alex@azsaturdaydbsrv;Password=123!@#qweQWE;Encrypt=True;TrustServerCertificate=False;Connection Timeout=30;";
                var connection = new SqlConnection(connectionString);
                var command = new SqlCommand("SELECT FirstName FROM [SalesLT].[Customer]", connection);
                connection.Open();

                System.Diagnostics.Trace.Write("Database connection open successfully - " + connection.Database);

                var reader = command.ExecuteReader();
                while (reader.Read())
                    ViewBag.Message += reader.GetString(0) + " ";
            }
            catch (Exception ex)
            {
                (new TelemetryClient()).TrackException(ex);
                throw;
            }


            return View();
        }
    }
}