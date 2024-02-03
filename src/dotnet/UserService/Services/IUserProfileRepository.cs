using UserApi.Models;

namespace UserApi.Services
{
    public interface IUserProfileRepository
    {
        Task CreateAsync(UserProfile userProfile);
        Task UpdateAsync(UserProfile userProfile);
        Task DeleteAsync(Guid tenantId, Guid userId);
    }
}