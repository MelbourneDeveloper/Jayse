#pragma warning disable IDE0057 


using System.Diagnostics;
using Newtonsoft.Json.Linq;

namespace Jayse
{
    public class JsonToken
    {
        public JsonToken(JsonTokenType type, string? value)
        {
            Type = type;
            Value = value;
        }

        public JsonTokenType Type { get; }
        public string? Value { get; }
    }





    public enum JsonTokenType
    {
        EndOfInput,
        LeftBrace,
        RightBrace,
        LeftBracket,
        RightBracket,
        Colon,
        Comma,
        StringValue,
        Number,
        True,
        False,
        Null,
    }

    public class JsonTokenizer
    {
        private readonly string input;
        private int position;

        public JsonTokenizer(string input)
        {
            this.input = input;
            position = 0;
        }

        public JsonToken? Current { get; private set; }

        public void MoveNext()
        {
            SkipWhitespace();
            if (position >= input.Length)
            {
                Current = new JsonToken(JsonTokenType.EndOfInput, null);
            }
            else if (input[position] == '"')
            {
                Current = ReadStringToken();
            }
            else if (input[position] == '[')
            {
                Current = new JsonToken(JsonTokenType.LeftBracket, null);
                position++;
            }
            else if (input[position] == ']')
            {
                Current = new JsonToken(JsonTokenType.RightBracket, null);
                position++;
            }
            else if (input[position] == '{')
            {
                Current = new JsonToken(JsonTokenType.LeftBrace, null);
                position++;
            }
            else if (input[position] == '}')
            {
                Current = new JsonToken(JsonTokenType.RightBrace, null);
                position++;
            }
            else if (input[position] == ':')
            {
                Current = new JsonToken(JsonTokenType.Colon, null);
                position++;
            }
            else if (input[position] == ',')
            {
                Current = new JsonToken(JsonTokenType.Comma, null);
                position++;
            }
            else if (input[position] == 't' && input.Substring(position, 4) == "true")
            {
                Current = new JsonToken(JsonTokenType.True, "true");
                position += 4;
            }
            else if (input[position] == 'f' && input.Substring(position, 5) == "false")
            {
                Current = new JsonToken(JsonTokenType.False, "false");
                position += 5;
            }
#pragma warning disable IDE0045 // Convert to conditional expression
            else if (input[position] == 'n' && input.Substring(position, 4) == "null")
            {
                Current = new JsonToken(JsonTokenType.Null, "null");
                position += 4;
            }
            else if (char.IsDigit(input[position]) || input[position] == '-')
            {
                Current = ReadNumberToken();
            }
            else
            {
                throw new JsonParserException("Unexpected character: " + input[position]);
            }
            Debug.Print($"Token: {Current.Type}, Value: {Current.Value}");
#pragma warning restore IDE0045 // Convert to conditional expression
        }

        private void SkipWhitespace()
        {
            while (position < input.Length && char.IsWhiteSpace(input[position]))
            {
                position++;
            }
        }

        private JsonToken ReadStringToken()
        {
            position++;
            var startIndex = position;
            while (position < input.Length && input[position] != '"')
            {
                position++;
            }
            if (position >= input.Length)
            {
                throw new JsonParserException("Unterminated string literal");
            }
            var value = input.Substring(startIndex, position - startIndex);
            position++;
            return new JsonToken(JsonTokenType.StringValue, value);
        }

        private JsonToken ReadNumberToken()
        {
            var startIndex = position;
            while (position < input.Length && (char.IsDigit(input[position]) || input[position] == '.' || input[position] == 'e' || input[position] == 'E' || input[position] == '+'))
            {
                position++;
            }
            var value = input.Substring(startIndex, position - startIndex);
#pragma warning disable IDE0046 // Convert to conditional expression
            if (!decimal.TryParse(value, out _))
            {
                throw new JsonParserException("Invalid number format: " + value);
            }
#pragma warning restore IDE0046 // Convert to conditional expression
            return new JsonToken(JsonTokenType.Number, value);
        }
    }
}