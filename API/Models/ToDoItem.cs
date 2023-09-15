namespace ToDoApi.Models;
internal class ToDoItem
{
    public string id { get; set; } = string.Empty;
    public string Title { get; set; } = string.Empty;
    public bool Completed { get; set; }
}