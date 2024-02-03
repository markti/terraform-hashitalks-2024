namespace TenantApi.Models
{
    public class OperationBreadcrumb
    {
        public string OperationStatus { get; set; }
        public string OperationName { get; set; }
        public string SessionId { get; set; }
        public string RequestId { get; set; }
        public InfrastructureMetadata Infrastructure { get; set; }
    }
}
