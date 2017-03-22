using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.Linq;
using System.Web;
using System.Web.Mvc;

namespace SqlInjectionDemo.Controllers
{
    public class HomeController : Controller
    {
        public ActionResult Index()
        {
            return View();
        }

        [HttpPost]
        public ActionResult Index(string username, string password)
        {
            var loginSuccessful = false;
            using (var sqlConnection = new SqlConnection("Server=tcp:devexdbsrv.database.windows.net,1433;Database=demoinject;User ID=alex@devexdbsrv;Password=123!@#qweQWE;Encrypt=True;TrustServerCertificate=False;Connection Timeout=30;"))
            {
                sqlConnection.Open();
                using (var sqlCmd = new SqlCommand())
                {
                    sqlCmd.Connection = sqlConnection;
                    sqlCmd.CommandText = $"SELECT * FROM dbo.IUsers WHERE [Username] = '{username}' AND [Password] = '{password}'";
                    using (var sqlDr = sqlCmd.ExecuteReader())
                    {
                        if (sqlDr.Read())
                            loginSuccessful = true;
                    }
                }
            }
            if (loginSuccessful)
                return RedirectToAction("Index", "Customers");
            else
                return View();
        }
    }
}