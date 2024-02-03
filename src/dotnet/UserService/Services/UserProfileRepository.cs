using Microsoft.Azure.Cosmos;
using UserApi.Models;

namespace UserApi.Services
{
    public class UserProfileRepository : IUserProfileRepository
    {
        private readonly CosmosClient _cosmosClient;

        public UserProfileRepository(CosmosClient cosmosClient)
        {
            _cosmosClient = cosmosClient;
        }

        public Task CreateAsync(UserProfile userProfile)
        {
            throw new NotImplementedException();
        }

        public Task DeleteAsync(Guid tenantId, Guid userId)
        {
            throw new NotImplementedException();
        }

        public Task UpdateAsync(UserProfile userProfile)
        {
            throw new NotImplementedException();
        }
    }
}