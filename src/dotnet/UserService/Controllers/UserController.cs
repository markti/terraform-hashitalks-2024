using Microsoft.AspNetCore.Mvc;
using System.Net.Mime;

namespace UserApi.Controllers;

[ApiController]
[Route("api/[controller]/[action]")]
public class UserController : ControllerBase
{
    private readonly ILogger<UserController> _logger;

    public UserController(ILogger<UserController> logger)
    {
        _logger = logger;
    }

    [HttpGet(Name = "GetUser")]
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
