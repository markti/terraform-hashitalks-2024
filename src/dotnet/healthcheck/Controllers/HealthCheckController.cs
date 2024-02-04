using Microsoft.AspNetCore.Mvc;
using System.Net.Http;
using System.Net.Mime;

namespace HealthCheck.Controllers;

[ApiController]
[Route("api/[controller]/[action]")]
public class HealthCheckController : ControllerBase
{
    private readonly ILogger<HealthCheckController> _logger;
    private readonly HttpClient _httpClient;

    private const string USER_SVC_ENDPOINT = "http://user-svc.app.svc.cluster.local/api/User/healthz/ready";
    private const string TENANT_SVC_ENDPOINT = "http://tenance-svc.app.svc.cluster.local/api/Tenant/healthz/ready";

    public HealthCheckController(ILogger<HealthCheckController> logger, HttpClient httpClient)
    {
        _logger = logger;
        _httpClient = httpClient;
    }

    [HttpGet(Name = "GetHealth")]
    [Consumes(MediaTypeNames.Application.Json)]
    [ProducesResponseType(StatusCodes.Status200OK, Type = typeof(Dictionary<int, int>))]
    public async Task<IActionResult> GetAsync()
    {
        try
        {
            var userResponse = await _httpClient.GetAsync(USER_SVC_ENDPOINT);

            if (userResponse.IsSuccessStatusCode)
            {
                _logger.LogInformation("User Service OK");
            } 
            else
            {
                _logger.LogInformation("User Service FAILED");
            }

            var tenantResponse = await _httpClient.GetAsync(TENANT_SVC_ENDPOINT);
            if (tenantResponse.IsSuccessStatusCode)
            {
                _logger.LogInformation("Tenant Service OK");
            } 
            else
            {
                _logger.LogInformation("Tenant Service FAILED");
            }

            var allOk = userResponse.IsSuccessStatusCode && tenantResponse.IsSuccessStatusCode;
            if(allOk)
            {
                return Ok();
            } 
            else 
            {
                return Problem("Health Check Failed");
            }
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Unhandled exception from HealthCheck");
            return Problem("Unable to Get Health");
        }
    }
}
