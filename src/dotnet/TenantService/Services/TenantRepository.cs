using Microsoft.Azure.Cosmos;
using TenantApi.Models;

namespace TenantApi.Services
{
    public class TenantRepository : ITenantRepository
    {

        public TenantRepository()
        {
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