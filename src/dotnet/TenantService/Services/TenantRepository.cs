using Microsoft.Azure.Cosmos;
using TenantApi.Models;

namespace TenantApi.Services
{
    public class TenantRepository : ITenantRepository
    {
        private readonly CosmosClient _cosmosClient;

        public TenantRepository(CosmosClient cosmosClient)
        {
            _cosmosClient = cosmosClient;
        }

        public Task CreateAsync(Guid id, string name)
        {
            throw new NotImplementedException();
        }

        public Task DeleteAsync(Guid id)
        {
            throw new NotImplementedException();
        }

        public Task ChangeNameAsync(Guid id, string name)
        {
            throw new NotImplementedException();
        }
    }
}