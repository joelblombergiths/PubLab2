using Microsoft.Azure.Cosmos;
using ToDoApi.Models;

WebApplicationBuilder builder = WebApplication.CreateBuilder(args);
ConfigurationManager config = builder.Configuration;

builder.Services.AddEndpointsApiExplorer(); // Required for Swagger in Minimal API
builder.Services.AddSwaggerGen(c =>
{
    c.SwaggerDoc("v1", new() { Title = "ToDo API", Version = "v1" });
});

builder.Services.AddSingleton(_ => new CosmosClient(config.GetConnectionString("CosmosDB")).GetContainer(config["cosmosDatabaseId"], config["cosmosContainerId"]));

builder.Services.AddCors(opt => {
    opt.AddPolicy("cors", cfg => {
        cfg.AllowAnyOrigin()
        .AllowAnyHeader()
        .AllowAnyMethod();    
    });
});

WebApplication app = builder.Build();

app.UseSwagger();
app.UseSwaggerUI();

app.UseHttpsRedirection();

app.UseCors("cors");

//Redirect to swagger page
app.MapGet("/", () => Results.Redirect("/swagger"));

//endpoint for getting all todo items from cosmosDB
app.MapGet("/todo", async (Container container) =>
{
    FeedIterator<ToDoItem>? query = container.GetItemQueryIterator<ToDoItem>(new QueryDefinition("SELECT * FROM c"));
    List<ToDoItem> results = new();
    while (query.HasMoreResults)
    {
        FeedResponse<ToDoItem>? response = await query.ReadNextAsync();
        results.AddRange(response.ToList());
    }
    return Results.Ok(results);
});

//endpoint for getting a single todo item from cosmosDB
app.MapGet("/todo/{id}", async (Container container, string id) =>
{
    ItemResponse<ToDoItem> res = await container.ReadItemAsync<ToDoItem>(
        id: id,
        partitionKey: PartitionKey.None
    );
    return Results.Ok(res.Resource);    
});

//endpoint for creating a todo item in cosmosDB
app.MapPost("/todo", async (Container container, ToDoItem todo) =>
{
    await container.CreateItemAsync(todo);
    return Results.Ok();
});

//endpoint for updating a todo item in cosmosDB
app.MapPut("/todo/{id}", async (Container container, string id, ToDoItem todo) =>
{
    await container.UpsertItemAsync(todo);
    return Results.Ok();
});

//endpoint for deleting a todo item in cosmosDB
app.MapDelete("/todo/{id}", async (Container container, string id) =>
{
    await container.DeleteItemAsync<ToDoItem>(id, new(id));
    return Results.Ok();
});

app.Run();
