using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Diagnostics;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace StressInMem
{
    class Program
    {
        private static string _target = "inmem";

        private static string _script = $@"
            DECLARE
                @i int = 0,
                @od SalesLT.SalesOrderDetailType_{_target},
                @SalesOrderID int,
                @DueDate datetime2 = sysdatetime(),
                @CustomerID int = rand() * 8000,
                @BillToAddressID int = rand() * 10000,
                @ShipToAddressID int = rand() * 10000;

            INSERT INTO @od
                SELECT OrderQty, ProductID
                FROM Demo.DemoSalesOrderDetailSeed
                WHERE OrderID= cast((rand()*60) as int);

            WHILE (@i < 20)
            begin;
                EXECUTE SalesLT.usp_InsertSalesOrder_{_target} @SalesOrderID OUTPUT,
                    @DueDate, @CustomerID, @BillToAddressID, @ShipToAddressID, @od;
                SET @i = @i + 1;
            end
        ";

        static void Main(string[] args)
        {
            var times = 1;
            if (args != null
                && args.Length > 0)
                times = int.Parse(args[0]);
            var sw = new Stopwatch();
            sw.Start();
            using (var sqlConn = new SqlConnection("Server=tcp:devexdbsrv.database.windows.net,1433;Database=demoInMem;User ID=alex;Password=123!@#qweQWE;Encrypt=True;TrustServerCertificate=False;Connection Timeout=30;"))
            {
                sqlConn.Open();
                using (var sqlCmd = new SqlCommand())
                {
                    sqlCmd.Connection = sqlConn;
                    sqlCmd.CommandType = CommandType.Text;
                    sqlCmd.CommandText = _script;
                    for (int i = 0; i < times; i++)
                    {
                        sqlCmd.ExecuteNonQuery();
                    }
                }
            }
            sw.Stop();
            Console.WriteLine(sw.Elapsed.ToString("c"));
            Console.ReadKey();
        }
    }
}
