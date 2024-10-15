namespace ChessBackApi.Model
{
    public class Puzzle
    {
        public string Title { get; set; }
        public string Url { get; set; }
        public long PublishTime { get; set; }
        public string Fen { get; set; }
        public string Pgn { get; set; }
        public string Image { get; set; }
    }
}
