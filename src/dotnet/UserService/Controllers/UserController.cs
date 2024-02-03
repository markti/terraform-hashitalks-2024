using Microsoft.AspNetCore.Mvc;
using System.Net.Mime;
using UserApi.Models;

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

    [HttpPost(Name = "CreateUser")]
    [Consumes(MediaTypeNames.Application.Json)]
    [ProducesResponseType(StatusCodes.Status200OK)]
    public async Task<IActionResult> CreateAsync(UserProfile userProfile)
    {
        try
        {
            _logger.LogInformation("OK");
            return Ok();
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Unhandled exception from UserController");
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
            _logger.LogError(ex, "Unhandled exception from UserController");
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
            _logger.LogError(ex, "Unhandled exception from UserController");
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
            _logger.LogError(ex, "Unhandled exception from UserController");
            return Problem("Unable to Delete User");
        }
    }
}
