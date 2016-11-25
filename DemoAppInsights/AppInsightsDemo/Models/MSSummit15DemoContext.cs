using System;
using System.Collections.Generic;
using System.Data.Entity;
using System.Linq;
using System.Web;

namespace MSSummit15Demo.Models
{
    public class MSSummit15DemoContext : DbContext
    {
        // You can add custom code to this file. Changes will not be overwritten.
        // 
        // If you want Entity Framework to drop and regenerate your database
        // automatically whenever you change your model schema, please use data migrations.
        // For more information refer to the documentation:
        // http://msdn.microsoft.com/en-us/data/jj591621.aspx
    
        public MSSummit15DemoContext() : base("name=MSSummit15DemoContext")
        {
        }

        public System.Data.Entity.DbSet<MSSummit15Demo.Models.Item> Items { get; set; }
    }
}
