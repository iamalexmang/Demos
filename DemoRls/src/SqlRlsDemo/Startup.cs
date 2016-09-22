using Microsoft.Owin;
using Owin;

[assembly: OwinStartupAttribute(typeof(SqlRlsDemo.Startup))]
namespace SqlRlsDemo
{
    public partial class Startup
    {
        public void Configuration(IAppBuilder app)
        {
            ConfigureAuth(app);
        }
    }
}
