namespace UserApi.Models
{
    public class UserProfile
    {
        public Guid Id { get; set; }
        public Guid TenantId { get; set; }
        public string UserName { get; set; }
        public string EmailAddress { get; set; }
    }
}