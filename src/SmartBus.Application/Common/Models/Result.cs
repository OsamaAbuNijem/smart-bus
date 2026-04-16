namespace SmartBus.Application.Common.Models;

public class Result<T>
{
    public bool IsSuccess { get; init; }
    public T? Data { get; init; }
    public string? Error { get; init; }
    public IEnumerable<string> Errors { get; init; } = Enumerable.Empty<string>();

    public static Result<T> Success(T data) => new() { IsSuccess = true, Data = data };
    public static Result<T> Failure(string error) => new() { IsSuccess = false, Error = error };
    public static Result<T> Failure(IEnumerable<string> errors) => new() { IsSuccess = false, Errors = errors };
}

public class Result
{
    public bool IsSuccess { get; init; }
    public string? Error { get; init; }
    public IEnumerable<string> Errors { get; init; } = Enumerable.Empty<string>();

    public static Result Success() => new() { IsSuccess = true };
    public static Result Failure(string error) => new() { IsSuccess = false, Error = error };
    public static Result Failure(IEnumerable<string> errors) => new() { IsSuccess = false, Errors = errors };
}
