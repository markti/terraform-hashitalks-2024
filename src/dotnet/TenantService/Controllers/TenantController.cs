using Microsoft.AspNetCore.Mvc;
using System.Net.Mime;
using TenantApi.Models;

namespace TenantApi.Controllers;

[ApiController]
[Route("api/[controller]/[action]")]
public class TenantController : ControllerBase
{
    private readonly ILogger<TenantController> _logger;

    public TenantController(ILogger<TenantController> logger)
    {
        _logger = logger;
    }

    [HttpPost(Name = "CreateTenant")]
    [Consumes(MediaTypeNames.Application.Json)]
    [ProducesResponseType(StatusCodes.Status200OK)]
    public async Task<IActionResult> CreateAsync(string name)
    {
        try
        {
            _logger.LogInformation("OK");
            return Ok();
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Unhandled exception from TenantController");
            return Problem("Unable to Create User");
        }
    }

    [HttpGet(Name = "GetUser")]
    [Consumes(MediaTypeNames.Application.Json)]
    [ProducesResponseType(StatusCodes.Status200OK)]
    public async Task<IActionResult> GetAsync(string userId)
    {
        try
        {
            _logger.LogInformation("OK");
            return Ok();
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Unhandled exception from TenantController");
            return Problem("Unable to Get User");
        }
    }

    [HttpPatch(Name = "UpdateUser")]
    [Consumes(MediaTypeNames.Application.Json)]
    [ProducesResponseType(StatusCodes.Status200OK)]
    public async Task<IActionResult> UpdateAsync(UserProfile userProfile)
    {
        try
        {
            _logger.LogInformation("OK");
            return Ok();
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Unhandled exception from TenantController");
            return Problem("Unable to Update User");
        }
    }

    [HttpPatch(Name = "DeleteUser")]
    [Consumes(MediaTypeNames.Application.Json)]
    [ProducesResponseType(StatusCodes.Status200OK)]
    public async Task<IActionResult> DeleteAsync(Guid tenantId, Guid userId)
    {
        try
        {
            _logger.LogInformation("OK");
            return Ok();
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Unhandled exception from TenantController");
            return Problem("Unable to Delete User");
        }
    }
}
