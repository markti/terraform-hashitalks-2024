using HealthCheck.Infrastructure;
using Microsoft.AspNetCore.Diagnostics.HealthChecks;
using System.Diagnostics;

namespace HealthCheck
{
    public class Startup
    {
        private readonly ILogger<Startup> _logger;

        public Startup(IConfiguration configuration, ILogger<Startup> logger)
        {
            Configuration = configuration;
            _logger = logger;
        }

        public IConfiguration Configuration { get; }

        public void ConfigureServices(IServiceCollection services)
        {
            services.AddControllers();

            // Learn more about configuring Swagger/OpenAPI at https://aka.ms/aspnetcore/swashbuckle
            services.AddEndpointsApiExplorer();
            services.AddSwaggerGen();
            services.AddHealthChecks();

            services.AddApplicationInsightsTelemetry();

            services.AddHealthChecks()
                .AddCheck<DoNothingHealthCheck>("nada");
        }

        public void Configure(WebApplication app, IWebHostEnvironment env)
        {
            // Configure the HTTP request pipeline.
            //if (app.Environment.IsDevelopment())
            //{
            //}
            app.UseSwagger(c =>
            {
                c.RouteTemplate = "api/HealthCheck/swagger/{documentName}/swagger.json";
            });
            app.UseSwaggerUI(c =>
            {
                c.SwaggerEndpoint("/api/HealthCheck/swagger/v1/swagger.json", "Order API V1");
                c.RoutePrefix = "api/HealthCheck/swagger";
            });

            using var serviceScope = app.Services.CreateScope();
            
            // Configure the HTTP request pipeline.
            if (!env.IsDevelopment())
            {
                app.UseExceptionHandler("/Home/Error");
                // The default HSTS value is 30 days. You may want to change this for production scenarios, see https://aka.ms/aspnetcore-hsts.
                app.UseHsts();
            }
            else if (Debugger.IsAttached)
            {
                // By default, we do not include any potential PII (personally identifiable information) in our exceptions in order to be in compliance with GDPR.
                // https://aka.ms/IdentityModel/PII
                //IdentityModelEventSource.ShowPII = true;
            }

            //app.UseRetryTestingMiddleware();

            //app.UseHttpsRedirection();

            //app.UseAuthentication();
            //app.UseAuthorization();

            app.UseRouting();
            app.MapControllers();

            app.UseEndpoints(endpoints => {
                endpoints.MapGet("/api/HealthCheck/healthz/live", async context =>
                {
                    await context.Response.WriteAsync("Healthy");
                });
                endpoints.MapHealthChecks("/api/HealthCheck/healthz/ready", new HealthCheckOptions
                {
                    Predicate = _ => true
                });
            });
        }
    }
}