namespace UserApi.Models
{
    public class InfrastructureMetadata
    {
        public string? Namespace { get; set; }
        public string? PodName { get; set; }
        public string? PodIP { get; set; }
        public string? ServiceAccount { get; set; }
        public string? NodeName { get; set; }
        public string? NodeIP { get; set; }
        public Dictionary<string, string> InputHeaders { get; set; }
    }
}
