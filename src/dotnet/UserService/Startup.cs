﻿using UserApi.Infrastructure;
using Microsoft.AspNetCore.Diagnostics.HealthChecks;
using System.Diagnostics;
using UserApi.Services;
using Microsoft.Azure.Cosmos;
using Azure.Identity;

namespace UserApi
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

            
            services.AddScoped<IUserProfileRepository, UserProfileRepository>();

            services.AddHealthChecks()
                .AddCheck<DoNothingHealthCheck>("nada")
                .AddCheck<CosmosDbHealthCheck>("cosmos");
        }

        private void AddCosmosDb(IServiceCollection services)
        {
            var endpoint = Configuration["CosmosDb:Endpoint"];
            var databaseName = Configuration["CosmosDb:Database"];
            services.AddSingleton<CosmosClient>((serviceProvider) =>
            {
                var clientOptions = new CosmosClientOptions();
                var credential = new DefaultAzureCredential();
                var cosmosClient = new CosmosClient(endpoint, credential, clientOptions);
                return cosmosClient;
            });
            services.AddSingleton((serviceProvider) =>
            {
                var cosmosClient = serviceProvider.GetRequiredService<CosmosClient>();
                var cosmosDatabase = cosmosClient.GetDatabase(databaseName);
                return cosmosDatabase;
            });
        }

        public void Configure(WebApplication app, IWebHostEnvironment env)
        {
            // Configure the HTTP request pipeline.
            //if (app.Environment.IsDevelopment())
            //{
            //}
            app.UseSwagger(c =>
            {
                c.RouteTemplate = "api/User/swagger/{documentName}/swagger.json";
            });
            app.UseSwaggerUI(c =>
            {
                c.SwaggerEndpoint("/api/User/swagger/v1/swagger.json", "Order API V1");
                c.RoutePrefix = "api/User/swagger";
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
                endpoints.MapGet("/api/User/healthz/live", async context =>
                {
                    await context.Response.WriteAsync("Healthy");
                });
                endpoints.MapHealthChecks("/api/User/healthz/ready", new HealthCheckOptions
                {
                    Predicate = _ => true
                });
            });
        }
    }
}