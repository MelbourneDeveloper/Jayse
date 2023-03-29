using System.Collections.Generic;
using System.Collections.Immutable;

#pragma warning disable IDE0058 // Expression value is never used
#pragma warning disable IDE0010 // Add missing cases
#pragma warning disable IDE0066 // Convert switch statement to expression

namespace Jayse
{
    public class JsonParser
    {
        private readonly JsonTokenizer tokenizer;

        public JsonParser(string input)
        {
            tokenizer = new JsonTokenizer(input);
            tokenizer.MoveNext();
        }

        public JsonValue Parse()
        {
            var token = tokenizer.Current;
            if (token == null)
            {
                throw new JsonParserException("Unexpected end of input");
            }

            switch (token.Type)
            {
                case JsonTokenType.LeftBrace:
                    return ParseObject();
                case JsonTokenType.LeftBracket:
                    return ParseArray();
                case JsonTokenType.StringValue:
                    return ParseString();
                case JsonTokenType.Number:
                    return ParseNumber();
                case JsonTokenType.True:
                    return ParseTrue();
                case JsonTokenType.False:
                    return ParseFalse();
                case JsonTokenType.Null:
                    return ParseNull();
                default:
                    throw new JsonParserException("Unexpected token: " + token.Type);
            }
        }

        private JsonValue ParseObject()
        {
            var properties = new Dictionary<string, JsonValue>();
            Expect(JsonTokenType.LeftBrace);
            tokenizer.MoveNext();
            while (tokenizer.Current?.Type != JsonTokenType.RightBrace)
            {
                var key = ParseString().StringValue;
                Expect(JsonTokenType.Colon);
                tokenizer.MoveNext();
                var value = Parse();
                properties.Add(key, value);
                if (tokenizer.Current?.Type == JsonTokenType.Comma)
                {
                    tokenizer.MoveNext();
                }
            }
            Expect(JsonTokenType.RightBrace);
            tokenizer.MoveNext();
            return new JsonValue(new OrderedImmutableDictionary<string, JsonValue>(properties));
        }

        private JsonValue ParseArray()
        {
            var elements = new List<JsonValue>();
            Expect(JsonTokenType.LeftBracket);
            tokenizer.MoveNext();
            while (tokenizer.Current?.Type != JsonTokenType.RightBracket)
            {
                var value = Parse();
                elements.Add(value);
                if (tokenizer.Current?.Type == JsonTokenType.Comma)
                {
                    tokenizer.MoveNext();
                }
            }
            Expect(JsonTokenType.RightBracket);
            tokenizer.MoveNext();
            return new JsonValue(elements.ToImmutableList());
        }

        private JsonValue ParseString()
        {
            var token = Expect(JsonTokenType.StringValue);
            tokenizer.MoveNext();
            return token.Value != null ? new JsonValue(token.Value) : new JsonValue(string.Empty);
        }

        private JsonValue ParseNumber()
        {
            var token = Expect(JsonTokenType.Number);
            tokenizer.MoveNext();
#pragma warning disable IDE0046 // Convert to conditional expression
            if (decimal.TryParse(token.Value, out var value))
            {
                return new JsonValue(value);
            }
            else
            {
                throw new JsonParserException("Invalid number format: " + token.Value);
            }
#pragma warning restore IDE0046 // Convert to conditional expression
        }

        private JsonValue ParseTrue()
        {
            Expect(JsonTokenType.True);
            tokenizer.MoveNext();
            return new JsonValue(true);
        }

        private JsonValue ParseFalse()
        {
            Expect(JsonTokenType.False);
            tokenizer.MoveNext();
            return new JsonValue(false);
        }

        private JsonValue ParseNull()
        {
            Expect(JsonTokenType.Null);
            tokenizer.MoveNext();
            return new JsonValue();
        }

        private JsonToken Expect(JsonTokenType expectedType)
        {
            var token = tokenizer.Current;
#pragma warning disable IDE0046 // Convert to conditional expression
            if (token?.Type != expectedType)
            {
                throw new JsonParserException($"Expected {expectedType} but got {token?.Type}");
            }
#pragma warning restore IDE0046 // Convert to conditional expression
            return token;
        }
    }
}
