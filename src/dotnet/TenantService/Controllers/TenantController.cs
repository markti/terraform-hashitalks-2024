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

    [HttpGet(Name = "GetTenant")]
    [Consumes(MediaTypeNames.Application.Json)]
    [ProducesResponseType(StatusCodes.Status200OK, Type = typeof(TenantProfile))]
    public async Task<IActionResult> GetAsync(Guid id)
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

    [HttpPatch(Name = "UpdateTenant")]
    [Consumes(MediaTypeNames.Application.Json)]
    [ProducesResponseType(StatusCodes.Status200OK, Type = typeof(TenantProfile))]
    public async Task<IActionResult> UpdateAsync(Guid id, string name)
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

    [HttpPatch(Name = "DeleteTenant")]
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
