using HealthCheck;

// load .env values
DotNetEnv.Env.Load();

var builder = WebApplication.CreateBuilder(args);

// enable developers to override settings with user secrets
builder.Configuration.AddUserSecrets<Program>(optional: true);

builder.Logging.AddConsole();

var logger = builder.Services.BuildServiceProvider().GetRequiredService<ILogger<Startup>>();

// Apps migrating to 6.0 don't need to use the new minimal hosting model
// https://learn.microsoft.com/aspnet/core/migration/50-to-60?view=aspnetcore-6.0&tabs=visual-studio#apps-migrating-to-60-dont-need-to-use-the-new-minimal-hosting-model
var startup = new Startup(builder.Configuration, logger);

startup.ConfigureServices(builder.Services);

var app = builder.Build();

startup.Configure(app, app.Environment);

app.Run();