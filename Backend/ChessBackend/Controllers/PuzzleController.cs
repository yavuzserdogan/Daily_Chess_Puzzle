using ChessBackApi.Model;
using Microsoft.AspNetCore.Mvc;
using Newtonsoft.Json;


[ApiController]
[Route("api/[controller]")]
public class PuzzleController : ControllerBase
{
    private readonly HttpClient _httpClient;

    public PuzzleController(HttpClient httpClient)
    {
        _httpClient = httpClient;
    }

    [HttpGet("puzzle")]
    public async Task<IActionResult> GetPuzzle()
    {
        try
        {
            var response = await _httpClient.GetStringAsync("https://api.chess.com/pub/puzzle");
            var puzzle = JsonConvert.DeserializeObject<Puzzle>(response);

            if (puzzle == null)
            {
                return NotFound("Puzzle not found");
            }

            return Ok(puzzle);
        }
        catch (Exception ex)
        {
            return StatusCode(500, $"Internal server error: {ex.Message}");
        }
    }
}
