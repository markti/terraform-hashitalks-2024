using Microsoft.AspNetCore.Mvc;
using System.Net.Mime;

namespace HealthCheck.Controllers;

[ApiController]
[Route("api/[controller]/[action]")]
public class HealthCheckController : ControllerBase
{
    private readonly ILogger<HealthCheckController> _logger;

    public HealthCheckController(ILogger<HealthCheckController> logger)
    {
        _logger = logger;
    }

    [HttpGet(Name = "GetHealth")]
    [Consumes(MediaTypeNames.Application.Json)]
    [ProducesResponseType(StatusCodes.Status200OK, Type = typeof(Dictionary<int, int>))]
    public async Task<IActionResult> GetAsync(string userId)
    {
        try
        {
            _logger.LogInformation("OK");
            return Ok();
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Unhandled exception from HealthCheck");
            return Problem("Unable to Get Health");
        }
    }
}
