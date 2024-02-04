using Microsoft.Extensions.Diagnostics.HealthChecks;
using StackExchange.Redis;

namespace HealthCheck.Infrastructure
{
    public class AggregateHealthCheck : IHealthCheck
    {
        private readonly HttpClient _httpClient;

        public AggregateHealthCheck(HttpClient httpClient)
        {
            _httpClient = httpClient;
        }

        public async Task<HealthCheckResult> CheckHealthAsync(HealthCheckContext context, CancellationToken cancellationToken = default)
        {
            try
            {
                return HealthCheckResult.Healthy();
            }
            catch (Exception ex)
            {
                return HealthCheckResult.Unhealthy("Redis connectivity check failed.", ex);
            }
        }
    }
}