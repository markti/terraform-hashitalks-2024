using Microsoft.Azure.Cosmos;
using Microsoft.Extensions.Diagnostics.HealthChecks;
using System.Net;

namespace TenantApi.Infrastructure
{
    public class CosmosDbHealthCheck : IHealthCheck
    {
        private readonly ILogger<CosmosDbHealthCheck> _logger;
        private readonly CosmosClient _cosmosClient;
        private readonly Database _cosmosDatabase;

        public CosmosDbHealthCheck(ILogger<CosmosDbHealthCheck> logger, CosmosClient cosmosClient, Database cosmosDatabase)
        {
            _logger = logger;
            _cosmosClient = cosmosClient;
            _cosmosDatabase = cosmosDatabase;
        }

        public async Task<HealthCheckResult> CheckHealthAsync(HealthCheckContext context, CancellationToken cancellationToken = default)
        {
            try
            {
                var dbResponse = await _cosmosDatabase.ReadAsync();
                if(dbResponse.StatusCode == HttpStatusCode.OK)
                {
                    return HealthCheckResult.Healthy();
                } 
                else
                {
                    _logger.LogInformation($"CosmosDB Health Check Status Code: {dbResponse.StatusCode}");
                    return HealthCheckResult.Unhealthy($"Database Read was not OK. Status Code: {dbResponse.StatusCode}");
                }
            }
            catch (Exception ex)
            {
                return HealthCheckResult.Unhealthy("Redis connectivity check failed.", ex);
            }
        }
    }
}