using Microsoft.Extensions.Diagnostics.HealthChecks;

namespace TenantApi.Infrastructure
{
    public class DoNothingHealthCheck : IHealthCheck
    {
        public DoNothingHealthCheck()
        {
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