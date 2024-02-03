using TenantApi.Models;

namespace TenantApi.Services
{
    public interface ITenantRepository
    {
        Task CreateAsync(Guid id, string name);
        Task DeleteAsync(Guid id);
        Task ChangeNameAsync(Guid id, string name);
    }
}